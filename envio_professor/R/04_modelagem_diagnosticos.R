# =============================================================================
# Modelo principal (MQO empilhado) e diagnósticos ensinados
#
# Modelo: ln do salário médio real sobre X2, X3, X4, X5 e X6, com erros de White (HC1).
# Diagnósticos: fator de inflação da variância, Breusch-Pagan-Godfrey, Goldfeld-Quandt,
# Shapiro-Wilk com gráfico Q-Q e ANOVA.
#
# Lê:    ./dados_processados/dados_painel_rmc.rds
# Grava: ./resultados_econometricos/ (coeficientes, testes, normalidade, FIV e ANOVA)
#        ./figuras_graficos/diag1, diag2 e diag5
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

PACOTES <- c("dplyr", "readr", "tibble", "purrr", "ggplot2", "car", "lmtest", "sandwich")
ausentes <- PACOTES[!vapply(PACOTES, requireNamespace, logical(1), quietly = TRUE)]
if (length(ausentes) > 0) stop("Pacotes ausentes: ", paste(ausentes, collapse = ", "), call. = FALSE)
invisible(lapply(PACOTES, function(p) suppressPackageStartupMessages(library(p, character.only = TRUE))))

DIR_PROCESSADOS <- "./dados_processados"
DIR_RESULTADOS  <- "./resultados_econometricos"
DIR_FIGURAS     <- "./figuras_graficos"
ARQ_PAINEL      <- file.path(DIR_PROCESSADOS, "dados_painel_rmc.rds")
ALFA            <- 0.05
N_MUNICIPIOS    <- 29L
N_ANOS          <- 10L

for (d in c(DIR_RESULTADOS, DIR_FIGURAS)) if (!dir.exists(d)) dir.create(d, recursive = TRUE)

FORMULA <- ln_salario_real ~ prop_superior + dom_industrial + gini_setorial + selic_real + dist_curitiba_km

carregar_painel <- function() {
  if (!file.exists(ARQ_PAINEL)) stop("Painel ausente: ", ARQ_PAINEL, ". Rode a Etapa 2.", call. = FALSE)
  painel <- readRDS(ARQ_PAINEL) |> dplyr::arrange(id_municipio, ano)
  necessarias <- c("id_municipio", "ano", "ln_salario_real", "prop_superior", "dom_industrial",
                   "gini_setorial", "selic_real", "dist_curitiba_km")
  faltam <- setdiff(necessarias, names(painel))
  if (length(faltam) > 0) stop("Painel sem colunas: ", paste(faltam, collapse = ", "), call. = FALSE)
  if (nrow(painel) != N_MUNICIPIOS * N_ANOS) {
    stop("Painel com ", nrow(painel), " linhas; esperado ", N_MUNICIPIOS * N_ANOS, ".", call. = FALSE)
  }
  for (v in necessarias[-(1:2)]) {
    nao_finitos <- sum(!is.finite(as.numeric(painel[[v]])))
    if (nao_finitos > 0) stop("Variável ", v, " com ", nao_finitos, " valores não finitos.", call. = FALSE)
    painel[[v]] <- as.numeric(painel[[v]])
  }
  message("Painel: ", nrow(painel), " linhas, sem NA, NaN ou Inf nas variáveis usadas.")
  painel
}

decisao <- function(p) ifelse(p < ALFA, "rejeita H0", "não rejeita H0")

# -----------------------------------------------------------------------------
# 1. Coeficientes: classico e White (HC1), com t de n - k graus de liberdade
# -----------------------------------------------------------------------------
tabela_coeficientes <- function(modelo) {
  gl <- modelo$df.residual
  ep_c <- sqrt(diag(stats::vcov(modelo)))
  ct_w <- lmtest::coeftest(modelo, vcov. = sandwich::vcovHC(modelo, type = "HC1"))
  t_crit <- stats::qt(0.975, gl)
  b <- stats::coef(modelo)
  dplyr::bind_rows(
    tibble::tibble(modelo = "Modelo 2 (principal)", matriz = "classico", termo = names(b),
                   estimativa = unname(b), erro_padrao = unname(ep_c),
                   estatistica_t = unname(b / ep_c), p_valor = 2 * stats::pt(-abs(unname(b / ep_c)), gl),
                   ic_inf_95 = unname(b - t_crit * ep_c), ic_sup_95 = unname(b + t_crit * ep_c), gl = gl),
    tibble::tibble(modelo = "Modelo 2 (principal)", matriz = "white", termo = names(b),
                   estimativa = unname(b), erro_padrao = unname(ct_w[, 2]),
                   estatistica_t = unname(ct_w[, 3]), p_valor = unname(ct_w[, 4]),
                   ic_inf_95 = unname(b - t_crit * ct_w[, 2]), ic_sup_95 = unname(b + t_crit * ct_w[, 2]), gl = gl)
  )
}

# -----------------------------------------------------------------------------
# 2. Testes de heterocedasticidade (H0: variância constante)
# -----------------------------------------------------------------------------
testes_heterocedasticidade <- function(modelo, painel) {
  bp <- lmtest::bptest(modelo)
  gq <- lmtest::gqtest(modelo, order.by = painel$dist_curitiba_km, fraction = 0.2, alternative = "greater")
  tibble::tibble(
    modelo = "Modelo 2 (principal)",
    teste = c("Breusch-Pagan-Godfrey (bptest, studentized)",
              "Goldfeld-Quandt (gqtest, ordenado por dist_curitiba_km, fração central 0,2)"),
    hipotese_nula = c("H0: Var(u_t) = sigma^2 para todo t (homocedasticidade)",
                      "H0: sigma_1^2 = sigma_2^2 (variância constante entre os dois segmentos)"),
    hipotese_alternativa = c("Ha: Var(u_t) depende de algum regressor (heterocedasticidade); BP ~ qui-quadrado com k - 1 gl",
                             "Ha: sigma_2^2 > sigma_1^2 (variância maior no segmento de maior distância)"),
    estatistica = c(unname(bp$statistic), unname(gq$statistic)),
    gl = c(as.character(unname(bp$parameter)), paste(unname(gq$parameter), collapse = "; ")),
    p_valor = c(bp$p.value, gq$p.value)
  ) |> dplyr::mutate(decisao_5pct = decisao(p_valor))
}

# -----------------------------------------------------------------------------
# 3. Normalidade dos resíduos: Shapiro-Wilk (H0: normal) e gráfico Q-Q
# -----------------------------------------------------------------------------
testes_normalidade <- function(modelo) {
  e <- stats::residuals(modelo)
  sw <- stats::shapiro.test(e)
  tibble::tibble(
    modelo = "Modelo 2 (principal)", teste = "Shapiro-Wilk (shapiro.test)",
    hipotese_nula = "H0: os resíduos têm distribuição normal",
    hipotese_alternativa = "Ha: os resíduos não têm distribuição normal",
    estatistica = unname(sw$statistic), gl = as.character(length(e)), p_valor = sw$p.value,
    decisao_5pct = decisao(sw$p.value),
    assimetria = mean((e - mean(e))^3) / mean((e - mean(e))^2)^1.5,
    curtose = mean((e - mean(e))^4) / mean((e - mean(e))^2)^2
  )
}

figura_qq <- function(modelo) {
  g <- ggplot2::ggplot(data.frame(e = stats::residuals(modelo)), ggplot2::aes(sample = e)) +
    ggplot2::stat_qq(colour = "#5F7F62", alpha = 0.7) +
    ggplot2::stat_qq_line(colour = "grey40") +
    ggplot2::labs(title = "Gráfico Q-Q dos resíduos do modelo principal",
                  subtitle = "Pontos sobre a reta indicam resíduos aproximadamente normais",
                  x = "Quantis teóricos da normal", y = "Quantis dos resíduos") +
    ggplot2::theme_bw(base_size = 11)
  ggplot2::ggsave(file.path(DIR_FIGURAS, "diag5_normalidade_qq.png"), g, width = 7, height = 5, dpi = 200, bg = "white")
}

# -----------------------------------------------------------------------------
# 4. Multicolinearidade (FIV) e ANOVA
# -----------------------------------------------------------------------------
vif_tabela <- function(modelo) {
  v <- car::vif(modelo)
  tibble::tibble(modelo = "Modelo 2 (principal)", variavel = names(v), fiv = unname(v),
                 tolerancia = 1 / unname(v),
                 decisao_fiv_10 = ifelse(v > 10, "multicolinearidade elevada", "sem problema (FIV <= 10)"))
}

anova_f <- function(modelo) {
  s <- summary(modelo)
  f <- unname(s$fstatistic)
  tibble::tibble(modelo = "Modelo 2 (principal)", estatistica_f = f[1], gl_numerador = f[2],
                 gl_denominador = f[3], p_valor = stats::pf(f[1], f[2], f[3], lower.tail = FALSE),
                 r2 = s$r.squared, r2_ajustado = s$adj.r.squared)
}

# -----------------------------------------------------------------------------
# 5. Figuras de resíduos
# -----------------------------------------------------------------------------
gerar_figuras <- function(modelo, painel) {
  df <- data.frame(ajustado = stats::fitted(modelo), residuo = stats::residuals(modelo),
                   municipio = painel$nome_municipio)
  g1 <- ggplot2::ggplot(df, ggplot2::aes(ajustado, residuo)) +
    ggplot2::geom_hline(yintercept = 0, colour = "grey50") +
    ggplot2::geom_point(colour = "#5F7F62", alpha = 0.7) +
    ggplot2::labs(title = "Resíduos contra valores ajustados (modelo principal)",
                  x = "Valor ajustado de ln(salário real)", y = "Resíduo") +
    ggplot2::theme_bw(base_size = 11)
  ggplot2::ggsave(file.path(DIR_FIGURAS, "diag1_residuos_vs_ajustados.png"), g1, width = 8, height = 5, dpi = 200, bg = "white")
  g2 <- ggplot2::ggplot(df, ggplot2::aes(stats::reorder(municipio, residuo, FUN = stats::median), residuo)) +
    ggplot2::geom_hline(yintercept = 0, colour = "grey50") +
    ggplot2::geom_boxplot(colour = "#5F7F62", outlier.size = 0.8) +
    ggplot2::coord_flip() +
    ggplot2::labs(title = "Resíduos por município (modelo principal)", x = NULL, y = "Resíduo") +
    ggplot2::theme_bw(base_size = 9)
  ggplot2::ggsave(file.path(DIR_FIGURAS, "diag2_residuos_por_municipio.png"), g2, width = 8, height = 9, dpi = 200, bg = "white")
}

# -----------------------------------------------------------------------------
# 6. Execução
# -----------------------------------------------------------------------------
executar_etapa_4 <- function() {
  painel <- carregar_painel()
  modelo <- stats::lm(FORMULA, data = painel)

  readr::write_csv(tabela_coeficientes(modelo), file.path(DIR_RESULTADOS, "coeficientes_modelos.csv"))
  readr::write_csv(dplyr::bind_rows(testes_heterocedasticidade(modelo, painel)),
                   file.path(DIR_RESULTADOS, "testes_diagnostico.csv"))
  readr::write_csv(testes_normalidade(modelo), file.path(DIR_RESULTADOS, "normalidade_residuos.csv"))
  readr::write_csv(vif_tabela(modelo), file.path(DIR_RESULTADOS, "vif_tolerancia.csv"))
  readr::write_csv(anova_f(modelo), file.path(DIR_RESULTADOS, "anova_f_modelo.csv"))
  gerar_figuras(modelo, painel)
  figura_qq(modelo)

  message("Etapa 4 concluída: coeficientes, heterocedasticidade, normalidade (Shapiro-Wilk), FIV, ANOVA e figuras gravados.")
  invisible(list(modelo = modelo))
}

executar_etapa_4()
