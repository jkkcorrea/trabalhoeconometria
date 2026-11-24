args <- commandArgs(trailingOnly = TRUE)
dir_origem <- args[1]; dir_destino <- args[2]; arq_relatorio <- args[3]
dir.create(dir_destino, showWarnings = FALSE, recursive = TRUE)

barra <- paste0("# ", strrep("=", 77))

cabecalhos <- list(
"01_extracao_dados.R" = c(barra,
"# Extração de dados: painel da Região Metropolitana de Curitiba, 2012 a 2021",
"#",
"# Fontes: SIDRA/IBGE (PIB municipal e valor adicionado por setor), SGS do Banco",
"# Central (séries 4390 e 433), malha municipal do IBGE e microdados da RAIS",
"# (Ministério do Trabalho).",
"# Grava em ./dados_brutos: pib_sidra.rds, macro_bacen.rds, malha_rmc.rds,",
"# distancias.rds e rais.rds (com um arquivo rais_AAAA.rds por ano).",
"# Os arquivos já acompanham a pasta dados_brutos/; este script só precisa ser",
"# executado para refazer a coleta (a RAIS exige o download de cerca de 3,5 GB).",
barra),
"02_tratamento_painel.R" = c(barra,
"# Tratamento dos dados brutos e construção do painel",
"# Salário médio real formal nos 29 municípios da Região Metropolitana de",
"# Curitiba, 2012 a 2021 (290 observações).",
"#",
"# Lê:    ./dados_brutos/pib_sidra.rds, macro_bacen.rds, rais.rds, distancias.rds",
"# Grava: ./dados_processados/dados_painel_rmc.rds e .csv",
"#        ./dados_processados/estatisticas_descritivas.csv",
"#        ./dados_processados/matriz_correlacao_explicativas.csv",
"#",
"# Variáveis:",
"#   Y  salário médio real: remuneração média nominal da RAIS multiplicada pelo",
"#      fator de deflação (índice acumulado do IPCA, série 433, média dos 12",
"#      meses do ano, com base em 2021), em reais de 2021.",
"#   X2 vínculos ativos com ensino superior completo sobre vínculos ativos com",
"#      escolaridade informada, em % (0 a 100).",
"#   X3 valor adicionado bruto da indústria sobre o valor adicionado bruto total,",
"#      em %.",
"#   X4 Gini da participação dos vínculos ativos entre as 87 divisões da CNAE,",
        "#      com zeros incluídos (fórmula da aula sobre medidas de desigualdade).",
"#   X5 Selic real anual pela equação de Fisher, com Selic (série 4390) e IPCA",
"#      (série 433) compostos a partir dos valores mensais.",
"#   X6 distância, em km, entre o centroide do município e o de Curitiba, em",
"#      SIRGAS 2000 / UTM 22S (EPSG 31982).",
barra),
"03_aede_visualizacoes.R" = c(barra,
"# Análise exploratória e visualizações",
"#",
"# Lê:    ./dados_processados/dados_painel_rmc.rds e ./dados_brutos/malha_rmc.rds",
"# Grava em ./figuras_graficos:",
"#   fig1_matriz_correlacao.png, fig2_ridgeplot_salario_anos.png,",
"#   fig3_dispersao_capital_humano_industria.png, mapa1_painel_espacial_rmc.png,",
"#   legenda_municipios_rmc.png, animacao1_mapa_renda_rmc.gif,",
"#   animacao2_ranking_salario_municipios.gif",
"#",
"# Os municípios são numerados de 1 a 29 pela ordem alfabética; o mesmo número",
"# aparece nos mapas e na legenda.",
barra),
"04_modelagem_diagnosticos.R" = c(barra,
"# Modelo principal (MQO empilhado) e diagnósticos ensinados",
"#",
"# Modelo: ln do salário médio real sobre X2, X3, X4, X5 e X6, com erros de White (HC1).",
"# Diagnósticos: fator de inflação da variância, Breusch-Pagan-Godfrey, Goldfeld-Quandt,",
"# Shapiro-Wilk com gráfico Q-Q e ANOVA.",
"#",
"# Lê:    ./dados_processados/dados_painel_rmc.rds",
"# Grava: ./resultados_econometricos/ (coeficientes, testes, normalidade, FIV e ANOVA)",
"#        ./figuras_graficos/diag1, diag2 e diag5",
barra)
)

tags <- "\\s*\\[(a confirmar|presunção da modelagem)[^]]*\\]"
ids  <- "(,?\\s*(e|ou)?\\s*)?D-20[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}"
proibidas <- paste(c("prompt", "antigravity", "handoff", "backlog", "pesquisador", "sessão", "claude",
                     "\\bIA\\b", "pendência", "desvio", "lista de alterações", "\\bitem [A-C0-9]",
                     "\\([A-C][0-9]\\)", "\\b[ABC][0-9]\\b", "decisão", "decisões", "aprovad", "autoriza",
                     "_Trilha", "BACKLOG", "DECISOES", "o gabarito", "[0-9]{2}/[0-9]{2}/20[0-9]{2}", "OneDrive",
                     "nesta máquina", "Etapa [0-9]", "conferid[oa]s? na execução", "na execução de"), collapse = "|")

relatorio <- character()
for (f in list.files(dir_origem, "^0.*\\.R$", full.names = TRUE)) {
  nome <- basename(f)
  txt <- readLines(f, encoding = "UTF-8", warn = FALSE)
  pd <- getParseData(parse(f, keep.source = TRUE, encoding = "UTF-8"))
  com <- pd[pd$token == "COMMENT", ]
  linhas_com <- sort(unique(com$line1))
  # Primeira linha de código real.
  cod <- pd[!pd$token %in% c("COMMENT"), ]
  primeira <- min(cod$line1)
  novo <- txt
  eliminar <- rep(FALSE, length(txt))

  limpa_texto <- function(x) {
    y <- gsub(tags, "", x)
    y <- gsub(ids, "", y)
    if (!identical(x, y)) {
      y <- gsub("\\s\\(\\s*\\)", "", y)
      y <- gsub("\\s+([.,;])", "\\1", y)
    }
    y
  }
  eh_separador <- function(x) grepl("^\\s*#\\s*[-=]{5,}\\s*$", x)

  # 1. cabeçalho (comentários antes da primeira linha de código)
  tem_cab <- nome %in% names(cabecalhos)
  if (tem_cab) {
    eliminar[seq_len(primeira - 1)] <- TRUE
  }

  # 2. demais comentários
  blocos_descartados <- 0; mantidos <- 0
  i <- primeira
  while (i <= length(txt)) {
    l <- txt[i]
    if (grepl("^\\s*#", l)) {
      # bloco contíguo de comentários de linha inteira
      j <- i
      while (j + 1 <= length(txt) && grepl("^\\s*#", txt[j + 1])) j <- j + 1
      idx <- i:j
      sep <- eh_separador(txt[idx])
      # percorre sub-blocos de linhas que não são separadores
      k <- 1
      while (k <= length(idx)) {
        if (sep[k]) { k <- k + 1; next }
        m <- k
        while (m + 1 <= length(idx) && !sep[m + 1]) m <- m + 1
        sub <- idx[k:m]
        titulo <- length(sub) == 1 && k > 1 && sep[k - 1] && grepl("^\\s*#\\s*\\d+[a-z]?\\.\\s", txt[sub])
        if (titulo) {
          t2 <- limpa_texto(txt[sub])
          if (grepl(proibidas, t2, ignore.case = TRUE)) eliminar[sub] <- TRUE else novo[sub] <- t2
        } else if (nome == "01_extracao_dados.R" || any(grepl(proibidas, limpa_texto(txt[sub]), ignore.case = TRUE))) {
          eliminar[sub] <- TRUE
          blocos_descartados <- blocos_descartados + 1
          relatorio <- c(relatorio, paste0("[", nome, ":", sub[1], "] DESCARTADO: ", paste(trimws(txt[sub]), collapse = " ")))
        } else {
          novo[sub] <- limpa_texto(txt[sub])
          mantidos <- mantidos + 1
        }
        k <- m + 1
      }
      i <- j + 1
    } else {
      # comentário no fim de linha de código
      if (i %in% linhas_com) {
        tx <- com$text[com$line1 == i]
        tx <- tx[length(tx)]
        if (endsWith(l, tx)) {
          corpo <- substr(l, 1, nchar(l) - nchar(tx))
          t2 <- limpa_texto(tx)
          if (nome == "01_extracao_dados.R" || grepl(proibidas, t2, ignore.case = TRUE)) {
            novo[i] <- sub("\\s+$", "", corpo)
            relatorio <- c(relatorio, paste0("[", nome, ":", i, "] FIM DE LINHA DESCARTADO: ", trimws(tx)))
          } else if (grepl("^#\\s*$", t2)) {
            novo[i] <- sub("\\s+$", "", corpo)
          } else {
            novo[i] <- paste0(corpo, t2)
          }
        }
      }
      i <- i + 1
    }
  }

  saida <- novo[!eliminar]
  if (tem_cab) saida <- c(cabecalhos[[nome]], "", saida)

  # 3. seções vazias: separador, (nada), separador
  repeat {
    n0 <- length(saida)
    k <- 1; manter <- rep(TRUE, length(saida))
    while (k < length(saida)) {
      if (eh_separador(saida[k]) && eh_separador(saida[k + 1])) { manter[k] <- FALSE; manter[k + 1] <- FALSE; k <- k + 2 } else k <- k + 1
    }
    saida <- saida[manter]
    # 4. linhas em branco consecutivas (máximo duas)
    r <- rle(trimws(saida) == "")
    pos <- cumsum(r$lengths); ini <- pos - r$lengths + 1
    manter <- rep(TRUE, length(saida))
    for (b in which(r$values & r$lengths > 2)) manter[(ini[b] + 2):pos[b]] <- FALSE
    saida <- saida[manter]
    if (length(saida) == n0) break
  }
  # remove branco no início
  while (length(saida) && trimws(saida[1]) == "") saida <- saida[-1]
  writeLines(saida, file.path(dir_destino, nome), useBytes = TRUE)
  relatorio <- c(relatorio, sprintf("## %s: %d linhas -> %d; blocos descartados %d", nome, length(txt), length(saida), blocos_descartados))
}
writeLines(relatorio, arq_relatorio)
cat("limpeza concluída\n")
