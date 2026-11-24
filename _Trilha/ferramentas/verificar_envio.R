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

# ============================== A. Inventário, higiene e escopo ==================
SCRIPTS <- c("00_executar_tudo", "01_extracao_dados", "02_tratamento_painel",
             "03_aede_visualizacoes", "04_modelagem_diagnosticos", "05_autocorrelacao_municipios",
             "06_especificacao_chow", "07_memorial_modelo_2")
esperado <- c("LEIAME.md", paste0("R/", SCRIPTS, ".R"),
  "figuras_graficos/animacao1_mapa_renda_rmc.gif", "figuras_graficos/animacao2_ranking_salario_municipios.gif",
  paste0("dados_brutos/", c("pib_sidra", "macro_bacen", "malha_rmc", "distancias", "rais"), ".rds"),
  paste0("dados_processados/", c("dados_painel_rmc.csv", "dados_painel_rmc.rds",
                                 "estatisticas_descritivas.csv", "matriz_correlacao_explicativas.csv")),
  paste0("resultados_econometricos/", c("coeficientes_modelos.csv", "testes_diagnostico.csv", "vif_tolerancia.csv",
                                        "anova_f_modelo.csv", "normalidade_residuos.csv",
                                        "autocorrelacao_por_municipio.csv", "autocorrelacao_resumo.csv",
                                        "especificacao_reset.csv", "especificacao_lm_tendencia.csv", "chow_quebra_periodo.csv",
                                        "medida_gini_checagem.csv", "robustez_x4_definicao_gini.csv", "robustez_porte_e_negativos.csv",
                                        "reespecificacao_forma_funcional.csv", "testes_heterocedasticidade_complementares.csv",
                                        "f_geral_robusto.csv", "maiores_residuos.csv",
                                        "autocorrelacao_heterogeneidade_municipios.csv", "autocorrelacao_heterogeneidade_resumo.csv",
                                        "f_incremental_robusto.csv", "previsao_media_2021.csv",
                                        "projecao_selic_m2.csv", "efeito_selic_m2.csv",
                                        "memorial_modelo_2.txt", "memorial_modelo_2_anova.csv",
                                        "memorial_modelo_2_coeficientes.csv", "memorial_modelo_2_determinacao_parcial.csv",
                                        "memorial_modelo_2_f_incremental.csv", "memorial_modelo_2_fiv.csv",
                                        "memorial_modelo_2_previsao.csv")),
  paste0("figuras_graficos/", c("diag1_residuos_vs_ajustados.png", "diag2_residuos_por_municipio.png",
                                "diag3_residuos_defasados.png", "diag5_normalidade_qq.png", "diag6_variaveis_no_tempo.png", "diag7_residuos_vs_regressores.png",
                                "fig1_matriz_correlacao.png", "fig2_ridgeplot_salario_anos.png",
                                "fig3_dispersao_capital_humano_industria.png", "legenda_municipios_rmc.png",
                                "mapa1_painel_espacial_rmc.png")),
  paste0("documentacao/", c("00_resumo.md", "01_dados_e_variaveis.md", "02_especificacao_e_metodos.md",
                            "03_resultados_modelos.md", "04_diagnosticos.md", "05_limitacoes.md",
                            "06_fontes.md", "07_criterios_da_disciplina.md")),
  "documentacao/ambiente_r.csv", "documentacao/dicionario_variaveis.csv")
# 08_verificacao.md é gerado ao final desta própria verificação, por isso não entra na lista de A1.
presentes <- sub(paste0("^", DIR, "/"), "", list.files(DIR, recursive = TRUE, full.names = TRUE))
faltam <- setdiff(esperado, presentes)
registrar("A1", "Arquivos essenciais presentes", length(faltam) == 0,
          if (length(faltam)) paste(faltam, collapse = ", ") else sprintf("%d arquivos esperados presentes; %d arquivos na pasta", length(esperado), length(presentes)))

sobra <- presentes[grepl("^(resultados_econometricos|figuras_graficos|dados_brutos)/", presentes) & !(presentes %in% esperado)]
registrar("A1b", "Sem arquivos de versões anteriores nos resultados, figuras e dados brutos", length(sobra) == 0,
          if (length(sobra)) paste(sobra, collapse = ", ") else "nenhum arquivo antigo")

# Métodos fora do escopo ensinado (Econometria I): não podem aparecer nos scripts nem nos documentos.
# Linhas que nomeiam um método só para dizer que ele não é usado são aceitas; blocos "removidos" também.
proibidos <- c("mundlak", "hausman", "efeito fixo", "efeitos fixos", "efeito aleatório", "dummy", "dummies",
               "variáveis binárias", "variável binária", "prais", "cochrane", "jarque", "carreiras", "cook",
               "dfbeta", "bootstrap", "cluster", "newey", "smearing", "duan", "boxcox", "box-cox", "plm::",
               "vcovHAC", "within")
arquivos_texto <- list.files(DIR, pattern = "\\.(R|md|csv|txt)$", recursive = TRUE, full.names = TRUE)
arquivos_texto <- arquivos_texto[!grepl("08_verificacao.md$|/resultados_econometricos/.*\\.csv$|/dados_processados/", arquivos_texto)]
achados <- character()
for (f in arquivos_texto) {
  x <- tolower(readLines(f, encoding = "UTF-8", warn = FALSE))
  if (grepl("\\.R$", f)) x <- x[!grepl("^\\s*#", x)]
  dentro <- FALSE
  mantem <- logical(length(x))
  for (i in seq_along(x)) {
    if (grepl("^## ", x[i])) dentro <- grepl("remov|não aplicad|não usad|fora do", x[i])
    mantem[i] <- !dentro
  }
  x <- x[mantem]
  x <- x[!grepl("não (é |foi |são |será )?(aplicad|usad|utilizad)|fora do (escopo|programa)|removid", x)]
  for (p in proibidos) {
    if (any(grepl(p, x, fixed = TRUE))) achados <- c(achados, sprintf("%s (%s)", sub(paste0("^", DIR, "/"), "", f), p))
  }
}
registrar("A2", "Nenhum método fora do escopo ensinado nos scripts e documentos", length(achados) == 0,
          if (length(achados)) paste(head(unique(achados), 8), collapse = "; ") else sprintf("%d arquivos varridos", length(arquivos_texto)))

proib_id <- c("prompt", "antigravity", "handoff", "backlog", "claude", "anthropic", "pesquisador",
              "presunção da modelagem", "a confirmar\\]", "\\[revisar", "\\[a inserir",
              "_Trilha", "kleis", "joao", "/home/", "OneDrive", "D-20[0-9]{2}-[0-9]{2}")
achados2 <- character()
for (f in arquivos_texto) {
  if (basename(f) == "08_verificacao.md") next
  x <- readLines(f, encoding = "UTF-8", warn = FALSE)
  for (p in proib_id) if (any(grepl(p, x, ignore.case = TRUE))) achados2 <- c(achados2, sub(paste0("^", DIR, "/"), "", f))
}
registrar("A3", "Sem identificadores internos de trabalho nem caminhos pessoais", length(achados2) == 0,
          if (length(achados2)) paste(unique(achados2), collapse = ", ") else "limpo")

dif <- character()
for (f in SCRIPTS) {
  a <- parse(file.path("R", paste0(f, ".R")), keep.source = FALSE, encoding = "UTF-8")
  b <- parse(file.path(DIR, "R", paste0(f, ".R")), keep.source = FALSE, encoding = "UTF-8")
  if (!identical(deparse(a), deparse(b))) dif <- c(dif, f)
}
registrar("A4", "Código dos scripts idêntico ao da versão de trabalho (só comentários diferem)", length(dif) == 0,
          if (length(dif)) paste(dif, collapse = ", ") else sprintf("%d scripts idênticos", length(SCRIPTS)))

abs_ <- character()
for (f in list.files(file.path(DIR, "R"), "\\.R$", full.names = TRUE)) {
  x <- readLines(f, encoding = "UTF-8", warn = FALSE); x <- x[!grepl("^\\s*#", x)]
  if (length(grep("[\"']([A-Za-z]:[/\\\\]|/home/|/Users/)", x))) abs_ <- c(abs_, basename(f))
}
registrar("A5", "Scripts usam só caminhos relativos", length(abs_) == 0,
          if (length(abs_)) paste(abs_, collapse = ", ") else "nenhum caminho absoluto")

# ============================== B. Painel e Gini recomputados ====================
painel <- as.data.frame(readRDS(pr("dados_processados/dados_painel_rmc.rds")))
painel <- painel[order(painel$id_municipio, painel$ano), ]
variaveis <- c("ln_salario_real", "prop_superior", "dom_industrial", "gini_setorial", "selic_real", "dist_curitiba_km")
registrar("B1", "Painel: 290 linhas, 29 municípios, 10 anos balanceados, sem NA, NaN ou Inf",
          nrow(painel) == 290 && length(unique(painel$id_municipio)) == 29 && all(table(painel$id_municipio) == 10) &&
            all(is.finite(as.matrix(painel[, variaveis]))),
          sprintf("%d x %d", nrow(painel), ncol(painel)))

rais <- readRDS(pr("dados_brutos/rais.rds")); cn <- as.data.frame(rais$cnae_divisao)
cn <- cn[cn$divisao_cnae != "ignorada", ]
gini_ref <- sapply(split(cn, paste(cn$id_municipio, cn$ano)), function(d) {
  x <- sort(d$vinculos_ativos / sum(d$vinculos_ativos)); x <- c(rep(0, 87 - length(x)), x); n <- length(x)
  sum((2 / n) * seq_len(n) * x) - (n + 1) / n
})
chave <- paste(painel$id_municipio, painel$ano)
dif_gini <- max(abs(painel$gini_setorial - gini_ref[chave]))
registrar("B2", "Gini setorial recomputado a partir da RAIS (fórmula da aula de desigualdade, Hasegawa 2020, 87 divisões)", dif_gini < 1e-9,
          sprintf("maior diferença %.2e", dif_gini))

# ============================== C. Resultados do modelo principal recomputados ====
X <- cbind(1, as.matrix(painel[, c("prop_superior", "dom_industrial", "gini_setorial", "selic_real", "dist_curitiba_km")]))
y <- painel$ln_salario_real
n <- nrow(X); k <- ncol(X); gl <- n - k
XtX_inv <- solve(t(X) %*% X)
b <- as.vector(XtX_inv %*% t(X) %*% y)
e <- as.vector(y - X %*% b)
s2 <- sum(e^2) / gl
ep_classico <- sqrt(diag(s2 * XtX_inv))

coef <- le("resultados_econometricos/coeficientes_modelos.csv")
cl <- coef[coef$matriz == "classico", ]
wh <- coef[coef$matriz == "white", ]
registrar("C1", "Coeficientes e erro clássico do modelo principal recalculados por álgebra matricial",
          max(abs(cl$estimativa - b)) < 1e-8 && max(abs(cl$erro_padrao - ep_classico)) < 1e-8,
          sprintf("maior diferença %.2e", max(abs(cl$estimativa - b), abs(cl$erro_padrao - ep_classico))))

# HC1: (n/(n-k)) (X'X)^-1 X' diag(e^2) X (X'X)^-1
meat <- t(X) %*% (X * e^2)
ep_white <- sqrt(diag((n / (n - k)) * XtX_inv %*% meat %*% XtX_inv))
registrar("C2", "Erro de White (HC1) recalculado", max(abs(wh$erro_padrao - ep_white)) < 1e-7,
          sprintf("maior diferença %.2e", max(abs(wh$erro_padrao - ep_white))))

# FIV: 1 / (1 - R2_j), regressão de cada explicativa nas demais
expl <- X[, -1]
fiv_ref <- sapply(seq_len(ncol(expl)), function(j) {
  r2 <- summary(stats::lm(expl[, j] ~ expl[, -j]))$r.squared
  1 / (1 - r2)
})
vif <- le("resultados_econometricos/vif_tolerancia.csv")
registrar("C3", "FIV do modelo principal recalculado por 1/(1 - R2_j)", max(abs(vif$fiv - fiv_ref)) < 1e-6,
          sprintf("maior FIV %.4f; maior diferença %.2e", max(fiv_ref), max(abs(vif$fiv - fiv_ref))))

# Breusch-Pagan (studentized): n R2 da regressão dos resíduos ao quadrado nos regressores
bp_ref <- n * summary(stats::lm(e^2 ~ expl))$r.squared
tst <- le("resultados_econometricos/testes_diagnostico.csv")
bp_csv <- tst$estatistica[grepl("Breusch", tst$teste)]
registrar("C4", "Breusch-Pagan-Godfrey recalculado (n R2 da regressão auxiliar)", abs(bp_ref - bp_csv) < 1e-6,
          sprintf("calculado %.4f; no arquivo %.4f", bp_ref, bp_csv))

# RESET (potências 2 e 3 dos ajustados): F pela soma de quadrados restrita e irrestrita
yhat <- as.vector(X %*% b)
Xr <- cbind(X, yhat^2, yhat^3)
b_r <- stats::lm.fit(Xr, y)$coefficients   # QR: estável com ajustados ao quadrado e ao cubo
sqr_u <- sum((y - Xr %*% b_r)^2); sqr_r <- sum(e^2)
F_reset <- ((sqr_r - sqr_u) / 2) / (sqr_u / (n - k - 2))
rs <- le("resultados_econometricos/especificacao_reset.csv")
registrar("C5", "RESET de Ramsey recalculado (F com ajustados ao quadrado e ao cubo)",
          abs(F_reset - rs$estatistica_f[1]) < 1e-6,
          sprintf("calculado %.4f; no arquivo %.4f", F_reset, rs$estatistica_f[1]))

# Durbin-Watson por município (29 séries de 10 anos), com as decisões da regra do Guia P2 e dL/dU da Tabela D.5A
aut <- le("resultados_econometricos/autocorrelacao_por_municipio.csv")
dw_ref <- sapply(split(e, painel$id_municipio), function(u) sum(diff(u)^2) / sum(u^2))
dw_csv <- aut$durbin_watson[match(names(dw_ref), aut$id_municipio)]
registrar("C6", "Durbin-Watson por município recalculado (29 séries de 10 anos)",
          length(dw_ref) == 29 && max(abs(dw_ref - dw_csv)) < 1e-8,
          sprintf("maior diferença %.2e", max(abs(dw_ref - dw_csv))))
decisao_ref <- ifelse(dw_ref < 0.243, "positiva", ifelse(dw_ref > 4 - 0.243, "negativa",
                      ifelse(dw_ref > 2.822 & dw_ref < 4 - 2.822, "não rejeita", "inconclusiva")))
decisao_csv <- ifelse(grepl("^positiva", aut$decisao_dw_tabela[match(names(dw_ref), aut$id_municipio)]), "positiva",
                      ifelse(grepl("^negativa", aut$decisao_dw_tabela[match(names(dw_ref), aut$id_municipio)]), "negativa",
                             ifelse(aut$decisao_dw_tabela[match(names(dw_ref), aut$id_municipio)] == "não rejeita H0", "não rejeita", "inconclusiva")))
registrar("C7", "Decisões de Durbin-Watson por município conferidas com dL = 0,243 e dU = 2,822 (Gujarati, Tabela D.5A)",
          all(decisao_ref == decisao_csv), sprintf("%d de 29 municípios com decisão igual à regra", sum(decisao_ref == decisao_csv)))

# Teste de Chow com o corte de 2017 (indicado pelo gráfico): F = [(SQR_R - SQR_1 - SQR_2)/k] / [(SQR_1+SQR_2)/(n-2k)]
p1 <- painel$ano <= 2017; p2 <- !p1
b1 <- solve(t(X[p1, ]) %*% X[p1, ], t(X[p1, ]) %*% y[p1])
b2 <- solve(t(X[p2, ]) %*% X[p2, ], t(X[p2, ]) %*% y[p2])
sqr_sep <- sum((y[p1] - X[p1, ] %*% b1)^2) + sum((y[p2] - X[p2, ] %*% b2)^2)
F_chow <- ((sqr_r - sqr_sep) / k) / (sqr_sep / (n - 2 * k))
ch <- le("resultados_econometricos/chow_quebra_periodo.csv")
f_chow_csv <- ch$estatistica_f[grepl("indicado", ch$teste)]
registrar("C8", "Teste de Chow (corte de 2017) recalculado", abs(F_chow - f_chow_csv) < 1e-6,
          sprintf("calculado %.4f; no arquivo %.4f", F_chow, f_chow_csv))

# Shapiro-Wilk: estatística W do resíduo (teste ensinado pelo professor)
sw_ref <- stats::shapiro.test(e)
nor <- le("resultados_econometricos/normalidade_residuos.csv")
registrar("C9", "Shapiro-Wilk dos resíduos recalculado", abs(sw_ref$statistic - nor$estatistica[1]) < 1e-8 &&
            abs(sw_ref$p.value - nor$p_valor[1]) < 1e-12,
          sprintf("W = %.4f; p = %.3g", sw_ref$statistic, sw_ref$p.value))

# Projeção de 2021: ajuste no ano de referência, e correção exp(s2/2) do viés da retransformação
pj <- le("resultados_econometricos/projecao_selic_m2.csv")
base21 <- pj[pj$cenario == "Selic de 2021", ]
ajuste21 <- as.vector(X[painel$ano == 2021, ] %*% b)
registrar("C10", "Projeção de 2021 (cenário base) igual ao ajuste do modelo e correção de viés exp(s2/2) aplicada",
          max(abs(base21$ln_previsto - ajuste21)) < 1e-8 &&
            max(abs(base21$salario_previsto_corrigido - base21$salario_previsto_sem_correcao * exp(s2 / 2))) < 1e-6,
          sprintf("desvio do ajuste %.2e; fator exp(s2/2) = %.5f", max(abs(base21$ln_previsto - ajuste21)), exp(s2 / 2)))

# Efeito da Selic com erro de White: IC 95% pelo t de n - k graus de liberdade
ef <- le("resultados_econometricos/efeito_selic_m2.csv")
b_s <- wh$estimativa[wh$termo == "selic_real"]; ep_s <- wh$erro_padrao[wh$termo == "selic_real"]
tc <- stats::qt(0.975, gl)
registrar("C11", "Intervalo de confiança da Selic (erro de White, gl = n - k) recalculado",
          abs(ef$ic95_inf_ln[1] - (b_s - tc * ep_s)) < 1e-8 && abs(ef$ic95_sup_ln[1] - (b_s + tc * ep_s)) < 1e-8,
          sprintf("IC [%.6f; %.6f]", b_s - tc * ep_s, b_s + tc * ep_s))

# Breusch-Godfrey de ordem 1 como em Gujarati: (n - 1) vezes o R2 não centrado da regressão do resíduo
# centrado no defasado, com o primeiro defasado descartado
bg_ref <- sapply(split(e, painel$id_municipio), function(u) {
  r <- u - mean(u); nn <- length(r); fit <- stats::lm.fit(cbind(1, r[-nn]), r[-1])
  (nn - 1) * (1 - sum(fit$residuals^2) / sum(r[-1]^2))
})
bg_csv <- aut$breusch_godfrey_estatistica[match(names(bg_ref), aut$id_municipio)]
registrar("C19", "Breusch-Godfrey por município recalculado (n - p observações, primeiro defasado descartado)",
          max(abs(bg_ref - bg_csv)) < 1e-8 &&
            sum(stats::pchisq(bg_ref, 1, lower.tail = FALSE) < 0.05) == sum(aut$breusch_godfrey_decisao == "rejeita H0"),
          sprintf("maior diferença %.2e; rejeitam %d de 29", max(abs(bg_ref - bg_csv)), sum(aut$breusch_godfrey_decisao == "rejeita H0")))

# Memorial matricial (R/07): b, s2 e erro-padrão recalculados
mem <- le("resultados_econometricos/memorial_modelo_2_coeficientes.csv")
registrar("C12", "Memorial matricial do modelo principal bate com a álgebra independente",
          max(abs(as.numeric(mem[[2]]) - b)) < 1e-6,
          sprintf("maior diferença nos coeficientes %.2e", max(abs(as.numeric(mem[[2]]) - b))))

# Teste de White: n R2 da regressão de e^2 sobre regressores, quadrados e produtos cruzados
Xv <- X[, -1]
cruz <- do.call(cbind, lapply(1:4, function(i) sapply((i + 1):5, function(j) Xv[, i] * Xv[, j])))
Zw <- cbind(1, Xv, Xv^2, cruz)
aux_w <- stats::lm.fit(Zw, e^2)
r2_w <- 1 - sum(aux_w$residuals^2) / sum((e^2 - mean(e^2))^2)
hw <- le("resultados_econometricos/testes_heterocedasticidade_complementares.csv")
reg_w <- hw[grepl("^White", hw$teste), ]
registrar("C13", "Teste de White recalculado (n R2 da regressão auxiliar com quadrados e produtos cruzados)",
          abs(n * r2_w - reg_w$estatistica) < 1e-6 && (aux_w$rank - 1) == as.numeric(reg_w$gl),
          sprintf("calculado %.4f (gl %d); no arquivo %.4f (gl %s)", n * r2_w, aux_w$rank - 1, reg_w$estatistica, reg_w$gl))

# Goldfeld-Quandt unilateral (Ha: a variância cresce com a variável de ordenação), ordenado por X3
ord3 <- order(painel$dom_industrial); omit <- floor(n * 0.2); m1 <- (n - omit) %/% 2
i1 <- ord3[seq_len(m1)]; i2 <- ord3[(n - m1 + 1):n]
rss <- function(i) sum(stats::lm.fit(X[i, ], y[i])$residuals^2)
gl_gq <- m1 - k; F_gq <- (rss(i2) / gl_gq) / (rss(i1) / gl_gq); p_gq <- stats::pf(F_gq, gl_gq, gl_gq, lower.tail = FALSE)
gq3 <- hw[grepl("Goldfeld", hw$teste) & hw$ordenado_por == "dom_industrial", ]
registrar("C20", "Goldfeld-Quandt unilateral ordenado por X3 recalculado (fração central 0,2 omitida)",
          abs(F_gq - gq3$estatistica) < 1e-6 && abs(p_gq - gq3$p_valor) < 1e-8,
          sprintf("calculado F = %.4f, p = %.4f; no arquivo F = %.4f, p = %.4f", F_gq, p_gq, gq3$estatistica, gq3$p_valor))

# F geral com a matriz de White (HC1): F = b'V^-1 b / q, com as q inclinações
meio <- t(X) %*% (X * e^2)
V_hc1 <- (n / (n - k)) * XtX_inv %*% meio %*% XtX_inv
F_rob <- as.numeric(t(b[-1]) %*% solve(V_hc1[-1, -1], b[-1])) / (k - 1)
fr <- le("resultados_econometricos/f_geral_robusto.csv")
registrar("C14", "F geral com erro de White (HC1) recalculado", abs(F_rob - fr$estatistica_f[fr$matriz == "White (HC1)"]) < 1e-6,
          sprintf("calculado %.4f; no arquivo %.4f", F_rob, fr$estatistica_f[fr$matriz == "White (HC1)"]))

# Durbin-Watson com os resíduos centrados na média do município e contagem de municípios de mesmo sinal
dwc_ref <- sapply(split(e, painel$id_municipio), function(u) { uc <- u - mean(u); sum(diff(uc)^2) / sum(uc^2) })
het <- le("resultados_econometricos/autocorrelacao_heterogeneidade_municipios.csv")
hres <- le("resultados_econometricos/autocorrelacao_heterogeneidade_resumo.csv")
mesmo_ref <- sum(sapply(split(e, painel$id_municipio), function(u) all(u > 0) || all(u < 0)))
registrar("C15", "Durbin-Watson com resíduos centrados por município e municípios de mesmo sinal recalculados",
          max(abs(dwc_ref - het$durbin_watson_centrado[match(names(dwc_ref), het$id_municipio)])) < 1e-8 &&
            mesmo_ref == hres$municipios_mesmo_sinal && sum(dwc_ref < 0.243) == hres$abaixo_dl_centrado,
          sprintf("mesmo sinal %d; abaixo de dL com resíduos centrados %d", mesmo_ref, sum(dwc_ref < 0.243)))

# Reespecificação com o logaritmo dos vínculos ativos: RESET e coeficiente do Gini recalculados
Xp <- cbind(X, log(painel$vinculos_ativos))
bp_ <- stats::lm.fit(Xp, y)$coefficients; ep_ <- y - Xp %*% bp_
yh <- as.vector(Xp %*% bp_); Xrp <- cbind(Xp, yh^2, yh^3)
sqr_u2 <- sum(stats::lm.fit(Xrp, y)$residuals^2); sqr_r2 <- sum(ep_^2)
F_reset_p <- ((sqr_r2 - sqr_u2) / 2) / (sqr_u2 / (n - ncol(Xp) - 2))
re <- le("resultados_econometricos/reespecificacao_forma_funcional.csv")
lin <- re[grepl("porte", re$especificacao) & !grepl("Quadrados", re$especificacao), ]
registrar("C16", "Reespecificação com o porte do município: RESET e coeficiente do Gini recalculados",
          abs(F_reset_p - lin$reset_f) < 1e-6 && abs(bp_[4] - lin$coef_gini) < 1e-8,
          sprintf("RESET calculado %.4f, no arquivo %.4f; Gini %.4f", F_reset_p, lin$reset_f, bp_[4]))

# F incremental com a matriz de White: bloco de X3 e X4 recalculado
bl <- c(3, 4)  # posições de X3 e X4 em b (intercepto é a 1ª)
f_blk <- as.numeric(t(b[bl]) %*% solve(V_hc1[bl, bl], b[bl])) / length(bl)
fi <- le("resultados_econometricos/f_incremental_robusto.csv")
registrar("C17", "F incremental com erro de White (bloco X3 e X4) recalculado",
          abs(f_blk - fi$estatistica_f_white[grepl("^X3 e X4", fi$bloco)]) < 1e-6,
          sprintf("calculado %.4f; no arquivo %.4f", f_blk, fi$estatistica_f_white[grepl("^X3 e X4", fi$bloco)]))

# Intervalo da média no ponto médio dos regressores de 2021 (cenário base, matriz de White)
x2021 <- colMeans(X[painel$ano == 2021, ])
ep_x <- sqrt(as.numeric(t(x2021) %*% V_hc1 %*% x2021))
pm <- le("resultados_econometricos/previsao_media_2021.csv")
base_pm <- pm[pm$cenario == "Selic de 2021", ]
registrar("C18", "Intervalo da média da previsão (matriz de White, regressores médios de 2021) recalculado",
          abs((sum(x2021 * b) - qt(0.975, gl) * ep_x) - base_pm$ic_inf_ln_white) < 1e-8,
          sprintf("limite inferior calculado %.4f; no arquivo %.4f", sum(x2021 * b) - qt(0.975, gl) * ep_x, base_pm$ic_inf_ln_white))

# ============================== D. Documentação conferida com os CSV =============
doc_res <- readLines(pr("documentacao/03_resultados_modelos.md"), encoding = "UTF-8", warn = FALSE)
doc_diag <- readLines(pr("documentacao/04_diagnosticos.md"), encoding = "UTF-8", warn = FALSE)
f4 <- function(x) formatC(x, format = "f", digits = 4, decimal.mark = ",")
registrar("D1", "Coeficiente de X2 (erro de White) escrito na documentação igual ao CSV",
          any(grepl(f4(wh$estimativa[wh$termo == "prop_superior"]), doc_res, fixed = TRUE)),
          sprintf("valor esperado %s", f4(wh$estimativa[wh$termo == "prop_superior"])))
registrar("D2", "Estatística de Shapiro-Wilk escrita na documentação igual ao CSV",
          any(grepl(f4(nor$estatistica[1]), doc_diag, fixed = TRUE)),
          sprintf("valor esperado %s", f4(nor$estatistica[1])))

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
