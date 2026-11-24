# =============================================================================
# Tratamento dos dados brutos e construção do painel
# Salário médio real formal nos 29 municípios da Região Metropolitana de
# Curitiba, 2012 a 2021 (290 observações).
#
# Lê:    ./dados_brutos/pib_sidra.rds, macro_bacen.rds, rais.rds, distancias.rds
# Grava: ./dados_processados/dados_painel_rmc.rds e .csv
#        ./dados_processados/estatisticas_descritivas.csv
#        ./dados_processados/matriz_correlacao_explicativas.csv
#
# Variáveis:
#   Y  salário médio real: remuneração média nominal da RAIS multiplicada pelo
#      fator de deflação (índice acumulado do IPCA, série 433, média dos 12
#      meses do ano, com base em 2021), em reais de 2021.
#   X2 vínculos ativos com ensino superior completo sobre vínculos ativos com
#      escolaridade informada, em % (0 a 100).
#   X3 valor adicionado bruto da indústria sobre o valor adicionado bruto total,
#      em %.
#   X4 Gini da participação dos vínculos ativos entre as 87 divisões da CNAE,
#      com zeros incluídos (fórmula da aula sobre medidas de desigualdade).
#   X5 Selic real anual pela equação de Fisher, com Selic (série 4390) e IPCA
#      (série 433) compostos a partir dos valores mensais.
#   X6 distância, em km, entre o centroide do município e o de Curitiba, em
#      SIRGAS 2000 / UTM 22S (EPSG 31982).
# =============================================================================

biblioteca_usuario <- Sys.getenv("R_LIBS_USER")
if (!nzchar(biblioteca_usuario)) {
  biblioteca_usuario <- file.path(
    Sys.getenv("LOCALAPPDATA"), "R", "win-library",
    paste(R.version$major, strsplit(R.version$minor, ".", fixed = TRUE)[[1]][1], sep = ".")
  )
}
if (dir.exists(biblioteca_usuario)) {
  .libPaths(c(biblioteca_usuario, .libPaths()))
}

pacotes_necessarios <- c("dplyr", "tidyr", "purrr", "readr", "tibble", "stringr", "stats")
pacotes_ausentes <- pacotes_necessarios[
  !vapply(pacotes_necessarios, requireNamespace, logical(1), quietly = TRUE)
]
if (length(pacotes_ausentes) > 0) {
  stop("Pacotes ausentes: ", paste(pacotes_ausentes, collapse = ", "),
       ". Instale-os antes de rodar a Etapa 2 (o script 01 instala os do tidyverse).")
}

invisible(lapply(c("tibble", "stringr", "readr", "purrr", "tidyr", "dplyr"), function(p) {
  suppressPackageStartupMessages(library(p, character.only = TRUE))
}))


# -----------------------------------------------------------------------------
# 2. Parâmetros
# -----------------------------------------------------------------------------
DIR_BRUTOS      <- "./dados_brutos"
DIR_PROCESSADOS <- "./dados_processados"
ANOS            <- 2012:2021
N_MUNICIPIOS    <- 29L
LINHAS_PAINEL   <- N_MUNICIPIOS * length(ANOS)
COD_CURITIBA    <- "4106902"
COD_ARAUCARIA   <- "4101804"
TOLERANCIA_VAB  <- 5   # mil reais, para as identidades contábeis do PIB

MUNICIPIOS_RMC <- tibble::tribble(
  ~id_municipio, ~nome_canonico,
  "4100202", "Adrianópolis",
  "4100301", "Agudos do Sul",
  "4100400", "Almirante Tamandaré",
  "4101804", "Araucária",
  "4102307", "Balsa Nova",
  "4103107", "Bocaiúva do Sul",
  "4104006", "Campina Grande do Sul",
  "4104105", "Campo do Tenente",
  "4104204", "Campo Largo",
  "4104253", "Campo Magro",
  "4105201", "Cerro Azul",
  "4105805", "Colombo",
  "4106209", "Contenda",
  "4106902", "Curitiba",
  "4107652", "Fazenda Rio Grande",
  "4111258", "Itaperuçu",
  "4113205", "Lapa",
  "4114302", "Mandirituba",
  "4119103", "Piên",
  "4119152", "Pinhais",
  "4119509", "Piraquara",
  "4120804", "Quatro Barras",
  "4121208", "Quitandinha",
  "4122206", "Rio Branco do Sul",
  "4122305", "Rio Negro",
  "4125506", "São José dos Pinhais",
  "4127601", "Tijucas do Sul",
  "4127882", "Tunas do Paraná",
  "4128633", "Doutor Ulysses"
)
stopifnot(nrow(MUNICIPIOS_RMC) == N_MUNICIPIOS,
          !anyDuplicated(MUNICIPIOS_RMC$id_municipio))


# -----------------------------------------------------------------------------
# 3. Funções auxiliares
# -----------------------------------------------------------------------------
# Leitura de um .rds bruto com mensagem clara se o arquivo faltar ou falhar.
ler_bruto <- function(nome_arquivo) {
  caminho <- file.path(DIR_BRUTOS, nome_arquivo)
  tryCatch({
    if (!file.exists(caminho)) {
      stop("arquivo não encontrado. Rode antes a Etapa 1 (R/01_extracao_dados.R).")
    }
    readRDS(caminho)
  }, error = function(e) {
    stop("Falha ao ler ", caminho, ": ", conditionMessage(e), call. = FALSE)
  })
}

# Conversão forçada para numérico; texto não conversível vira NA e é relatado.
forcar_numerico <- function(x) {
  if (is.numeric(x)) return(as.numeric(x))
  suppressWarnings(as.numeric(as.character(x)))
}

# Código IBGE sempre como texto de 7 dígitos.
padronizar_codigo <- function(x) {
  codigo <- stringr::str_pad(stringr::str_trim(as.character(x)), 7, pad = "0")
  if (any(!stringr::str_detect(codigo, "^[0-9]{7}$"), na.rm = FALSE)) {
    stop("Há códigos de município que não têm 7 dígitos numéricos.")
  }
  codigo
}

validar_tabela <- function(df, rotulo, linhas_esperadas = NULL,
                           colunas_obrigatorias = character(),
                           colunas_economicas = character()) {
  df <- tibble::as_tibble(df)
  ausentes <- setdiff(c(colunas_obrigatorias, colunas_economicas), names(df))
  if (length(ausentes) > 0) {
    stop(rotulo, ": colunas ausentes: ", paste(ausentes, collapse = ", "))
  }
  df <- df |>
    dplyr::mutate(dplyr::across(dplyr::all_of(colunas_economicas), forcar_numerico))

  if (!is.null(linhas_esperadas) && nrow(df) != linhas_esperadas) {
    stop(rotulo, ": dimensão inesperada. Esperadas ", linhas_esperadas,
         " linhas, obtidas ", nrow(df), ".")
  }

  message("Validação de ", rotulo, ": ", nrow(df), " linhas e ", ncol(df), " colunas",
          if (!is.null(linhas_esperadas)) " (dimensão conferida)." else ".")
  relatorio <- purrr::imap_chr(df, function(coluna, nome) {
    n_nan <- if (is.numeric(coluna)) sum(is.nan(coluna)) else 0L
    n_na  <- sum(is.na(coluna)) - n_nan
    n_inf <- if (is.numeric(coluna)) sum(is.infinite(coluna)) else 0L
    sprintf("  %-28s NA = %d | NaN = %d | Inf = %d", nome, n_na, n_nan, n_inf)
  })
  message(paste(relatorio, collapse = "\n"))

  problemas <- purrr::map_lgl(df, function(coluna) {
    any(is.na(coluna)) || (is.numeric(coluna) && any(is.infinite(coluna)))
  })
  if (any(problemas)) {
    warning(rotulo, ": há NA, NaN ou Inf nas colunas ",
            paste(names(df)[problemas], collapse = ", "), ". Confira o relatório acima.",
            call. = FALSE)
  }
  df
}

# Confere que a tabela municipal cobre exatamente os 29 municípios e os 10 anos.
conferir_grade <- function(df, rotulo) {
  if (!setequal(unique(df$id_municipio), MUNICIPIOS_RMC$id_municipio)) {
    stop(rotulo, ": os municípios não coincidem com a lista canônica dos 29 da RMC.")
  }
  if (!setequal(unique(df$ano), ANOS)) {
    stop(rotulo, ": os anos (", paste(sort(unique(df$ano)), collapse = ", "),
         ") diferem de ", min(ANOS), " a ", max(ANOS), ".")
  }
  if (anyDuplicated(df[c("id_municipio", "ano")]) > 0) {
    stop(rotulo, ": há pares município e ano duplicados.")
  }
  invisible(TRUE)
}


# -----------------------------------------------------------------------------
# 4. Tratamento macroeconômico: Selic real (X5) e deflator
# -----------------------------------------------------------------------------
tratar_dados_macro <- function(dados_bacen_raw) {
  if (!is.list(dados_bacen_raw) || !"anual" %in% names(dados_bacen_raw)) {
    stop("macro_bacen.rds: a lista não contém o elemento 'anual'.")
  }
  anual <- validar_tabela(
    dados_bacen_raw$anual, "macro_bacen$anual (bruto)",
    linhas_esperadas = length(ANOS),
    colunas_obrigatorias = "ano",
    colunas_economicas = c("selic_ano", "ipca_ano", "indice_ipca_medio")
  ) |>
    dplyr::mutate(ano = as.integer(ano))

  if (!setequal(anual$ano, ANOS) || anyDuplicated(anual$ano) > 0) {
    stop("macro_bacen$anual: os anos não são exatamente ", min(ANOS), " a ", max(ANOS), ".")
  }

  indice_base <- anual |> dplyr::filter(ano == max(ANOS)) |> dplyr::pull(indice_ipca_medio)
  if (length(indice_base) != 1 || !is.finite(indice_base) || indice_base <= 0) {
    stop("macro_bacen$anual: índice médio do IPCA de ", max(ANOS), " inválido.")
  }

  df_macro <- anual |>
    dplyr::transmute(
      ano,
      selic_nominal_ano = selic_ano,
      ipca_ano,
      indice_ipca_medio,
      # Fator que leva valores nominais do ano a reais do último ano da amostra.
      fator_deflacao    = indice_base / indice_ipca_medio,
      # Equação de Fisher ex post, em % ao ano.
      selic_real        = ((1 + selic_ano / 100) / (1 + ipca_ano / 100) - 1) * 100
    ) |>
    dplyr::arrange(ano)

  validar_tabela(df_macro, "macro tratado", linhas_esperadas = length(ANOS),
                 colunas_economicas = c("selic_nominal_ano", "ipca_ano", "indice_ipca_medio",
                                        "fator_deflacao", "selic_real"))
}


# -----------------------------------------------------------------------------
# 5. Tratamento do PIB municipal: dominância industrial (X3)
# -----------------------------------------------------------------------------
tratar_dados_pib <- function(dados_sidra_raw) {
  colunas_valor <- c("pib", "impostos_liquidos", "vab_total", "vab_agropecuaria",
                     "vab_industria", "vab_servicos", "vab_adm_publica")
  pib <- validar_tabela(
    dados_sidra_raw, "pib_sidra (bruto)",
    linhas_esperadas = LINHAS_PAINEL,
    colunas_obrigatorias = c("id_municipio", "ano"),
    colunas_economicas = colunas_valor
  ) |>
    dplyr::mutate(id_municipio = padronizar_codigo(id_municipio), ano = as.integer(ano))
  conferir_grade(pib, "pib_sidra")

  pib <- pib |>
    dplyr::mutate(
      vab_total_soma   = vab_agropecuaria + vab_industria + vab_servicos + vab_adm_publica,
      dif_soma_vab     = vab_total_soma - vab_total,
      dif_pib          = (vab_total_soma + impostos_liquidos) - pib
    )

  max_dif_vab <- max(abs(pib$dif_soma_vab))
  max_dif_pib <- max(abs(pib$dif_pib))
  message(sprintf(paste0("Identidades do PIB: |soma dos 4 VAB - vab_total| máximo = %.3f; ",
                         "|VAB + impostos - PIB| máximo = %.3f (tolerância %s mil reais)."),
                  max_dif_vab, max_dif_pib, TOLERANCIA_VAB))
  if (max_dif_vab > TOLERANCIA_VAB) {
    stop("pib_sidra: a soma dos quatro VAB difere de vab_total em mais de ",
         TOLERANCIA_VAB, " mil reais.")
  }
  if (max_dif_pib > TOLERANCIA_VAB) {
    stop("pib_sidra: VAB total mais impostos difere do PIB em mais de ",
         TOLERANCIA_VAB, " mil reais.")
  }
  if (any(pib$vab_total_soma <= 0)) {
    stop("pib_sidra: VAB total não positivo; X3 ficaria indefinida.")
  }

  df_pib <- pib |>
    dplyr::transmute(
      id_municipio, ano, pib, vab_total_soma, vab_industria,
      dom_industrial = 100 * vab_industria / vab_total_soma,
      x3_negativo    = dom_industrial < 0
    ) |>
    dplyr::arrange(id_municipio, ano)

  validar_tabela(df_pib, "PIB tratado", linhas_esperadas = LINHAS_PAINEL,
                 colunas_economicas = c("pib", "vab_total_soma", "vab_industria",
                                        "dom_industrial"))
}


# -----------------------------------------------------------------------------
# 6. Tratamento da RAIS: salário (Y), escolaridade (X2) e Gini setorial (X4)
# -----------------------------------------------------------------------------
tratar_dados_mercado_trabalho <- function(dados_rais_raw) {
  if (!is.list(dados_rais_raw) ||
      !all(c("municipio_ano", "cnae_divisao") %in% names(dados_rais_raw))) {
    stop("rais.rds: a lista não contém 'municipio_ano' e 'cnae_divisao'.")
  }

  mun <- validar_tabela(
    dados_rais_raw$municipio_ano, "rais$municipio_ano (bruto)",
    linhas_esperadas = LINHAS_PAINEL,
    colunas_obrigatorias = c("id_municipio", "ano"),
    colunas_economicas = c("vinculos_ativos", "vinculos_superior", "vinculos_escolaridade_na",
                           "vinculos_remuneracao_valida", "rem_media_nominal")
  ) |>
    dplyr::mutate(id_municipio = padronizar_codigo(id_municipio), ano = as.integer(ano))
  conferir_grade(mun, "rais$municipio_ano")

  cnae <- validar_tabela(
    dados_rais_raw$cnae_divisao, "rais$cnae_divisao (bruto)",
    colunas_obrigatorias = c("id_municipio", "ano", "divisao_cnae"),
    colunas_economicas = "vinculos_ativos"
  ) |>
    dplyr::mutate(id_municipio = padronizar_codigo(id_municipio),
                  ano = as.integer(ano),
                  divisao_cnae = stringr::str_trim(as.character(divisao_cnae)))
  if (any(cnae$vinculos_ativos < 0, na.rm = TRUE)) {
    stop("rais$cnae_divisao: há contagens negativas de vínculos.")
  }

  # Conferência: a soma por divisão bate com o total de vínculos do município e ano.
  conferencia <- cnae |>
    dplyr::group_by(id_municipio, ano) |>
    dplyr::summarise(soma_divisoes = sum(vinculos_ativos), .groups = "drop") |>
    dplyr::full_join(mun |> dplyr::select(id_municipio, ano, vinculos_ativos),
                     by = c("id_municipio", "ano")) |>
    dplyr::filter(is.na(soma_divisoes) | is.na(vinculos_ativos) |
                    soma_divisoes != vinculos_ativos)
  if (nrow(conferencia) > 0) {
    stop("rais: a soma por divisão CNAE diverge de vinculos_ativos em ",
         nrow(conferencia), " pares município e ano.")
  }

  cnae_validos <- cnae |> dplyr::filter(divisao_cnae != "ignorada")
  vinculos_ignorados <- sum(cnae$vinculos_ativos[cnae$divisao_cnae == "ignorada"])
  message("Vínculos com divisão 'ignorada' excluídos do Gini setorial: ", vinculos_ignorados)
  N_DIVISOES_CNAE <- 87L
  s_divisoes <- dplyr::n_distinct(cnae_validos$divisao_cnae)
  message("Divisões CNAE válidas observadas no painel (S): ", s_divisoes)
  if (s_divisoes != 87L) {
    warning("S = ", s_divisoes, " difere de 87 (total oficial da CNAE 2.0, IBGE). ",
            "Verifique se alguma divisão válida não aparece no painel.", call. = FALSE)
  }
  if (s_divisoes < 2) stop("rais$cnae_divisao: menos de duas divisões válidas; o Gini não se aplica.")

  pares_sem_valido <- dplyr::anti_join(
    dplyr::distinct(cnae[, c("id_municipio", "ano")]),
    dplyr::distinct(cnae_validos[, c("id_municipio", "ano")]),
    by = c("id_municipio", "ano")
  )
  if (nrow(pares_sem_valido) > 0) {
    stop("rais: ", nrow(pares_sem_valido), " pares município e ano sem divisão CNAE válida.",
         call. = FALSE)
  }

  # Índice de Gini da participação setorial no emprego do município (concentração).
  # Fórmula ensinada no Guia P2 (questão 3): G = (2 / (n^2 mu)) * soma(i * x_(i)) - 1/n - 1,
  # com x = participação de cada divisão no total de vínculos, ordenada de forma crescente.
  # Como sum(x) = 1, mu = 1/n e a fórmula vira G = (2/n) * soma(i * x_(i)) - (n + 1)/n.
  # As 87 divisões entram com participação zero quando não têm vínculo. Usar n = 87 e tratar
  # as divisões como indivíduos segue a aula de medidas de desigualdade (Hasegawa, 2020) e
  # Hoffmann (2006, cap. 17); o total de 87 divisões da CNAE 2.0 foi conferido no IBGE.
  if (s_divisoes > N_DIVISOES_CNAE) {
    stop("rais: ", s_divisoes, " divisões válidas, acima de ", N_DIVISOES_CNAE, " (CNAE 2.0).", call. = FALSE)
  }
  gini_setorial <- cnae_validos |>
    dplyr::group_by(id_municipio, ano) |>
    dplyr::summarise(
      gini_setorial = {
        x <- sort(vinculos_ativos / sum(vinculos_ativos))
        x <- c(rep(0, N_DIVISOES_CNAE - length(x)), x)
        n_div <- length(x)
        sum((2 / n_div) * seq_len(n_div) * x) - (n_div + 1) / n_div
      },
      .groups = "drop"
    )

  denominador_x2 <- mun$vinculos_ativos - mun$vinculos_escolaridade_na
  if (any(denominador_x2 <= 0)) {
    stop("rais: há município e ano sem nenhum vínculo com escolaridade informada.")
  }
  if (any(mun$rem_media_nominal <= 0)) {
    stop("rais: remuneração média nominal não positiva; o logaritmo ficaria indefinido.")
  }

  df_rais <- mun |>
    dplyr::transmute(
      id_municipio, ano,
      salario_medio_nominal = rem_media_nominal,
      prop_superior = 100 * vinculos_superior / (vinculos_ativos - vinculos_escolaridade_na),
      vinculos_ativos, vinculos_superior, vinculos_escolaridade_na
    ) |>
    dplyr::left_join(gini_setorial, by = c("id_municipio", "ano")) |>
    dplyr::arrange(id_municipio, ano)

  attr(df_rais, "s_divisoes") <- s_divisoes
  df_rais_validado <- validar_tabela(
    df_rais, "RAIS tratada", linhas_esperadas = LINHAS_PAINEL,
    colunas_economicas = c("salario_medio_nominal", "prop_superior", "vinculos_ativos",
                           "vinculos_superior", "vinculos_escolaridade_na",
                           "gini_setorial")
  )
  attr(df_rais_validado, "s_divisoes") <- s_divisoes
  df_rais_validado
}


# -----------------------------------------------------------------------------
# 7. Tratamento espacial: distância a Curitiba (X6)
# -----------------------------------------------------------------------------
tratar_dados_espaciais <- function(dados_geobr_raw) {
  geo <- validar_tabela(
    dados_geobr_raw, "distancias (bruto)",
    linhas_esperadas = N_MUNICIPIOS,
    colunas_obrigatorias = c("id_municipio", "nome_municipio"),
    colunas_economicas = "dist_curitiba_km"
  ) |>
    dplyr::mutate(id_municipio = padronizar_codigo(id_municipio),
                  nome_municipio = as.character(nome_municipio))

  if (!setequal(geo$id_municipio, MUNICIPIOS_RMC$id_municipio) ||
      anyDuplicated(geo$id_municipio) > 0) {
    stop("distancias: os códigos não coincidem com a lista canônica dos 29 da RMC.")
  }

  # Conferência de nome contra a lista canônica, sem distinção de caixa.
  divergentes <- geo |>
    dplyr::inner_join(MUNICIPIOS_RMC, by = "id_municipio") |>
    dplyr::filter(stringr::str_to_lower(stringr::str_squish(nome_municipio)) !=
                    stringr::str_to_lower(nome_canonico))
  if (nrow(divergentes) > 0) {
    stop("distancias: nome divergente da lista canônica para os códigos ",
         paste(divergentes$id_municipio, collapse = ", "), ".")
  }

  geo |>
    dplyr::transmute(
      id_municipio, nome_municipio, dist_curitiba_km
    ) |>
    dplyr::arrange(id_municipio)
}


# -----------------------------------------------------------------------------
# 8. Consolidação do painel mestre
# -----------------------------------------------------------------------------
consolidar_painel_mestre <- function(df_macro, df_pib, df_rais, df_geo) {
  painel <- df_rais |>
    dplyr::inner_join(df_pib, by = c("id_municipio", "ano")) |>
    dplyr::inner_join(df_geo, by = "id_municipio") |>
    dplyr::inner_join(df_macro, by = "ano")

  if (nrow(painel) != LINHAS_PAINEL) {
    stop("Consolidação: o painel tem ", nrow(painel), " linhas, esperadas ",
         LINHAS_PAINEL, ". Alguma junção perdeu ou duplicou observações.")
  }

  painel |>
    dplyr::mutate(
      # Salário em reais do último ano da amostra (2021).
      salario_medio_real = salario_medio_nominal * fator_deflacao,
      ln_salario_real    = log(salario_medio_real)
    ) |>
    dplyr::select(
      id_municipio, nome_municipio, ano,
      salario_medio_nominal, salario_medio_real, ln_salario_real,
      prop_superior, dom_industrial, gini_setorial,
      selic_real, dist_curitiba_km, x3_negativo,
      selic_nominal_ano, ipca_ano, indice_ipca_medio,
      vinculos_ativos, vinculos_superior, vinculos_escolaridade_na,
      pib, vab_total_soma, vab_industria
    ) |>
    dplyr::mutate(id_municipio = as.character(id_municipio), ano = as.integer(ano)) |>
    dplyr::arrange(id_municipio, ano)
}


# -----------------------------------------------------------------------------
# 9. Auditoria do painel
# -----------------------------------------------------------------------------
# stop() para falha estrutural; warning() para achado de conteúdo.
auditar_painel <- function(df_painel) {
  message("\n==== Auditoria do painel ====")

  # 9.1 Balanceamento estrito.
  if (nrow(df_painel) != LINHAS_PAINEL) {
    stop("Painel com ", nrow(df_painel), " linhas; esperadas ", LINHAS_PAINEL, ".")
  }
  if (dplyr::n_distinct(df_painel$id_municipio) != N_MUNICIPIOS) {
    stop("Painel com ", dplyr::n_distinct(df_painel$id_municipio),
         " municípios; esperados ", N_MUNICIPIOS, ".")
  }
  if (anyDuplicated(df_painel[c("id_municipio", "ano")]) > 0) {
    stop("Painel com pares município e ano duplicados.")
  }
  grade_anos <- df_painel |>
    dplyr::group_by(id_municipio) |>
    dplyr::summarise(anos = paste(sort(ano), collapse = ","), .groups = "drop")
  if (dplyr::n_distinct(grade_anos$anos) != 1 ||
      grade_anos$anos[1] != paste(ANOS, collapse = ",")) {
    stop("Painel desbalanceado: os municípios não têm a mesma grade de anos ",
         min(ANOS), " a ", max(ANOS), ".")
  }
  if (!all(stringr::str_detect(df_painel$id_municipio, "^[0-9]{7}$"))) {
    stop("id_municipio fora do formato de 7 dígitos.")
  }
  message("[OK] Painel estritamente balanceado: ", N_MUNICIPIOS, " municípios x ",
          length(ANOS), " anos = ", nrow(df_painel), " linhas, sem duplicatas.")

  # 9.2 NA, NaN e Inf por coluna.
  message("\nRelatório de NA, NaN e Inf por coluna:")
  relatorio <- purrr::imap_chr(df_painel, function(coluna, nome) {
    n_nan <- if (is.numeric(coluna)) sum(is.nan(coluna)) else 0L
    n_na  <- sum(is.na(coluna)) - n_nan
    n_inf <- if (is.numeric(coluna)) sum(is.infinite(coluna)) else 0L
    sprintf("  %-28s NA = %d | NaN = %d | Inf = %d", nome, n_na, n_nan, n_inf)
  })
  message(paste(relatorio, collapse = "\n"))
  com_problema <- purrr::map_lgl(df_painel, function(coluna) {
    any(is.na(coluna)) || (is.numeric(coluna) && any(is.infinite(coluna)))
  })
  if (any(com_problema)) {
    warning("Painel: há NA, NaN ou Inf em ",
            paste(names(df_painel)[com_problema], collapse = ", "), ".", call. = FALSE)
  } else {
    message("[OK] Nenhum NA, NaN ou Inf no painel.")
  }

  # 9.3 Percentuais fora de 0 a 100 em X2 e X3.
  fora_faixa <- df_painel |>
    dplyr::select(id_municipio, nome_municipio, ano, prop_superior, dom_industrial) |>
    tidyr::pivot_longer(c(prop_superior, dom_industrial),
                        names_to = "variavel", values_to = "valor") |>
    dplyr::filter(valor < 0 | valor > 100)
  if (nrow(fora_faixa) > 0) {
    message("\nObservações de X2 ou X3 fora de 0 a 100:")
    message(paste(sprintf("  %s %-22s %d %-15s %.4f",
                          fora_faixa$id_municipio, fora_faixa$nome_municipio,
                          fora_faixa$ano, fora_faixa$variavel, fora_faixa$valor),
                  collapse = "\n"))
    esperado <- tibble::tibble(id_municipio = COD_ARAUCARIA, ano = c(2012L, 2013L),
                               variavel = "dom_industrial")
    inesperados <- dplyr::anti_join(fora_faixa, esperado,
                                    by = c("id_municipio", "ano", "variavel"))
    if (nrow(inesperados) > 0) {
      warning(nrow(inesperados), " observação(ões) de X2 ou X3 fora de 0 a 100 além de ",
              "Araucária 2012 e 2013. Confira a lista acima.", call. = FALSE)
    } else {
      message("[OK] Fora da faixa só Araucária em X3 (valor adicionado da indústria negativo na fonte, em 2012 e 2013).")
    }
  } else {
    message("[OK] X2 e X3 dentro de 0 a 100 em todas as observações.")
  }
  marcados <- df_painel |> dplyr::filter(x3_negativo)
  esperado_marcado <- nrow(marcados) == 2 &&
    all(marcados$id_municipio == COD_ARAUCARIA) &&
    setequal(marcados$ano, c(2012L, 2013L))
  if (esperado_marcado) {
    message("[OK] x3_negativo = TRUE só em Araucária 2012 e 2013.")
  } else {
    warning("x3_negativo marca observações diferentes de Araucária 2012 e 2013: ",
            paste(marcados$id_municipio, marcados$ano, collapse = "; "), call. = FALSE)
  }

  # 9.4 Gini setorial entre 0 e 1.
  fora_gini <- df_painel |>
    dplyr::filter(gini_setorial < 0 | gini_setorial > 1)
  if (nrow(fora_gini) > 0) {
    warning(nrow(fora_gini), " observação(ões) com gini_setorial fora de 0 a 1.", call. = FALSE)
  } else {
    message(sprintf("[OK] gini_setorial entre 0 e 1 (mínimo %.4f, máximo %.4f).",
                    min(df_painel$gini_setorial), max(df_painel$gini_setorial)))
  }

  # 9.5 Selic real constante entre municípios em cada ano.
  selic_variavel <- df_painel |>
    dplyr::group_by(ano) |>
    dplyr::summarise(n_valores = dplyr::n_distinct(selic_real), .groups = "drop") |>
    dplyr::filter(n_valores != 1)
  if (nrow(selic_variavel) > 0) {
    stop("selic_real varia entre municípios nos anos ",
         paste(selic_variavel$ano, collapse = ", "), ".")
  }
  message("[OK] selic_real constante entre municípios em cada ano.")

  # 9.6 Distância constante no tempo por município.
  dist_variavel <- df_painel |>
    dplyr::group_by(id_municipio) |>
    dplyr::summarise(n_valores = dplyr::n_distinct(dist_curitiba_km), .groups = "drop") |>
    dplyr::filter(n_valores != 1)
  if (nrow(dist_variavel) > 0) {
    stop("dist_curitiba_km varia no tempo para ",
         paste(dist_variavel$id_municipio, collapse = ", "), ".")
  }
  message("[OK] dist_curitiba_km constante no tempo em cada município.")

  # 9.7 Curitiba com distância zero.
  curitiba <- df_painel |> dplyr::filter(id_municipio == COD_CURITIBA)
  if (nrow(curitiba) != length(ANOS) || any(curitiba$dist_curitiba_km != 0)) {
    stop("Curitiba (", COD_CURITIBA, ") ausente ou com distância diferente de zero.")
  }
  message("[OK] Curitiba com distância 0.")

  invisible(df_painel)
}


# -----------------------------------------------------------------------------
# 10. Estatísticas descritivas e correlação
# -----------------------------------------------------------------------------
VARIAVEIS_MODELO <- c("salario_medio_real", "ln_salario_real", "prop_superior",
                      "dom_industrial", "gini_setorial",
                      "selic_real", "dist_curitiba_km")
VARIAVEIS_EXPLICATIVAS <- c("prop_superior", "dom_industrial", "gini_setorial",
                            "selic_real", "dist_curitiba_km")

gerar_descritivas <- function(df_painel) {
  df_painel |>
    dplyr::select(dplyr::all_of(VARIAVEIS_MODELO)) |>
    tidyr::pivot_longer(dplyr::everything(), names_to = "variavel", values_to = "valor") |>
    dplyr::group_by(variavel) |>
    dplyr::summarise(
      n             = dplyr::n(),
      media         = mean(valor),
      desvio_padrao = stats::sd(valor),
      mediana       = stats::median(valor),
      minimo        = min(valor),
      maximo        = max(valor),
      .groups = "drop"
    ) |>
    dplyr::mutate(variavel = factor(variavel, levels = VARIAVEIS_MODELO)) |>
    dplyr::arrange(variavel) |>
    dplyr::mutate(variavel = as.character(variavel))
}

gerar_correlacao <- function(df_painel) {
  df_painel |>
    dplyr::select(dplyr::all_of(VARIAVEIS_EXPLICATIVAS)) |>
    stats::cor(method = "pearson")
}


# -----------------------------------------------------------------------------
# 11. Execução
# -----------------------------------------------------------------------------
executar_etapa_2 <- function() {
  message("Etapa 2: leitura dos dados brutos em ", normalizePath(DIR_BRUTOS, mustWork = FALSE))
  pib_raw   <- ler_bruto("pib_sidra.rds")
  macro_raw <- ler_bruto("macro_bacen.rds")
  rais_raw  <- ler_bruto("rais.rds")
  dist_raw  <- ler_bruto("distancias.rds")

  df_macro <- tratar_dados_macro(macro_raw)
  df_pib   <- tratar_dados_pib(pib_raw)
  df_rais  <- tratar_dados_mercado_trabalho(rais_raw)
  df_geo   <- tratar_dados_espaciais(dist_raw)

  painel <- consolidar_painel_mestre(df_macro, df_pib, df_rais, df_geo)
  auditar_painel(painel)

  if (!dir.exists(DIR_PROCESSADOS)) dir.create(DIR_PROCESSADOS, recursive = TRUE)
  caminho_rds <- file.path(DIR_PROCESSADOS, "dados_painel_rmc.rds")
  caminho_csv <- file.path(DIR_PROCESSADOS, "dados_painel_rmc.csv")
  tryCatch({
    saveRDS(painel, caminho_rds)
    readr::write_csv(painel, caminho_csv, na = "")
  }, error = function(e) {
    stop("Falha ao gravar o painel: ", conditionMessage(e), call. = FALSE)
  })
  message("\nPainel gravado em ", caminho_rds, " e ", caminho_csv, ".")

  descritivas <- gerar_descritivas(painel)
  correlacao  <- gerar_correlacao(painel)

  message("\n==== Estatísticas descritivas das variáveis do modelo ====")
  print(as.data.frame(descritivas |>
                        dplyr::mutate(dplyr::across(where(is.numeric), ~ round(.x, 4)))),
        row.names = FALSE)
  message("\n==== Matriz de correlação de Pearson entre X2 e X6 ====")
  print(round(correlacao, 4))

  caminho_desc <- file.path(DIR_PROCESSADOS, "estatisticas_descritivas.csv")
  caminho_cor  <- file.path(DIR_PROCESSADOS, "matriz_correlacao_explicativas.csv")
  tryCatch({
    readr::write_csv(descritivas, caminho_desc)
    readr::write_csv(tibble::as_tibble(correlacao, rownames = "variavel"), caminho_cor)
  }, error = function(e) {
    stop("Falha ao gravar descritivas ou correlação: ", conditionMessage(e), call. = FALSE)
  })
  message("\nDescritivas e correlação gravadas em ", caminho_desc, " e ", caminho_cor, ".")
  message("Etapa 2 concluída.")

  invisible(list(painel = painel, descritivas = descritivas, correlacao = correlacao))
}

resultado_etapa_2 <- executar_etapa_2()
