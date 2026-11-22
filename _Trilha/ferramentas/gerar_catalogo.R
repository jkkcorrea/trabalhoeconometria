# Gera CATALOGO_DO_PROJETO.md a partir do conteúdo real das pastas.
# Uso (na raiz do projeto): Rscript _Trilha/ferramentas/gerar_catalogo.R
# O catálogo não é editado à mão: rode o script de novo quando algo mudar.

suppressPackageStartupMessages({
  library(dplyr); library(purrr); library(stringr); library(readr)
})

if (!file.exists("CLAUDE.md") || !dir.exists("R")) {
  stop("Rode a partir da raiz do projeto (pasta com CLAUDE.md e R/).")
}

tamanho <- function(x) {
  s <- file.size(x)
  case_when(is.na(s) ~ "?", s < 1024 ~ paste0(s, " B"),
            s < 1024^2 ~ sprintf("%.0f KB", s / 1024),
            TRUE ~ sprintf("%.1f MB", s / 1024^2))
}

# Resumo de uma linha por tipo de arquivo (lido do próprio arquivo).
resumo <- function(f) {
  ext <- tolower(tools::file_ext(f))
  tryCatch({
    if (ext == "csv") {
      d <- suppressMessages(read_csv(f, show_col_types = FALSE, n_max = 5000,
                                     progress = FALSE))
      nm <- names(d); if (length(nm) > 8) nm <- c(nm[1:8], "…")
      sprintf("CSV, %d linhas x %d colunas: %s", nrow(d), ncol(d),
              paste(nm, collapse = ", "))
    } else if (ext == "md") {
      l <- readLines(f, n = 40, warn = FALSE, encoding = "UTF-8")
      h <- l[str_detect(l, "^#\\s")][1]
      if (is.na(h)) "Markdown" else paste("Markdown:", str_remove(h, "^#+\\s*"))
    } else if (ext == "r") {
      l <- readLines(f, n = 12, warn = FALSE, encoding = "UTF-8")
      h <- l[str_detect(l, "^#\\s*(Etapa|Script|Executa|Gera|Uso)")][1]
      if (is.na(h)) "Script R" else paste("Script R:", str_remove(h, "^#+\\s*"))
    } else if (ext == "png") "Figura PNG"
    else if (ext == "gif") "Animação GIF"
    else if (ext == "rds") "Objeto R serializado (.rds)"
    else if (ext == "html") "Tabela HTML"
    else if (ext == "txt") "Texto simples"
    else if (ext == "sh") "Script de shell"
    else ""
  }, error = function(e) "(não foi possível resumir)")
}

linhas_pasta <- function(pasta, recursivo = FALSE) {
  fs <- list.files(pasta, full.names = TRUE, recursive = recursivo,
                   include.dirs = FALSE)
  fs <- fs[!str_detect(fs, "/\\.git/")]
  if (!length(fs)) return("_(pasta vazia ou ausente)_")
  tb <- tibble(arq = fs) |>
    mutate(nome = str_remove(arq, paste0("^", pasta, "/")),
           tam = tamanho(arq), res = map_chr(arq, resumo)) |>
    arrange(nome)
  c("| Arquivo | Tamanho | O que contém |", "|---|---|---|",
    with(tb, sprintf("| `%s` | %s | %s |", nome, tam, str_replace_all(res, "\\|", "/"))))
}

secao <- function(titulo, pasta, nota = NULL, recursivo = FALSE) {
  c(paste0("## ", titulo), "", if (!is.null(nota)) c(nota, ""),
    linhas_pasta(pasta, recursivo), "")
}

n_scripts <- length(list.files("R", pattern = "\\.R$"))
n_fig <- length(list.files("envio_professor/figuras_graficos"))
n_res <- length(list.files("envio_professor/resultados_econometricos"))

# Decisões e backlog (contagem real)
dec <- if (file.exists("_Trilha/DECISOES.md")) readLines("_Trilha/DECISOES.md", warn = FALSE) else character()
n_dec <- sum(str_detect(dec, "^\\| D-"))
n_dec_vig <- sum(str_detect(dec, "^\\| D-") & str_detect(dec, "\\| vigente \\|\\s*$"))
bl <- if (file.exists("_Trilha/BACKLOG.md")) readLines("_Trilha/BACKLOG.md", warn = FALSE) else character()
n_abertas <- sum(str_detect(bl, "^- \\[ \\]"))
n_fechadas <- sum(str_detect(bl, "^- \\[x\\]"))

out <- c(
  "# Catálogo do projeto",
  "",
  paste0("Gerado por `_Trilha/ferramentas/gerar_catalogo.R` em ", format(Sys.Date(), "%d/%m/%Y"),
         ". Não edite à mão: rode o script de novo."),
  "",
  "Projeto: salário médio real formal nos 29 municípios da Região Metropolitana de Curitiba, 2012 a 2021 (290 observações), Econometria I, UFPR.",
  "",
  "## Números do projeto",
  "",
  sprintf("- Scripts em `R/`: %d.", n_scripts),
  sprintf("- Figuras e animações em `envio_professor/figuras_graficos/`: %d arquivos.", n_fig),
  sprintf("- Arquivos em `envio_professor/resultados_econometricos/`: %d.", n_res),
  sprintf("- Decisões registradas em `_Trilha/DECISOES.md`: %d (vigentes na última coluna: %d).", n_dec, n_dec_vig),
  sprintf("- Pendências em `_Trilha/BACKLOG.md`: %d abertas e %d baixadas.", n_abertas, n_fechadas),
  "",
  "## Onde começar",
  "",
  "1. `SUMARIO_DO_PROJETO.md` (uma página).",
  "2. `instrucoes_ia/LEIA_PRIMEIRO.md` (regras para quem usa IA no projeto).",
  "3. `envio_professor/documentacao/00_resumo.md` (resultados validados).",
  "",
  secao("Raiz do projeto", ".", "Arquivos soltos na raiz (instruções, guias e documentos do projeto)."),
  secao("Scripts do projeto (`R/`, com comentários de processo)", "R"),
  secao("Instruções para IA (`instrucoes_ia/`)", "instrucoes_ia",
        "Prompts e regras para os colegas que usam IA. Não contêm texto do artigo."),
  secao("Skills (`.claude/skills/`)", ".claude/skills", "Cada skill é uma pasta com `SKILL.md`.", TRUE),
  secao("Agentes (`.claude/agents/`)", ".claude/agents"),
  secao("Ferramentas (`_Trilha/ferramentas/`)", "_Trilha/ferramentas"),
  secao("Trilha de decisões e handoffs (`_Trilha/`)", "_Trilha/_Handoffs"),
  secao("Pasta de envio: scripts (`envio_professor/R/`)", "envio_professor/R",
        "Gerada; não editar à mão."),
  secao("Pasta de envio: dados processados", "envio_professor/dados_processados"),
  secao("Pasta de envio: resultados econométricos", "envio_professor/resultados_econometricos"),
  secao("Pasta de envio: figuras e animações", "envio_professor/figuras_graficos"),
  secao("Pasta de envio: documentação validada", "envio_professor/documentacao")
)

writeLines(out, "CATALOGO_DO_PROJETO.md", useBytes = FALSE)
message("CATALOGO_DO_PROJETO.md gravado (", length(out), " linhas).")
