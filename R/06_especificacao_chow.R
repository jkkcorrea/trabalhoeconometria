# =============================================================================
# Etapa 6: especificação do modelo e estabilidade estrutural (métodos ensinados)
# Trabalho de Econometria I (UFPR).
#
#   - RESET de Ramsey (forma funcional), com potências 2 e 3 dos valores ajustados
#     (especificao_diagnostico, Gujarati cap. 13);
#   - teste LM para acréscimo de variável omitida: tendência linear do ano
#     (n * R2 da regressão auxiliar, qui-quadrado com 1 gl);
#   - teste de Chow (teste_Chow, Gujarati cap. 8): amostra dividida em
#     2012 a 2016 e 2017 a 2021 (145 observações em cada parte). A divisão
#     no meio do período é [presunção da modelagem].
#
# Lê:    ./dados_processados/dados_painel_rmc.rds
# Grava: ./resultados_econometricos/especificacao_reset.csv
#        ./resultados_econometricos/especificacao_lm_tendencia.csv
#        ./resultados_econometricos/chow_quebra_periodo.csv
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

PACOTES <- c("dplyr", "readr", "tibble", "lmtest", "ggplot2", "patchwork")
ausentes <- PACOTES[!vapply(PACOTES, requireNamespace, logical(1), quietly = TRUE)]
if (length(ausentes) > 0) stop("Pacotes ausentes: ", paste(ausentes, collapse = ", "), call. = FALSE)
invisible(lapply(PACOTES, function(p) suppressPackageStartupMessages(library(p, character.only = TRUE))))
patchwork_side <- function(a, b) patchwork::wrap_plots(a, b, ncol = 2)

DIR_PROCESSADOS <- "./dados_processados"
DIR_RESULTADOS  <- "./resultados_econometricos"
DIR_FIGURAS     <- "./figuras_graficos"
DIR_BRUTOS      <- "./dados_brutos"
ARQ_PAINEL      <- file.path(DIR_PROCESSADOS, "dados_painel_rmc.rds")
ANO_CORTE       <- 2016L   # última observação da primeira parte [presunção da modelagem]

painel <- readRDS(ARQ_PAINEL)
FORMULA <- ln_salario_real ~ prop_superior + dom_industrial + gini_setorial + selic_real + dist_curitiba_km
modelo2 <- stats::lm(FORMULA, data = painel)

# RESET: potências 2 e 3 dos valores ajustados (type = "fitted").
reset <- lmtest::resettest(modelo2, power = 2:3, type = "fitted")
tabela_reset <- tibble::tibble(
  modelo = "Modelo 2", teste = "RESET de Ramsey (potências 2 e 3 dos ajustados)",
  hipotese_nula = "H0: forma funcional correta (coeficientes de y^2 e y^3 na regressão auxiliar iguais a zero)",
  hipotese_alternativa = "Ha: forma funcional incorreta (ao menos um dos coeficientes de y^2 e y^3 diferente de zero)",
  estatistica_f = unname(reset$statistic),
  gl = paste(unname(reset$parameter), collapse = "; "), p_valor = reset$p.value,
  decisao_5pct = ifelse(reset$p.value < 0.05, "rejeita H0", "não rejeita H0")
)
# Modelo 4 (dummies de município): RESET e teste F de acréscimo das dummies sobre o Modelo 2.
modelo4 <- stats::lm(ln_salario_real ~ prop_superior + dom_industrial + gini_setorial + selic_real +
                       factor(id_municipio), data = painel)
reset4 <- lmtest::resettest(modelo4, power = 2:3, type = "fitted")
tabela_reset <- dplyr::bind_rows(tabela_reset, tibble::tibble(
  modelo = "Modelo 4", teste = "RESET de Ramsey (potências 2 e 3 dos ajustados)",
  hipotese_nula = "H0: forma funcional correta (coeficientes de y^2 e y^3 na regressão auxiliar iguais a zero)",
  hipotese_alternativa = "Ha: forma funcional incorreta (ao menos um dos coeficientes de y^2 e y^3 diferente de zero)",
  estatistica_f = unname(reset4$statistic),
  gl = paste(unname(reset4$parameter), collapse = "; "), p_valor = reset4$p.value,
  decisao_5pct = ifelse(reset4$p.value < 0.05, "rejeita H0", "não rejeita H0")
))
readr::write_csv(tabela_reset, file.path(DIR_RESULTADOS, "especificacao_reset.csv"))

# Teste F de acréscimo (ensinado): modelo sem dummies contra o Modelo 4, com as 28 dummies de município.
# Os dois modelos são aninhados (mesmas variáveis X2 a X5; X6 fica fora porque é constante no município).
modelo4_restrito <- stats::lm(ln_salario_real ~ prop_superior + dom_industrial + gini_setorial + selic_real,
                              data = painel)
acrescimo <- stats::anova(modelo4_restrito, modelo4)
tabela_acrescimo <- tibble::tibble(
  teste = "F de acréscimo das dummies de município (X2 a X5, sem e com as dummies)",
  hipotese_nula = "H0: beta(dummies de município) = 0 conjuntamente (modelo restrito, sem dummies)",
  hipotese_alternativa = "Ha: ao menos uma dummy de município diferente de zero (modelo irrestrito, com dummies)",
  gl_numerador = acrescimo$Df[2], gl_denominador = acrescimo$Res.Df[2],
  estatistica_f = acrescimo$F[2], p_valor = acrescimo$`Pr(>F)`[2],
  decisao_5pct = ifelse(acrescimo$`Pr(>F)`[2] < 0.05, "rejeita H0", "não rejeita H0")
)
readr::write_csv(tabela_acrescimo, file.path(DIR_RESULTADOS, "especificacao_acrescimo_municipios.csv"))

# LM para acréscimo de tendência linear do ano: n * R2 da regressão dos resíduos.
aux <- stats::lm(stats::residuals(modelo2) ~ prop_superior + dom_industrial + gini_setorial +
                   selic_real + dist_curitiba_km + ano, data = painel)
lm_stat <- nrow(painel) * summary(aux)$r.squared
tabela_lm <- tibble::tibble(
  modelo = "Modelo 2", teste = "LM para acréscimo de tendência linear (ano)",
  hipotese_nula = "H0: coeficiente de ano = 0 (sem tendência linear omitida); LM = n R^2 ~ qui-quadrado com 1 gl",
  hipotese_alternativa = "Ha: coeficiente de ano diferente de zero (tendência linear omitida)",
  estatistica = lm_stat, gl = 1L,
  p_valor = stats::pchisq(lm_stat, df = 1, lower.tail = FALSE),
  decisao_5pct = ifelse(stats::pchisq(lm_stat, df = 1, lower.tail = FALSE) < 0.05, "rejeita H0", "não rejeita H0")
)
readr::write_csv(tabela_lm, file.path(DIR_RESULTADOS, "especificacao_lm_tendencia.csv"))

# Chow: F = [(SQR_R - (SQR1 + SQR2)) / k] / [(SQR1 + SQR2) / (n1 + n2 - 2k)].
parte1 <- painel[painel$ano <= ANO_CORTE, ]
parte2 <- painel[painel$ano > ANO_CORTE, ]
m1 <- stats::lm(FORMULA, data = parte1)
m2 <- stats::lm(FORMULA, data = parte2)
sqr_r  <- sum(stats::residuals(modelo2)^2)
sqr_sr <- sum(stats::residuals(m1)^2) + sum(stats::residuals(m2)^2)
k <- length(stats::coef(modelo2))
n1 <- nrow(parte1); n2 <- nrow(parte2)
f_chow <- ((sqr_r - sqr_sr) / k) / (sqr_sr / (n1 + n2 - 2 * k))
gl_1 <- k; gl_2 <- n1 + n2 - 2 * k
tabela_chow <- tibble::tibble(
  modelo = "Modelo 2", teste = paste0("Chow: quebra estrutural entre 2012-", ANO_CORTE, " e ", ANO_CORTE + 1, "-2021"),
  hipotese_nula = "H0: beta(2012-2016) = beta(2017-2021) (sem quebra estrutural)",
  hipotese_alternativa = "Ha: ao menos um coeficiente diferente entre os dois períodos (quebra estrutural)",
  n1 = n1, n2 = n2, k = k,
  estatistica_f = f_chow, gl = paste(gl_1, gl_2, sep = "; "),
  p_valor = stats::pf(f_chow, gl_1, gl_2, lower.tail = FALSE),
  decisao_5pct = ifelse(stats::pf(f_chow, gl_1, gl_2, lower.tail = FALSE) < 0.05, "rejeita H0", "não rejeita H0")
)
readr::write_csv(tabela_chow, file.path(DIR_RESULTADOS, "chow_quebra_periodo.csv"))

# Inferência para variáveis que variam pouco: a Selic tem 10 valores distintos (um por ano) e a
# distância tem 29 (um por município). Com 290 observações, o t do modelo trata essas linhas como
# independentes e tende a superestimar a precisão. A checagem usa regressões simples sobre médias
# por ano (n = 10) e por município (n = 29), método ensinado; o gl é n - 2.
media_ano <- stats::aggregate(cbind(ln_salario_real, selic_real) ~ ano, data = painel, FUN = mean)
ajuste_ano <- stats::lm(ln_salario_real ~ selic_real, data = media_ano)
media_mun <- stats::aggregate(cbind(ln_salario_real, dist_curitiba_km) ~ id_municipio, data = painel, FUN = mean)
ajuste_mun <- stats::lm(ln_salario_real ~ dist_curitiba_km, data = media_mun)
linha <- function(ajuste, termo, rotulo, base, n_obs) {
  co <- summary(ajuste)$coefficients[termo, ]
  tibble::tibble(variavel = rotulo, base = base, n = n_obs, gl = ajuste$df.residual,
                 estimativa = unname(co[1]), erro_padrao = unname(co[2]), estatistica_t = unname(co[3]),
                 p_valor = unname(co[4]),
                 decisao_5pct = ifelse(unname(co[4]) < 0.05, "rejeita H0", "não rejeita H0"))
}
inferencia <- dplyr::bind_rows(
  linha(ajuste_ano, "selic_real", "X5 Selic real", "médias anuais (n = 10)", nrow(media_ano)),
  linha(ajuste_mun, "dist_curitiba_km", "X6 distância a Curitiba", "médias por município (n = 29)", nrow(media_mun))
)
readr::write_csv(inferencia, file.path(DIR_RESULTADOS, "inferencia_agregada_x5_x6.csv"))
print(inferencia[, c("variavel", "base", "estimativa", "p_valor", "decisao_5pct")], row.names = FALSE)

grafico_ano <- ggplot2::ggplot(media_ano, ggplot2::aes(selic_real, ln_salario_real)) +
  ggplot2::geom_smooth(method = "lm", formula = y ~ x, se = TRUE, colour = "#8F6244", fill = "#D9C7B8") +
  ggplot2::geom_point(size = 2.5, colour = "#3C6A6D") +
  ggplot2::labs(title = "Selic real e ln do salário médio, médias anuais (n = 10)",
                subtitle = "A inclinação não é significativa com a base de dez anos: p = 0,19",
                x = "Selic real (% a.a.)", y = "ln do salário médio real (média dos municípios)") +
  ggplot2::theme_bw(base_size = 11)
grafico_mun <- ggplot2::ggplot(media_mun, ggplot2::aes(dist_curitiba_km, ln_salario_real)) +
  ggplot2::geom_smooth(method = "lm", formula = y ~ x, se = TRUE, colour = "#8F6244", fill = "#D9C7B8") +
  ggplot2::geom_point(size = 2.5, colour = "#3C6A6D") +
  ggplot2::labs(title = "Distância e ln do salário, médias por município (n = 29)",
                subtitle = "Inclinação negativa e significativa a 5% com 27 graus de liberdade",
                x = "Distância a Curitiba (km)", y = "ln do salário médio real (média 2012-2021)") +
  ggplot2::theme_bw(base_size = 11)
ggplot2::ggsave(file.path(DIR_FIGURAS, "diag4_agregados_selic_distancia.png"),
                patchwork_side(grafico_ano, grafico_mun), width = 11, height = 5, dpi = 200, bg = "white")

# Checagem da medida X4: o Gini de participação setorial acompanha o número de divisões com emprego.
arq_rais <- file.path(DIR_BRUTOS, "rais.rds")
if (file.exists(arq_rais)) {
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
  message("Checagem do Gini: correlação com divisões ativas = ", checagem$valor[1])
}

# Teste da Selic e da produção agrícola (fonte: PAM, IBGE/SIDRA, tabela 5457, variável 215).
# Compara o modelo com Selic, sem Selic e com a produção no lugar da Selic, nos dois desenhos:
# com dummies de município (Modelo 4) e sem elas, com X6 (Modelo 2). Métrica de desempenho: AIC,
# BIC e R2 ajustado; diagnósticos: RESET e Breusch-Pagan-Godfrey. O t usa erro de White (HC1).
especificacoes_comparacao <- list(
  "M4 com Selic" = ln_salario_real ~ prop_superior + dom_industrial + gini_setorial + selic_real + factor(id_municipio),
  "M4 sem Selic" = ln_salario_real ~ prop_superior + dom_industrial + gini_setorial + factor(id_municipio),
  "M4 sem Selic + ln produção agrícola" = ln_salario_real ~ prop_superior + dom_industrial + gini_setorial + ln_producao_agricola + factor(id_municipio),
  "M2 com Selic" = ln_salario_real ~ prop_superior + dom_industrial + gini_setorial + selic_real + dist_curitiba_km,
  "M2 sem Selic" = ln_salario_real ~ prop_superior + dom_industrial + gini_setorial + dist_curitiba_km,
  "M2 sem Selic + ln produção agrícola" = ln_salario_real ~ prop_superior + dom_industrial + gini_setorial + dist_curitiba_km + ln_producao_agricola
)
comparacao <- purrr::imap_dfr(especificacoes_comparacao, function(f, nome) {
  m <- stats::lm(f, data = painel)
  ct <- lmtest::coeftest(m, vcov. = sandwich::vcovHC(m, type = "HC1"))
  termo_x5 <- if ("selic_real" %in% rownames(ct)) "selic_real" else NA
  termo_pr <- if ("ln_producao_agricola" %in% rownames(ct)) "ln_producao_agricola" else NA
  tibble::tibble(
    especificacao = nome,
    parametros = length(stats::coef(m)),
    r2_ajustado = summary(m)$adj.r.squared,
    aic = stats::AIC(m),
    bic = stats::BIC(m),
    reset_p = lmtest::resettest(m, power = 2:3, type = "fitted")$p.value,
    bp_p = lmtest::bptest(m)$p.value,
    p_selic_white = if (is.na(termo_x5)) NA_real_ else ct[termo_x5, 4],
    coef_producao_white = if (is.na(termo_pr)) NA_real_ else ct[termo_pr, 1],
    p_producao_white = if (is.na(termo_pr)) NA_real_ else ct[termo_pr, 4]
  )
})
readr::write_csv(comparacao, file.path(DIR_RESULTADOS, "comparacao_selic_producao.csv"))
# F de retirar a Selic, nos dois desenhos (modelo sem Selic contra modelo com Selic).
f_selic <- tibble::tibble(
  desenho = c("M4 (dummies de município)", "M2 (com X6)"),
  estatistica_f = c(
    stats::anova(stats::lm(especificacoes_comparacao[[2]], data = painel),
                 stats::lm(especificacoes_comparacao[[1]], data = painel))$F[2],
    stats::anova(stats::lm(especificacoes_comparacao[[5]], data = painel),
                 stats::lm(especificacoes_comparacao[[4]], data = painel))$F[2]),
  p_valor = c(
    stats::anova(stats::lm(especificacoes_comparacao[[2]], data = painel),
                 stats::lm(especificacoes_comparacao[[1]], data = painel))$`Pr(>F)`[2],
    stats::anova(stats::lm(especificacoes_comparacao[[5]], data = painel),
                 stats::lm(especificacoes_comparacao[[4]], data = painel))$`Pr(>F)`[2])
)
readr::write_csv(f_selic, file.path(DIR_RESULTADOS, "comparacao_f_retirar_selic.csv"))
print(comparacao[, c("especificacao", "r2_ajustado", "aic", "reset_p", "p_selic_white", "p_producao_white")], row.names = FALSE)

# Projeção pela previsão matricial (Gujarati, cap. 7; notas de regressão múltipla, slides 82 a 93):
# x0 é o vetor de valores das explicativas (inclui 1 e as dummies de município); a previsão média tem
# variância sigma2 * x0' (X'X)^-1 x0 e a previsão individual tem sigma2 * (1 + x0' (X'X)^-1 x0).
# Cenários da Selic para 2021: valor observado e +/- 1 ponto percentual, com M4 (dummies de município).
m4 <- stats::lm(ln_salario_real ~ prop_superior + dom_industrial + gini_setorial + selic_real +
                  factor(id_municipio), data = painel)
Xm <- stats::model.matrix(m4)
XtXi <- solve(t(Xm) %*% Xm)
sigma2 <- sum(stats::residuals(m4)^2) / m4$df.residual
t_crit <- stats::qt(0.975, m4$df.residual)
selic_2021 <- painel$selic_real[painel$ano == max(painel$ano)][1]
cenarios <- tibble::tibble(cenario = c("Selic de 2021", "Selic de 2021 + 1 p.p.", "Selic de 2021 - 1 p.p."),
                           selic = c(selic_2021, selic_2021 + 1, selic_2021 - 1))
dados_2021 <- painel[painel$ano == max(painel$ano), ]
projecao <- purrr::map_dfr(seq_len(nrow(cenarios)), function(i) {
  purrr::map_dfr(seq_len(nrow(dados_2021)), function(j) {
    x0 <- Xm[painel$ano == max(painel$ano) & painel$id_municipio == dados_2021$id_municipio[j], , drop = FALSE][1, ]
    x0[["selic_real"]] <- cenarios$selic[i]
    yhat <- sum(x0 * stats::coef(m4))
    h <- as.numeric(t(x0) %*% XtXi %*% x0)
    ep_media <- sqrt(sigma2 * h)
    ep_ind <- sqrt(sigma2 * (1 + h))
    tibble::tibble(cenario = cenarios$cenario[i], selic = cenarios$selic[i],
                   id_municipio = dados_2021$id_municipio[j], nome_municipio = dados_2021$nome_municipio[j],
                   ln_previsto = yhat, salario_previsto_reais = exp(yhat),
                   ic_media_inf = yhat - t_crit * ep_media, ic_media_sup = yhat + t_crit * ep_media,
                   ic_individual_inf = yhat - t_crit * ep_ind, ic_individual_sup = yhat + t_crit * ep_ind)
  })
})
readr::write_csv(projecao, file.path(DIR_RESULTADOS, "projecao_selic_m4.csv"))

# Efeito da Selic: variação do ln do salário por 1 ponto percentual, com erro de White (HC1) e
# com a checagem agregada (regressão sobre médias anuais, n = 10, gl = 8).
ct_m4 <- lmtest::coeftest(m4, vcov. = sandwich::vcovHC(m4, type = "HC1"))
b_selic <- ct_m4["selic_real", 1]
ep_selic <- ct_m4["selic_real", 2]
efeito_selic <- tibble::tibble(
  modelo = "M4 (dummies de município), erro de White",
  efeito_ln_por_pp = b_selic,
  efeito_percentual_por_pp = 100 * (exp(b_selic) - 1),
  ic95_inf_ln = b_selic - t_crit * ep_selic,
  ic95_sup_ln = b_selic + t_crit * ep_selic,
  gl = m4$df.residual,
  p_valor = ct_m4["selic_real", 4]
)
agregado <- summary(stats::lm(ln_salario_real ~ selic_real, data = media_ano))$coefficients["selic_real", ]
efeito_selic <- dplyr::bind_rows(efeito_selic, tibble::tibble(
  modelo = "Checagem agregada (médias anuais, n = 10)",
  efeito_ln_por_pp = agregado[1], efeito_percentual_por_pp = 100 * (exp(agregado[1]) - 1),
  ic95_inf_ln = agregado[1] - stats::qt(0.975, 8) * agregado[2],
  ic95_sup_ln = agregado[1] + stats::qt(0.975, 8) * agregado[2],
  gl = 8L, p_valor = agregado[4]))
readr::write_csv(efeito_selic, file.path(DIR_RESULTADOS, "efeito_selic_projecao.csv"))

# Robustez da X4: Gini calculado só sobre as divisões com vínculo (n = número de divisões com emprego).
# Ao contrário do Gini sobre 87 divisões, esta versão não depende mecanicamente de quantos setores
# existem (correlação com o número de divisões: -0,41, contra -0,95 no Gini de 87 divisões).
if (file.exists(arq_rais)) {
  gini_ativas <- sapply(split(cnae, paste(cnae$id_municipio, cnae$ano)), function(d) {
    x <- sort(d$vinculos_ativos / sum(d$vinculos_ativos)); n_div <- length(x)
    sum((2 / n_div) * seq_len(n_div) * x) - (n_div + 1) / n_div
  })
  painel$gini_ativas <- gini_ativas[paste(painel$id_municipio, painel$ano)]
  linhas_x4 <- purrr::imap_dfr(c(gini_setorial = "87 divisões (zeros incluídos)",
                                 gini_ativas = "somente divisões com vínculo"), function(rot, v) {
    f_m4 <- stats::as.formula(paste("ln_salario_real ~ prop_superior + dom_industrial +", v,
                                    "+ selic_real + factor(id_municipio)"))
    f_m2 <- stats::as.formula(paste("ln_salario_real ~ prop_superior + dom_industrial +", v,
                                    "+ selic_real + dist_curitiba_km"))
    purrr::imap_dfr(list("Modelo 4" = f_m4, "Modelo 2" = f_m2), function(f, nome) {
      m <- stats::lm(f, data = painel)
      ct <- lmtest::coeftest(m, vcov. = sandwich::vcovHC(m, type = "HC1"))
      tibble::tibble(modelo = nome, definicao_x4 = rot, coef_x4 = ct[v, 1], p_valor_x4 = ct[v, 4],
                     r2_ajustado = summary(m)$adj.r.squared, aic = stats::AIC(m),
                     reset_p = lmtest::resettest(m, power = 2:3, type = "fitted")$p.value)
    })
  })
  readr::write_csv(linhas_x4, file.path(DIR_RESULTADOS, "robustez_x4_definicao_gini.csv"))
}

message("Etapa 6 concluída: RESET, LM, Chow, inferência agregada e checagem do Gini gravados.")
print(tabela_reset[, c("modelo", "teste", "estatistica_f", "p_valor", "decisao_5pct")], row.names = FALSE)
print(tabela_acrescimo[, c("teste", "estatistica_f", "p_valor", "decisao_5pct")], row.names = FALSE)
print(tabela_lm[, c("teste", "estatistica", "p_valor", "decisao_5pct")], row.names = FALSE)
print(tabela_chow[, c("teste", "estatistica_f", "p_valor", "decisao_5pct")], row.names = FALSE)
