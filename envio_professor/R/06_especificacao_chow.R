# =============================================================================
# Etapa 6: especificação, estabilidade estrutural e previsão do modelo principal
# Trabalho de Econometria I (UFPR).
#
# Modelo principal: MQO empilhado (Modelo 2).
#
# Conteúdo:
#   - gráfico das variáveis no tempo (escolha do corte do teste de Chow, orientação do professor);
#   - RESET de Ramsey (Gujarati, cap. 13) e LM para tendência linear do ano;
#   - teste de Chow com o corte indicado pelo gráfico (2017) e com o corte anterior (2016), para comparação;
#   - robustez da X4: Gini com 87 divisões e Gini só com as divisões com vínculo;
#   - projeção para 2021 com a Selic observada e ±1 p.p. (previsão matricial), com a correção
#     do viés da retransformação exp(ln) pelo fator exp(s²/2) [presunção da modelagem].
#
# Lê:    ./dados_processados/dados_painel_rmc.rds; ./dados_brutos/rais.rds (checagem do Gini)
# Grava: ./resultados_econometricos/especificacao_reset.csv, especificacao_lm_tendencia.csv,
#        chow_quebra_periodo.csv, medida_gini_checagem.csv, robustez_x4_definicao_gini.csv, robustez_porte_e_negativos.csv, reespecificacao_forma_funcional.csv,
#        projecao_selic_m2.csv, efeito_selic_m2.csv
#        ./figuras_graficos/diag6_variaveis_no_tempo.png
# =============================================================================

if (!dir.exists("R") || !dir.exists("dados_processados")) {
  stop("O diretório de trabalho atual (", getwd(), ") não é a raiz do projeto.", call. = FALSE)
}
biblioteca_usuario <- Sys.getenv("R_LIBS_USER")
if (!nzchar(biblioteca_usuario)) {
  base_usuario <- if (nzchar(Sys.getenv("LOCALAPPDATA"))) {
    file.path(Sys.getenv("LOCALAPPDATA"), "R", "win-library")
  } else {
    file.path(Sys.getenv("HOME"), "R", "library")
  }
  biblioteca_usuario <- file.path(base_usuario,
    paste(R.version$major, strsplit(R.version$minor, ".", fixed = TRUE)[[1]][1], sep = "."))
}
if (dir.exists(biblioteca_usuario)) .libPaths(c(biblioteca_usuario, .libPaths()))

PACOTES <- c("dplyr", "tidyr", "readr", "tibble", "purrr", "ggplot2", "lmtest", "sandwich")
ausentes <- PACOTES[!vapply(PACOTES, requireNamespace, logical(1), quietly = TRUE)]
if (length(ausentes) > 0) stop("Pacotes ausentes: ", paste(ausentes, collapse = ", "), call. = FALSE)
invisible(lapply(PACOTES, function(p) suppressPackageStartupMessages(library(p, character.only = TRUE))))

DIR_PROCESSADOS <- "./dados_processados"
DIR_BRUTOS      <- "./dados_brutos"
DIR_RESULTADOS  <- "./resultados_econometricos"
DIR_FIGURAS     <- "./figuras_graficos"
ARQ_PAINEL      <- file.path(DIR_PROCESSADOS, "dados_painel_rmc.rds")
ANO_CORTE       <- 2017L   # corte indicado pelo gráfico (diag6); o corte de 2016 é mostrado para comparação
ALFA            <- 0.05

FORMULA <- ln_salario_real ~ prop_superior + dom_industrial + gini_setorial + selic_real + dist_curitiba_km
painel <- readRDS(ARQ_PAINEL) |> dplyr::arrange(id_municipio, ano)
modelo2 <- stats::lm(FORMULA, data = painel)

# -----------------------------------------------------------------------------
# 1. Gráfico das variáveis no tempo (médias dos 29 municípios)
# -----------------------------------------------------------------------------
serie <- painel |>
  dplyr::group_by(ano) |>
  dplyr::summarise(
    `ln salário real (média)` = mean(ln_salario_real),
    `X2 escolaridade (%)` = mean(prop_superior),
    `X3 industrialização (%)` = mean(dom_industrial),
    `X4 Gini setorial` = mean(gini_setorial),
    `X5 Selic real (% a.a.)` = mean(selic_real),
    .groups = "drop"
  )
longo <- tidyr::pivot_longer(serie, -ano, names_to = "variavel", values_to = "valor")
g_tempo <- ggplot2::ggplot(longo, ggplot2::aes(ano, valor)) +
  ggplot2::geom_line(colour = "#5F7F62", linewidth = 0.8) +
  ggplot2::geom_point(colour = "#5F7F62", size = 1.8) +
  ggplot2::geom_vline(xintercept = ANO_CORTE + 0.5, linetype = "dashed", colour = "grey40") +
  ggplot2::facet_wrap(~variavel, scales = "free_y", ncol = 2) +
  ggplot2::labs(title = "Variáveis do modelo ao longo do tempo (média dos 29 municípios)",
                subtitle = paste0("Linha tracejada: corte do teste de Chow (", ANO_CORTE, ")"),
                x = "Ano", y = NULL) +
  ggplot2::theme_bw(base_size = 10)
ggplot2::ggsave(file.path(DIR_FIGURAS, "diag6_variaveis_no_tempo.png"), g_tempo,
                width = 8, height = 7, dpi = 200, bg = "white")

# -----------------------------------------------------------------------------
# 2. RESET de Ramsey (forma funcional) e LM para tendência linear do ano
# -----------------------------------------------------------------------------
reset <- lmtest::resettest(modelo2, power = 2:3, type = "fitted")
tabela_reset <- tibble::tibble(
  modelo = "Modelo 2 (principal)", teste = "RESET de Ramsey (potências 2 e 3 dos ajustados)",
  hipotese_nula = "H0: forma funcional correta (coeficientes de y^2 e y^3 iguais a zero)",
  hipotese_alternativa = "Ha: forma funcional incorreta (algum coeficiente diferente de zero)",
  estatistica_f = unname(reset$statistic), gl = paste(unname(reset$parameter), collapse = "; "),
  p_valor = reset$p.value, decisao_5pct = ifelse(reset$p.value < ALFA, "rejeita H0", "não rejeita H0")
)
readr::write_csv(tabela_reset, file.path(DIR_RESULTADOS, "especificacao_reset.csv"))

aux <- stats::lm(stats::residuals(modelo2) ~ prop_superior + dom_industrial + gini_setorial +
                   selic_real + dist_curitiba_km + ano, data = painel)
lm_stat <- nrow(painel) * summary(aux)$r.squared
p_lm <- stats::pchisq(lm_stat, df = 1, lower.tail = FALSE)
tabela_lm <- tibble::tibble(
  modelo = "Modelo 2 (principal)", teste = "LM para acréscimo de tendência linear (ano)",
  hipotese_nula = "H0: coeficiente de ano = 0 (LM = n R^2 ~ qui-quadrado com 1 gl)",
  hipotese_alternativa = "Ha: coeficiente de ano diferente de zero (tendência omitida)",
  estatistica = lm_stat, gl = 1L, p_valor = p_lm,
  decisao_5pct = ifelse(p_lm < ALFA, "rejeita H0", "não rejeita H0")
)
readr::write_csv(tabela_lm, file.path(DIR_RESULTADOS, "especificacao_lm_tendencia.csv"))

# -----------------------------------------------------------------------------
# 3. Teste de Chow: F = [(SQR_R - (SQR1 + SQR2)) / k] / [(SQR1 + SQR2) / (n1 + n2 - 2k)]
# -----------------------------------------------------------------------------
chow_corte <- function(corte) {
  parte1 <- painel[painel$ano <= corte, ]
  parte2 <- painel[painel$ano > corte, ]
  m1 <- stats::lm(FORMULA, data = parte1)
  m2 <- stats::lm(FORMULA, data = parte2)
  sqr_r <- sum(stats::residuals(modelo2)^2)
  sqr_sr <- sum(stats::residuals(m1)^2) + sum(stats::residuals(m2)^2)
  k <- length(stats::coef(modelo2))
  n1 <- nrow(parte1); n2 <- nrow(parte2)
  indicado <- corte == ANO_CORTE   # calculado antes do tibble, para não ser ofuscado pela coluna 'corte'
  f <- ((sqr_r - sqr_sr) / k) / (sqr_sr / (n1 + n2 - 2 * k))
  gl_1 <- k; gl_2 <- n1 + n2 - 2 * k
  p <- stats::pf(f, gl_1, gl_2, lower.tail = FALSE)
  tibble::tibble(
    modelo = "Modelo 2 (principal)",
    corte = paste0(min(painel$ano), "-", corte, " x ", corte + 1, "-", max(painel$ano)),
    teste = if (indicado) "Chow, corte indicado pelo gráfico" else "Chow, corte anterior (comparação)",
    hipotese_nula = "H0: beta(primeiro período) = beta(segundo período) (sem quebra estrutural)",
    hipotese_alternativa = "Ha: ao menos um coeficiente diferente entre os dois períodos (quebra estrutural)",
    n1 = n1, n2 = n2, k = k, estatistica_f = f, gl = paste(gl_1, gl_2, sep = "; "),
    p_valor = p, decisao_5pct = ifelse(p < ALFA, "rejeita H0", "não rejeita H0")
  )
}
tabela_chow <- dplyr::bind_rows(chow_corte(ANO_CORTE), chow_corte(ANO_CORTE - 1L))
readr::write_csv(tabela_chow, file.path(DIR_RESULTADOS, "chow_quebra_periodo.csv"))

# -----------------------------------------------------------------------------
# 4. Checagem da X4 e robustez: Gini com 87 divisões e Gini só com as divisões com vínculo
# -----------------------------------------------------------------------------
arq_rais <- file.path(DIR_BRUTOS, "rais.rds")
if (!file.exists(arq_rais)) stop("RAIS ausente em ", arq_rais, ". Rode a Etapa 1.", call. = FALSE)
cnae <- as.data.frame(readRDS(arq_rais)$cnae_divisao)
cnae <- cnae[cnae$divisao_cnae != "ignorada", ]
ativas <- stats::aggregate(divisao_cnae ~ id_municipio + ano, data = cnae, FUN = length)
names(ativas)[3] <- "divisoes_ativas"
junto <- merge(painel[, c("id_municipio", "ano", "gini_setorial")], ativas, by = c("id_municipio", "ano"))
checagem <- tibble::tibble(
  indicador = c("correlação entre X4 (Gini) e divisões com emprego",
                "divisões com emprego: mínimo", "divisões com emprego: máximo"),
  valor = c(round(stats::cor(junto$gini_setorial, junto$divisoes_ativas), 4),
            min(junto$divisoes_ativas), max(junto$divisoes_ativas))
)
readr::write_csv(checagem, file.path(DIR_RESULTADOS, "medida_gini_checagem.csv"))

gini_ativas <- sapply(split(cnae, paste(cnae$id_municipio, cnae$ano)), function(d) {
  x <- sort(d$vinculos_ativos / sum(d$vinculos_ativos)); n_div <- length(x)
  sum((2 / n_div) * seq_len(n_div) * x) - (n_div + 1) / n_div
})
painel$gini_ativas <- gini_ativas[paste(painel$id_municipio, painel$ano)]
robustez_x4 <- purrr::imap_dfr(c(gini_setorial = "87 divisões (zeros incluídos)",
                                 gini_ativas = "somente divisões com vínculo"), function(rot, v) {
  f <- stats::as.formula(paste("ln_salario_real ~ prop_superior + dom_industrial +", v,
                               "+ selic_real + dist_curitiba_km"))
  m <- stats::lm(f, data = painel)
  ct <- lmtest::coeftest(m, vcov. = sandwich::vcovHC(m, type = "HC1"))
  tibble::tibble(modelo = "Modelo 2 (principal)", definicao_x4 = rot, coef_x4 = ct[v, 1],
                 p_valor_x4 = ct[v, 4], r2_ajustado = summary(m)$adj.r.squared, aic = stats::AIC(m),
                 reset_p = lmtest::resettest(m, power = 2:3, type = "fitted")$p.value)
})
readr::write_csv(robustez_x4, file.path(DIR_RESULTADOS, "robustez_x4_definicao_gini.csv"))

# Robustez adicional: porte do município e observações com VAB da indústria negativo.
# O Gini setorial cai quando mais divisões têm vínculo e, por isso, acompanha o porte do
# município; a primeira especificação acrescenta o logaritmo dos vínculos ativos como controle.
# A segunda tira as duas observações de Araucária (2012 e 2013) com VAB da indústria negativo.
painel$ln_vinculos_ativos <- log(painel$vinculos_ativos)
formula_base <- ln_salario_real ~ prop_superior + dom_industrial + gini_setorial + selic_real + dist_curitiba_km
especificacoes <- list(
  "Modelo 2 mais ln dos vínculos ativos (porte)" =
    list(f = stats::update(formula_base, . ~ . + ln_vinculos_ativos), d = painel),
  "Modelo 2 sem as 2 observações com VAB da indústria negativo" =
    list(f = formula_base, d = painel[!as.logical(painel$x3_negativo), ])
)
cor_gini_porte <- stats::cor(painel$gini_setorial, painel$ln_vinculos_ativos)
robustez_adicional <- purrr::imap_dfr(especificacoes, function(e, rot) {
  m <- stats::lm(e$f, data = e$d)
  ct <- lmtest::coeftest(m, vcov. = sandwich::vcovHC(m, type = "HC1"))
  tibble::tibble(especificacao = rot, n = stats::nobs(m), termo = rownames(ct), coeficiente = ct[, 1],
                 erro_padrao_white = ct[, 2], p_valor = ct[, 4],
                 r2_ajustado = summary(m)$adj.r.squared, cor_gini_ln_vinculos = cor_gini_porte)
})
readr::write_csv(robustez_adicional, file.path(DIR_RESULTADOS, "robustez_porte_e_negativos.csv"))
message(sprintf("Correlação entre o Gini setorial e ln(vínculos ativos): %.3f.", cor_gini_porte))

# Forma funcional: o RESET rejeita a forma linear, e a aula de especificação e diagnóstico
# trata a forma funcional incorreta como erro de especificação. Cada reespecificação abaixo
# acrescenta termos ao modelo principal e repete os diagnósticos. Os quadrados usam X2 e X3
# centrados na média, para não criar colinearidade artificial entre o termo e o seu quadrado.
painel$x2_c <- painel$prop_superior - mean(painel$prop_superior)
painel$x3_c <- painel$dom_industrial - mean(painel$dom_industrial)
f_quad <- stats::update(formula_base, . ~ . + I(x2_c^2) + I(x3_c^2))
reespecificacoes <- list(
  "Modelo principal" = formula_base,
  "Mais quadrados de X2 e X3 (centrados na média)" = f_quad,
  "Mais ln dos vínculos ativos (porte)" = stats::update(formula_base, . ~ . + ln_vinculos_ativos),
  "Quadrados de X2 e X3 e porte" = stats::update(f_quad, . ~ . + ln_vinculos_ativos)
)
tabela_reespecificacao <- purrr::imap_dfr(reespecificacoes, function(f, rot) {
  m <- stats::lm(f, data = painel)
  ct <- lmtest::coeftest(m, vcov. = sandwich::vcovHC(m, type = "HC1"))
  rs <- lmtest::resettest(m, power = 2:3, type = "fitted")
  sw <- stats::shapiro.test(stats::residuals(m))
  tibble::tibble(
    especificacao = rot, n_parametros = length(stats::coef(m)), r2_ajustado = summary(m)$adj.r.squared,
    aic = stats::AIC(m), reset_f = unname(rs$statistic), reset_p = rs$p.value,
    shapiro_w = unname(sw$statistic), shapiro_p = sw$p.value, breusch_pagan_p = lmtest::bptest(m)$p.value,
    coef_gini = ct["gini_setorial", 1], p_gini = ct["gini_setorial", 4],
    coef_distancia = ct["dist_curitiba_km", 1], p_distancia = ct["dist_curitiba_km", 4]
  )
})
readr::write_csv(tabela_reespecificacao, file.path(DIR_RESULTADOS, "reespecificacao_forma_funcional.csv"))

# -----------------------------------------------------------------------------
# 5. Projeção de 2021 e efeito da Selic (Modelo 2)
# -----------------------------------------------------------------------------
# A projeção é previsão dentro da amostra para 2021, o último ano observado em todas as variáveis.
# Não há dados de 2022 em diante, por isso não se projeta 2026. Previsão: x0'b (previsão matricial).
# Intervalo da média: x0'(X'X)^-1 x0 σ²; intervalo individual: σ²(1 + x0'(X'X)^-1 x0).
# Viés da retransformação: E(y) = exp(x0'b + σ²/2) se os erros forem normais; por isso a
# previsão em reais é corrigida pelo fator exp(s²/2). Sem a correção,
# a previsão em reais é exp(x0'b), e subestima a média.
s2 <- sum(stats::residuals(modelo2)^2) / modelo2$df.residual
fator_viés <- exp(s2 / 2)
ano_ref <- max(painel$ano)
base_ref <- painel[painel$ano == ano_ref, ]
cenarios <- tibble::tibble(
  cenario = c("Selic de 2021", "Selic de 2021 + 1 p.p.", "Selic de 2021 - 1 p.p."),
  selic = unique(base_ref$selic_real)[1] + c(0, 1, -1)
)
# Intervalo da média com a matriz de White (HC1): x0' V x0, em vez de s^2 x0'(X'X)^-1 x0.
V_white <- sandwich::vcovHC(modelo2, type = "HC1")
t_previsao <- stats::qt(0.975, modelo2$df.residual)
projecao <- purrr::pmap_dfr(cenarios, function(cenario, selic) {
  nd <- base_ref
  nd$selic_real <- selic
  pr_m <- stats::predict(modelo2, newdata = nd, interval = "confidence", level = 0.95)
  pr_i <- stats::predict(modelo2, newdata = nd, interval = "prediction", level = 0.95)
  x0 <- stats::model.matrix(stats::delete.response(stats::terms(modelo2)), data = nd)
  ep_white <- sqrt(rowSums((x0 %*% V_white) * x0))
  tibble::tibble(
    cenario = cenario, selic = selic, id_municipio = nd$id_municipio, nome_municipio = nd$nome_municipio,
    ln_previsto = pr_m[, "fit"],
    salario_previsto_sem_correcao = exp(pr_m[, "fit"]),
    salario_previsto_corrigido = exp(pr_m[, "fit"]) * fator_viés,
    ic_media_inf_ln = pr_m[, "lwr"], ic_media_sup_ln = pr_m[, "upr"],
    ic_media_inf_ln_white = pr_m[, "fit"] - t_previsao * ep_white,
    ic_media_sup_ln_white = pr_m[, "fit"] + t_previsao * ep_white,
    ic_individual_inf_ln = pr_i[, "lwr"], ic_individual_sup_ln = pr_i[, "upr"]
  )
})
readr::write_csv(projecao, file.path(DIR_RESULTADOS, "projecao_selic_m2.csv"))

# Efeito da Selic: coeficiente com erro de White (HC1), gl = n - k; efeito percentual = exp(b) - 1.
ct_w <- lmtest::coeftest(modelo2, vcov. = sandwich::vcovHC(modelo2, type = "HC1"))
b_s <- ct_w["selic_real", 1]; ep_s <- ct_w["selic_real", 2]
gl_m2 <- modelo2$df.residual
t_crit <- stats::qt(0.975, gl_m2)
efeito <- tibble::tibble(
  termo = "selic_real", efeito_ln_por_pp = b_s,
  efeito_percentual_por_pp = 100 * (exp(b_s) - 1),
  ic95_inf_ln = b_s - t_crit * ep_s, ic95_sup_ln = b_s + t_crit * ep_s,
  gl = gl_m2, p_valor = ct_w["selic_real", 4],
  fator_correcao_vies = fator_viés, s2_residual = s2
)
readr::write_csv(efeito, file.path(DIR_RESULTADOS, "efeito_selic_m2.csv"))

message("Etapa 6 concluída: gráfico no tempo, RESET, LM, Chow (", ANO_CORTE, " e ", ANO_CORTE - 1L,
        "), robustez da X4, projeção de 2021 e efeito da Selic gravados.")
print(tabela_chow[, c("corte", "estatistica_f", "gl", "p_valor", "decisao_5pct")], row.names = FALSE)
