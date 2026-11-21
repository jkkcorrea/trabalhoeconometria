# =============================================================================
# Extração de dados: painel da Região Metropolitana de Curitiba, 2012 a 2021
#
# Fontes: SIDRA/IBGE (PIB municipal e valor adicionado por setor), SGS do Banco
# Central (séries 4390 e 433), malha municipal do IBGE e microdados da RAIS
# (Ministério do Trabalho).
# Grava em ./dados_brutos: pib_sidra.rds, macro_bacen.rds, malha_rmc.rds,
# distancias.rds e rais.rds (com um arquivo rais_AAAA.rds por ano).
# Os arquivos já acompanham a pasta dados_brutos/; este script só precisa ser
# executado para refazer a coleta (a RAIS exige o download de cerca de 3,5 GB).
# =============================================================================

if (!dir.exists("R")) {
  stop(
    "O diretório de trabalho atual (", getwd(), ") não é a raiz do projeto. ",
    "Use setwd() ou abra o projeto no RStudio de modo que a pasta R/ ",
    "fique visível no diretório de trabalho."
  )
}


biblioteca_usuario <- Sys.getenv("R_LIBS_USER")
if (!nzchar(biblioteca_usuario)) {
  base_usuario <- if (nzchar(Sys.getenv("LOCALAPPDATA"))) {
    file.path(Sys.getenv("LOCALAPPDATA"), "R", "win-library")
  } else {
    file.path(Sys.getenv("HOME"), "R", "library")
  }
  biblioteca_usuario <- file.path(
    base_usuario,
    paste(R.version$major, strsplit(R.version$minor, ".", fixed = TRUE)[[1]][1], sep = ".")
  )
}
if (!dir.exists(biblioteca_usuario)) {
  dir.create(biblioteca_usuario, recursive = TRUE, showWarnings = FALSE)
}
.libPaths(c(biblioteca_usuario, .libPaths()))

pacotes_necessarios <- c(
  "dplyr", "tidyr", "purrr", "readr", "stringr", "tibble", "lubridate", "fs",
  "sidrar", "rbcb", "geobr", "sf", "archive", "data.table"
)

pacotes_faltantes <- pacotes_necessarios[
  !vapply(pacotes_necessarios, requireNamespace, logical(1), quietly = TRUE)
]

if (length(pacotes_faltantes) > 0) {
  message("Instalando pacotes ausentes em ", biblioteca_usuario, ": ",
          paste(pacotes_faltantes, collapse = ", "))
  utils::install.packages(
    pacotes_faltantes,
    lib = biblioteca_usuario,
    repos = "https://cloud.r-project.org",
    dependencies = c("Depends", "Imports", "LinkingTo")
  )
}

pacotes_ainda_ausentes <- pacotes_necessarios[
  !vapply(pacotes_necessarios, requireNamespace, logical(1), quietly = TRUE)
]
if (length(pacotes_ainda_ausentes) > 0) {
  stop("Pacotes não instalados: ", paste(pacotes_ainda_ausentes, collapse = ", "),
       ". Confira a conexão com a internet e a mensagem do install.packages().")
}

pacotes_carregados <- c("sf", "geobr", "sidrar", "rbcb", "fs", "lubridate",
                        "tibble", "stringr", "readr", "purrr", "tidyr", "dplyr")
invisible(lapply(pacotes_carregados, function(p) {
  suppressPackageStartupMessages(library(p, character.only = TRUE))
}))


# -----------------------------------------------------------------------------
# 2. Parâmetros
# -----------------------------------------------------------------------------
options(timeout = 3600)

ANOS_PADRAO <- 2012:2021

DIR_BRUTOS     <- "./dados_brutos"
DIR_CACHE_RAIS <- Sys.getenv(
  "TRABALHO_ECONOMETRIA_CACHE",
  unset = if (nzchar(Sys.getenv("LOCALAPPDATA"))) {
    file.path(Sys.getenv("LOCALAPPDATA"), "trabalho_econometria_rais")
  } else {
    file.path(Sys.getenv("HOME"), ".cache", "trabalho_econometria_rais")
  }
)
URL_BASE_RAIS  <- "ftp://ftp.mtps.gov.br/pdet/microdados/RAIS/"

fs::dir_create(DIR_BRUTOS)
fs::dir_create(DIR_CACHE_RAIS)

MUNICIPIOS_RMC <- tibble::tribble(
  ~id_municipio, ~nome_municipio,
  "4100202", "Adrian\u00f3polis",
  "4100301", "Agudos do Sul",
  "4100400", "Almirante Tamandar\u00e9",
  "4101804", "Arauc\u00e1ria",
  "4102307", "Balsa Nova",
  "4103107", "Bocai\u00fava do Sul",
  "4104006", "Campina Grande do Sul",
  "4104105", "Campo do Tenente",
  "4104204", "Campo Largo",
  "4104253", "Campo Magro",
  "4105201", "Cerro Azul",
  "4105805", "Colombo",
  "4106209", "Contenda",
  "4106902", "Curitiba",
  "4107652", "Fazenda Rio Grande",
  "4111258", "Itaperu\u00e7u",
  "4113205", "Lapa",
  "4114302", "Mandirituba",
  "4119103", "Pi\u00ean",
  "4119152", "Pinhais",
  "4119509", "Piraquara",
  "4120804", "Quatro Barras",
  "4121208", "Quitandinha",
  "4122206", "Rio Branco do Sul",
  "4122305", "Rio Negro",
  "4125506", "S\u00e3o Jos\u00e9 dos Pinhais",
  "4127601", "Tijucas do Sul",
  "4127882", "Tunas do Paran\u00e1",
  "4128633", "Doutor Ulysses"
)

COD_CURITIBA <- "4106902"

stopifnot(
  nrow(MUNICIPIOS_RMC) == 29,
  dplyr::n_distinct(MUNICIPIOS_RMC$id_municipio) == 29,
  all(grepl("^41[0-9]{5}$", MUNICIPIOS_RMC$id_municipio))
)

VARIAVEIS_PIB <- tibble::tribble(
  ~codigo, ~coluna,             ~fragmento,
  "37",    "pib",               "produto interno bruto",
  "543",   "impostos_liquidos", "impostos liquidos de subsidios",
  "498",   "vab_total",         "valor adicionado bruto a precos correntes total",
  "513",   "vab_agropecuaria",  "agropecuaria",
  "517",   "vab_industria",     "industria",
  "6575",  "vab_servicos",      "servicos exclusive administracao",
  "525",   "vab_adm_publica",   "administracao defesa educacao e saude publicas"
)

TAMANHO_RAIS_MB <- c(
  "2012" = 106, "2013" = 108, "2014" = 109, "2015" = 176, "2016" = 182,
  "2017" = 177, "2018" = 495, "2019" = 495, "2020" = 495, "2021" = 495,
  "2022" = 495
)


# -----------------------------------------------------------------------------
# 3. Funções auxiliares
# -----------------------------------------------------------------------------

normalizar_texto <- function(x) {
  x <- enc2utf8(as.character(x))
  com_acento <- paste0(
    "\u00e1\u00e0\u00e2\u00e3\u00e4\u00e9\u00e8\u00ea\u00eb\u00ed\u00ec\u00ee",
    "\u00ef\u00f3\u00f2\u00f4\u00f5\u00f6\u00fa\u00f9\u00fb\u00fc\u00e7\u00f1",
    "\u00c1\u00c0\u00c2\u00c3\u00c4\u00c9\u00c8\u00ca\u00cb\u00cd\u00cc\u00ce",
    "\u00cf\u00d3\u00d2\u00d4\u00d5\u00d6\u00da\u00d9\u00db\u00dc\u00c7\u00d1"
  )
  sem_acento <- paste0(
    "aaaaaeeeeiii", "iooooouuuucn",
    "AAAAAEEEEIII", "IOOOOOUUUUCN"
  )
  x <- chartr(com_acento, sem_acento, x)
  x <- tolower(x)
  x <- gsub("[^a-z0-9]+", " ", x)
  trimws(x)
}

converter_numero_br <- function(x) {
  if (is.numeric(x)) return(as.numeric(x))
  x <- trimws(as.character(x))
  com_virgula <- grepl(",", x, fixed = TRUE)
  x[com_virgula] <- gsub(",", ".", gsub(".", "", x[com_virgula], fixed = TRUE), fixed = TRUE)
  numero <- suppressWarnings(as.numeric(x))
  n_falhas <- sum(is.na(numero) & !is.na(x) & nzchar(x))
  if (n_falhas > 0) {
    warning(n_falhas, " valor(es) não vazio(s) não puderam ser convertidos em número e viraram NA.")
  }
  numero
}

validar_anos <- function(anos, minimo, maximo, rotulo) {
  if (length(anos) == 0 || any(is.na(anos)) || any(anos != round(anos))) {
    stop(rotulo, ": o vetor de anos deve conter apenas números inteiros.")
  }
  anos <- sort(unique(as.integer(anos)))
  if (!identical(anos, seq(min(anos), max(anos)))) {
    stop(rotulo, ": os anos devem formar uma sequência contínua.")
  }
  if (min(anos) < minimo || max(anos) > maximo) {
    stop(rotulo, ": anos fora da faixa coberta (", minimo, " a ", maximo, ").")
  }
  anos
}

validar_tabela <- function(df, rotulo, linhas_esperadas = NULL, colunas_economicas = character()) {
  if (inherits(df, "sf")) df <- sf::st_drop_geometry(df)
  df <- tibble::as_tibble(df)

  ausentes <- setdiff(colunas_economicas, names(df))
  if (length(ausentes) > 0) {
    stop(rotulo, ": colunas econômicas ausentes: ", paste(ausentes, collapse = ", "))
  }
  df <- df |>
    dplyr::mutate(dplyr::across(dplyr::all_of(colunas_economicas), converter_numero_br))
  nao_numericas <- colunas_economicas[!vapply(df[colunas_economicas], is.numeric, logical(1))]
  if (length(nao_numericas) > 0) {
    stop(rotulo, ": colunas que deveriam ser numéricas: ", paste(nao_numericas, collapse = ", "))
  }

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
            paste(names(df)[problemas], collapse = ", "), ". Confira o relatório acima.")
  }
  invisible(df)
}

conferir_anos_cache <- function(anos_cache, anos, caminho) {
  if (!setequal(unique(anos_cache), anos)) {
    stop("O cache ", caminho, " cobre os anos ",
         paste(sort(unique(anos_cache)), collapse = ", "),
         ", diferentes dos pedidos (", paste(anos, collapse = ", "), "). ",
         "Apague o arquivo manualmente se quiser refazer a consulta.")
  }
  invisible(TRUE)
}


# -----------------------------------------------------------------------------
# 4. PIB municipal: SIDRA, tabela 5938
# -----------------------------------------------------------------------------
get_pib_sidra <- function(cod_municipios, anos) {
  anos <- validar_anos(anos, 2002, 2023, "PIB SIDRA")
  cod_municipios <- as.character(cod_municipios)
  caminho <- file.path(DIR_BRUTOS, "pib_sidra.rds")
  colunas_valor <- VARIAVEIS_PIB$coluna
  linhas_esperadas <- length(cod_municipios) * length(anos)

  if (file.exists(caminho)) {
    message("PIB SIDRA: cache encontrado em ", caminho, "; a API não será consultada.")
    pib <- readRDS(caminho)
    conferir_anos_cache(pib$ano, anos, caminho)
    return(validar_tabela(pib, "PIB SIDRA", linhas_esperadas, colunas_valor))
  }

  caminho_api <- paste0(
    "/t/5938",
    "/n6/", paste(cod_municipios, collapse = ","),
    "/v/", paste(VARIAVEIS_PIB$codigo, collapse = ","),
    "/p/", paste(anos, collapse = ",")
  )
  message("PIB SIDRA: consultando a API (", caminho_api, ").")

  bruto <- tryCatch(
    sidrar::get_sidra(api = caminho_api),
    error = function(e) stop("PIB SIDRA: falha na consulta à API: ", conditionMessage(e))
  )
  bruto <- tibble::as_tibble(bruto)

  nomes_norm <- normalizar_texto(names(bruto))
  localizar <- function(padroes, rotulo) {
    idx <- integer()
    for (padrao in padroes) {
      idx <- grep(padrao, nomes_norm)
      if (length(idx) == 1) break
    }
    if (length(idx) != 1) {
      stop("PIB SIDRA: coluna '", rotulo, "' não localizada de forma única. Colunas devolvidas: ",
           paste(names(bruto), collapse = " | "))
    }
    names(bruto)[idx]
  }
  col_municipio <- localizar("^municipio codigo$", "Município (Código)")
  col_ano       <- localizar(c("^ano codigo$", "^ano$"), "Ano")
  col_var_cod   <- localizar("^variavel codigo$", "Variável (Código)")
  col_var_nome  <- localizar("^variavel$", "Variável")
  col_valor     <- localizar("^valor$", "Valor")

  longo <- bruto |>
    dplyr::transmute(
      id_municipio   = as.character(.data[[col_municipio]]),
      ano            = as.integer(.data[[col_ano]]),
      codigo         = as.character(.data[[col_var_cod]]),
      nome_variavel  = as.character(.data[[col_var_nome]]),
      valor          = converter_numero_br(.data[[col_valor]])
    )

  conferencia <- longo |>
    dplyr::distinct(codigo, nome_variavel) |>
    dplyr::inner_join(VARIAVEIS_PIB, by = "codigo") |>
    dplyr::mutate(confere = stringr::str_detect(normalizar_texto(nome_variavel), stringr::fixed(fragmento)))
  if (!setequal(unique(longo$codigo), VARIAVEIS_PIB$codigo) || !all(conferencia$confere)) {
    print(conferencia)
    stop("PIB SIDRA: as variáveis devolvidas pela API não correspondem às esperadas.")
  }

  if (!setequal(unique(longo$id_municipio), cod_municipios)) {
    stop("PIB SIDRA: municípios devolvidos diferem dos pedidos. Faltam: ",
         paste(setdiff(cod_municipios, longo$id_municipio), collapse = ", "))
  }
  if (!setequal(unique(longo$ano), anos)) {
    stop("PIB SIDRA: anos devolvidos diferem dos pedidos. Faltam: ",
         paste(setdiff(anos, longo$ano), collapse = ", "))
  }

  pib <- longo |>
    dplyr::inner_join(dplyr::select(VARIAVEIS_PIB, codigo, coluna), by = "codigo") |>
    dplyr::select(id_municipio, ano, coluna, valor) |>
    tidyr::pivot_wider(names_from = coluna, values_from = valor) |>
    dplyr::select(id_municipio, ano, dplyr::all_of(colunas_valor)) |>
    dplyr::arrange(id_municipio, ano)

  pib <- validar_tabela(pib, "PIB SIDRA", linhas_esperadas, colunas_valor)
  saveRDS(pib, caminho)
  message("PIB SIDRA: gravado em ", caminho, ".")
  pib
}


# -----------------------------------------------------------------------------
# 5. Selic e IPCA: Banco Central, séries 4390 e 433
# -----------------------------------------------------------------------------
get_macro_bacen <- function(anos) {
  anos <- validar_anos(anos, 1995, as.integer(format(Sys.Date(), "%Y")) - 1L, "Macro Bacen")
  caminho <- file.path(DIR_BRUTOS, "macro_bacen.rds")
  colunas_mensais <- c("selic_mensal", "ipca_mensal", "indice_ipca")
  colunas_anuais  <- c("selic_ano", "ipca_ano", "indice_ipca_medio")

  if (file.exists(caminho)) {
    message("Macro Bacen: cache encontrado em ", caminho, "; a API não será consultada.")
    macro <- readRDS(caminho)
    conferir_anos_cache(macro$anual$ano, anos, caminho)
    macro$mensal <- validar_tabela(macro$mensal, "Macro Bacen (mensal)", 12L * length(anos), colunas_mensais)
    macro$anual  <- validar_tabela(macro$anual, "Macro Bacen (anual)", length(anos), colunas_anuais)
    return(macro)
  }

  data_inicial <- as.Date(sprintf("%d-01-01", min(anos)))
  data_final   <- as.Date(sprintf("%d-12-31", max(anos)))

  baixar_serie <- function(codigo) {
    serie <- tryCatch(
      rbcb::get_series(codigo, start_date = data_inicial, end_date = data_final),
      error = function(e) stop("Macro Bacen: falha ao baixar a série ", codigo, ": ", conditionMessage(e))
    )
    serie <- tibble::as_tibble(serie)
    col_data <- names(serie)[vapply(serie, inherits, logical(1), what = "Date")]
    col_valor <- setdiff(names(serie), col_data)
    if (length(col_data) != 1 || length(col_valor) != 1) {
      stop("Macro Bacen: formato inesperado na série ", codigo, ". Colunas: ",
           paste(names(serie), collapse = " | "))
    }
    tibble::tibble(
      data  = lubridate::floor_date(serie[[col_data]], "month"),
      valor = converter_numero_br(serie[[col_valor]])
    )
  }

  message("Macro Bacen: consultando as séries 4390 e 433 de ", data_inicial, " a ", data_final, ".")
  selic <- baixar_serie(4390) |> dplyr::rename(selic_mensal = valor)
  ipca  <- baixar_serie(433)  |> dplyr::rename(ipca_mensal = valor)

  mensal <- dplyr::full_join(selic, ipca, by = "data") |>
    dplyr::arrange(data) |>
    dplyr::mutate(
      ano = as.integer(lubridate::year(data)),
      mes = as.integer(lubridate::month(data))
    ) |>
    dplyr::filter(ano %in% anos)

  meses_por_ano <- mensal |>
    dplyr::count(ano, name = "n_meses") |>
    tidyr::complete(ano = anos, fill = list(n_meses = 0L))
  if (any(meses_por_ano$n_meses != 12) || anyNA(mensal$selic_mensal) || anyNA(mensal$ipca_mensal)) {
    print(meses_por_ano)
    stop("Macro Bacen: as séries não têm 12 meses completos em todos os anos pedidos.")
  }

  if (any(mensal$selic_mensal < 0 | mensal$selic_mensal > 5)) {
    stop("Macro Bacen: Selic mensal fora da faixa plausível de 0 a 5% ao mês.")
  }
  if (any(mensal$ipca_mensal < -3 | mensal$ipca_mensal > 5)) {
    stop("Macro Bacen: IPCA mensal fora da faixa plausível de -3 a 5% ao mês.")
  }

  mensal <- mensal |>
    dplyr::mutate(
      indice_ipca = 100 * cumprod(c(1, 1 + ipca_mensal[-1] / 100))
    ) |>
    dplyr::select(data, ano, mes, selic_mensal, ipca_mensal, indice_ipca)

  anual <- mensal |>
    dplyr::group_by(ano) |>
    dplyr::summarise(
      selic_ano         = (prod(1 + selic_mensal / 100) - 1) * 100,
      ipca_ano          = (prod(1 + ipca_mensal / 100) - 1) * 100,
      indice_ipca_medio = mean(indice_ipca),
      .groups = "drop"
    ) |>
    dplyr::arrange(ano)

  mensal <- validar_tabela(mensal, "Macro Bacen (mensal)", 12L * length(anos), colunas_mensais)
  anual  <- validar_tabela(anual, "Macro Bacen (anual)", length(anos), colunas_anuais)

  macro <- list(mensal = mensal, anual = anual)
  saveRDS(macro, caminho)
  message("Macro Bacen: gravado em ", caminho, ".")
  macro
}


# -----------------------------------------------------------------------------
# 6. RAIS: microdados de vínculos do Ministério do Trabalho
# -----------------------------------------------------------------------------

baixar_rais_ano <- function(ano) {
  nome_arquivo <- if (ano <= 2017) paste0("PR", ano, ".7z") else "RAIS_VINC_PUB_SUL.7z"
  url <- paste0(URL_BASE_RAIS, ano, "/", nome_arquivo)
  destino <- file.path(DIR_CACHE_RAIS, paste0(ano, "_", nome_arquivo))

  if (file.exists(destino) && file.size(destino) > 0) {
    message("RAIS ", ano, ": arquivo compactado já está no cache (", destino, ").")
    return(destino)
  }

  parcial <- paste0(destino, ".parcial")
  if (file.exists(parcial)) unlink(parcial)
  message("RAIS ", ano, ": baixando ", url, " (cerca de ", TAMANHO_RAIS_MB[[as.character(ano)]], " MB).")
  status <- tryCatch(
    utils::download.file(url, parcial, mode = "wb", method = "libcurl", quiet = FALSE),
    error = function(e) {
      unlink(parcial)
      stop("RAIS ", ano, ": falha no download de ", url, ": ", conditionMessage(e))
    }
  )
  if (!identical(as.integer(status), 0L) || !file.exists(parcial)) {
    unlink(parcial)
    stop("RAIS ", ano, ": o download de ", url, " terminou com código ", status, ".")
  }
  if (!file.rename(parcial, destino)) {
    stop("RAIS ", ano, ": não foi possível renomear ", parcial, " para ", destino, ".")
  }

  tamanho_mb <- file.size(destino) / 1024^2
  esperado_mb <- TAMANHO_RAIS_MB[[as.character(ano)]]
  if (tamanho_mb < 0.9 * esperado_mb) {
    warning("RAIS ", ano, ": arquivo com ", round(tamanho_mb), " MB, abaixo dos cerca de ",
            esperado_mb, " MB da listagem do FTP. Pode estar truncado; apague ", destino,
            " e rode de novo se a leitura falhar.")
  }
  destino
}

localizar_colunas_rais <- function(cabecalho, arquivo) {
  norm <- normalizar_texto(cabecalho)
  regras <- list(
    municipio = list(
      padrao = "^munic",
      exclui = "trab"
    ),
    vinculo_ativo = list(
      padrao = "(ativo|emp).*31 12",
      exclui = "^$"
    ),
    rem_media_nominal = list(
      padrao = "^(vl )?rem(un)? m.*(nom|r)$",
      exclui = "( sm$|dez|jan|fev|mar|abr|mai|jun|jul|ago|set|out|nov|hora|contr)"
    ),
    escolaridade = list(
      padrao = "(escolaridade|instrucao).*2005",
      exclui = "^$"
    ),
    classe_cnae = list(
      padrao = "(cnae 2 ?0 classe|clas(se)? cnae 2 ?0)",
      exclui = "sub|sb "
    )
  )

  posicoes <- purrr::imap_int(regras, function(regra, rotulo) {
    idx <- which(grepl(regra$padrao, norm) & !grepl(regra$exclui, norm))
    if (length(idx) != 1) {
      stop("RAIS: a coluna '", rotulo, "' não foi localizada de forma única em ", arquivo,
           " (", length(idx), " candidatas). Cabeçalhos lidos:\n",
           paste(sprintf("  [%d] %s  (normalizado: %s)", seq_along(cabecalho), cabecalho, norm),
                 collapse = "\n"))
    }
    idx
  })
  message("RAIS: colunas localizadas em ", basename(arquivo), ": ",
          paste(sprintf("%s = '%s'", names(posicoes), cabecalho[posicoes]), collapse = "; "))
  posicoes
}

ler_rais_em_blocos <- function(arquivo, posicoes, cod_municipios, linhas_por_bloco = 1e6) {
  primeira_linha <- readLines(arquivo, n = 1, encoding = "latin1", warn = FALSE)
  candidatos <- c(";", "\t", ",", "|")
  ocorrencias <- vapply(candidatos, function(s) {
    lengths(regmatches(primeira_linha, gregexpr(s, primeira_linha, fixed = TRUE)))
  }, integer(1))
  separador <- candidatos[which.max(ocorrencias)]
  padrao <- paste(unique(substr(cod_municipios, 1, 6)), collapse = "|")
  message("RAIS: lendo ", basename(arquivo), " em blocos de ", format(linhas_por_bloco, scientific = FALSE),
          " linhas; separador detectado: '", separador, "'.")

  conexao <- file(arquivo, open = "r", encoding = "latin1")
  on.exit(close(conexao), add = TRUE)
  invisible(readLines(conexao, n = 1, warn = FALSE))

  blocos <- list()
  linhas_lidas <- 0
  repeat {
    linhas <- readLines(conexao, n = linhas_por_bloco, warn = FALSE)
    if (length(linhas) == 0) break
    linhas_lidas <- linhas_lidas + length(linhas)
    linhas <- linhas[grepl(padrao, linhas, perl = TRUE)]
    if (length(linhas) > 0) {
      blocos[[length(blocos) + 1]] <- data.table::fread(
        text = linhas, sep = separador, header = FALSE,
        select = unname(posicoes), colClasses = "character", showProgress = FALSE
      )
    }
  }
  message("RAIS: ", format(linhas_lidas, big.mark = "."), " linhas lidas em ", basename(arquivo), ".")
  if (length(blocos) == 0) stop("RAIS: nenhuma linha de município da RMC em ", basename(arquivo), ".")
  dt <- data.table::rbindlist(blocos)
  data.table::setnames(dt, old = paste0("V", posicoes), new = names(posicoes))
  dt
}

ler_rais_arquivo <- function(arquivo, cod_municipios) {
  cabecalho <- names(data.table::fread(arquivo, nrows = 0, encoding = "Latin-1",
                                       showProgress = FALSE))
  posicoes <- localizar_colunas_rais(cabecalho, arquivo)

  dt <- NULL
  if (!isTRUE(getOption("rais.forcar_blocos", FALSE))) {
    dt <- tryCatch(
      data.table::fread(
        arquivo,
        select = unname(posicoes),
        colClasses = "character",
        encoding = "Latin-1",
        showProgress = FALSE
      ),
      error = function(e) {
        warning("RAIS: a leitura direta de ", basename(arquivo), " falhou (", conditionMessage(e),
                "); o arquivo será lido em blocos.", call. = FALSE)
        NULL
      }
    )
    if (!is.null(dt)) data.table::setnames(dt, old = cabecalho[posicoes], new = names(posicoes))
  }
  if (is.null(dt)) dt <- ler_rais_em_blocos(arquivo, posicoes, cod_municipios)

  mapa_codigos <- tibble::tibble(
    id_municipio = cod_municipios,
    municipio_6  = substr(cod_municipios, 1, 6)
  )

  tibble::as_tibble(dt) |>
    dplyr::mutate(municipio_6 = stringr::str_trim(municipio)) |>
    dplyr::filter(municipio_6 %in% mapa_codigos$municipio_6) |>
    dplyr::inner_join(mapa_codigos, by = "municipio_6") |>
    dplyr::select(id_municipio, vinculo_ativo, rem_media_nominal, escolaridade, classe_cnae)
}

processar_rais_ano <- function(ano, cod_municipios) {
  caminho_ano <- file.path(DIR_BRUTOS, paste0("rais_", ano, ".rds"))
  if (file.exists(caminho_ano)) {
    message("RAIS ", ano, ": cache anual encontrado em ", caminho_ano, "; o ano não será reprocessado.")
    return(readRDS(caminho_ano))
  }

  inicio <- Sys.time()
  arquivo_7z <- baixar_rais_ano(ano)

  dir_extracao <- file.path(tempdir(), paste0("rais_", ano))
  if (dir.exists(dir_extracao)) unlink(dir_extracao, recursive = TRUE, force = TRUE)
  dir.create(dir_extracao, recursive = TRUE, showWarnings = FALSE)
  on.exit(unlink(dir_extracao, recursive = TRUE, force = TRUE), add = TRUE)

  conteudo <- tryCatch(
    archive::archive(arquivo_7z),
    error = function(e) stop("RAIS ", ano, ": não foi possível abrir ", arquivo_7z, ": ", conditionMessage(e))
  )
  arquivos_dados <- conteudo$path[grepl("\\.(txt|csv)$", conteudo$path, ignore.case = TRUE)]
  if (length(arquivos_dados) == 0) {
    stop("RAIS ", ano, ": nenhum arquivo .txt ou .csv dentro de ", arquivo_7z, ". Conteúdo: ",
         paste(conteudo$path, collapse = " | "))
  }

  message("RAIS ", ano, ": extraindo ", paste(arquivos_dados, collapse = ", "), " para ", dir_extracao, ".")
  tryCatch(
    archive::archive_extract(arquivo_7z, dir = dir_extracao, files = arquivos_dados),
    error = function(e) stop("RAIS ", ano, ": falha na extração: ", conditionMessage(e))
  )
  caminhos_extraidos <- file.path(dir_extracao, arquivos_dados)
  if (!all(file.exists(caminhos_extraidos))) {
    stop("RAIS ", ano, ": arquivo extraído não encontrado: ",
         paste(caminhos_extraidos[!file.exists(caminhos_extraidos)], collapse = ", "))
  }

  vinculos <- purrr::map(caminhos_extraidos, ler_rais_arquivo, cod_municipios = cod_municipios) |>
    dplyr::bind_rows()
  unlink(caminhos_extraidos, force = TRUE)
  gc(verbose = FALSE)

  valores_ativo <- sort(unique(stringr::str_trim(vinculos$vinculo_ativo)))
  if (!all(valores_ativo %in% c("0", "1"))) {
    stop("RAIS ", ano, ": valores inesperados no indicador de vínculo ativo: ",
         paste(valores_ativo, collapse = ", "))
  }

  vinculos <- vinculos |>
    dplyr::mutate(
      ativo        = stringr::str_trim(vinculo_ativo) == "1",
      escolaridade = suppressWarnings(as.integer(stringr::str_trim(escolaridade))),
      remuneracao  = converter_numero_br(rem_media_nominal),
      digitos_cnae = gsub("[^0-9]", "", classe_cnae),
      divisao_cnae = dplyr::if_else(
        nchar(digitos_cnae) %in% c(4L, 5L),
        substr(stringr::str_pad(digitos_cnae, 5, side = "left", pad = "0"), 1, 2),
        "ignorada"
      )
    )

  escolaridade_invalida <- sum(!is.na(vinculos$escolaridade) & !(vinculos$escolaridade %in% c(-1L, 1:11)))
  if (escolaridade_invalida > 0) {
    warning("RAIS ", ano, ": ", escolaridade_invalida, " vínculo(s) com escolaridade fora dos códigos -1 e 1 a 11.")
  }

  ativos <- dplyr::filter(vinculos, ativo)

  municipio_ano <- ativos |>
    dplyr::group_by(id_municipio) |>
    dplyr::summarise(
      vinculos_ativos             = dplyr::n(),
      vinculos_superior           = sum(escolaridade %in% 9:11),
      vinculos_escolaridade_na    = sum(is.na(escolaridade) | escolaridade == -1L),
      vinculos_remuneracao_valida = sum(!is.na(remuneracao) & remuneracao > 0),
      rem_media_nominal           = mean(remuneracao[!is.na(remuneracao) & remuneracao > 0]),
      .groups = "drop"
    ) |>
    dplyr::mutate(ano = as.integer(ano), .after = id_municipio) |>
    dplyr::arrange(id_municipio)

  faltantes <- setdiff(cod_municipios, municipio_ano$id_municipio)
  if (length(faltantes) > 0) {
    stop("RAIS ", ano, ": municípios sem nenhum vínculo ativo após o filtro: ",
         paste(faltantes, collapse = ", "), ". Confira o código de 6 dígitos na coluna de município.")
  }

  cnae_divisao <- ativos |>
    dplyr::count(id_municipio, divisao_cnae, name = "vinculos_ativos") |>
    dplyr::mutate(ano = as.integer(ano), .after = id_municipio) |>
    dplyr::arrange(id_municipio, divisao_cnae)

  soma_cnae <- cnae_divisao |>
    dplyr::group_by(id_municipio) |>
    dplyr::summarise(total = sum(vinculos_ativos), .groups = "drop") |>
    dplyr::inner_join(dplyr::select(municipio_ano, id_municipio, vinculos_ativos), by = "id_municipio")
  if (any(soma_cnae$total != soma_cnae$vinculos_ativos)) {
    stop("RAIS ", ano, ": a soma por divisão CNAE não bate com o total de vínculos ativos.")
  }
  n_ignorada <- sum(cnae_divisao$vinculos_ativos[cnae_divisao$divisao_cnae == "ignorada"])
  if (n_ignorada > 0) {
    message("RAIS ", ano, ": ", n_ignorada, " vínculo(s) ativo(s) sem divisão CNAE válida (rótulo 'ignorada').")
  }

  municipio_ano <- validar_tabela(
    municipio_ano, paste0("RAIS ", ano, " (município)"), length(cod_municipios),
    c("vinculos_ativos", "vinculos_superior", "vinculos_escolaridade_na",
      "vinculos_remuneracao_valida", "rem_media_nominal")
  )
  cnae_divisao <- validar_tabela(cnae_divisao, paste0("RAIS ", ano, " (CNAE)"), NULL, "vinculos_ativos")

  resultado <- list(municipio_ano = municipio_ano, cnae_divisao = cnae_divisao)
  saveRDS(resultado, caminho_ano)

  decorrido <- difftime(Sys.time(), inicio, units = "mins")
  message("RAIS ", ano, ": concluído em ", format(round(as.numeric(decorrido), 1), nsmall = 1),
          " min; ", sum(municipio_ano$vinculos_ativos), " vínculos ativos na RMC; gravado em ",
          caminho_ano, ".")
  resultado
}

get_rais_data <- function(cod_municipios, anos) {
  anos <- validar_anos(anos, 2012, 2022, "RAIS")
  cod_municipios <- as.character(cod_municipios)
  caminho <- file.path(DIR_BRUTOS, "rais.rds")
  colunas_economicas <- c("vinculos_ativos", "vinculos_superior", "vinculos_escolaridade_na",
                          "vinculos_remuneracao_valida", "rem_media_nominal")
  linhas_esperadas <- length(cod_municipios) * length(anos)

  if (file.exists(caminho)) {
    rais <- readRDS(caminho)
    if (setequal(unique(rais$municipio_ano$ano), anos)) {
      message("RAIS: cache consolidado encontrado em ", caminho, "; nenhum ano será reprocessado.")
      rais$municipio_ano <- validar_tabela(rais$municipio_ano, "RAIS (município e ano)",
                                           linhas_esperadas, colunas_economicas)
      rais$cnae_divisao  <- validar_tabela(rais$cnae_divisao, "RAIS (CNAE)", NULL, "vinculos_ativos")
      return(rais)
    }
    message("RAIS: o cache consolidado cobre outros anos; ele será refeito a partir dos caches anuais.")
  }

  inicio <- Sys.time()
  por_ano <- purrr::map(anos, processar_rais_ano, cod_municipios = cod_municipios)

  municipio_ano <- purrr::map(por_ano, "municipio_ano") |>
    dplyr::bind_rows() |>
    dplyr::arrange(id_municipio, ano)
  cnae_divisao <- purrr::map(por_ano, "cnae_divisao") |>
    dplyr::bind_rows() |>
    dplyr::arrange(id_municipio, ano, divisao_cnae)

  municipio_ano <- validar_tabela(municipio_ano, "RAIS (município e ano)", linhas_esperadas, colunas_economicas)
  cnae_divisao  <- validar_tabela(cnae_divisao, "RAIS (CNAE)", NULL, "vinculos_ativos")

  rais <- list(municipio_ano = municipio_ano, cnae_divisao = cnae_divisao)
  saveRDS(rais, caminho)
  message("RAIS: consolidado gravado em ", caminho, " após ",
          format(round(as.numeric(difftime(Sys.time(), inicio, units = "mins")), 1), nsmall = 1), " min.")
  rais
}


# -----------------------------------------------------------------------------
# 7. Malha municipal e distâncias: geobr e sf
# -----------------------------------------------------------------------------
get_spatial_data <- function(cod_municipios) {
  cod_municipios <- as.character(cod_municipios)
  caminho_malha <- file.path(DIR_BRUTOS, "malha_rmc.rds")
  caminho_dist  <- file.path(DIR_BRUTOS, "distancias.rds")
  n_esperado <- length(cod_municipios)

  if (file.exists(caminho_malha) && file.exists(caminho_dist)) {
    message("Malha: caches encontrados em ", caminho_malha, " e ", caminho_dist,
            "; o geobr não será consultado.")
    malha <- readRDS(caminho_malha)
    distancias <- readRDS(caminho_dist)
    validar_tabela(malha, "Malha RMC", n_esperado)
    distancias <- validar_tabela(distancias, "Distâncias", n_esperado, "dist_curitiba_km")
    return(list(malha = malha, distancias = distancias))
  }

  message("Malha: baixando a malha municipal do Paraná (geobr, ano 2020).")
  malha_pr <- tryCatch(
    geobr::read_municipality(code_muni = "PR", year = 2020, showProgress = FALSE),
    error = function(e) {
      message("Malha: o geobr falhou (", conditionMessage(e), ").")
      NULL
    }
  )
  geobr_ok <- !is.null(malha_pr) && inherits(malha_pr, "sf") &&
    all(c("code_muni", "name_muni") %in% names(malha_pr))

  if (geobr_ok) {
    fonte_malha <- "geobr (ano 2020)"
    malha <- malha_pr |>
      dplyr::mutate(id_municipio = sprintf("%.0f", as.numeric(code_muni))) |>
      dplyr::filter(id_municipio %in% cod_municipios)
  } else {
    fonte_malha <- "API de malhas do IBGE (versão 3)"
    url_ibge <- paste0("https://servicodados.ibge.gov.br/api/v3/malhas/estados/41",
                       "?formato=application/vnd.geo+json&intrarregiao=municipio&qualidade=intermediaria")
    message("Malha: o geobr não entregou a malha; usando a API de malhas do IBGE: ", url_ibge)
    arquivo_geojson <- tempfile(fileext = ".geojson")
    on.exit(unlink(arquivo_geojson), add = TRUE)
    tryCatch(
      utils::download.file(url_ibge, arquivo_geojson, mode = "wb", quiet = TRUE),
      error = function(e) stop("Malha: falha no geobr e na API de malhas do IBGE: ", conditionMessage(e))
    )
    malha_pr <- sf::st_read(arquivo_geojson, quiet = TRUE)
    if (!"codarea" %in% names(malha_pr) || nrow(malha_pr) != 399) {
      stop("Malha: a API do IBGE devolveu ", nrow(malha_pr), " linhas (esperadas 399, os municípios do Paraná) ",
           "e as colunas ", paste(names(malha_pr), collapse = " | "), ".")
    }
    malha <- malha_pr |>
      dplyr::mutate(id_municipio = as.character(codarea)) |>
      dplyr::filter(id_municipio %in% cod_municipios)
  }

  faltantes <- setdiff(cod_municipios, malha$id_municipio)
  if (length(faltantes) > 0 || nrow(malha) != n_esperado) {
    stop("Malha: códigos não achados ou duplicados na malha (", fonte_malha, "). Faltam: ",
         paste(faltantes, collapse = ", "), "; linhas filtradas: ", nrow(malha), ".")
  }

  if (geobr_ok) {
    comparacao <- malha |>
      sf::st_drop_geometry() |>
      dplyr::select(id_municipio, name_muni) |>
      dplyr::inner_join(MUNICIPIOS_RMC, by = "id_municipio") |>
      dplyr::mutate(confere = normalizar_texto(name_muni) == normalizar_texto(nome_municipio))
    if (!all(comparacao$confere)) {
      print(dplyr::filter(comparacao, !confere))
      stop("Malha: nomes do geobr divergem da tabela canônica para os códigos acima.")
    }
  }
  message("Malha: fonte usada: ", fonte_malha, ".")

  malha <- malha |>
    dplyr::left_join(MUNICIPIOS_RMC, by = "id_municipio") |>
    dplyr::select(id_municipio, nome_municipio) |>
    sf::st_transform(31982) |>
    dplyr::arrange(id_municipio)

  centroides <- sf::st_centroid(sf::st_geometry(malha))
  idx_curitiba <- which(malha$id_municipio == COD_CURITIBA)
  if (length(idx_curitiba) != 1) stop("Malha: Curitiba não localizada de forma única.")

  distancia_m <- sf::st_distance(centroides, centroides[idx_curitiba])
  distancias <- tibble::tibble(
    id_municipio     = malha$id_municipio,
    nome_municipio   = malha$nome_municipio,
    dist_curitiba_km = as.numeric(distancia_m[, 1]) / 1000
  )

  if (abs(distancias$dist_curitiba_km[idx_curitiba]) > 1e-6) {
    stop("Malha: a distância de Curitiba a ela mesma não é zero.")
  }
  distancias$dist_curitiba_km[idx_curitiba] <- 0
  if (any(distancias$dist_curitiba_km[-idx_curitiba] <= 0)) {
    stop("Malha: há município, além de Curitiba, com distância nula ou negativa.")
  }

  validar_tabela(malha, "Malha RMC", n_esperado)
  distancias <- validar_tabela(distancias, "Distâncias", n_esperado, "dist_curitiba_km")

  saveRDS(malha, caminho_malha)
  saveRDS(distancias, caminho_dist)
  message("Malha: gravados ", caminho_malha, " e ", caminho_dist, ".")
  list(malha = malha, distancias = distancias)
}


# -----------------------------------------------------------------------------
# 8. Orquestração
# -----------------------------------------------------------------------------
executar_extracao_completa <- function(anos = ANOS_PADRAO) {
  cod_municipios <- MUNICIPIOS_RMC$id_municipio

  executar_fonte <- function(fonte, cache, expressao, contar_linhas) {
    message("\n==== ", fonte, " ====")
    resultado <- tryCatch(
      expressao(),
      error = function(e) {
        message("FALHA em ", fonte, ": ", conditionMessage(e))
        NULL
      }
    )
    list(
      resultado = resultado,
      placar = tibble::tibble(
        fonte  = fonte,
        status = if (is.null(resultado)) "falha" else "ok",
        linhas = if (is.null(resultado)) NA_character_ else contar_linhas(resultado),
        cache  = cache
      )
    )
  }

  pib <- executar_fonte(
    "PIB SIDRA", file.path(DIR_BRUTOS, "pib_sidra.rds"),
    function() get_pib_sidra(cod_municipios, anos),
    function(x) as.character(nrow(x))
  )
  macro <- executar_fonte(
    "Macro Bacen", file.path(DIR_BRUTOS, "macro_bacen.rds"),
    function() get_macro_bacen(anos),
    function(x) paste0(nrow(x$mensal), " mensais; ", nrow(x$anual), " anuais")
  )
  rais <- executar_fonte(
    "RAIS", file.path(DIR_BRUTOS, "rais.rds"),
    function() get_rais_data(cod_municipios, anos),
    function(x) paste0(nrow(x$municipio_ano), " município-ano; ", nrow(x$cnae_divisao), " CNAE")
  )
  espacial <- executar_fonte(
    "Malha e distâncias",
    paste(file.path(DIR_BRUTOS, "malha_rmc.rds"), file.path(DIR_BRUTOS, "distancias.rds"), sep = " e "),
    function() get_spatial_data(cod_municipios),
    function(x) as.character(nrow(x$distancias))
  )

  placar <- dplyr::bind_rows(pib$placar, macro$placar, rais$placar, espacial$placar)
  message("\n==== Placar da extração (anos ", min(anos), " a ", max(anos), ") ====")
  print(placar, width = Inf)

  invisible(list(
    pib      = pib$resultado,
    macro    = macro$resultado,
    rais     = rais$resultado,
    espacial = espacial$resultado,
    placar   = placar
  ))
}

