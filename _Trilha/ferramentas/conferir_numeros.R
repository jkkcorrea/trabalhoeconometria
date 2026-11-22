# Confere se os números de um rascunho (.md ou .txt) aparecem nas fontes do projeto.
# Uso (na raiz do projeto): Rscript _Trilha/ferramentas/conferir_numeros.R rascunho.md
# Fontes: CSV de resultados e dados processados, .md e .txt de documentação e resultados.
# Número não encontrado não é, necessariamente, erro: pode ser ano, contagem ou número de seção.
# O script só aponta o que precisa de explicação. Não substitui a leitura do texto.

suppressPackageStartupMessages({ library(stringr); library(readr); library(purrr) })

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1 || !file.exists(args[1])) {
  stop("Uso: Rscript _Trilha/ferramentas/conferir_numeros.R caminho/do/rascunho.md")
}
if (!dir.exists("envio_professor")) stop("Rode a partir da raiz do projeto.")

padrao <- "(?<![\\w.,])[-−]?\\d+(?:[.,]\\d+)*(?![\\w])"

para_num <- function(tok) {
  t <- str_replace(tok, "−", "-")
  # 1.234,56 (pt-BR) ou 1,234.56 (en) ou 7,3341 ou 0.0159
  if (str_detect(t, "\\d\\.\\d{3}(?!\\d)") && str_detect(t, ",")) t <- str_remove_all(t, "\\.")
  t <- str_replace(t, ",", ".")
  suppressWarnings(as.numeric(t))
}
casas <- function(tok) {
  m <- str_match(tok, "[.,](\\d+)$")[, 2]
  ifelse(is.na(m), 0L, nchar(m))
}

extrair <- function(txt) {
  tk <- unlist(str_extract_all(txt, padrao))
  tk[!is.na(tk)]
}

# ---- fontes ----
arq_csv <- c(list.files("envio_professor/resultados_econometricos", "\\.csv$", full.names = TRUE),
             list.files("envio_professor/dados_processados", "\\.csv$", full.names = TRUE),
             list.files("envio_professor/documentacao", "\\.csv$", full.names = TRUE))
arq_txt <- c(list.files("envio_professor/documentacao", "\\.md$", full.names = TRUE),
             list.files("envio_professor/resultados_econometricos", "\\.txt$", full.names = TRUE),
             "envio_professor/LEIAME.md", "CLAUDE.md")
arq_txt <- arq_txt[file.exists(arq_txt)]

vals <- numeric(0)
for (f in arq_csv) {
  d <- tryCatch(read_csv(f, col_types = cols(.default = col_character()), progress = FALSE),
                error = function(e) NULL)
  if (is.null(d)) next
  cel <- unlist(d, use.names = FALSE)
  cel <- cel[!is.na(cel)]
  vals <- c(vals, suppressWarnings(as.numeric(cel)))
  vals <- c(vals, map_dbl(extrair(paste(cel[nchar(cel) < 40], collapse = " ")), para_num))
}
for (f in arq_txt) {
  vals <- c(vals, map_dbl(extrair(readLines(f, warn = FALSE, encoding = "UTF-8")), para_num))
}
vals <- unique(abs(vals[is.finite(vals)]))

# ---- rascunho ----
lin <- readLines(args[1], warn = FALSE, encoding = "UTF-8")
lin_idx <- seq_along(lin)
lin_ok <- !str_detect(lin, "^\\s*(<!--|```)")          # ignora comentários e cercas de código
achados <- tibble::tibble(linha = integer(), token = character(), valor = numeric(), casas = integer())
for (i in lin_idx[lin_ok]) {
  tk <- extrair(lin[i])
  if (!length(tk)) next
  achados <- rbind(achados, tibble::tibble(linha = i, token = tk,
                                           valor = map_dbl(tk, para_num), casas = casas(tk)))
}
achados <- achados[is.finite(achados$valor), ]

# ignora o que não é dado: anos e inteiros de até 2 dígitos (seção, contagem pequena)
ignorar <- (achados$casas == 0 & abs(achados$valor) < 100) |
           (achados$casas == 0 & achados$valor >= 1900 & achados$valor <= 2100)
candidatos <- achados[!ignorar, ]

confere <- function(v, d) {
  any(abs(round(vals, d) - abs(v)) < 1e-9)
}
candidatos$achado <- map2_lgl(candidatos$valor, candidatos$casas, confere)

cat("\nCONFERÊNCIA AUTOMÁTICA DE NÚMEROS\n")
cat("Rascunho:", args[1], "\n")
cat("Números verificáveis:", nrow(candidatos),
    "| achados nas fontes:", sum(candidatos$achado),
    "| sem origem:", sum(!candidatos$achado), "\n")
cat("Ignorados (anos e inteiros de até 2 dígitos):", sum(ignorar), "\n\n")

sem <- candidatos[!candidatos$achado, ]
if (nrow(sem)) {
  cat("NÚMEROS SEM ORIGEM (explique ou corrija):\n")
  for (k in seq_len(nrow(sem))) {
    cat(sprintf("  linha %d: %s  | trecho: %s\n", sem$linha[k], sem$token[k],
                str_trunc(str_squish(lin[sem$linha[k]]), 90)))
  }
  cat("\nResultado: PENDENTE (há números sem origem).\n")
  quit(status = 1)
} else {
  cat("Resultado: nenhum número sem origem. Conferir ainda unidade, modelo e matriz de variância.\n")
}
