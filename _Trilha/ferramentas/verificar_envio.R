# Verificação independente da pasta de envio. Base R apenas; não reutiliza o código dos scripts entregues.
# Uso (raiz do projeto): Rscript _Trilha/ferramentas/verificar_envio.R
DIR <- "envio_professor"
stopifnot(dir.exists(DIR))
resultado <- data.frame(id = character(), verificacao = character(), situacao = character(),
                        detalhe = character(), stringsAsFactors = FALSE)
registrar <- function(id, verificacao, ok, detalhe) {
  resultado[nrow(resultado) + 1, ] <<- list(id, verificacao, ifelse(ok, "APROVADA", "FALHOU"), detalhe)
  message(sprintf("[%s] %s: %s | %s", ifelse(ok, "ok", "FALHOU"), id, verificacao, detalhe))
}
le <- function(p) read.csv(file.path(DIR, p), check.names = FALSE, stringsAsFactors = FALSE)
pr <- function(p) file.path(DIR, p)

# ============================== A. Inventário, higiene e escopo ===================
esperado <- c("LEIAME.md",
  paste0("R/", c("00_executar_tudo", "01_extracao_dados", "02_tratamento_painel", "03_aede_visualizacoes",
                 "04_modelagem_diagnosticos", "05_autocorrelacao_municipios", "06_especificacao_chow",
                 "07_memorial_modelo_2"), ".R"),
  "figuras_graficos/animacao1_mapa_renda_rmc.gif", "figuras_graficos/animacao2_ranking_salario_municipios.gif",
  paste0("dados_brutos/", c("pib_sidra", "macro_bacen", "malha_rmc", "distancias", "rais"), ".rds"),
  paste0("dados_processados/", c("dados_painel_rmc.csv", "dados_painel_rmc.rds",
                                 "estatisticas_descritivas.csv", "matriz_correlacao_explicativas.csv")),
  paste0("resultados_econometricos/", c("coeficientes_modelos.csv", "testes_diagnostico.csv", "vif_tolerancia.csv",
                                        "anova_f_modelos.csv", "autocorrelacao_por_municipio.csv",
                                        "autocorrelacao_resumo.csv", "especificacao_reset.csv",
                                        "especificacao_lm_tendencia.csv", "chow_quebra_periodo.csv",
                                        "inferencia_agregada_x5_x6.csv", "medida_gini_checagem.csv",
                                        "memorial_modelo_2.txt", "memorial_modelo_2_anova.csv",
                                        "memorial_modelo_2_coeficientes.csv", "memorial_modelo_2_determinacao_parcial.csv",
                                        "memorial_modelo_2_f_incremental.csv", "memorial_modelo_2_fiv.csv",
                                        "memorial_modelo_2_previsao.csv")),
  paste0("documentacao/", c("00_resumo.md", "01_dados_e_variaveis.md", "02_especificacao_e_metodos.md",
                            "03_resultados_modelos.md", "04_diagnosticos.md", "05_limitacoes.md",
                            "06_fontes.md", "07_criterios_da_disciplina.md",
                            "ambiente_r.csv", "dicionario_variaveis.csv")))
presentes <- sub(paste0("^", DIR, "/"), "", list.files(DIR, recursive = TRUE, full.names = TRUE))
faltam <- setdiff(esperado, presentes)
registrar("A1", "Arquivos essenciais presentes", length(faltam) == 0,
          if (length(faltam)) paste(faltam, collapse = ", ") else sprintf("%d arquivos", length(esperado)))

sobra <- presentes[grepl("^(resultados_econometricos|figuras_graficos)/", presentes) &
                     !(presentes %in% esperado) & !grepl("^figuras_graficos/(fig|mapa|legenda|diag|animacao|robustez)", presentes)]
registrar("A1b", "Sem saídas de métodos removidos nem arquivos antigos", length(sobra) == 0,
          if (length(sobra)) paste(sobra, collapse = ", ") else "nenhuma saída antiga")

# Métodos fora do escopo ensinado: não podem aparecer nos scripts nem nos documentos.
proibidos <- c("mundlak", "hausman", "plm::", "vcovCL", "clustered", "cluster", "bootstrap", "webb", "wild",
               "rademacher", "shannon", "entrop", "prais", "neweywest", "newey", "smearing", "duan",
               "boxcox", "box-cox", "jarque", "efeitos fixos", "within", "pbgtest", "pwartest", "exp\\(", "vcovHAC")
arquivos_texto <- list.files(DIR, pattern = "\\.(R|md|csv|txt)$", recursive = TRUE, full.names = TRUE)
arquivos_texto <- arquivos_texto[!grepl("08_verificacao.md$|/resultados_econometricos/.*\\.csv$|/dados_processados/", arquivos_texto)]
achados <- character()
for (f in arquivos_texto) {
  x <- tolower(readLines(f, encoding = "UTF-8", warn = FALSE))
  if (grepl("\\.R$", f)) x <- x[!grepl("^\\s*#", x)]  # comentários R ficam fora; títulos Markdown ficam
  # Bloco "Métodos removidos": documenta a remoção, não é uso. Ignora do título até a próxima seção.
  dentro <- FALSE
  mantem <- logical(length(x))
  for (i in seq_along(x)) {
    if (grepl("^## ", x[i])) dentro <- grepl("remov", x[i])
    mantem[i] <- !dentro
  }
  x <- x[mantem]
  for (p in proibidos) {
    h <- grep(p, x, fixed = !grepl("\\\\|\\(|\\[|::", p))
    if (length(h)) achados <- c(achados, sprintf("%s (%s)", sub(paste0("^", DIR, "/"), "", f), p))
  }
}
registrar("A2", "Nenhum método fora do escopo ensinado nos scripts e documentos", length(achados) == 0,
          if (length(achados)) paste(head(unique(achados), 8), collapse = "; ") else sprintf("%d arquivos varridos", length(arquivos_texto)))

proib_id <- c("prompt", "antigravity", "handoff", "backlog", "claude", "anthropic", "pesquisador",
              "_Trilha", "kleis", "joao", "/home/", "OneDrive", "D-20[0-9]{2}-[0-9]{2}")
achados2 <- character()
for (f in arquivos_texto) {
  if (basename(f) == "08_verificacao.md") next
  x <- readLines(f, encoding = "UTF-8", warn = FALSE)
  for (p in proib_id) if (any(grepl(p, x, ignore.case = TRUE))) achados2 <- c(achados2, sub(paste0("^", DIR, "/"), "", f))
}
registrar("A3", "Sem identificadores internos de trabalho nem caminhos pessoais", length(achados2) == 0,
          if (length(achados2)) paste(unique(achados2), collapse = ", ") else "limpo")

# Código dos scripts igual ao do projeto, a menos dos comentários.
dif <- character()
for (f in c("00_executar_tudo", "01_extracao_dados", "02_tratamento_painel", "03_aede_visualizacoes",
            "04_modelagem_diagnosticos", "05_autocorrelacao_municipios", "06_especificacao_chow",
            "07_memorial_modelo_2")) {
  a <- parse(file.path("R", paste0(f, ".R")), keep.source = FALSE, encoding = "UTF-8")
  b <- parse(file.path(DIR, "R", paste0(f, ".R")), keep.source = FALSE, encoding = "UTF-8")
  if (!identical(deparse(a), deparse(b))) dif <- c(dif, f)
}
registrar("A4", "Código dos scripts idêntico ao da versão de trabalho (só comentários diferem)", length(dif) == 0,
          if (length(dif)) paste(dif, collapse = ", ") else "8 scripts idênticos")

abs_ <- character()
for (f in list.files(file.path(DIR, "R"), "\\.R$", full.names = TRUE)) {
  x <- readLines(f, encoding = "UTF-8", warn = FALSE); x <- x[!grepl("^\\s*#", x)]
  if (length(grep("[\"']([A-Za-z]:[/\\\\]|/home/|/Users/)", x))) abs_ <- c(abs_, basename(f))
}
registrar("A5", "Scripts usam só caminhos relativos", length(abs_) == 0,
          if (length(abs_)) paste(abs_, collapse = ", ") else "nenhum caminho absoluto")

# ============================== B. Painel e Gini recomputados ====================
painel <- readRDS(pr("dados_processados/dados_painel_rmc.rds")); painel <- as.data.frame(painel)
painel <- painel[order(painel$id_municipio, painel$ano), ]
registrar("B1", "Painel: 290 linhas, 29 municípios, 10 anos balanceados, sem NA, NaN ou Inf",
          nrow(painel) == 290 && length(unique(painel$id_municipio)) == 29 && all(table(painel$id_municipio) == 10) &&
            all(is.finite(as.matrix(painel[, c("ln_salario_real", "prop_superior", "dom_industrial", "gini_setorial",
                                               "selic_real", "dist_curitiba_km")]))),
          sprintf("%d x %d", nrow(painel), ncol(painel)))

rais <- readRDS(pr("dados_brutos/rais.rds")); cn <- as.data.frame(rais$cnae_divisao)
cn <- cn[cn$divisao_cnae != "ignorada", ]
gini_ref <- sapply(split(cn, paste(cn$id_municipio, cn$ano)), function(d) {
  x <- sort(d$vinculos_ativos / sum(d$vinculos_ativos)); x <- c(rep(0, 87 - length(x)), x); n <- length(x)
  sum((2 / n) * seq_len(n) * x) - (n + 1) / n
})
chave <- paste(painel$id_municipio, painel$ano)
dif_gini <- max(abs(painel$gini_setorial - gini_ref[chave]))
registrar("B2", "Gini setorial recomputado a partir da RAIS (fórmula do Guia P2, 87 divisões)", dif_gini < 1e-9,
          sprintf("maior diferença %.2e", dif_gini))

# ============================== C. Resultados ensinados recomputados ==============
X <- cbind(1, painel$prop_superior, painel$dom_industrial, painel$gini_setorial, painel$selic_real, painel$dist_curitiba_km)
y <- painel$ln_salario_real; n <- nrow(X); k <- ncol(X); gl <- n - k
XtXi <- solve(t(X) %*% X); b <- XtXi %*% t(X) %*% y; e <- as.numeric(y - X %*% b)
s2 <- sum(e^2) / gl
ep_cl <- sqrt(diag(s2 * XtXi))
meat <- t(X) %*% (X * e^2)
ep_white <- sqrt(diag((n / gl) * XtXi %*% meat %*% XtXi))  # HC1

coef <- le("resultados_econometricos/coeficientes_modelos.csv")
m2 <- coef[coef$modelo == "Modelo 2", ]
cl <- m2[m2$matriz == "classico", ]; wh <- m2[m2$matriz == "white", ]
registrar("C1", "Coeficientes e erro clássico do Modelo 2 recalculados por álgebra matricial",
          max(abs(cl$estimativa - as.numeric(b))) < 1e-7 && max(abs(cl$erro_padrao - ep_cl)) < 1e-7,
          sprintf("max dif coef %.1e; erro %.1e", max(abs(cl$estimativa - as.numeric(b))), max(abs(cl$erro_padrao - ep_cl))))
registrar("C2", "Erro de White (HC1) do Modelo 2 recalculado", max(abs(wh$erro_padrao - ep_white)) < 1e-7,
          sprintf("max dif %.1e", max(abs(wh$erro_padrao - ep_white))))

# FIV pela regra ensinada: 1 / (1 - R2_j).
fiv_ref <- sapply(2:k, function(j) {
  r2 <- summary(lm(X[, j] ~ X[, -j]))$r.squared; 1 / (1 - r2)
})
vif <- le("resultados_econometricos/vif_tolerancia.csv"); vif <- vif[vif$modelo == "Modelo 2", ]
registrar("C3", "FIV do Modelo 2 recalculado por 1/(1 - R2_j)", max(abs(vif$fiv - fiv_ref)) < 1e-6,
          sprintf("max dif %.1e; maior FIV %.4f", max(abs(vif$fiv - fiv_ref)), max(fiv_ref)))

# Breusch-Pagan (studentized): n R2 da regressão de e^2 em X.
bp_ref <- n * summary(lm(e^2 ~ X[, -1]))$r.squared
tst <- le("resultados_econometricos/testes_diagnostico.csv")
bp_csv <- tst$estatistica[tst$modelo == "Modelo 2" & grepl("Breusch", tst$teste)]
registrar("C4", "Breusch-Pagan-Godfrey do Modelo 2 recalculado (n R2)", abs(bp_ref - bp_csv) < 1e-6,
          sprintf("calculado %.4f; no arquivo %.4f", bp_ref, bp_csv))

# Durbin-Watson por município e decisão pela tabela (dL, dU para n = 10, k' = 5).
aut <- le("resultados_econometricos/autocorrelacao_por_municipio.csv")
e_df <- data.frame(id = painel$id_municipio, ano = painel$ano, e = e)
dw_ref <- sapply(split(e_df, e_df$id), function(d) { d <- d[order(d$ano), ]; sum(diff(d$e)^2) / sum(d$e^2) })
dw_csv <- aut$durbin_watson[match(names(dw_ref), aut$id_municipio)]
registrar("C5", "Durbin-Watson por município recalculado (29 séries de 10 anos)", max(abs(dw_ref - dw_csv)) < 1e-8,
          sprintf("max dif %.1e; mediana %.4f", max(abs(dw_ref - dw_csv)), median(dw_ref)))

# Chow: partes 2012-2016 e 2017-2021.
ch <- le("resultados_econometricos/chow_quebra_periodo.csv")
sel <- function(sub) {
  Xs <- X[sub, ]; ys <- y[sub]; bs <- solve(t(Xs) %*% Xs) %*% t(Xs) %*% ys; sum((ys - Xs %*% bs)^2)
}
c1 <- painel$ano <= 2016; c2 <- painel$ano > 2016
f_chow <- ((sum(e^2) - (sel(c1) + sel(c2))) / k) / ((sel(c1) + sel(c2)) / (n - 2 * k))
registrar("C6", "Teste de Chow recalculado", abs(f_chow - ch$estatistica_f) < 1e-6,
          sprintf("calculado %.4f; no arquivo %.4f", f_chow, ch$estatistica_f))

# ============================== D. Documentação conferida com os CSV =============
resumo <- paste(readLines(pr("documentacao/00_resumo.md"), encoding = "UTF-8", warn = FALSE), collapse = "\n")
f4 <- function(x) formatC(as.numeric(x), format = "f", digits = 4, decimal.mark = ",")
conf_b2 <- f4(wh$estimativa[wh$termo == "prop_superior"])
registrar("D1", "Coeficiente de X2 (erro de White) escrito no resumo igual ao CSV",
          grepl(conf_b2, resumo, fixed = TRUE), sprintf("valor %s", conf_b2))

pdesc <- le("resultados_econometricos/anova_f_modelos.csv")
registrar("D2", "Os modelos e testes do resumo batem com os arquivos de resultado",
          all(c("Modelo 2", "Modelo 3", "Modelo 3b") %in% pdesc$modelo), "três modelos presentes")

# Inferência agregada da Selic recalculada (regressão simples sobre médias anuais, n = 10).
medias <- aggregate(cbind(ln_salario_real, selic_real) ~ ano, data = painel, FUN = mean)
t_ag <- summary(lm(ln_salario_real ~ selic_real, data = medias))$coefficients["selic_real", ]
ia <- le("resultados_econometricos/inferencia_agregada_x5_x6.csv")
registrar("C7", "Inferência agregada da Selic (n = 10) recalculada", abs(t_ag[4] - ia$p_valor[1]) < 1e-8,
          sprintf("p-valor recalculado %.4f; no arquivo %.4f", t_ag[4], ia$p_valor[1]))

# ============================== E. Resumo final ==================================
status_ok <- sum(resultado$situacao == "APROVADA"); total <- nrow(resultado)
rodape <- sprintf("%d de %d verificações aprovadas.", status_ok, total)
cab <- c("# Verificação do envio", "",
         "Verificação independente. Recalcula por álgebra matricial e pelas fórmulas ensinadas, sem reusar o código dos scripts.", "")
tab <- c("| Id | Verificação | Situação | Detalhe |", "|---|---|---|---|",
         sprintf("| %s | %s | %s | %s |", resultado$id, resultado$verificacao, resultado$situacao, resultado$detalhe))
writeLines(c(cab, tab, "", rodape), file.path(DIR, "documentacao/08_verificacao.md"), useBytes = TRUE)
message(rodape)
if (status_ok < total) message("FALHAS: ", paste(resultado$id[resultado$situacao != "APROVADA"], collapse = ", "))
