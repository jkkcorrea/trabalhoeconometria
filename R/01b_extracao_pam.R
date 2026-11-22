# =============================================================================
# Etapa 1b: produção agrícola municipal (PAM), valor da produção, dos 29 municípios
# Trabalho de Econometria I (UFPR).
#
# Fonte: IBGE, SIDRA, tabela 5457 (Produção Agrícola Municipal), variável 215
# ("Valor da produção", em mil reais), nível município (N6), 2012 a 2021.
# Códigos da tabela e da variável conferidos na API em 22/11/2026 (valores de
# Curitiba, 2019: 427 mil reais). A lista dos 29 municípios é a canônica
# (decisão registrada no projeto).
#
# Lê:    API do SIDRA (somente se o cache não existir)
# Grava: ./dados_brutos/pam_valor_producao.rds
# =============================================================================

if (!dir.exists("R") || !dir.exists("dados_brutos")) {
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
for (p in c("jsonlite", "dplyr", "tibble")) {
  if (!requireNamespace(p, quietly = TRUE)) stop("Pacote ausente: ", p, call. = FALSE)
}

CODIGOS_RMC <- c(4100202, 4100301, 4100400, 4101804, 4102307, 4103107, 4104006, 4104105, 4104204,
                 4104253, 4105201, 4105805, 4106209, 4106902, 4107652, 4111258, 4113205, 4114302,
                 4119103, 4119152, 4119509, 4120804, 4121208, 4122206, 4122305, 4125506, 4127601,
                 4127882, 4128633)
ANOS <- 2012:2021
CAMINHO <- file.path("dados_brutos", "pam_valor_producao.rds")

baixar_pam <- function() {
  url <- paste0("https://apisidra.ibge.gov.br/values/t/5457/n6/",
                paste(CODIGOS_RMC, collapse = ","),
                "/v/215/p/", min(ANOS), "-", max(ANOS))
  resposta <- tryCatch(jsonlite::fromJSON(url), error = function(e) {
    stop("PAM: falha na consulta à API do SIDRA: ", conditionMessage(e), call. = FALSE)
  })
  # A primeira linha da resposta do SIDRA é o cabeçalho com os nomes das colunas; os dados começam na linha 2.
  if (!identical(as.character(resposta$D2N[2]), "Valor da produção")) {
    stop("PAM: a variável devolvida não é 'Valor da produção'.", call. = FALSE)
  }
  if (!identical(as.character(resposta$MN[2]), "Mil Reais")) {
    stop("PAM: a unidade devolvida não é 'Mil Reais'.", call. = FALSE)
  }
  dados <- resposta[-1, ]
  tibble::tibble(
    id_municipio = as.character(dados$D1C),
    ano = as.integer(dados$D3N),
    valor_producao_mil = suppressWarnings(as.numeric(dados$V))
  )
}

if (file.exists(CAMINHO)) {
  message("PAM: cache encontrado em ", CAMINHO, "; a API não será consultada.")
  pam <- readRDS(CAMINHO)
} else {
  message("PAM: consultando a API do SIDRA (tabela 5457, variável 215).")
  pam <- baixar_pam()
  saveRDS(pam, CAMINHO)
}

# Validação: 29 municípios, 10 anos, sem valores ausentes.
if (dplyr::n_distinct(pam$id_municipio) != 29L) stop("PAM: não são 29 municípios.", call. = FALSE)
if (!setequal(unique(pam$ano), ANOS)) stop("PAM: os anos não batem com 2012 a 2021.", call. = FALSE)
if (nrow(pam) != 290L) stop("PAM: ", nrow(pam), " linhas; esperado 290.", call. = FALSE)
if (any(!is.finite(pam$valor_producao_mil))) stop("PAM: há valores ausentes ou não numéricos.", call. = FALSE)
if (any(pam$valor_producao_mil <= 0)) {
  message("PAM: ", sum(pam$valor_producao_mil <= 0), " observações com valor zero; o logaritmo usará log(1 + valor).")
}
message("PAM validada: 29 municípios x 10 anos; valores entre ",
        min(pam$valor_producao_mil), " e ", max(pam$valor_producao_mil), " mil reais.")
