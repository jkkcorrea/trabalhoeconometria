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
  "15. Conferência contra stats::lm() (maior diferença absoluta)",
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
