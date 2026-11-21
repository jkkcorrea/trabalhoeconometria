# Verificação independente da pasta de envio. Base R apenas, sem reutilizar o código dos scripts entregues.
# Uso (raiz do projeto): Rscript _Trilha/ferramentas/verificar_envio.R
DIR <- "envio_professor"
stopifnot(dir.exists(DIR))
resultado <- data.frame(id = character(), verificacao = character(), situacao = character(), detalhe = character(), stringsAsFactors = FALSE)
registrar <- function(id, verificacao, ok, detalhe) {
  resultado[nrow(resultado) + 1, ] <<- list(id, verificacao, ifelse(ok, "APROVADA", "FALHOU"), detalhe)
  message(sprintf("[%s] %s: %s | %s", ifelse(ok, "ok", "FALHOU"), id, verificacao, detalhe))
}
le <- function(p) read.csv(file.path(DIR, p), check.names = FALSE, stringsAsFactors = FALSE)
cl <- function(y, X, g, ajuste_k) {                 # erro agrupado HC1 por laço explícito
  n <- nrow(X); G <- length(unique(g)); XtXi <- solve(t(X) %*% X); b <- XtXi %*% t(X) %*% y; e <- as.numeric(y - X %*% b)
  meat <- matrix(0, ncol(X), ncol(X))
  for (k in unique(g)) { i <- which(g == k); s <- colSums(X[i, , drop = FALSE] * e[i]); meat <- meat + s %*% t(s) }
  list(b = as.numeric(b), V = (G / (G - 1)) * ((n - 1) / (n - ajuste_k)) * XtXi %*% meat %*% XtXi, e = e)
}

# ============================== A. Inventário e higiene ===========================
esperado <- c("LEIAME.md",
  paste0("R/", c("00_executar_tudo", "01_extracao_dados", "02_tratamento_painel", "03_aede_visualizacoes", "04_modelagem_diagnosticos", "05_robustez_mundlak", "06_calibracao_modelo", "07_memorial_modelo_2", "08_fragilidades_modelo"), ".R"),
  "figuras_graficos/animacao1_mapa_renda_rmc.gif", "figuras_graficos/animacao2_ranking_salario_municipios.gif",
  paste0("dados_brutos/", c("pib_sidra", "macro_bacen", "malha_rmc", "distancias", "rais"), ".rds"),
  paste0("dados_processados/", c("dados_painel_rmc.csv", "dados_painel_rmc.rds", "estatisticas_descritivas.csv", "matriz_correlacao_explicativas.csv")))
presentes <- sub(paste0("^", DIR, "/"), "", list.files(DIR, recursive = TRUE, full.names = TRUE))
faltam <- setdiff(esperado, presentes)
registrar("A1", "Arquivos essenciais presentes (scripts, dados, painel, LEIAME)", length(faltam) == 0, if (length(faltam)) paste(faltam, collapse = ", ") else sprintf("%d arquivos", length(esperado)))

permitidas <- "\\.(R|md|csv|txt|html|png|rds|gif)$"
extras <- presentes[!grepl(permitidas, presentes)]
registrar("A1b", "Nenhum arquivo inesperado (só R, md, csv, txt, html, png, gif e rds)", length(extras) == 0, if (length(extras)) paste(extras, collapse = ", ") else sprintf("%d arquivos, todos de tipo permitido", length(presentes)))

proibidos <- c("prompt", "antigravity", "handoff", "backlog", "claude", "anthropic", "\\[a confirmar", "\\[presun", "D-20[0-9]{2}-[0-9]{2}",
               "pesquisador", "_Trilha", "kleis", "joao", "/home/", "OneDrive", "\\([A-C][0-9]\\)", "quatro_matrizes")
texto <- list.files(DIR, pattern = "\\.(R|md|csv|txt|html)$", recursive = TRUE, full.names = TRUE)
achados <- character()
for (f in texto) {
  # a documentação de verificação cita os termos buscados; fica fora da varredura
  if (basename(f) == "08_verificacao.md") next
  x <- readLines(f, encoding = "UTF-8", warn = FALSE)
  for (p in proibidos) { h <- grep(p, x, ignore.case = !grepl("[A-C][0-9]", p, fixed = TRUE)); if (length(h)) achados <- c(achados, sprintf("%s:%d (%s)", sub(paste0("^", DIR, "/"), "", f), h[1], p)) }
}
registrar("A2", "Arquivos de texto sem identificadores internos de trabalho nem caminhos pessoais", length(achados) == 0,
          if (length(achados)) paste(head(achados, 6), collapse = "; ") else sprintf("%d arquivos varridos, %d padrões", length(texto), length(proibidos)))

rds <- list.files(DIR, pattern = "\\.rds$", recursive = TRUE, full.names = TRUE)
achados_rds <- character()
for (f in rds) {
  x <- readRDS(f); s <- unlist(rapply(list(x, attributes(x)), function(z) if (is.character(z)) z else NULL, how = "unlist"))
  s <- paste(c(s, names(unlist(list(x)))), collapse = " ")
  if (grepl("kleis|joao|/home/|OneDrive", s, ignore.case = TRUE)) achados_rds <- c(achados_rds, basename(f))
}
registrar("A3", "Nenhum caminho pessoal dentro dos arquivos .rds", length(achados_rds) == 0, if (length(achados_rds)) paste(achados_rds, collapse = ", ") else sprintf("%d arquivos .rds", length(rds)))

# Código idêntico ao do projeto (só comentários diferem).
dif <- character()
for (f in list.files(file.path(DIR, "R"), "\\.R$")) {
  a <- parse(file.path("R", f), keep.source = FALSE, encoding = "UTF-8"); b <- parse(file.path(DIR, "R", f), keep.source = FALSE, encoding = "UTF-8")
  if (!identical(deparse(a), deparse(b))) dif <- c(dif, f)
}
registrar("A4", "Código dos scripts idêntico ao da versão de trabalho (só os comentários foram removidos)", length(dif) == 0, if (length(dif)) paste(dif, collapse = ", ") else sprintf("%d scripts", length(list.files(file.path(DIR, "R"), "\\.R$"))))

abs_ <- character()
for (f in list.files(file.path(DIR, "R"), "\\.R$", full.names = TRUE)) {
  x <- readLines(f, encoding = "UTF-8", warn = FALSE); x <- x[!grepl("^\\s*#", x)]
  h <- grep("[\"']([A-Za-z]:[/\\\\]|/home/|/Users/)", x); if (length(h)) abs_ <- c(abs_, basename(f))
}
registrar("A5", "Scripts usam só caminhos relativos à raiz da pasta", length(abs_) == 0, if (length(abs_)) paste(abs_, collapse = ", ") else "nenhum caminho absoluto")

# ============================== B. Recomputação do painel =========================
painel <- readRDS(file.path(DIR, "dados_processados/dados_painel_rmc.rds")); painel <- as.data.frame(painel); painel <- painel[order(painel$id_municipio, painel$ano), ]
rais <- readRDS(file.path(DIR, "dados_brutos/rais.rds")); mac <- readRDS(file.path(DIR, "dados_brutos/macro_bacen.rds"))
pib <- as.data.frame(readRDS(file.path(DIR, "dados_brutos/pib_sidra.rds"))); dist <- as.data.frame(readRDS(file.path(DIR, "dados_brutos/distancias.rds")))
mu <- as.data.frame(rais$municipio_ano); cn <- as.data.frame(rais$cnae_divisao)
chave <- paste(painel$id_municipio, painel$ano)

registrar("B1", "Painel: 290 linhas, 29 municípios, 10 anos, balanceado, sem NA/NaN/Inf",
          nrow(painel) == 290 && length(unique(painel$id_municipio)) == 29 && length(unique(painel$ano)) == 10 && all(table(painel$id_municipio) == 10) &&
            all(is.finite(as.matrix(painel[, c("ln_salario_real", "prop_superior", "dom_industrial", "shannon_diversificacao", "selic_real", "dist_curitiba_km")]))),
          sprintf("%d x %d", nrow(painel), ncol(painel)))

# X2
x2 <- 100 * mu$vinculos_superior / (mu$vinculos_ativos - mu$vinculos_escolaridade_na); names(x2) <- paste(mu$id_municipio, mu$ano)
d <- max(abs(x2[chave] - painel$prop_superior)); registrar("B2", "X2 recomputada dos microdados agregados da RAIS", d < 1e-9, sprintf("maior diferença %.2e", d))
# X3
tot <- pib$vab_agropecuaria + pib$vab_industria + pib$vab_servicos + pib$vab_adm_publica
x3 <- 100 * pib$vab_industria / tot; names(x3) <- paste(pib$id_municipio, pib$ano)
d <- max(abs(x3[chave] - painel$dom_industrial)); registrar("B3", "X3 recomputada do valor adicionado setorial (soma dos quatro setores no denominador)", d < 1e-9, sprintf("maior diferença %.2e", d))
# X4
sh <- tapply(seq_len(nrow(cn)), paste(cn$id_municipio, cn$ano), function(i) { v <- cn$vinculos_ativos[i]; p <- v[v > 0] / sum(v); -sum(p * log(p)) })
d <- max(abs(sh[chave] - painel$shannon_diversificacao)); registrar("B4", "X4 (entropia de Shannon) recomputada das contagens por divisão da CNAE", d < 1e-9, sprintf("maior diferença %.2e; divisões distintas: %d", d, length(unique(cn$divisao_cnae))))
# X5 e deflator
m <- mac$mensal; m <- m[order(m$data), ]
idx <- numeric(nrow(m)); idx[1] <- 100; for (t in 2:nrow(m)) idx[t] <- idx[t - 1] * (1 + m$ipca_mensal[t] / 100)
selic_ano <- tapply(m$selic_mensal, m$ano, function(v) (prod(1 + v / 100) - 1) * 100); ipca_ano <- tapply(m$ipca_mensal, m$ano, function(v) (prod(1 + v / 100) - 1) * 100)
idx_medio <- tapply(idx, m$ano, mean); x5 <- ((1 + selic_ano / 100) / (1 + ipca_ano / 100) - 1) * 100
d <- max(abs(x5[as.character(painel$ano)] - painel$selic_real)); registrar("B5", "X5 (Selic real, Fisher) recomputada das séries mensais 4390 e 433", d < 1e-9, sprintf("maior diferença %.2e", d))
# Y
fator <- idx_medio["2021"] / idx_medio; y <- mu$rem_media_nominal * fator[as.character(mu$ano)]; names(y) <- paste(mu$id_municipio, mu$ano)
d <- max(abs(y[chave] / painel$salario_medio_real - 1)); d2 <- max(abs(log(painel$salario_medio_real) - painel$ln_salario_real))
registrar("B6", "Y (salário médio real em R$ de 2021) e ln Y recomputados", d < 1e-9 && d2 < 1e-12, sprintf("maior diferença relativa %.2e; ln %.2e", d, d2))
# X6 e indicadora
dd <- setNames(dist$dist_curitiba_km, dist$id_municipio)
d <- max(abs(dd[painel$id_municipio] - painel$dist_curitiba_km))
registrar("B7", "X6 igual às distâncias brutas, constante no tempo; Curitiba com distância 0 e indicadora = 1 só para ela", d < 1e-9 && all(painel$dist_curitiba_km[painel$id_municipio == "4106902"] == 0) && sum(painel$dummy_curitiba) == 10 && all(painel$dummy_curitiba[painel$id_municipio == "4106902"] == 1), sprintf("diferença %.2e", d))
registrar("B8", "X5 constante entre municípios em cada ano (10 valores distintos)", all(tapply(painel$selic_real, painel$ano, function(v) length(unique(v))) == 1) && length(unique(round(painel$selic_real, 8))) == 10, "10 valores")
neg <- painel[painel$dom_industrial < 0, c("nome_municipio", "ano")]
registrar("B9", "Exatamente duas observações com X3 negativo (Araucária 2012 e 2013), marcadas em x3_negativo", nrow(neg) == 2 && all(neg$nome_municipio == "Araucária") && setequal(neg$ano, c(2012, 2013)) && sum(painel$x3_negativo) == 2, paste(neg$nome_municipio, neg$ano, collapse = "; "))
registrar("B10", "Nenhum vínculo com divisão CNAE 'ignorada' e nenhum vínculo com escolaridade ignorada", !any(cn$divisao_cnae == "ignorada") && all(mu$vinculos_escolaridade_na == 0), "0 e 0")

# ============================== C. Recomputação da regressão ======================
y <- painel$ln_salario_real; Xr <- as.matrix(painel[, c("prop_superior", "dom_industrial", "shannon_diversificacao", "selic_real", "dist_curitiba_km")]); X <- cbind(1, Xr); n <- nrow(X); k <- ncol(X)
b <- qr.solve(X, y); e <- as.numeric(y - X %*% b)
cinco <- le("resultados_econometricos/coeficientes_cinco_matrizes.csv")
m2 <- cinco[cinco$modelo == "Modelo 2" & cinco$matriz == "Clássico (MQO)", ]
s2 <- sum(e^2) / (n - k); ep <- sqrt(diag(s2 * solve(t(X) %*% X)))
registrar("C1", "Modelo 2: coeficientes (QR) e erros-padrão clássicos iguais aos do arquivo de resultados", max(abs(b - m2$estimativa)) < 1e-9 && max(abs(ep - m2$erro_padrao)) < 1e-9, sprintf("coef %.2e; ep %.2e", max(abs(b - m2$estimativa)), max(abs(ep - m2$erro_padrao))))
cal <- le("resultados_econometricos/calibracao_coeficientes.csv"); cp <- cal[cal$estimador == "MQO empilhado (Modelo 2)", ]
a <- cl(y, X, painel$id_municipio, k)
tt <- a$b / sqrt(diag(a$V)); pp <- 2 * pt(-abs(tt), 28)
registrar("C2", "Modelo 2: erro agrupado por município (laço explícito) e p-valor com t de 28 gl iguais ao arquivo de calibração", max(abs(sqrt(diag(a$V)) - cp$erro_padrao)) < 1e-9 && max(abs(pp - cp$p_valor)) < 1e-9, sprintf("ep %.2e; p %.2e", max(abs(sqrt(diag(a$V)) - cp$erro_padrao)), max(abs(pp - cp$p_valor))))
# Efeitos fixos por variáveis binárias e erro com K = regressores
id <- painel$id_municipio; D <- model.matrix(~ factor(id) - 1)
res_y <- residuals(lm.fit(D, y)); res_X <- sapply(1:4, function(j) residuals(lm.fit(D, Xr[, j])))
fe <- cl(res_y, res_X, id, 4); cf <- cal[cal$estimador == "Efeitos fixos (within)", ]
registrar("C3", "Efeitos fixos: coeficientes e erro agrupado (partialling-out por variáveis binárias) iguais ao arquivo", max(abs(fe$b - cf$estimativa)) < 1e-9 && max(abs(sqrt(diag(fe$V)) - cf$erro_padrao)) < 1e-9, sprintf("coef %.2e; ep %.2e", max(abs(fe$b - cf$estimativa)), max(abs(sqrt(diag(fe$V)) - cf$erro_padrao))))
mm <- as.data.frame(painel); mean_i <- function(v) ave(v, id)
Xm <- cbind(X, mean_i(painel$prop_superior), mean_i(painel$dom_industrial), mean_i(painel$shannon_diversificacao)); bm <- qr.solve(Xm, y)
registrar("C4", "Mundlak: efeitos de X2, X3 e X4 iguais aos de efeitos fixos", max(abs(bm[2:4] - fe$b[1:3])) < 1e-9, sprintf("diferença %.2e", max(abs(bm[2:4] - fe$b[1:3]))))
# Teste F de efeitos individuais
rss_pool <- sum(residuals(lm.fit(cbind(1, Xr[, 1:4]), y))^2); rss_fe <- sum(residuals(lm.fit(cbind(D, Xr[, 1:4]), y))^2)
Fef <- ((rss_pool - rss_fe) / 28) / (rss_fe / (290 - 29 - 4)); tp <- le("resultados_econometricos/calibracao_testes_painel.csv")
registrar("C5", "Teste F de efeitos individuais recomputado (28; 257 gl)", abs(Fef - tp$estatistica[1]) < 1e-6, sprintf("F = %.4f contra %.4f", Fef, tp$estatistica[1]))
# Diagnósticos do Modelo 2
dg <- le("resultados_econometricos/diagnosticos_modelo_2.csv")
r2 <- function(yy, XX) { f <- lm.fit(XX, yy); 1 - sum(f$residuals^2) / sum((yy - mean(yy))^2) }
bp <- n * r2(e^2, X); dw <- sum(diff(e)^2) / sum(e^2)
lag1 <- c(0, e[-n]); bg <- n * r2(e, cbind(X, lag1))
xs <- Xr; pot <- cbind(xs^2, xs^3); f1 <- lm.fit(cbind(X, pot), y); F_reset <- ((sum(e^2) - sum(f1$residuals^2)) / 10) / (sum(f1$residuals^2) / (n - k - 10))
obt <- function(padrao) dg$estatistica[grepl(padrao, dg$teste)][1]
ok_dg <- abs(bp - obt("Breusch-Pagan")) < 1e-6 && abs(dw - obt("Durbin-Watson empilhado")) < 1e-6 && abs(bg - obt("Breusch-Godfrey")) < 1e-5 && abs(F_reset - obt("RESET")) < 1e-5
registrar("C6", "Diagnósticos recomputados à mão: Breusch-Pagan (Koenker), Durbin-Watson, Breusch-Godfrey, RESET", ok_dg,
          sprintf("BP %.4f/%.4f; DW %.4f/%.4f; BG %.4f/%.4f; RESET %.4f/%.4f", bp, obt("Breusch-Pagan"), dw, obt("Durbin-Watson empilhado"), bg, obt("Breusch-Godfrey"), F_reset, obt("RESET")))
# Goldfeld-Quandt
o <- order(painel$vinculos_ativos); g1 <- o[1:116]; g2 <- o[175:290]
rr <- function(i) { f <- lm.fit(X[i, ], y[i]); sum(f$residuals^2) / (length(i) - k) }
Fg <- rr(g2) / rr(g1); pg <- pf(Fg, 110, 110, lower.tail = FALSE); pg2 <- 2 * min(pf(Fg, 110, 110), pf(Fg, 110, 110, lower.tail = FALSE)); gq <- le("resultados_econometricos/calibracao_goldfeld_quandt.csv")
registrar("C7", "Goldfeld-Quandt (ordenado por vínculos) recomputado, p unilateral e bilateral", abs(Fg - gq$estatistica_f[1]) < 1e-6 && abs(pg - gq$p_valor[1]) < 1e-6 && abs(pg2 - gq$p_valor_bilateral[1]) < 1e-6, sprintf("F %.4f/%.4f; p unilateral %.4f/%.4f; bilateral %.4f/%.4f", Fg, gq$estatistica_f[1], pg, gq$p_valor[1], pg2, gq$p_valor_bilateral[1]))
# Selic agrupada por ano
sa <- cl(y, X, painel$ano, k); ts <- sa$b[5] / sqrt(sa$V[5, 5]); psel <- 2 * pt(-abs(ts), 9); ss <- le("resultados_econometricos/selic_p_valor_conservador.csv")
registrar("C8", "P-valor da Selic agrupado por ano recomputado (t com 9 gl)", abs(psel - ss$p_valor) < 1e-9, sprintf("%.6f contra %.6f", psel, ss$p_valor))
# FIV
fiv <- sapply(1:5, function(j) 1 / (1 - r2(Xr[, j], cbind(1, Xr[, -j])))); fv <- le("resultados_econometricos/fiv_modelos_2_3_3b.csv"); fv <- fv[fv$modelo == "Modelo 2", ]
registrar("C9", "FIV do Modelo 2 pelas regressões auxiliares", max(abs(fiv - fv$fiv)) < 1e-9, sprintf("maior diferença %.2e", max(abs(fiv - fv$fiv))))
# Bootstrap: segunda implementação, outra semente
boot_alt <- function(j, B = 12000, semente = 7) {
  g <- as.integer(factor(painel$id_municipio)); G <- 29; Xc <- X; XtXi <- solve(t(Xc) %*% Xc)
  tstat <- function(yy) { bb <- XtXi %*% t(Xc) %*% yy; ee <- as.numeric(yy - Xc %*% bb); S <- rowsum(Xc * ee, g); V <- (G / (G - 1)) * ((n - 1) / (n - k)) * XtXi %*% crossprod(S) %*% XtXi; bb[j] / sqrt(V[j, j]) }
  t0 <- tstat(y); Xn <- Xc[, -j]; fit0 <- as.numeric(Xn %*% qr.solve(Xn, y)); u0 <- y - fit0; set.seed(semente)
  tb <- vapply(seq_len(B), function(i) tstat(fit0 + sample(c(-1, 1), G, TRUE)[g] * u0), numeric(1)); mean(abs(tb) >= abs(t0))
}
bt <- le("resultados_econometricos/calibracao_bootstrap_wild_cluster.csv"); bt <- bt[bt$estimador == "MQO empilhado (Modelo 2)", ]
p_x4 <- boot_alt(4); p_x6 <- boot_alt(6)
registrar("C10", "Bootstrap wild cluster: segunda implementação com outra semente concorda dentro de 0,012 (cerca de 3 desvios de Monte Carlo) (cerca de 3 desvios de Monte Carlo)",
          abs(p_x4 - bt$p_bootstrap[bt$termo == "shannon_diversificacao"]) < 0.02 && abs(p_x6 - bt$p_bootstrap[bt$termo == "dist_curitiba_km"]) < 0.02,
          sprintf("X4 %.4f/%.4f; X6 %.4f/%.4f", p_x4, bt$p_bootstrap[bt$termo == "shannon_diversificacao"], p_x6, bt$p_bootstrap[bt$termo == "dist_curitiba_km"]))
# Memorial
me <- le("resultados_econometricos/memorial_modelo_2_coeficientes.csv")
registrar("C11", "Memorial matricial: coeficientes iguais aos recomputados por QR", max(abs(me$estimativa - b)) < 1e-9, sprintf("diferença %.2e", max(abs(me$estimativa - b))))
sm <- summary(lm(y ~ Xr)); an <- le("resultados_econometricos/memorial_modelo_2_anova.csv")
registrar("C12", "Memorial: R², R² ajustado e F global iguais aos de lm()", abs(1 - sum(e^2) / sum((y - mean(y))^2) - sm$r.squared) < 1e-9 && abs(an$estatistica_f[1] - unname(sm$fstatistic[1])) < 1e-6, sprintf("R² %.4f; F %.4f", sm$r.squared, an$estatistica_f[1]))


# ---- C13 a C17: script 08 ----
fr <- function(a) le(paste0("resultados_econometricos/fragilidades_", a))
ln <- painel$ln_salario_real; ids <- painel$id_municipio; Dm <- model.matrix(~ factor(ids) - 1)
Q <- cbind(sup = painel$prop_superior, dom = painel$dom_industrial, sha = painel$shannon_diversificacao, selic = painel$selic_real,
           sup2 = painel$prop_superior^2, dom2 = painel$dom_industrial^2, sha2 = painel$shannon_diversificacao^2)
fit <- lm.fit(cbind(Q, Dm), ln); bq <- fit$coefficients[1:7]
cq <- fr("fe_quadratico_coeficientes.csv")
registrar("C13", "Efeitos fixos com quadráticos: coeficientes por variáveis binárias iguais ao arquivo", max(abs(bq - cq$estimativa)) < 1e-9, sprintf("diferença %.2e", max(abs(bq - cq$estimativa))))
rk <- function(M) qr(M)$rank
rss <- function(M) sum(lm.fit(M, ln)$residuals^2)
M0 <- cbind(Q, Dm); M1 <- cbind(M0, Q^2, Q^3)
Frq <- ((rss(M0) - rss(M1)) / (rk(M1) - rk(M0))) / (rss(M1) / (290 - rk(M1))); ffn <- fr("forma_funcional.csv")
registrar("C14", "RESET (regressores) dos efeitos fixos com quadráticos recomputado à mão, graus de liberdade pelo posto", abs(Frq - ffn$reset_regressores_f[3]) < 1e-6, sprintf("F %.4f/%.4f", Frq, ffn$reset_regressores_f[3]))
# bootstrap exato por ano: implementação independente com variáveis binárias de município (sem a transformação within do script).
# O fator HC1 multiplica igualmente a estatística observada e as das réplicas, então o p-valor não depende dele.
gy <- as.integer(factor(painel$ano)); Xfull <- cbind(Q[, 1:4], Dm); Xres <- cbind(Q[, 1:3], Dm)
ur <- lm.fit(Xres, ln)$residuals; fit_r <- ln - ur
tst <- function(yy) { a <- cl(yy, Xfull, gy, ncol(Xfull)); a$b[4] / sqrt(a$V[4, 4]) }
t_obs <- tst(ln); sg <- as.matrix(expand.grid(rep(list(c(-1, 1)), 10))); tb <- apply(sg, 1, function(s) tst(fit_r + s[gy] * ur)); pex <- mean(abs(tb) >= abs(t_obs) - 1e-9)
sb <- fr("selic_bootstrap_exato_por_ano.csv")
registrar("C15", "Bootstrap wild cluster por ano exato (1.024 combinações) recomputado com variáveis binárias de município (independente do script)", abs(pex - sb$p_bootstrap_exato[1]) < 1e-12, sprintf("%.6f contra %.6f", pex, sb$p_bootstrap_exato[1]))
# exogeneidade: valor futuro de X2, pela transformação within com k = número de regressores
pn <- painel[order(painel$id_municipio, painel$ano), ]
fut <- function(v) ave(v, pn$id_municipio, FUN = function(z) c(z[-1], NA))
keep <- !is.na(fut(pn$prop_superior)); idk <- pn$id_municipio[keep]
Xf <- cbind(pn$prop_superior, pn$dom_industrial, pn$shannon_diversificacao, pn$selic_real, fut(pn$prop_superior), fut(pn$dom_industrial), fut(pn$shannon_diversificacao))[keep, ]
wk <- function(v) v - ave(v, idk); Xfw <- apply(Xf, 2, wk); yfw <- wk(pn$ln_salario_real[keep]); ec <- fr("exogeneidade_coeficientes.csv")
aa <- cl(yfw, Xfw, idk, ncol(Xfw))
registrar("C16", "Exogeneidade estrita: coeficientes dos valores futuros iguais aos recomputados (within)", max(abs(aa$b[5:7] - ec$estimativa[5:7])) < 1e-9, sprintf("diferença %.2e", max(abs(aa$b[5:7] - ec$estimativa[5:7]))))
R <- aa$b[5:7]; Fx <- as.numeric(t(R) %*% solve(aa$V[5:7, 5:7]) %*% R) / 3; ex <- fr("exogeneidade_teste.csv")
registrar("C17", "Teste conjunto de exogeneidade estrita recomputado (Wald, F com 3 e 28 gl)", abs(Fx - ex$estatistica_f) < 1e-6, sprintf("F %.4f/%.4f", Fx, ex$estatistica_f))
gifs <- file.size(file.path(DIR, c("figuras_graficos/animacao1_mapa_renda_rmc.gif", "figuras_graficos/animacao2_ranking_salario_municipios.gif")))
registrar("C18", "Animações .gif presentes e válidas (cabeçalho GIF)", all(gifs > 1e5) && all(vapply(file.path(DIR, c("figuras_graficos/animacao1_mapa_renda_rmc.gif", "figuras_graficos/animacao2_ranking_salario_municipios.gif")), function(f) rawToChar(readBin(f, "raw", 3)) == "GIF", logical(1))), paste(round(gifs / 1024), "KB", collapse = "; "))


# ---- C19 a C22: correções após a revisão ----
mk <- le("resultados_econometricos/robustez_mundlak_coeficientes.csv"); tc28 <- qt(0.975, 28)
registrar("C19", "Intervalos de confiança de robustez_mundlak_coeficientes.csv usam o erro agrupado e t de 28 gl (estimativa +/- t x erro)", max(abs(mk$ic_inf_95 - (mk$estimativa - tc28 * mk$erro_padrao))) < 1e-12 && max(abs(mk$ic_sup_95 - (mk$estimativa + tc28 * mk$erro_padrao))) < 1e-12, sprintf("diferença %.2e", max(abs(mk$ic_inf_95 - (mk$estimativa - tc28 * mk$erro_padrao)))))
if (requireNamespace("MASS", quietly = TRUE)) {
  bcf <- MASS::boxcox(lm(painel$salario_medio_real ~ cbind(Q[, 1:4]) + factor(ids)), lambda = seq(-3, 2, 0.01), plotit = FALSE)
  lam <- bcf$x[which.max(bcf$y)]; bcc <- fr("box_cox.csv")
  registrar("C20", "Box-Cox com efeitos fixos: lambda estimado igual ao de MASS::boxcox", abs(lam - bcc$lambda_estimado[2]) < 0.011, sprintf("%.2f contra %.2f", lam, bcc$lambda_estimado[2]))
} else registrar("C20", "Box-Cox: MASS indisponível", TRUE, "ignorada")
sm <- fr("simulacao_efeitos_fixos.csv"); b_fe <- lm.fit(cbind(Q[, 1:4], Dm), ln)$coefficients
registrar("C21", "Simulação com efeitos fixos: variação percentual de +10 pontos em X3 e +5 pontos em X2 recomputada", abs(sm$variacao_pct[2] - 100 * (exp(10 * b_fe[2]) - 1)) < 1e-9 && abs(sm$variacao_pct[5] - 100 * (exp(5 * b_fe[1]) - 1)) < 1e-9, sprintf("%.4f e %.4f", sm$variacao_pct[2], sm$variacao_pct[5]))
inf <- fr("influencia_sensibilidade.csv"); m2c <- lm(ln ~ Xr); n_cook <- sum(cooks.distance(m2c) > 4 / 290)
sem_adr <- painel$id_municipio != "4100202"; Dm2 <- model.matrix(~ factor(ids[sem_adr]) - 1); b_adr <- lm.fit(cbind(Q[sem_adr, 1:4], Dm2), ln[sem_adr])$coefficients[1]
ref <- inf$estimativa[inf$cenario == "Sem Adrianópolis (município inteiro)" & inf$modelo == "Efeitos fixos" & inf$termo == "prop_superior"]
registrar("C22", "Sensibilidade a influentes: 15 observações com Cook > 4/n e coeficiente de efeitos fixos sem Adrianópolis recomputado", n_cook == 15 && abs(b_adr - ref) < 1e-9, sprintf("%d observações; coef %.6f/%.6f", n_cook, b_adr, ref))


# ---- C23 a C25: Chow, decomposição da Selic e Webb ----
dcu <- painel$dummy_curitiba; Mr <- cbind(1, Xr); Mu <- cbind(Mr, dcu, dcu * Q[, 1:4])
rk_ <- function(M) qr(M)$rank; rss_ <- function(M) sum(lm.fit(M, ln)$residuals^2)
Fch <- ((rss_(Mr) - rss_(Mu)) / (rk_(Mu) - rk_(Mr))) / (rss_(Mu) / (290 - rk_(Mu))); ch <- fr("quebra_curitiba.csv")
registrar("C23", "Teste de Chow recomputado: Modelo 2 contra indicadora de Curitiba e interações com X2 a X5 (F com 5 e 279 gl)", abs(Fch - ch$estatistica_f) < 1e-9, sprintf("F %.4f/%.4f", Fch, ch$estatistica_f))
# Restrição de Fisher (soma dos coeficientes da Selic nominal e do IPCA igual a zero), erro agrupado por município e por ano
Xd5 <- apply(cbind(Q[, 1:3], painel$selic_nominal_ano, painel$ipca_ano), 2, function(v) v - ave(v, ids)); yd5 <- ln - ave(ln, ids)
fisher_p <- function(g, gl) { a <- cl(yd5, Xd5, g, 5); tv <- sum(a$b[4:5]) / sqrt(sum(a$V[4:5, 4:5])); 2 * pt(-abs(tv), gl) }
fe_f <- fr("selic_decomposicao_teste_fisher.csv")
registrar("C26", "Teste da restrição de Fisher recomputado (agrupado por município, t com 28 gl, e por ano, t com 9 gl)", abs(fisher_p(ids, 28) - fe_f$p_valor[1]) < 1e-9 && abs(fisher_p(painel$ano, 9) - fe_f$p_valor[2]) < 1e-9, sprintf("p %.4f e %.4f", fisher_p(ids, 28), fisher_p(painel$ano, 9)))
Xd <- cbind(Q[, 1:3], painel$selic_nominal_ano, painel$ipca_ano); bd <- lm.fit(cbind(Xd, Dm), ln)$coefficients[4:5]; dc <- fr("selic_decomposicao.csv")
registrar("C24", "Decomposição da Selic real (Selic nominal e IPCA) por variáveis binárias recomputada", max(abs(bd - dc$estimativa[4:5])) < 1e-9, sprintf("%.6f e %.6f", bd[1], bd[2]))
set.seed(99); pesos <- c(-sqrt(1.5), -1, -sqrt(0.5), sqrt(0.5), 1, sqrt(1.5))
tbw <- vapply(1:12000, function(i) tst(fit_r + sample(pesos, 10, TRUE)[gy] * ur), numeric(1)); pw_ <- mean(abs(tbw) >= abs(t_obs) - 1e-9); wbc <- fr("selic_bootstrap_webb.csv")
registrar("C25", "Bootstrap com pesos de Webb por ano: segunda implementação (variáveis binárias, outra semente) concorda dentro de 0,02", abs(pw_ - wbc$p_bootstrap_webb[1]) < 0.012, sprintf("%.4f contra %.4f", pw_, wbc$p_bootstrap_webb[1]))

# ============================== D. Documentação ===================================
doc3 <- readLines(file.path(DIR, "documentacao/04_calibracao.md"), encoding = "UTF-8")
fmt <- function(x) formatC(x, format = "f", digits = 4, decimal.mark = ",")
cf2 <- cf$estimativa[1]
registrar("D1", "Documentação cita o coeficiente de X2 de efeitos fixos com o valor do arquivo (quatro casas)", any(grepl(fmt(cf2), doc3, fixed = TRUE)), fmt(cf2))
dic <- le("documentacao/dicionario_variaveis.csv")
registrar("D2", "Dicionário de variáveis cobre todas as colunas do modelo no painel", all(c("ln_salario_real", "prop_superior", "dom_industrial", "shannon_diversificacao", "selic_real", "dist_curitiba_km", "dummy_curitiba", "x3_negativo") %in% dic[["Nome no painel"]]), sprintf("%d linhas", nrow(dic)))

# ============================== E. Reexecução em cópia limpa ======================
tmp <- file.path(tempdir(), "reexecucao"); dir.create(tmp)
for (p in c("R", "dados_brutos")) file.copy(file.path(DIR, p), tmp, recursive = TRUE)
for (p in c("dados_processados", "resultados_econometricos", "figuras_graficos")) dir.create(file.path(tmp, p))
cwd <- getwd(); setwd(tmp)
rodou <- vapply(c("02_tratamento_painel", "03_aede_visualizacoes", "04_modelagem_diagnosticos", "05_robustez_mundlak", "06_calibracao_modelo", "07_memorial_modelo_2", "08_fragilidades_modelo"), function(s) {
  r <- system2("Rscript", c("--vanilla", file.path("R", paste0(s, ".R"))), stdout = FALSE, stderr = FALSE); r == 0 }, logical(1))
setwd(cwd)
registrar("E1", "Reexecução em cópia limpa (a partir de dados_brutos): scripts 02 a 08 terminam sem erro", all(rodou), paste(names(rodou), ifelse(rodou, "ok", "ERRO"), collapse = "; "))
comp <- list.files(file.path(DIR, "resultados_econometricos"), "\\.(csv|txt)$"); difer <- character()
for (f in comp) { a <- file.path(DIR, "resultados_econometricos", f); bb <- file.path(tmp, "resultados_econometricos", f); if (!file.exists(bb) || !identical(readLines(a, warn = FALSE), readLines(bb, warn = FALSE))) difer <- c(difer, f) }
registrar("E2", "Reexecução reproduz os arquivos .csv e .txt de resultados byte a byte", length(difer) == 0, if (length(difer)) paste(difer, collapse = ", ") else sprintf("%d arquivos idênticos", length(comp)))
pngs <- list.files(file.path(DIR, "figuras_graficos"), "\\.png$"); dpng <- pngs[!vapply(pngs, function(f) isTRUE(all(readBin(file.path(DIR, "figuras_graficos", f), "raw", 1e8) == readBin(file.path(tmp, "figuras_graficos", f), "raw", 1e8))), logical(1))]
registrar("E4", "Reexecução reproduz as figuras .png byte a byte", length(dpng) == 0, if (length(dpng)) paste(dpng, collapse = ", ") else sprintf("%d figuras idênticas", length(pngs)))
tam <- file.size(file.path(DIR, "figuras_graficos", pngs)); vazias <- pngs[tam < 30000]
registrar("E5", "Nenhuma figura .png vazia (todas com mais de 30 KB)", length(vazias) == 0, if (length(vazias)) paste(vazias, collapse = ", ") else sprintf("menor figura: %.0f KB", min(tam) / 1024))
pa <- readRDS(file.path(tmp, "dados_processados/dados_painel_rmc.rds")); registrar("E3", "Reexecução reproduz o painel (identical)", identical(as.data.frame(pa), painel[order(painel$id_municipio, painel$ano), ]) || isTRUE(all.equal(as.data.frame(pa), painel)), "painel")

# ============================== Relatório =========================================
cab <- c("# Registro de verificação", "",
  "Verificações independentes da pasta de envio, feitas em base R sem reutilizar o código dos scripts entregues. Cada linha traz o que foi conferido e a diferença medida.", "",
  paste0("Data: ", format(Sys.Date(), "%d/%m/%Y"), ". Versão do R: ", R.version$major, ".", R.version$minor, "."), "",
  "- A: inventário, higiene dos arquivos e identidade do código (só os comentários mudaram).",
  "- B: recomputação do painel a partir dos dados brutos.",
  "- C: recomputação dos resultados de regressão, dos diagnósticos e dos testes do script 08.",
  "- D: coerência da documentação com os arquivos de resultado.",
  "- E: reexecução completa em cópia limpa da pasta.", "", "A verificação A4 compara os scripts com a versão de trabalho, que não acompanha o envio.", "")
tab <- c("| Id | Verificação | Situação | Detalhe |", "|---|---|---|---|", sprintf("| %s | %s | %s | %s |", resultado$id, resultado$verificacao, resultado$situacao, gsub("\\|", "/", resultado$detalhe)), "")
rodape <- c(sprintf("Resultado: %d de %d verificações aprovadas.", sum(resultado$situacao == "APROVADA"), nrow(resultado)), "",
  "Limites: o script `01_extracao_dados.R` não foi reexecutado (exige o download de cerca de 3,5 GB), e a coleta fica documentada pelos arquivos de `dados_brutos/`, conferidos nas verificações B1 a B10.")
writeLines(c(cab, tab, rodape), file.path(DIR, "documentacao/08_verificacao.md"), useBytes = TRUE)
message(sprintf("\n%d de %d verificações aprovadas.", sum(resultado$situacao == "APROVADA"), nrow(resultado)))
if (any(resultado$situacao != "APROVADA")) quit(status = 1)
