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

PACOTES <- c("dplyr", "readr", "tibble", "lmtest")
ausentes <- PACOTES[!vapply(PACOTES, requireNamespace, logical(1), quietly = TRUE)]
if (length(ausentes) > 0) stop("Pacotes ausentes: ", paste(ausentes, collapse = ", "), call. = FALSE)
invisible(lapply(PACOTES, function(p) suppressPackageStartupMessages(library(p, character.only = TRUE))))

DIR_PROCESSADOS <- "./dados_processados"
DIR_RESULTADOS  <- "./resultados_econometricos"
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

message("Etapa 6 concluída: RESET, LM e Chow gravados.")
print(tabela_reset[, c("teste", "estatistica_f", "p_valor", "decisao_5pct")], row.names = FALSE)
print(tabela_lm[, c("teste", "estatistica", "p_valor", "decisao_5pct")], row.names = FALSE)
print(tabela_chow[, c("teste", "estatistica_f", "p_valor", "decisao_5pct")], row.names = FALSE)
