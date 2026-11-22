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
  hipotese_nula = "forma funcional correta", estatistica_f = unname(reset$statistic),
  gl = paste(unname(reset$parameter), collapse = "; "), p_valor = reset$p.value,
  decisao_5pct = ifelse(reset$p.value < 0.05, "rejeita H0", "não rejeita H0")
)
readr::write_csv(tabela_reset, file.path(DIR_RESULTADOS, "especificacao_reset.csv"))

# LM para acréscimo de tendência linear do ano: n * R2 da regressão dos resíduos.
aux <- stats::lm(stats::residuals(modelo2) ~ prop_superior + dom_industrial + gini_setorial +
                   selic_real + dist_curitiba_km + ano, data = painel)
lm_stat <- nrow(painel) * summary(aux)$r.squared
tabela_lm <- tibble::tibble(
  modelo = "Modelo 2", teste = "LM para acréscimo de tendência linear (ano)",
  hipotese_nula = "coeficiente de ano = 0", estatistica = lm_stat, gl = 1L,
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
  hipotese_nula = "coeficientes iguais nas duas partes", n1 = n1, n2 = n2, k = k,
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

message("Etapa 6 concluída: RESET, LM, Chow, inferência agregada e checagem do Gini gravados.")
print(tabela_reset[, c("teste", "estatistica_f", "p_valor", "decisao_5pct")], row.names = FALSE)
print(tabela_lm[, c("teste", "estatistica", "p_valor", "decisao_5pct")], row.names = FALSE)
print(tabela_chow[, c("teste", "estatistica_f", "p_valor", "decisao_5pct")], row.names = FALSE)
