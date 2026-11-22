# =============================================================================
# Etapa 7: memorial de cálculo matricial do Modelo 2
#
# Reproduz, em forma matricial, a estimação do Modelo 2 por mínimos quadrados
# ordinários e confere cada resultado contra stats::lm():
#   ln(Y_it) = b1 + b2 X2 + b3 X3 + b4 X4 + b5 X5 + b6 X6 + u_it
#
# Conteúdo: X'X e seu determinante, (X'X)^-1, X'y, vetor de estimativas, soma
# dos quadrados dos resíduos, s^2, matriz de variância e covariância, quadro de
# análise de variância, testes t e F com hipóteses H0 e Ha, intervalos de
# confiança, fatores de inflação da variância, coeficientes de determinação
# parcial, teste F de contribuição incremental e previsão.
#
# Todos os valores do memorial são apresentados com quatro casas decimais.
#
# Lê:    ./dados_processados/dados_painel_rmc.rds
# Grava: ./resultados_econometricos/memorial_modelo_2.txt
#        ./resultados_econometricos/memorial_modelo_2_*.csv
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
  biblioteca_usuario <- file.path(
    base_usuario,
    paste(R.version$major, strsplit(R.version$minor, ".", fixed = TRUE)[[1]][1], sep = ".")
  )
}
if (dir.exists(biblioteca_usuario)) .libPaths(c(biblioteca_usuario, .libPaths()))

for (p in c("dplyr", "tibble", "readr", "stringr", "lmtest")) {
  if (!requireNamespace(p, quietly = TRUE)) stop("Pacote ausente: ", p, call. = FALSE)
}

DIR_RESULTADOS <- "./resultados_econometricos"
ARQ_PAINEL     <- "./dados_processados/dados_painel_rmc.rds"
ALFA           <- 0.05
REGRESSORES    <- c("prop_superior", "dom_industrial", "gini_setorial",
                    "selic_real", "dist_curitiba_km")
NOMES_X <- c("X2 (ensino superior)", "X3 (dominância industrial)", "X4 (concentração setorial, Gini)",
             "X5 (Selic real)", "X6 (distância a Curitiba)")

fmt4 <- function(x) formatC(x, format = "f", digits = 4, decimal.mark = ",", big.mark = "")
fmt_p <- function(p) ifelse(p < 0.0001, "< 0,0001", fmt4(p))


# -----------------------------------------------------------------------------
# Dados
# -----------------------------------------------------------------------------
dados <- readRDS(ARQ_PAINEL) |>
  tibble::as_tibble() |>
  dplyr::mutate(id_municipio = stringr::str_pad(as.character(id_municipio), 7, pad = "0"),
                ano = as.integer(ano)) |>
  dplyr::arrange(id_municipio, ano)
if (nrow(dados) != 290L) stop("O painel deve ter 290 linhas.", call. = FALSE)
if (any(!is.finite(as.matrix(dados[, c("ln_salario_real", REGRESSORES)])))) {
  stop("Há NA, NaN ou Inf nas variáveis do modelo.", call. = FALSE)
}

y <- dados$ln_salario_real
X <- cbind(`(Intercept)` = 1, as.matrix(as.data.frame(dados)[, REGRESSORES]))
n <- nrow(X)
k <- ncol(X)
gl <- n - k


# -----------------------------------------------------------------------------
# Cálculo matricial
# -----------------------------------------------------------------------------
XtX     <- crossprod(X)
det_XtX <- det(XtX)
XtX_inv <- solve(XtX)
Xty     <- crossprod(X, y)
beta    <- XtX_inv %*% Xty
yty     <- sum(y^2)
SQR     <- as.numeric(yty - t(beta) %*% Xty)
s2      <- SQR / gl
V       <- s2 * XtX_inv
ep      <- sqrt(diag(V))
ybar    <- mean(y)
STC     <- yty - n * ybar^2
SEC     <- STC - SQR
R2      <- SEC / STC
R2aj    <- 1 - (SQR / gl) / (STC / (n - 1))
F_glob  <- (SEC / (k - 1)) / s2
p_F     <- stats::pf(F_glob, k - 1, gl, lower.tail = FALSE)
t_val   <- as.numeric(beta) / ep
p_t     <- 2 * stats::pt(-abs(t_val), gl)
t_crit  <- stats::qt(1 - ALFA / 2, gl)
F_crit  <- stats::qf(1 - ALFA, k - 1, gl)
ic_inf  <- as.numeric(beta) - t_crit * ep
ic_sup  <- as.numeric(beta) + t_crit * ep

# Conferência contra lm().
m_lm <- stats::lm(ln_salario_real ~ prop_superior + dom_industrial + gini_setorial +
                    selic_real + dist_curitiba_km, data = dados)
sm <- summary(m_lm)
conferencias <- c(
  coeficientes = max(abs(as.numeric(beta) - unname(stats::coef(m_lm)))),
  erros_padrao = max(abs(ep - unname(sm$coefficients[, 2]))),
  R2           = abs(R2 - sm$r.squared),
  R2_ajustado  = abs(R2aj - sm$adj.r.squared),
  F_global     = abs(F_glob - unname(sm$fstatistic[1])),
  SQR          = abs(SQR - sum(stats::residuals(m_lm)^2))
)
# Tolerância relativa: diferenças de arredondamento de ponto flutuante (ex.: F ~ 100 com diferença ~5e-8).
escala <- c(max(1, abs(as.numeric(beta))), max(1, abs(ep)), max(1, abs(R2)), max(1, abs(R2aj)),
            max(1, abs(F_glob)), max(1, abs(SQR)))
if (any(conferencias / escala > 1e-8)) {
  stop("O cálculo matricial diverge de lm(): ", paste(names(conferencias), signif(conferencias, 3),
                                                       collapse = "; "), call. = FALSE)
}

# Fatores de inflação da variância pelas regressões auxiliares (R2_j).
fiv <- tibble::tibble(
  variavel = NOMES_X,
  R2_auxiliar = vapply(REGRESSORES, function(v) {
    outros <- setdiff(REGRESSORES, v)
    summary(stats::lm(stats::reformulate(outros, v), data = dados))$r.squared
  }, numeric(1))
) |>
  dplyr::mutate(tolerancia = 1 - R2_auxiliar, fiv = 1 / tolerancia,
                decisao = ifelse(fiv > 10, "multicolinearidade severa (FIV > 10)", "sem multicolinearidade severa"))
R_x <- stats::cor(X[, -1])
det_R <- det(R_x)

# Coeficiente de determinação parcial: r2 = t^2 / (t^2 + gl).
parcial <- tibble::tibble(
  variavel = NOMES_X,
  estatistica_t = t_val[-1],
  r2_parcial = t_val[-1]^2 / (t_val[-1]^2 + gl),
  leitura = "fração da variação de ln(Y) não explicada pelas demais variáveis que X_j explica"
)

# Contribuição incremental por teste F: (SQR_restrito - SQR_irrestrito)/m dividido por s^2.
f_incremental <- function(rotulo, retirar) {
  m_r <- stats::lm(stats::reformulate(setdiff(REGRESSORES, retirar), "ln_salario_real"), data = dados)
  SQR_r <- sum(stats::residuals(m_r)^2)
  m <- length(retirar)
  F <- ((SQR_r - SQR) / m) / s2
  tibble::tibble(
    bloco = rotulo, restricoes = m, SQR_restrito = SQR_r, SQR_irrestrito = SQR,
    estatistica_f = F, F_critico_5pct = stats::qf(1 - ALFA, m, gl),
    p_valor = stats::pf(F, m, gl, lower.tail = FALSE)
  )
}
incremental <- dplyr::bind_rows(
  f_incremental("X2 (capital humano)", "prop_superior"),
  f_incremental("X3 e X4 (estrutura produtiva)", c("dom_industrial", "gini_setorial")),
  f_incremental("X5 (macroeconomia)", "selic_real"),
  f_incremental("X6 (localização)", "dist_curitiba_km")
) |>
  dplyr::mutate(decisao = ifelse(p_valor < ALFA, "rejeita H0 a 5%", "não rejeita H0 a 5%"))

# Previsão para dois vetores x0: média da amostra e Curitiba em 2021.
previsao <- function(rotulo, x0) {
  x0 <- c(1, x0)
  ponto <- sum(x0 * as.numeric(beta))
  q <- as.numeric(t(x0) %*% XtX_inv %*% x0)
  ep_media <- sqrt(s2 * q)
  ep_indiv <- sqrt(s2 * (1 + q))
  tibble::tibble(
    cenario = rotulo, ln_previsto = ponto,
    ic_media_inf = ponto - t_crit * ep_media, ic_media_sup = ponto + t_crit * ep_media,
    ic_individual_inf = ponto - t_crit * ep_indiv, ic_individual_sup = ponto + t_crit * ep_indiv
  )
}
curitiba_2021 <- dados[dados$id_municipio == "4106902" & dados$ano == 2021, REGRESSORES]
if (nrow(curitiba_2021) != 1L) stop("Curitiba 2021 não encontrada.", call. = FALSE)
prev <- dplyr::bind_rows(
  previsao("médias amostrais dos regressores", colMeans(as.matrix(as.data.frame(dados)[, REGRESSORES]))),
  previsao("valores de Curitiba em 2021", as.numeric(curitiba_2021))
)


# -----------------------------------------------------------------------------
# Passo a passo de dois diagnósticos
# Breusch-Pagan studentizado: LM = n R^2 da regressão auxiliar de e^2 sobre X (k - 1 graus de liberdade).
e_m <- as.numeric(y - X %*% beta)
aux_bp <- stats::lm.fit(X, e_m^2)
R2_bp <- 1 - sum(aux_bp$residuals^2) / sum((e_m^2 - mean(e_m^2))^2)
LM_bp <- n * R2_bp
gl_bp <- k - 1
crit_bp <- stats::qchisq(1 - ALFA, gl_bp)
p_bp <- stats::pchisq(LM_bp, gl_bp, lower.tail = FALSE)
# Durbin-Watson: d = soma((e_t - e_t-1)^2)/soma(e_t^2), sobre as 290 linhas ordenadas por município e ano.
num_dw <- sum(diff(e_m)^2)
den_dw <- sum(e_m^2)
d_dw <- num_dw / den_dw
dw_teste <- lmtest::dwtest(m_lm, alternative = "two.sided")
# Memorial em texto (quatro casas decimais)
# -----------------------------------------------------------------------------
# Matrizes em notação científica com quatro algarismos significativos: a escala das
# variáveis faria quase todos os elementos aparecerem como 0,0000 com quatro casas.
matriz_texto <- function(M, escala = 1e6) {
  capture.output(print(noquote(matrix(formatC(M * escala, format = "f", digits = 4, decimal.mark = ","),
                                      nrow = nrow(M), dimnames = dimnames(M))), right = TRUE))
}
pad <- function(x, largura) stringr::str_pad(x, largura, side = "right")
nomes_termos <- c("Intercepto", NOMES_X)
dimnames(XtX_inv) <- list(nomes_termos, nomes_termos)
dimnames(V) <- list(nomes_termos, nomes_termos)
XtX_m <- XtX
dimnames(XtX_m) <- list(nomes_termos, nomes_termos)

linhas <- c(
  "MEMORIAL DE CÁLCULO DO MODELO 2 (MÍNIMOS QUADRADOS ORDINÁRIOS)",
  "ln(Y_it) = b1 + b2 X2 + b3 X3 + b4 X4 + b5 X5 + b6 X6 + u_it",
  "",
  sprintf("1. Dimensões: n = %d observações; k = %d parâmetros; n - k = %d graus de liberdade.", n, k, gl),
  "",
  "2. Matriz X'X e determinante",
  sprintf("   det(X'X) = %s (escala dos dados; o determinante da matriz de correlação dos regressores é a medida sem escala).",
          sub(".", ",", format(det_XtX, scientific = TRUE, digits = 4), fixed = TRUE)),
  sprintf("   det(R) da matriz de correlação dos cinco regressores = %s (valor longe de zero indica ausência de quase-dependência linear).", fmt4(det_R)),
  "",
  "2b. Matriz X'X",
  matriz_texto(XtX_m, escala = 1),
  "",
  "2c. Vetor X'y",
  paste0("   ", sprintf("%s %s", pad(nomes_termos, 28), fmt4(as.numeric(Xty)))),
  "",
  "3. Inversa (X'X)^-1 (elementos multiplicados por 10^6)",
  matriz_texto(XtX_inv),
  "",
  "4. Vetor de estimativas b = (X'X)^-1 X'y",
  paste0("   ", sprintf("%s %s", pad(nomes_termos, 28), fmt4(as.numeric(beta)))),
  "",
  "5. Soma dos quadrados dos resíduos e variância estimada",
  sprintf("   SQR = y'y - b'X'y = %s - %s = %s", fmt4(yty), fmt4(as.numeric(t(beta) %*% Xty)), fmt4(SQR)),
  sprintf("   s^2 = SQR/(n - k) = %s/%d = %s;  s = %s", fmt4(SQR), gl, fmt4(s2), fmt4(sqrt(s2))),
  "",
  "6. Matriz de variância e covariância s^2 (X'X)^-1 (estimador clássico; elementos multiplicados por 10^6)",
  matriz_texto(V),
  "",
  "7. Quadro de análise de variância",
  sprintf("   Regressão: gl = %d; SEC = %s; SEC/gl = %s", k - 1, fmt4(SEC), fmt4(SEC / (k - 1))),
  sprintf("   Resíduo:   gl = %d; SQR = %s; s^2 = %s", gl, fmt4(SQR), fmt4(s2)),
  sprintf("   Total:     gl = %d; STC = %s", n - 1, fmt4(STC)),
  sprintf("   R^2 = SEC/STC = %s;  R^2 ajustado = %s", fmt4(R2), fmt4(R2aj)),
  "",
  "8. Teste F de significância global",
  "   H0: b2 = b3 = b4 = b5 = b6 = 0   contra   Ha: ao menos um bj diferente de zero",
  sprintf("   F = (SEC/(k-1))/s^2 = %s; F crítico a 5%% com (%d; %d) gl = %s; p-valor %s",
          fmt4(F_glob), k - 1, gl, fmt4(F_crit), fmt_p(p_F)),
  sprintf("   Decisão: %s H0 a 5%%.", ifelse(F_glob > F_crit, "rejeita-se", "não se rejeita")),
  "",
  "9. Testes t individuais (H0: bj = 0 contra Ha: bj diferente de zero) e intervalos de confiança de 95%",
  sprintf("   t crítico bilateral a 5%% com %d gl = %s", gl, fmt4(t_crit)),
  paste0("   ", sprintf("%s b = %10s  ep = %8s  t = %10s  p = %9s  IC95 = [%s; %s]  %s",
                        pad(nomes_termos, 28), fmt4(as.numeric(beta)), fmt4(ep), fmt4(t_val), fmt_p(p_t),
                        fmt4(ic_inf), fmt4(ic_sup),
                        ifelse(abs(t_val) > t_crit, "rejeita H0", "não rejeita H0"))),
  "",
  "10. Multicolinearidade: tolerância e fator de inflação da variância (regra de Gujarati e Porter: FIV > 10)",
  paste0("   ", sprintf("%s R2_j = %s  TOL = %s  FIV = %s  %s", pad(fiv$variavel, 28), fmt4(fiv$R2_auxiliar),
                        fmt4(fiv$tolerancia), fmt4(fiv$fiv), fiv$decisao)),
  "",
  "11. Coeficientes de determinação parcial r2 = t^2/(t^2 + n - k)",
  paste0("   ", sprintf("%s %s", pad(parcial$variavel, 28), fmt4(parcial$r2_parcial))),
  "",
  "12. Teste F de contribuição incremental (F = ((SQR_r - SQR)/m)/s^2)",
  "   H0: os coeficientes do bloco são todos iguais a zero   contra   Ha: ao menos um coeficiente do bloco é diferente de zero",
  paste0("   ", sprintf("%s m = %d  F = %s  F crítico = %s  p = %s  %s", pad(incremental$bloco, 32),
                        incremental$restricoes, fmt4(incremental$estatistica_f),
                        fmt4(incremental$F_critico_5pct), fmt_p(incremental$p_valor), incremental$decisao)),
  "",
  "13. Previsão de ln(Y) com intervalo de 95% para a média e para o valor individual",
  paste0("   ", sprintf("%s ln previsto = %s  média [%s; %s]  individual [%s; %s]", pad(prev$cenario, 36),
                        fmt4(prev$ln_previsto), fmt4(prev$ic_media_inf), fmt4(prev$ic_media_sup),
                        fmt4(prev$ic_individual_inf), fmt4(prev$ic_individual_sup))),
  "",
  "14. Teste de Breusch-Pagan, passo a passo",
  "   H0: homocedasticidade   contra   Ha: a variância dos erros depende dos regressores",
  sprintf("   R^2 da regressão auxiliar de e^2 sobre X = %s;  LM = n R^2 = %d x %s = %s", fmt4(R2_bp), n, fmt4(R2_bp), fmt4(LM_bp)),
  sprintf("   Qui-quadrado crítico a 5%% com %d gl = %s; p-valor %s. Decisão: %s H0.", gl_bp, fmt4(crit_bp), fmt_p(p_bp), ifelse(LM_bp > crit_bp, "rejeita-se", "não se rejeita")),
  "",
  "15. Estatística de Durbin-Watson, passo a passo (painel empilhado ordenado por município e ano)",
  "   H0: sem autocorrelação de primeira ordem   contra   Ha: autocorrelação de primeira ordem (rho diferente de zero, teste bilateral)",
  sprintf("   soma((e_t - e_t-1)^2) = %s;  soma(e_t^2) = %s;  d = %s", fmt4(num_dw), fmt4(den_dw), fmt4(d_dw)),
  sprintf("   rho aproximado = 1 - d/2 = %s. p-valor de lmtest::dwtest = %s.", fmt4(1 - d_dw / 2), fmt_p(dw_teste$p.value)),
  "   A decisão usa o p-valor exato, porque n = 290 não consta nas linhas usuais das tabelas de dL e dU. Como as linhas vizinhas de municípios diferentes entram como defasagem (28 pares), o valor é uma referência; a evidência válida está em calibracao_autocorrelacao.csv.",
  "",
  "16. Conferência contra stats::lm() (maior diferença absoluta)",
  paste0("   ", sprintf("%-14s %s", names(conferencias), format(conferencias, scientific = TRUE, digits = 3)))
)
writeLines(linhas, file.path(DIR_RESULTADOS, "memorial_modelo_2.txt"), useBytes = TRUE)

coef_tab <- tibble::tibble(
  termo = nomes_termos, estimativa = as.numeric(beta), erro_padrao_classico = ep,
  estatistica_t = t_val, p_valor = p_t, ic_inf_95 = ic_inf, ic_sup_95 = ic_sup,
  graus_liberdade = gl
)
anova <- tibble::tibble(
  fonte = c("Regressão", "Resíduo", "Total"),
  graus_liberdade = c(k - 1, gl, n - 1),
  soma_quadrados = c(SEC, SQR, STC),
  quadrado_medio = c(SEC / (k - 1), s2, NA_real_),
  estatistica_f = c(F_glob, NA_real_, NA_real_),
  F_critico_5pct = c(F_crit, NA_real_, NA_real_),
  p_valor = c(p_F, NA_real_, NA_real_)
)
readr::write_csv(coef_tab,    file.path(DIR_RESULTADOS, "memorial_modelo_2_coeficientes.csv"))
readr::write_csv(anova,       file.path(DIR_RESULTADOS, "memorial_modelo_2_anova.csv"))
readr::write_csv(fiv,         file.path(DIR_RESULTADOS, "memorial_modelo_2_fiv.csv"))
readr::write_csv(parcial,     file.path(DIR_RESULTADOS, "memorial_modelo_2_determinacao_parcial.csv"))
readr::write_csv(incremental, file.path(DIR_RESULTADOS, "memorial_modelo_2_f_incremental.csv"))
readr::write_csv(prev,        file.path(DIR_RESULTADOS, "memorial_modelo_2_previsao.csv"))

message("Memorial gravado em ", DIR_RESULTADOS, ". Conferência contra lm(): maior diferença = ",
        format(max(conferencias), scientific = TRUE, digits = 3), ".")


REG_FOCAIS <- c("prop_superior", "dom_industrial", "gini_setorial", "selic_real")
rotulos_focais <- c("X2 (ensino superior)", "X3 (dominância industrial)", "X4 (Gini setorial)", "X5 (Selic real)")

mun <- dados$id_municipio
desvio <- function(v) v - ave(v, mun)
Zd <- sapply(REG_FOCAIS, function(v) desvio(dados[[v]]))
yd <- desvio(y)
ZtZ4 <- crossprod(Zd)
Zty4 <- crossprod(Zd, yd)
b4 <- solve(ZtZ4, Zty4)
k4 <- 1 + length(REG_FOCAIS) + (nlevels(factor(mun)) - 1)
gl4 <- n - k4
ssr4 <- sum(yd^2) - sum(b4 * Zty4)
s2_4 <- ssr4 / gl4
ep4 <- sqrt(diag(s2_4 * solve(ZtZ4)))
t4 <- as.vector(b4) / ep4
p4 <- 2 * stats::pt(-abs(t4), df = gl4)
modelo4_lm <- stats::lm(ln_salario_real ~ prop_superior + dom_industrial + gini_setorial + selic_real +
                          factor(id_municipio), data = dados)
b4_lm <- stats::coef(modelo4_lm)[REG_FOCAIS]
ep4_lm <- sqrt(diag(stats::vcov(modelo4_lm)))[REG_FOCAIS]
memorial_m4 <- tibble::tibble(
  termo = REG_FOCAIS, rotulo = rotulos_focais,
  estimativa_memorial = as.vector(b4), erro_padrao_memorial = ep4, t = t4, p_valor = p4,
  estimativa_lm = as.vector(b4_lm), erro_padrao_lm = as.vector(ep4_lm),
  diferenca_maxima = max(abs(as.vector(b4) - as.vector(b4_lm)), abs(ep4 - as.vector(ep4_lm)))
)
if (memorial_m4$diferenca_maxima[1] > 1e-8) stop("Memorial do Modelo 4 não bate com lm().", call. = FALSE)
matriz_m4 <- tibble::as_tibble(cbind(termo_linha = REG_FOCAIS, as.data.frame(ZtZ4)), .name_repair = "minimal")
names(matriz_m4) <- c("termo_linha", REG_FOCAIS)
readr::write_csv(memorial_m4, file.path(DIR_RESULTADOS, "memorial_modelo_4_fwl.csv"))
readr::write_csv(tibble::tibble(termo = REG_FOCAIS, Z_transposto_y = as.vector(Zty4),
                                gl = gl4, SQR = ssr4, s2 = s2_4), file.path(DIR_RESULTADOS, "memorial_modelo_4_fwl_vetores.csv"))
readr::write_csv(matriz_m4, file.path(DIR_RESULTADOS, "memorial_modelo_4_fwl_matriz.csv"))

corr <- readr::read_csv(file.path(DIR_RESULTADOS, "autocorrelacao_correcao.csv"), show_col_types = FALSE)
pw2 <- corr[corr$modelo == "Modelo 2" & corr$metodo == "Prais-Winsten", ]
rho_pw <- pw2$rho[1]
primeira <- !duplicated(mun)
ant <- which(!primeira) - 1L
Xs <- X; ys <- y
Xs[!primeira, ] <- X[!primeira, , drop = FALSE] - rho_pw * X[ant, , drop = FALSE]
ys[!primeira] <- y[!primeira] - rho_pw * y[ant]
Xs[primeira, ] <- sqrt(1 - rho_pw^2) * X[primeira, , drop = FALSE]
ys[primeira] <- sqrt(1 - rho_pw^2) * y[primeira]
XtX_pw <- crossprod(Xs)
Xty_pw <- crossprod(Xs, ys)
b_pw <- solve(XtX_pw, Xty_pw)
ssr_pw <- sum((ys - Xs %*% b_pw)^2)
s2_pw <- ssr_pw / gl
ep_pw <- sqrt(diag(s2_pw * solve(XtX_pw)))
t_pw <- as.vector(b_pw) / ep_pw
p_pw <- 2 * stats::pt(-abs(t_pw), df = gl)
# ρ de ponto fixo: regressão auxiliar dos resíduos originais, dentro de cada município
e_orig <- as.vector(y - X %*% b_pw)
rho_fixo <- sum(e_orig[!primeira] * e_orig[ant]) / sum(e_orig[ant]^2)
coef_arq <- pw2$estimativa
memorial_pw <- tibble::tibble(
  termo = colnames(X), estimativa_memorial = as.vector(b_pw), erro_padrao_memorial = ep_pw,
  t = t_pw, p_valor = p_pw,
  estimativa_arquivo = coef_arq[match(make.names(colnames(X), unique = TRUE), make.names(pw2$termo, unique = TRUE))]
)
memorial_pw$diferenca <- abs(memorial_pw$estimativa_memorial - memorial_pw$estimativa_arquivo)
if (max(memorial_pw$diferenca, na.rm = TRUE) > 1e-8) stop("Memorial Prais-Winsten não bate com a Etapa 5.", call. = FALSE)
if (abs(rho_fixo - rho_pw) > 1e-8) stop("ρ não é ponto fixo da regressão auxiliar.", call. = FALSE)
readr::write_csv(memorial_pw, file.path(DIR_RESULTADOS, "memorial_prais_winsten_m2.csv"))
readr::write_csv(tibble::tibble(rho = rho_pw, rho_ponto_fixo = rho_fixo, gl = gl, SQR_transformada = ssr_pw, s2 = s2_pw),
                 file.path(DIR_RESULTADOS, "memorial_prais_winsten_m2_escalares.csv"))
message("Memorial do Modelo 4 (FWL) e de Prais-Winsten gravados; diferenças máximas em relação a lm() e à Etapa 5 abaixo de 1e-8.")

# ---- C) RESET de Ramsey depois da transformação de Prais-Winsten (modelo principal, Modelo 4, e referência, Modelo 2).
# Regressão transformada com ŷ* (ajustados da regressão transformada) elevado a 2 e 3; F com 2 e gl restantes.
reset_pw <- function(Xt, yt, rotulo, gl_resid) {
  fit0 <- stats::lm.fit(Xt, yt)
  yhat <- as.vector(Xt %*% fit0$coefficients)
  Xa <- cbind(Xt, yhat^2, yhat^3)
  fit1 <- stats::lm.fit(Xa, yt)
  sqr0 <- sum(fit0$residuals^2); sqr1 <- sum(fit1$residuals^2)
  gl_num <- 2; gl_den <- gl_resid - 2
  F_r <- ((sqr0 - sqr1) / gl_num) / (sqr1 / gl_den)
  tibble::tibble(modelo = rotulo, teste = "RESET de Ramsey após Prais-Winsten (potências 2 e 3 dos ajustados transformados)",
                 hipotese_nula = "H0: forma funcional correta (coeficientes de y^2 e y^3 iguais a zero na regressão transformada)",
                 hipotese_alternativa = "Ha: forma funcional incorreta (ao menos um coeficiente diferente de zero)",
                 estatistica_f = F_r, gl = paste(gl_num, gl_den, sep = "; "),
                 p_valor = stats::pf(F_r, gl_num, gl_den, lower.tail = FALSE),
                 decisao_5pct = ifelse(stats::pf(F_r, gl_num, gl_den, lower.tail = FALSE) < 0.05, "rejeita H0", "não rejeita H0"))
}
# Transformação de Prais-Winsten de uma matriz de modelo com ρ comum (mesma regra do memorial B).
transformar_pw <- function(M, v, rho) {
  Mt <- M; vt <- v
  Mt[!primeira, ] <- M[!primeira, , drop = FALSE] - rho * M[ant, , drop = FALSE]
  vt[!primeira] <- v[!primeira] - rho * v[ant]
  Mt[primeira, ] <- sqrt(1 - rho^2) * M[primeira, , drop = FALSE]
  vt[primeira] <- sqrt(1 - rho^2) * v[primeira]
  list(X = Mt, y = vt)
}
# Modelo 2 (já em X, com intercepto) e Modelo 4 (matriz com dummies de município).
X4full <- stats::model.matrix(modelo4_lm)
rho_m4 <- corr$rho[corr$modelo == "Modelo 4" & corr$metodo == "Prais-Winsten"][1]
t4 <- transformar_pw(X4full, dados$ln_salario_real, rho_m4)
reset_m4 <- reset_pw(t4$X, t4$y, "Modelo 4 (principal, Prais-Winsten)", n - ncol(X4full))
t2 <- transformar_pw(X, y, rho_pw)
reset_m2 <- reset_pw(t2$X, t2$y, "Modelo 2 (referência, Prais-Winsten)", gl)
readr::write_csv(dplyr::bind_rows(reset_m4, reset_m2), file.path(DIR_RESULTADOS, "especificacao_reset_prais_winsten.csv"))
message("RESET após Prais-Winsten gravado: Modelo 4 p = ", format(reset_m4$p_valor, digits = 4),
        "; Modelo 2 p = ", format(reset_m2$p_valor, digits = 4), ".")
