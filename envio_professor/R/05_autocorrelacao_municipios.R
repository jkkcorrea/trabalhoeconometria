# =============================================================================
# Etapa 5: autocorrelação dos resíduos e correções, aplicadas dentro de cada município
# Trabalho de Econometria I (UFPR).
#
# Por que por município: no painel empilhado, a defasagem de uma linha é o
# município anterior, e não o ano anterior. Os testes são aplicados à série de
# dez anos de cada um dos 29 municípios (com os resíduos do Modelo 2 e do Modelo 4).
#
# Testes (Gujarati, cap. 12; Guia P2; slides autocorrel):
#   - Durbin-Watson, com as cinco zonas de decisão do Guia P2;
#   - ρ por regressão auxiliar AR(1) sem constante;
#   - Breusch-Godfrey de ordem 1 (lmtest::bgtest);
#   - teste das carreiras (Gujarati, cap. 12; slides autocorrel p. 89 a 91).
#
# Tabela de Durbin-Watson: n = 10 e k' = 5, 5% de significância: dL = 0,243 e dU = 2,822
# (Gujarati, Apêndice D, Tabela D.5A, p. 995 do PDF da 4ª edição; valores conferidos no livro).
#
# Correções (Gujarati, cap. 12; Guia P2): Prais-Winsten e Cochrane-Orcutt, com ρ comum a
# todos os municípios e transformação feita dentro de cada município [presunção da modelagem].
# Newey-West não é aplicado ao painel empilhado (ver fontes/VERIFICACAO_CORRECOES.md).
#
# Lê:    ./dados_processados/dados_painel_rmc.rds
# Grava: ./resultados_econometricos/autocorrelacao_por_municipio.csv
#        ./resultados_econometricos/autocorrelacao_resumo.csv
#        ./resultados_econometricos/autocorrelacao_correcao.csv
#        ./figuras_graficos/diag3_residuos_defasados.png
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

PACOTES <- c("dplyr", "readr", "tibble", "purrr", "ggplot2", "lmtest", "sandwich")
ausentes <- PACOTES[!vapply(PACOTES, requireNamespace, logical(1), quietly = TRUE)]
if (length(ausentes) > 0) stop("Pacotes ausentes: ", paste(ausentes, collapse = ", "), call. = FALSE)
invisible(lapply(PACOTES, function(p) suppressPackageStartupMessages(library(p, character.only = TRUE))))

DIR_PROCESSADOS <- "./dados_processados"
DIR_RESULTADOS  <- "./resultados_econometricos"
DIR_FIGURAS     <- "./figuras_graficos"
ARQ_PAINEL      <- file.path(DIR_PROCESSADOS, "dados_painel_rmc.rds")
DW_N            <- 10L
DW_K            <- 5L
DW_DL           <- 0.243   # Gujarati, Tabela D.5A (n = 10, k = 5, 5%)
DW_DU           <- 2.822   # Gujarati, Tabela D.5A (n = 10, k = 5, 5%)

FORMULA_M2 <- ln_salario_real ~ prop_superior + dom_industrial + gini_setorial + selic_real + dist_curitiba_km
FORMULA_M4 <- ln_salario_real ~ prop_superior + dom_industrial + gini_setorial + selic_real + factor(id_municipio)

painel <- readRDS(ARQ_PAINEL) |> dplyr::arrange(id_municipio, ano)
modelo2 <- stats::lm(FORMULA_M2, data = painel)
modelo4 <- stats::lm(FORMULA_M4, data = painel)
painel$residuo <- stats::residuals(modelo2)
painel$residuo_m4 <- stats::residuals(modelo4)

# H0: ρ = 0 (ausência de autocorrelação de primeira ordem) contra Ha: ρ > 0 (positiva) ou ρ < 0 (negativa).
decidir_dw <- function(d) {
  dplyr::case_when(
    d < DW_DL ~ "positiva (d < dL): rejeita H0",
    d > 4 - DW_DL ~ "negativa (d > 4 - dL): rejeita H0",
    d > DW_DU & d < 4 - DW_DU ~ "não rejeita H0",
    TRUE ~ "inconclusiva"
  )
}

# -----------------------------------------------------------------------------
# 2. Teste das carreiras (Gujarati, cap. 12): N1 e N2 > 10 para a aproximação normal
# -----------------------------------------------------------------------------
# H0: resíduos aleatórios (independentes). Ha: resíduos não aleatórios.
# E(R) = 2 N1 N2 / N + 1; Var(R) = 2 N1 N2 (2 N1 N2 - N) / (N^2 (N - 1)).
teste_carreiras <- function(e) {
  s <- sign(e[e != 0])
  n1 <- sum(s > 0); n2 <- sum(s < 0); N <- n1 + n2
  R <- 1 + sum(diff(s) != 0)
  ER <- 2 * n1 * n2 / N + 1
  VR <- 2 * n1 * n2 * (2 * n1 * n2 - N) / (N^2 * (N - 1))
  z <- (R - ER) / sqrt(VR)
  valido <- n1 > 10 && n2 > 10
  list(n1 = n1, n2 = n2, R = R, ER = ER, z = z, p = 2 * stats::pnorm(-abs(z)), valido = valido)
}

# -----------------------------------------------------------------------------
# 3. Testes por município
# -----------------------------------------------------------------------------
analisar_municipio <- function(df, coluna_residuo) {
  df <- dplyr::arrange(df, ano)
  e <- df[[coluna_residuo]]
  n <- length(e)
  d <- sum(diff(e)^2) / sum(e^2)
  rho <- unname(stats::coef(stats::lm(e[-1] ~ 0 + e[-n])))
  bg <- lmtest::bgtest(stats::lm(e ~ 1), order = 1)
  cr <- teste_carreiras(e)
  tibble::tibble(
    id_municipio = df$id_municipio[1],
    nome_municipio = df$nome_municipio[1],
    n = n,
    durbin_watson = d,
    decisao_dw_tabela = decidir_dw(d),
    rho_auxiliar = rho,
    breusch_godfrey_estatistica = unname(bg$statistic),
    breusch_godfrey_p = bg$p.value,
    breusch_godfrey_decisao = ifelse(bg$p.value < 0.05, "rejeita H0", "não rejeita H0"),
    carreiras_n1 = cr$n1, carreiras_n2 = cr$n2, carreiras_R = cr$R, carreiras_ER = cr$ER,
    carreiras_p = ifelse(cr$valido, cr$p, NA_real_),
    carreiras_decisao = ifelse(cr$valido,
      ifelse(cr$p < 0.05, "rejeita H0 (não aleatório)", "não rejeita H0"),
      "não aplicável (N1 ou N2 <= 10)")
  )
}

analisar_todos <- function(coluna_residuo, nome_modelo) {
  painel |>
    dplyr::group_split(id_municipio) |>
    purrr::map_dfr(analisar_municipio, coluna_residuo = coluna_residuo) |>
    dplyr::mutate(modelo = nome_modelo)
}

autocorrelacao <- dplyr::bind_rows(analisar_todos("residuo", "Modelo 2"), analisar_todos("residuo_m4", "Modelo 4"))
# Para o Modelo 4 (k' = 32) a tabela de Durbin-Watson usada não se aplica (cobre k' até 20).
autocorrelacao$decisao_dw_tabela[autocorrelacao$modelo == "Modelo 4"] <- "tabela não cobre k' = 32"

if (nrow(autocorrelacao) != 58L) stop("A análise devia cobrir 29 municípios em dois modelos.", call. = FALSE)

# -----------------------------------------------------------------------------
# 4. Correções: Prais-Winsten e Cochrane-Orcutt com ρ comum (dentro de cada município)
# -----------------------------------------------------------------------------
# Transformação de Prais-Winsten: a primeira observação de cada município é multiplicada por
# sqrt(1 - ρ^2); as demais por y_t - ρ y_{t-1}. Cochrane-Orcutt descarta essas primeiras observações.
# ρ é estimado pelos resíduos originais, em pares de anos consecutivos do mesmo município,
# e o processo é repetido até a convergência (Cochrane-Orcutt iterado).
estimar_correcao <- function(formula, dados, pw = TRUE, tol = 1e-10, maxit = 500) {
  mf <- stats::model.frame(formula, dados)
  y <- stats::model.response(mf)
  X <- stats::model.matrix(formula, mf)
  colnames(X) <- make.names(colnames(X), unique = TRUE)
  id <- dados$id_municipio
  primeira <- !duplicated(id)
  idx_ant <- which(!primeira) - 1L
  rho <- 0
  for (it in seq_len(maxit)) {
    ys <- y; Xs <- X
    ys[!primeira] <- y[!primeira] - rho * y[idx_ant]
    Xs[!primeira, ] <- X[!primeira, , drop = FALSE] - rho * X[idx_ant, , drop = FALSE]
    if (pw) {
      ys[primeira] <- sqrt(1 - rho^2) * y[primeira]
      Xs[primeira, ] <- sqrt(1 - rho^2) * X[primeira, , drop = FALSE]
    }
    keep <- if (pw) rep(TRUE, length(y)) else !primeira
    td <- as.data.frame(Xs[keep, , drop = FALSE])
    td$.y <- ys[keep]
    fit <- stats::lm(.y ~ . - 1, data = td)
    b <- stats::coef(fit)
    e <- as.vector(y - X %*% b)
    ant <- which(!primeira)
    rho_novo <- sum(e[ant] * e[ant - 1L]) / sum(e[ant - 1L]^2)
    if (abs(rho_novo - rho) < tol) { rho <- rho_novo; break }
    rho <- rho_novo
  }
  # Resíduos da regressão transformada e ρ auxiliar nessa regressão
  u_t <- ys - Xs %*% b
  u_t <- as.vector(u_t)
  # Pares (t, t-1) usados: as duas observações precisam estar na regressão transformada.
  pares_t <- which(!primeira)
  if (!pw) pares_t <- pares_t[!primeira[pares_t - 1L]]
  rho_pos <- sum(u_t[pares_t] * u_t[pares_t - 1L]) / sum(u_t[pares_t - 1L]^2)
  list(fit = fit, rho = rho, iter = it, rho_pos_correcao = rho_pos,
       n_usada = sum(keep), metodo = if (pw) "Prais-Winsten" else "Cochrane-Orcutt")
}

tabela_correcao <- function(formula, dados, nome_modelo) {
  purrr::map_dfr(c(TRUE, FALSE), function(pw) {
    cor <- estimar_correcao(formula, dados, pw = pw)
    vc_hc1 <- sandwich::vcovHC(cor$fit, type = "HC1")
    ct <- lmtest::coeftest(cor$fit, vcov. = vc_hc1)
    tibble::tibble(
      modelo = nome_modelo, metodo = cor$metodo, rho = cor$rho, iteracoes = cor$iter,
      observacoes_usadas = cor$n_usada, rho_auxiliar_residuos_corrigidos = cor$rho_pos_correcao,
      termo = rownames(ct), estimativa = unname(stats::coef(cor$fit)),
      erro_padrao_classico = sqrt(diag(stats::vcov(cor$fit))),
      erro_padrao_HC1 = unname(ct[, 2]), t_HC1 = unname(ct[, 3]), p_valor_HC1 = unname(ct[, 4])
    )
  })
}

# Apenas as variáveis explicativas do Modelo 2 e do Modelo 4 (sem as dummies de município).
correcao <- dplyr::bind_rows(
  tabela_correcao(FORMULA_M2, painel, "Modelo 2"),
  tabela_correcao(FORMULA_M4, painel, "Modelo 4")
)

# -----------------------------------------------------------------------------
# 5. Resumos e saídas
# -----------------------------------------------------------------------------
resumo <- autocorrelacao |>
  dplyr::group_by(modelo) |>
  dplyr::summarise(
    municipios = dplyr::n(),
    durbin_watson_mediano = signif(stats::median(durbin_watson), 4),
    rho_auxiliar_mediano = signif(stats::median(rho_auxiliar), 4),
    dw_positiva = sum(grepl("^positiva", decisao_dw_tabela)),
    dw_inconclusiva = sum(decisao_dw_tabela == "inconclusiva"),
    dw_nao_rejeita = sum(decisao_dw_tabela == "não rejeita H0"),
    dw_nao_aplicavel = sum(grepl("não cobre", decisao_dw_tabela)),
    breusch_godfrey_rejeita = sum(breusch_godfrey_decisao == "rejeita H0"),
    carreiras_nao_aplicavel = sum(grepl("não aplicável", carreiras_decisao)),
    .groups = "drop"
  )

readr::write_csv(autocorrelacao, file.path(DIR_RESULTADOS, "autocorrelacao_por_municipio.csv"))
readr::write_csv(resumo, file.path(DIR_RESULTADOS, "autocorrelacao_resumo.csv"))
readr::write_csv(correcao, file.path(DIR_RESULTADOS, "autocorrelacao_correcao.csv"))

# Figura: resíduo contra resíduo defasado, dentro de cada município (método gráfico ensinado).
pares <- painel |>
  dplyr::arrange(id_municipio, ano) |>
  dplyr::group_by(id_municipio) |>
  dplyr::mutate(residuo_defasado = dplyr::lag(residuo)) |>
  dplyr::ungroup() |>
  dplyr::filter(!is.na(residuo_defasado))
g <- ggplot2::ggplot(pares, ggplot2::aes(residuo_defasado, residuo)) +
  ggplot2::geom_hline(yintercept = 0, colour = "grey60") +
  ggplot2::geom_vline(xintercept = 0, colour = "grey60") +
  ggplot2::geom_point(colour = "#5F7F62", alpha = 0.7) +
  ggplot2::labs(title = "Resíduo contra resíduo defasado, dentro de cada município",
                subtitle = "Pares do mesmo município, 2013 a 2021; inclinação positiva sugere autocorrelação positiva",
                x = "Resíduo no ano anterior", y = "Resíduo no ano") +
  ggplot2::theme_bw(base_size = 11)
ggplot2::ggsave(file.path(DIR_FIGURAS, "diag3_residuos_defasados.png"), g,
                width = 7, height = 5, dpi = 200, bg = "white")

message("Etapa 5 concluída: autocorrelação por município, correções Prais-Winsten e Cochrane-Orcutt gravadas.")
print(resumo, row.names = FALSE)
