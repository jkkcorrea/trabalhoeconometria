# =============================================================================
# Etapa 5: autocorrelação dos resíduos, por município (testes paramétricos)
# Trabalho de Econometria I (UFPR).
#
# Por que por município: no painel empilhado, a defasagem de uma linha é o município
# anterior, e não o ano anterior. Os testes são aplicados à série de dez anos de cada
# município, com os resíduos do modelo principal (Modelo 2).
#
# Testes paramétricos (Gujarati, 4ª ed., cap. 12; slides autocorrel; Guia P2):
#   - Durbin-Watson, com as cinco zonas de decisão do Guia P2;
#   - Breusch-Godfrey de ordem 1 (lmtest::bgtest), qui-quadrado com 1 gl;
#   - ρ por regressão auxiliar AR(1) sem constante (descritivo).
#
# Tabela de Durbin-Watson: n = 10 e k' = 5, 5%: dL = 0,243 e dU = 2,822 (Gujarati, 4ª ed.,
# Apêndice D, Tabela D.5A, PDF p. 995).
#
# Sem correção de autocorrelação no modelo principal: a autocorrelação é declarada como limitação.
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
DW_DL           <- 0.243   # Gujarati, Tabela D.5A (n = 10, k = 5, 5%)
DW_DU           <- 2.822   # Gujarati, Tabela D.5A (n = 10, k = 5, 5%)

FORMULA <- ln_salario_real ~ prop_superior + dom_industrial + gini_setorial + selic_real + dist_curitiba_km
painel <- readRDS(ARQ_PAINEL) |> dplyr::arrange(id_municipio, ano)
modelo <- stats::lm(FORMULA, data = painel)
painel$residuo <- stats::residuals(modelo)

decidir_dw <- function(d) {
  dplyr::case_when(
    d < DW_DL ~ "positiva (d < dL): rejeita H0",
    d > 4 - DW_DL ~ "negativa (d > 4 - dL): rejeita H0",
    d > DW_DU & d < 4 - DW_DU ~ "não rejeita H0",
    TRUE ~ "inconclusiva"
  )
}

analisar_municipio <- function(df) {
  df <- dplyr::arrange(df, ano)
  e <- df$residuo
  n <- length(e)
  d <- sum(diff(e)^2) / sum(e^2)
  rho <- unname(stats::coef(stats::lm(e[-1] ~ 0 + e[-n])))
  bg <- lmtest::bgtest(stats::lm(e ~ 1), order = 1)
  tibble::tibble(
    id_municipio = df$id_municipio[1],
    nome_municipio = df$nome_municipio[1],
    n = n,
    durbin_watson = d,
    decisao_dw_tabela = decidir_dw(d),
    rho_auxiliar = rho,
    breusch_godfrey_estatistica = unname(bg$statistic),
    breusch_godfrey_gl = unname(bg$parameter),
    breusch_godfrey_p = bg$p.value,
    breusch_godfrey_decisao = ifelse(bg$p.value < 0.05, "rejeita H0", "não rejeita H0")
  )
}

autocorrelacao <- painel |>
  dplyr::group_split(id_municipio) |>
  purrr::map_dfr(analisar_municipio) |>
  dplyr::mutate(
    modelo = "Modelo 2 (principal)",
    hipotese_dw = "H0: ρ = 0 (sem autocorrelação de 1ª ordem); Ha: ρ > 0 ou ρ < 0 (zonas do Guia P2)",
    hipotese_bg = "H0: sem autocorrelação até a ordem 1; Ha: há autocorrelação de ordem 1 (qui-quadrado, 1 gl)"
  )

if (nrow(autocorrelacao) != 29L) stop("A análise devia cobrir 29 municípios.", call. = FALSE)

resumo <- autocorrelacao |>
  dplyr::summarise(
    municipios = dplyr::n(),
    durbin_watson_mediano = signif(stats::median(durbin_watson), 4),
    rho_auxiliar_mediano = signif(stats::median(rho_auxiliar), 4),
    dw_positiva = sum(grepl("^positiva", decisao_dw_tabela)),
    dw_inconclusiva = sum(decisao_dw_tabela == "inconclusiva"),
    dw_nao_rejeita = sum(decisao_dw_tabela == "não rejeita H0"),
    dw_negativa = sum(grepl("^negativa", decisao_dw_tabela)),
    breusch_godfrey_rejeita = sum(breusch_godfrey_decisao == "rejeita H0")
  )

readr::write_csv(autocorrelacao, file.path(DIR_RESULTADOS, "autocorrelacao_por_municipio.csv"))
readr::write_csv(resumo, file.path(DIR_RESULTADOS, "autocorrelacao_resumo.csv"))

# -----------------------------------------------------------------------------
# 2. Figura: resíduo contra resíduo defasado, dentro de cada município
# -----------------------------------------------------------------------------
pares <- painel |>
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
ggplot2::ggsave(file.path(DIR_FIGURAS, "diag3_residuos_defasados.png"), g, width = 7, height = 5, dpi = 200, bg = "white")

# -----------------------------------------------------------------------------
# 3. Heterogeneidade entre municípios (o modelo empilhado não tem termo de município)
# -----------------------------------------------------------------------------
por_municipio <- painel |>
  dplyr::group_split(id_municipio) |>
  purrr::map_dfr(function(df) {
    df <- dplyr::arrange(df, ano)
    e <- df$residuo
    ec <- e - mean(e)
    tibble::tibble(
      id_municipio = df$id_municipio[1], nome_municipio = df$nome_municipio[1],
      residuo_medio = mean(e), todos_mesmo_sinal = all(e > 0) || all(e < 0),
      durbin_watson = sum(diff(e)^2) / sum(e^2),
      durbin_watson_centrado = sum(diff(ec)^2) / sum(ec^2)
    )
  }) |>
  dplyr::mutate(decisao_dw = decidir_dw(durbin_watson), decisao_dw_centrado = decidir_dw(durbin_watson_centrado))

soma_entre <- sum(10 * por_municipio$residuo_medio^2)
resumo_heterogeneidade <- tibble::tibble(
  durbin_watson_mediano = stats::median(por_municipio$durbin_watson),
  durbin_watson_centrado_mediano = stats::median(por_municipio$durbin_watson_centrado),
  abaixo_dl = sum(por_municipio$durbin_watson < DW_DL),
  abaixo_dl_centrado = sum(por_municipio$durbin_watson_centrado < DW_DL),
  municipios_mesmo_sinal = sum(por_municipio$todos_mesmo_sinal),
  parcela_soma_quadrados_entre_municipios = soma_entre / sum(painel$residuo^2)
)
readr::write_csv(por_municipio, file.path(DIR_RESULTADOS, "autocorrelacao_heterogeneidade_municipios.csv"))
readr::write_csv(resumo_heterogeneidade, file.path(DIR_RESULTADOS, "autocorrelacao_heterogeneidade_resumo.csv"))

message("Etapa 5 concluída: Durbin-Watson e Breusch-Godfrey por município gravados.")
print(resumo, row.names = FALSE)
print(resumo_heterogeneidade, row.names = FALSE)
