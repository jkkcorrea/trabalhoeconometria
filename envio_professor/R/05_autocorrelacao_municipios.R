# =============================================================================
# Etapa 5: autocorrelação dos resíduos, aplicada à série de cada município
# Trabalho de Econometria I (UFPR).
#
# Por que por município: no painel empilhado, a defasagem de uma linha é o
# município anterior, e não o ano anterior; o Durbin-Watson do painel
# empilhado não é evidência de autocorrelação. Aplicam-se, então, os métodos
# ensinados (Durbin-Watson, ρ por regressão auxiliar AR(1) e Breusch-Godfrey)
# à série de dez anos de cada um dos 29 municípios, com os resíduos do
# Modelo 2 (MQO empilhado).
#
# Tabela de Durbin-Watson: n = 10 e k' = 5 (cinco explicativas, sem constante),
# 5% de significância: dL = 0,243 e dU = 2,822 (tabela_DW.pdf, Drive da
# disciplina). Os valores foram lidos por OCR e devem ser conferidos
# visualmente no PDF [a confirmar].
#
# Lê:    ./dados_processados/dados_painel_rmc.rds
# Grava: ./resultados_econometricos/autocorrelacao_por_municipio.csv
#        ./resultados_econometricos/autocorrelacao_resumo.csv
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

PACOTES <- c("dplyr", "readr", "tibble", "purrr", "ggplot2", "lmtest")
ausentes <- PACOTES[!vapply(PACOTES, requireNamespace, logical(1), quietly = TRUE)]
if (length(ausentes) > 0) stop("Pacotes ausentes: ", paste(ausentes, collapse = ", "), call. = FALSE)
invisible(lapply(PACOTES, function(p) suppressPackageStartupMessages(library(p, character.only = TRUE))))

DIR_PROCESSADOS <- "./dados_processados"
DIR_RESULTADOS  <- "./resultados_econometricos"
DIR_FIGURAS     <- "./figuras_graficos"
ARQ_PAINEL      <- file.path(DIR_PROCESSADOS, "dados_painel_rmc.rds")
DW_N            <- 10L
DW_K            <- 5L
DW_DL           <- 0.243
DW_DU           <- 2.822

painel <- readRDS(ARQ_PAINEL)
modelo2 <- stats::lm(ln_salario_real ~ prop_superior + dom_industrial + gini_setorial +
                       selic_real + dist_curitiba_km, data = painel)
painel$residuo <- stats::residuals(modelo2)
# Modelo 4 (dummies de município): resíduos da mesma análise, para comparação.
modelo4 <- stats::lm(ln_salario_real ~ prop_superior + dom_industrial + gini_setorial + selic_real +
                       factor(id_municipio), data = painel)
painel$residuo_m4 <- stats::residuals(modelo4)

decidir_dw <- function(d) {
  dplyr::case_when(
    d < DW_DL ~ "autocorrelação positiva",
    d > 4 - DW_DL ~ "autocorrelação negativa",
    d > DW_DU & d < 4 - DW_DU ~ "não rejeita H0",
    TRUE ~ "zona de inconclusão"
  )
}

analisar_municipio <- function(df, coluna_residuo = "residuo") {
  df <- dplyr::arrange(df, ano)
  e <- df[[coluna_residuo]]
  n <- length(e)
  d <- sum(diff(e)^2) / sum(e^2)                          # Durbin-Watson (Gujarati, eq. 18)
  rho <- unname(stats::coef(stats::lm(e[-1] ~ 0 + e[-n])))  # AR(1) sem constante
  bg <- lmtest::bgtest(stats::lm(e ~ 1), order = 1)       # Breusch-Godfrey, ordem 1
  tibble::tibble(
    id_municipio = df$id_municipio[1],
    nome_municipio = df$nome_municipio[1],
    n = n,
    durbin_watson = d,
    decisao_dw_tabela = decidir_dw(d),
    rho_auxiliar = rho,
    breusch_godfrey_estatistica = unname(bg$statistic),
    breusch_godfrey_p = bg$p.value,
    breusch_godfrey_decisao = ifelse(bg$p.value < 0.05, "rejeita H0", "não rejeita H0")
  )
}

autocorrelacao <- painel |>
  dplyr::group_split(id_municipio) |>
  purrr::map_dfr(analisar_municipio) |>
  dplyr::mutate(modelo = "Modelo 2")
autocorrelacao_m4 <- painel |>
  dplyr::group_split(id_municipio) |>
  purrr::map_dfr(analisar_municipio, coluna_residuo = "residuo_m4") |>
  dplyr::mutate(modelo = "Modelo 4")
autocorrelacao <- dplyr::bind_rows(autocorrelacao, autocorrelacao_m4)
autocorrelacao$decisao_dw_tabela[autocorrelacao$modelo == "Modelo 4"] <- "tabela não cobre k' = 32"

if (nrow(autocorrelacao) != 58L) stop("A análise devia cobrir 29 municípios em dois modelos.", call. = FALSE)

resumo <- autocorrelacao |>
  dplyr::group_by(modelo) |>
  dplyr::summarise(
    municipios = dplyr::n(),
    durbin_watson_mediano = signif(stats::median(durbin_watson), 4),
    rho_auxiliar_mediano = signif(stats::median(rho_auxiliar), 4),
    positiva_pela_tabela = sum(decisao_dw_tabela == "autocorrelação positiva"),
    zona_inconclusao = sum(decisao_dw_tabela == "zona de inconclusão"),
    breusch_godfrey_rejeita = sum(breusch_godfrey_decisao == "rejeita H0"),
    .groups = "drop"
  )
readr::write_csv(autocorrelacao, file.path(DIR_RESULTADOS, "autocorrelacao_por_municipio.csv"))
readr::write_csv(resumo, file.path(DIR_RESULTADOS, "autocorrelacao_resumo.csv"))

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

message("Etapa 5 concluída: autocorrelação por município gravada.")
print(resumo, row.names = FALSE)
