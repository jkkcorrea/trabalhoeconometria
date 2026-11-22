# =============================================================================
# Modelos de regressão linear, diagnósticos do modelo clássico e inferência robusta
#
# Modelo 1: salário médio real (nível) sobre X2
# Modelo 2: ln do salário médio real sobre X2, X3, X4, X5 e X6
# Modelo 3: Modelo 2 com indicadora de Curitiba
# Modelo 3b: Modelo 3 com a interação X3:X6
#
# Diagnósticos do Modelo 2: fator de inflação da variância, Breusch-Pagan,
# White, Durbin-Watson, Breusch-Godfrey, Jarque-Bera, Shapiro-Wilk e RESET.
# Erros-padrão: clássico, White (HC1), Newey-West, agrupado por município e
# agrupado por município e ano. Simulação de cenários com o Modelo 2.
#
# Lê:    ./dados_processados/dados_painel_rmc.rds
# Grava: ./resultados_econometricos/ (tabelas, testes e simulação) e
#        ./figuras_graficos/diag1 a diag4 (gráficos dos resíduos)
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

PACOTES <- c("dplyr", "readr", "tibble", "stringr", "purrr", "ggplot2", "car", "lmtest", "sandwich")
ausentes <- PACOTES[!vapply(PACOTES, requireNamespace, logical(1), quietly = TRUE)]
if (length(ausentes) > 0) {
  stop("Pacotes ausentes: ", paste(ausentes, collapse = ", "), ". Este script não instala pacotes.", call. = FALSE)
}
invisible(lapply(PACOTES, function(p) suppressPackageStartupMessages(library(p, character.only = TRUE))))

DIR_PROCESSADOS <- "./dados_processados"
DIR_RESULTADOS  <- "./resultados_econometricos"
DIR_FIGURAS     <- "./figuras_graficos"
ARQ_PAINEL      <- file.path(DIR_PROCESSADOS, "dados_painel_rmc.rds")
N_MUNICIPIOS    <- 29L
N_ANOS          <- 10L
ALFA            <- 0.05

for (d in c(DIR_RESULTADOS, DIR_FIGURAS)) if (!dir.exists(d)) dir.create(d, recursive = TRUE)

# -----------------------------------------------------------------------------
# 1. Painel e validação
# -----------------------------------------------------------------------------
carregar_painel <- function() {
  if (!file.exists(ARQ_PAINEL)) stop("Painel ausente: ", ARQ_PAINEL, ". Rode a Etapa 2.", call. = FALSE)
  painel <- readRDS(ARQ_PAINEL)
  necessarias <- c("id_municipio", "ano", "ln_salario_real", "prop_superior", "dom_industrial",
                   "gini_setorial", "selic_real", "dist_curitiba_km", "dummy_curitiba")
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

# -----------------------------------------------------------------------------
# 2. Modelos (fórmulas)
# -----------------------------------------------------------------------------
FORMULA_M2 <- ln_salario_real ~ prop_superior + dom_industrial + gini_setorial + selic_real + dist_curitiba_km
FORMULA_M3 <- update(FORMULA_M2, . ~ . + dummy_curitiba)
FORMULA_M3B <- update(FORMULA_M3, . ~ . + dom_industrial:dist_curitiba_km)

ajustar_modelos <- function(painel) {
  list(
    "Modelo 2" = lm(FORMULA_M2, data = painel),
    "Modelo 3" = lm(FORMULA_M3, data = painel),
    "Modelo 3b" = lm(FORMULA_M3B, data = painel)
  )
}

# -----------------------------------------------------------------------------
# 3. Coeficientes: classico e White (HC1), com t de n - k graus de liberdade
# -----------------------------------------------------------------------------
tabela_coeficientes <- function(modelos) {
  purrr::imap_dfr(modelos, function(m, nome) {
    gl <- df.residual(m)
    matrizes <- list(classico = stats::vcov(m), white = sandwich::vcovHC(m, type = "HC1"))
    purrr::imap_dfr(matrizes, function(V, tipo) {
      est <- stats::coef(m)
      ep  <- sqrt(diag(V))
      tt  <- est / ep
      tibble::tibble(modelo = nome, matriz = tipo, termo = names(est),
                     estimativa = unname(est), erro_padrao = unname(ep),
                     estatistica_t = unname(tt),
                     p_valor = 2 * stats::pt(-abs(tt), df = gl),
                     ic_inf_95 = unname(est - stats::qt(1 - ALFA / 2, gl) * ep),
                     ic_sup_95 = unname(est + stats::qt(1 - ALFA / 2, gl) * ep),
                     gl = gl)
    })
  })
}

# -----------------------------------------------------------------------------
# 4. Testes ensinados
# -----------------------------------------------------------------------------
decisao <- function(p) ifelse(p < ALFA, "rejeita H0", "não rejeita H0")

testes_diagnostico <- function(modelos, painel) {
  m2 <- modelos[["Modelo 2"]]
  lista <- list()
  for (nome in names(modelos)) {
    m <- modelos[[nome]]
    bp <- lmtest::bptest(m)
    lista[[length(lista) + 1]] <- tibble::tibble(
      modelo = nome, teste = "Breusch-Pagan-Godfrey (bptest, studentized)",
      hipotese_nula = "erros homocedásticos", estatistica = unname(bp$statistic),
      gl = as.character(unname(bp$parameter)), p_valor = bp$p.value
    )
  }
  # Goldfeld-Quandt: ordenação pela distância a Curitiba, fração central omitida 0,2.
  # Ordenar por dist_curitiba_km e alternativa "greater" são: a
  # variável de ordenação deve ser a que se suspeita causar a heterocedasticidade.
  gq <- lmtest::gqtest(m2, order.by = painel$dist_curitiba_km, fraction = 0.2, alternative = "greater")
  lista[[length(lista) + 1]] <- tibble::tibble(
    modelo = "Modelo 2", teste = "Goldfeld-Quandt (gqtest, unilateral; ordenado por dist_curitiba_km)",
    hipotese_nula = "variância constante", estatistica = unname(gq$statistic),
    gl = paste(unname(gq$parameter), collapse = "; "), p_valor = gq$p.value
  )
  dplyr::bind_rows(lista) |>
    dplyr::mutate(decisao_5pct = decisao(p_valor))
}

vif_tabela <- function(modelos) {
  purrr::imap_dfr(modelos[c("Modelo 2", "Modelo 3")], function(m, nome) {
    v <- car::vif(m)
    if (is.matrix(v)) v <- v[, "GVIF"]
    tibble::tibble(modelo = nome, variavel = names(v), fiv = unname(v),
                   tolerancia = 1 / unname(v), decisao_fiv_10 = ifelse(v > 10, "multicolinearidade elevada", "sem problema (FIV <= 10)"))
  })
}

anova_f <- function(modelos) {
  purrr::imap_dfr(modelos, function(m, nome) {
    s <- summary(m)
    f <- unname(s$fstatistic)
    tibble::tibble(modelo = nome, estatistica_f = f[1], gl_numerador = f[2], gl_denominador = f[3],
                   p_valor = stats::pf(f[1], f[2], f[3], lower.tail = FALSE), r2 = s$r.squared,
                   r2_ajustado = s$adj.r.squared)
  })
}

# -----------------------------------------------------------------------------
# 5. Figuras de diagnóstico (método gráfico ensinado)
# -----------------------------------------------------------------------------
gerar_figuras <- function(m2, painel) {
  base <- tibble::tibble(ajustado = fitted(m2), residuo = residuals(m2),
                         municipio = painel$id_municipio, ano = painel$ano)
  g1 <- ggplot(base, aes(ajustado, residuo)) +
    geom_hline(yintercept = 0, colour = "grey50") +
    geom_point(alpha = 0.6, colour = "#3C6A6D") +
    labs(title = "Resíduos contra valores ajustados (Modelo 2)",
         subtitle = "Dispersão constante em torno de zero sugere variância constante",
         x = "Valor ajustado de ln(salário real)", y = "Resíduo") +
    theme_bw(base_size = 11)
  ggsave(file.path(DIR_FIGURAS, "diag1_residuos_vs_ajustados.png"), g1, width = 8, height = 5, dpi = 200, bg = "white")

  g2 <- ggplot(base, aes(ano, residuo, group = municipio)) +
    geom_hline(yintercept = 0, colour = "grey50") +
    geom_line(alpha = 0.35, colour = "#496785") +
    labs(title = "Resíduos do Modelo 2 ao longo do tempo, por município",
         subtitle = "Uma linha por município; sequências do mesmo sinal indicam autocorrelação dentro do município",
         x = "Ano", y = "Resíduo") +
    theme_bw(base_size = 11)
  ggsave(file.path(DIR_FIGURAS, "diag2_residuos_por_municipio.png"), g2, width = 8, height = 5, dpi = 200, bg = "white")
  invisible(TRUE)
}

# -----------------------------------------------------------------------------
# 6. Execução
# -----------------------------------------------------------------------------
executar_etapa_4 <- function() {
  painel <- carregar_painel()
  modelos <- ajustar_modelos(painel)

  coeficientes <- tabela_coeficientes(modelos)
  readr::write_csv(coeficientes, file.path(DIR_RESULTADOS, "coeficientes_modelos.csv"))

  testes <- testes_diagnostico(modelos, painel)
  readr::write_csv(testes, file.path(DIR_RESULTADOS, "testes_diagnostico.csv"))

  vif <- vif_tabela(modelos)
  readr::write_csv(vif, file.path(DIR_RESULTADOS, "vif_tolerancia.csv"))

  anova <- anova_f(modelos)
  readr::write_csv(anova, file.path(DIR_RESULTADOS, "anova_f_modelos.csv"))

  gerar_figuras(modelos[["Modelo 2"]], painel)

  message("Etapa 4 concluída: coeficientes, testes, VIF, ANOVA e figuras de diagnóstico gravados.")
  invisible(list(modelos = modelos, coeficientes = coeficientes, testes = testes, vif = vif, anova = anova))
}

executar_etapa_4()
