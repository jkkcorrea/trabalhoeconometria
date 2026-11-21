# =============================================================================
# Etapa 6: calibração do modelo
#
# O Modelo 2 (MQO empilhado) é a linha de base da disciplina. Esta etapa
# verifica se ele atende às hipóteses do modelo clássico e, onde não atende,
# estima o modelo por métodos que corrigem a violação:
#
#   1. Diagnósticos complementares do Modelo 2: Goldfeld-Quandt, influência
#      (distância de Cook, alavancagem, DFBETAS), relação entre variância e
#      tamanho do município, autocorrelação dentro do município, RESET.
#   2. Testes de efeito de município: teste F de efeitos individuais,
#      Breusch-Pagan de multiplicadores de Lagrange, Hausman e Mundlak.
#   3. Estimadores lado a lado, todos com erros-padrão agrupados por município
#      (HC1) e t de G - 1 = 28 graus de liberdade: MQO empilhado, Prais-Winsten,
#      efeitos fixos (within), efeitos fixos de município e ano, Mundlak e
#      primeiras diferenças.
#   4. Bootstrap wild cluster (restrito, pesos de Rademacher), com 29 clusters.
#   5. P-valor conservador da Selic, agrupado por ano (G - 1 = 9).
#
# Lê:    ./dados_processados/dados_painel_rmc.rds
# Grava: ./resultados_econometricos/calibracao_*.csv
#        ./figuras_graficos/calibracao_coeficientes_estimadores.png
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

pacotes_necessarios <- c("dplyr", "tibble", "purrr", "stringr", "readr", "ggplot2",
                         "car", "lmtest", "sandwich", "plm", "scales")
pacotes_ausentes <- pacotes_necessarios[
  !vapply(pacotes_necessarios, requireNamespace, logical(1), quietly = TRUE)
]
if (length(pacotes_ausentes) > 0) {
  stop("Pacotes ausentes: ", paste(pacotes_ausentes, collapse = ", "), call. = FALSE)
}
suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
})


# -----------------------------------------------------------------------------
# 2. Parâmetros
# -----------------------------------------------------------------------------
DIR_PROCESSADOS <- "./dados_processados"
DIR_RESULTADOS  <- "./resultados_econometricos"
DIR_FIGURAS     <- "./figuras_graficos"
ARQ_PAINEL      <- file.path(DIR_PROCESSADOS, "dados_painel_rmc.rds")
N_MUNICIPIOS    <- 29L
N_ANOS          <- 10L
LINHAS_PAINEL   <- N_MUNICIPIOS * N_ANOS
GL_MUNICIPIOS   <- N_MUNICIPIOS - 1L
GL_ANOS         <- N_ANOS - 1L
B_BOOTSTRAP     <- 9999L
SEMENTE         <- 20261121L
PREFIXO         <- "calibracao_"

REGRESSORES   <- c("prop_superior", "dom_industrial", "shannon_diversificacao",
                   "selic_real", "dist_curitiba_km")
VARIAVEIS_TEMPO <- c("prop_superior", "dom_industrial", "shannon_diversificacao")
ROTULOS_TERMOS <- c(
  prop_superior          = "Ensino superior (X2)",
  dom_industrial         = "Dominância industrial (X3)",
  shannon_diversificacao = "Diversificação setorial (X4)",
  selic_real             = "Selic real (X5)",
  dist_curitiba_km       = "Distância a Curitiba (X6)"
)

fmt4 <- function(x) formatC(x, format = "f", digits = 4, decimal.mark = ",")


# -----------------------------------------------------------------------------
# 3. Leitura e validação do painel
# -----------------------------------------------------------------------------
ler_painel <- function() {
  if (!file.exists(ARQ_PAINEL)) stop("Painel não encontrado em ", ARQ_PAINEL, call. = FALSE)
  dados <- readRDS(ARQ_PAINEL) |>
    tibble::as_tibble() |>
    mutate(
      id_municipio = stringr::str_pad(as.character(id_municipio), 7, pad = "0"),
      ano          = as.integer(ano)
    ) |>
    arrange(id_municipio, ano)

  numericas <- c("ln_salario_real", REGRESSORES, "dummy_curitiba", "vinculos_ativos")
  if (nrow(dados) != LINHAS_PAINEL) {
    stop("O painel tem ", nrow(dados), " linhas; esperado ", LINHAS_PAINEL, ".", call. = FALSE)
  }
  if (dplyr::n_distinct(dados$id_municipio) != N_MUNICIPIOS ||
      dplyr::n_distinct(dados$ano) != N_ANOS) {
    stop("O painel não tem 29 municípios em 10 anos.", call. = FALSE)
  }
  if (anyDuplicated(dados[, c("id_municipio", "ano")]) > 0) {
    stop("Há pares município e ano repetidos.", call. = FALSE)
  }
  if (any(table(dados$id_municipio) != N_ANOS)) stop("O painel não é balanceado.", call. = FALSE)
  if (any(!is.finite(as.matrix(dados[, numericas])))) {
    stop("Há NA, NaN ou Inf nas variáveis do modelo.", call. = FALSE)
  }

  dados |>
    group_by(id_municipio) |>
    mutate(
      media_prop    = mean(prop_superior),
      media_dom     = mean(dom_industrial),
      media_shannon = mean(shannon_diversificacao)
    ) |>
    ungroup()
}


# -----------------------------------------------------------------------------
# 4. Ferramentas de estimação com erro agrupado
# -----------------------------------------------------------------------------
# Matriz agrupada tipo HC1: G/(G-1) * (n-1)/(n-k) * (X'X)^-1 [soma_g X_g' e_g e_g' X_g] (X'X)^-1.
ajuste_cluster <- function(y, X, cluster, k_ajuste = ncol(X)) {
  g <- as.integer(factor(cluster))
  G <- max(g)
  n <- nrow(X)
  XtXi <- solve(crossprod(X))
  beta <- as.numeric(XtXi %*% crossprod(X, y))
  e <- as.numeric(y - X %*% beta)
  S <- rowsum(X * e, g)
  V <- (G / (G - 1)) * ((n - 1) / (n - k_ajuste)) * XtXi %*% crossprod(S) %*% XtXi
  names(beta) <- colnames(X)
  list(beta = beta, V = V, e = e, G = G, n = n, k = ncol(X))
}

tabela_estimador <- function(nome, y, X, cluster, gl, k_ajuste = ncol(X), observacao = "") {
  a <- ajuste_cluster(y, X, cluster, k_ajuste)
  ep <- sqrt(diag(a$V))
  est <- a$beta
  tv <- est / ep
  tc <- stats::qt(0.975, gl)
  tibble::tibble(
    estimador = nome, termo = names(est), estimativa = unname(est),
    erro_padrao = unname(ep), estatistica_t = unname(tv),
    p_valor = 2 * stats::pt(-abs(unname(tv)), gl),
    ic_inf_95 = unname(est - tc * ep), ic_sup_95 = unname(est + tc * ep),
    n = a$n, graus_liberdade = gl, observacao = observacao
  )
}

matriz_x <- function(dados, termos, intercepto = TRUE) {
  X <- as.matrix(as.data.frame(dados)[, termos, drop = FALSE])
  if (intercepto) X <- cbind(`(Intercept)` = 1, X)
  X
}

dentro <- function(x, grupo) x - stats::ave(x, grupo)

rho_intramunicipal <- function(e, id) {
  i2 <- which(id[-1] == id[-length(id)]) + 1
  sum(e[i2] * e[i2 - 1]) / sum(e[i2 - 1]^2)
}

# Prais-Winsten com rho comum, iterado, aplicado dentro de cada município.
prais_winsten <- function(y, X, id, tol = 1e-8, max_iter = 200) {
  transformar <- function(rho) {
    yt <- y; Xt <- X
    for (g in unique(id)) {
      i <- which(id == g)
      yt[i[1]] <- sqrt(1 - rho^2) * y[i[1]]
      Xt[i[1], ] <- sqrt(1 - rho^2) * X[i[1], ]
      for (k in seq_along(i)[-1]) {
        yt[i[k]] <- y[i[k]] - rho * y[i[k - 1]]
        Xt[i[k], ] <- X[i[k], ] - rho * X[i[k - 1], ]
      }
    }
    list(y = yt, X = Xt)
  }
  rho <- rho_intramunicipal(as.numeric(y - X %*% solve(crossprod(X), crossprod(X, y))), id)
  convergiu <- FALSE
  for (it in seq_len(max_iter)) {
    t <- transformar(rho)
    b <- solve(crossprod(t$X), crossprod(t$X, t$y))
    e <- as.numeric(y - X %*% b)
    novo <- rho_intramunicipal(e, id)
    if (abs(novo - rho) < tol) { rho <- novo; convergiu <- TRUE; break }
    rho <- novo
  }
  t <- transformar(rho)
  list(y = t$y, X = t$X, rho = rho, iteracoes = it, convergiu = convergiu)
}


# -----------------------------------------------------------------------------
# 5. Bootstrap wild cluster restrito (pesos de Rademacher)
# -----------------------------------------------------------------------------
# H0: beta_j = 0. Estima o modelo sem a coluna j, gera y* = fitted_r + w_g * u_r,
# com w_g igual a -1 ou +1 por município, reestima o modelo completo e compara a
# estatística t agrupada de cada réplica com a observada.
bootstrap_wild_cluster <- function(y, X, cluster, j, k_ajuste = ncol(X),
                                   B = B_BOOTSTRAP, semente = SEMENTE) {
  g <- as.integer(factor(cluster))
  G <- max(g)
  n <- nrow(X)
  XtXi <- solve(crossprod(X))
  fator <- (G / (G - 1)) * ((n - 1) / (n - k_ajuste))
  estatistica_t <- function(yy) {
    beta <- as.numeric(XtXi %*% crossprod(X, yy))
    e <- as.numeric(yy - X %*% beta)
    S <- rowsum(X * e, g)
    V <- fator * XtXi %*% crossprod(S) %*% XtXi
    beta[j] / sqrt(V[j, j])
  }
  t_obs <- estatistica_t(y)
  Xr <- X[, -j, drop = FALSE]
  fit_r <- as.numeric(Xr %*% solve(crossprod(Xr), crossprod(Xr, y)))
  u_r <- y - fit_r
  set.seed(semente)
  t_boot <- numeric(B)
  for (b in seq_len(B)) {
    w <- sample(c(-1, 1), G, replace = TRUE)
    t_boot[b] <- estatistica_t(fit_r + w[g] * u_r)
  }
  c(t_observado = unname(t_obs), p_bootstrap = mean(abs(t_boot) >= abs(t_obs)))
}


# -----------------------------------------------------------------------------
# 6. Diagnósticos complementares do Modelo 2 (MQO empilhado)
# -----------------------------------------------------------------------------
FORMULA_M2 <- ln_salario_real ~ prop_superior + dom_industrial +
  shannon_diversificacao + selic_real + dist_curitiba_km

diagnosticos_complementares <- function(dados, m2) {
  # Goldfeld-Quandt: H0 variância constante; Ha variância crescente com a variável de
  # ordenação (unilateral, como no curso); 20% centrais omitidos. O p-valor bilateral segue em coluna própria.
  gq <- purrr::map_dfr(c("vinculos_ativos", "prop_superior", "dom_industrial"), function(v) {
    # Teste unilateral do curso: a variância cresce com a variável de ordenação.
    t <- lmtest::gqtest(m2, order.by = dados[[v]], fraction = 0.2, alternative = "greater")
    t2 <- lmtest::gqtest(m2, order.by = dados[[v]], fraction = 0.2, alternative = "two.sided")
    tibble::tibble(
      teste = "Goldfeld-Quandt", ordenado_por = v,
      hipotese_nula = "homocedasticidade", estatistica_f = unname(t$statistic),
      gl_numerador = unname(t$parameter[1]), gl_denominador = unname(t$parameter[2]),
      p_valor = t$p.value, p_valor_bilateral = t2$p.value
    )
  })

  # Variância e tamanho do município: log do resíduo ao quadrado contra log dos vínculos.
  e <- stats::residuals(m2)
  aux <- stats::lm(log(e^2) ~ log(dados$vinculos_ativos))
  sa <- summary(aux)$coefficients
  variancia_tamanho <- tibble::tibble(
    modelo = "Modelo 2", correlacao = stats::cor(log(e^2), log(dados$vinculos_ativos)),
    inclinacao = sa[2, 1], estatistica_t = sa[2, 3], p_valor = sa[2, 4],
    leitura = "inclinação próxima de -1 indicaria variância proporcional a 1/n"
  )

  # Influência.
  cook <- stats::cooks.distance(m2)
  alav <- stats::hatvalues(m2)
  dfb  <- abs(stats::dfbetas(m2))
  influencia <- tibble::tibble(
    id_municipio = dados$id_municipio, nome_municipio = dados$nome_municipio,
    ano = dados$ano, cook = unname(cook), alavancagem = unname(alav),
    max_dfbetas = apply(dfb, 1, max),
    cook_acima_4_sobre_n = unname(cook) > 4 / nrow(dados),
    dfbetas_acima_2_sobre_raiz_n = apply(dfb, 1, max) > 2 / sqrt(nrow(dados))
  ) |>
    arrange(desc(cook))

  list(gq = gq, variancia_tamanho = variancia_tamanho, influencia = influencia)
}


# -----------------------------------------------------------------------------
# 7. Estimadores lado a lado
# -----------------------------------------------------------------------------
estimadores <- function(dados) {
  id  <- dados$id_municipio
  y   <- dados$ln_salario_real

  # 1. MQO empilhado (Modelo 2).
  X_pool <- matriz_x(dados, REGRESSORES)
  t_pool <- tabela_estimador("MQO empilhado (Modelo 2)", y, X_pool, id, GL_MUNICIPIOS)

  # 2. Prais-Winsten dentro de cada município.
  pw <- prais_winsten(y, X_pool, id)
  t_pw <- tabela_estimador(
    "Prais-Winsten", as.numeric(pw$y), pw$X, id, GL_MUNICIPIOS,
    observacao = paste0("rho = ", fmt4(pw$rho), "; iterações = ", pw$iteracoes)
  )

  # 3. Efeitos fixos (within): X6 é absorvida pelo efeito de município.
  X_fe <- sapply(c(VARIAVEIS_TEMPO, "selic_real"), function(v) dentro(dados[[v]], id))
  y_fe <- dentro(y, id)
  t_fe <- tabela_estimador("Efeitos fixos (within)", y_fe, X_fe, id, GL_MUNICIPIOS,
                           k_ajuste = ncol(X_fe),
                           observacao = "X6 absorvida pelo efeito de município")

  # 4. Efeitos fixos de município e de ano: a Selic é absorvida pelo efeito de ano.
  duas_vias <- function(v) dentro(v, id) - stats::ave(v, dados$ano) + mean(v)
  X_tw <- sapply(VARIAVEIS_TEMPO, function(v) duas_vias(dados[[v]]))
  t_tw <- tabela_estimador("Efeitos fixos de município e ano", duas_vias(y), X_tw, id,
                           GL_MUNICIPIOS, k_ajuste = ncol(X_tw) + GL_ANOS,
                           observacao = "X5 e X6 absorvidas pelos efeitos de ano e município")

  # 5. Mundlak: médias por município das variáveis que variam no tempo.
  X_mund <- matriz_x(dados, c(REGRESSORES, "media_prop", "media_dom", "media_shannon"))
  t_mund <- tabela_estimador("Mundlak (efeitos aleatórios correlacionados)", y, X_mund, id,
                             GL_MUNICIPIOS,
                             observacao = "efeitos de X2, X3 e X4 iguais aos de efeitos fixos; X6 preservada")

  # 6. Primeiras diferenças.
  fd <- dados |>
    group_by(id_municipio) |>
    mutate(across(c(ln_salario_real, all_of(c(VARIAVEIS_TEMPO, "selic_real"))),
                  \(v) v - dplyr::lag(v), .names = "d_{.col}")) |>
    ungroup() |>
    filter(!is.na(d_ln_salario_real))
  X_fd <- matriz_x(fd, paste0("d_", c(VARIAVEIS_TEMPO, "selic_real")))
  colnames(X_fd) <- c("(Intercept)", VARIAVEIS_TEMPO, "selic_real")
  t_fd <- tabela_estimador("Primeiras diferenças", fd$d_ln_salario_real, X_fd,
                           fd$id_municipio, GL_MUNICIPIOS,
                           observacao = "variação anual de ln(salário) sobre variações anuais; 261 observações")

  list(
    tabela = dplyr::bind_rows(t_pool, t_pw, t_fe, t_tw, t_mund, t_fd),
    pw = pw,
    insumos = list(pool = list(y = y, X = X_pool, id = id),
                   fe = list(y = y_fe, X = X_fe, id = id),
                   mundlak = list(y = y, X = X_mund, id = id))
  )
}


# -----------------------------------------------------------------------------
# 8. Testes de efeito de município e autocorrelação
# -----------------------------------------------------------------------------
testes_painel <- function(dados, ins) {
  pd <- plm::pdata.frame(as.data.frame(dados), index = c("id_municipio", "ano"))
  fo <- ln_salario_real ~ prop_superior + dom_industrial + shannon_diversificacao + selic_real
  fe   <- plm::plm(fo, data = pd, model = "within")
  re   <- plm::plm(fo, data = pd, model = "random")
  pool <- plm::plm(fo, data = pd, model = "pooling")

  f_efeitos <- plm::pFtest(fe, pool)
  lm_bp     <- plm::plmtest(pool, type = "bp")
  hausman   <- plm::phtest(fe, re)
  wooldridge <- plm::pwartest(fe)
  bg_painel  <- plm::pbgtest(fe, order = 1)

  # Mundlak: teste conjunto das médias, com matriz agrupada.
  mund <- stats::lm(ln_salario_real ~ prop_superior + dom_industrial + shannon_diversificacao +
                      selic_real + dist_curitiba_km + media_prop + media_dom + media_shannon,
                    data = dados)
  V <- sandwich::vcovCL(mund, cluster = dados$id_municipio, type = "HC1")
  hm <- car::linearHypothesis(mund, c("media_prop = 0", "media_dom = 0", "media_shannon = 0"),
                              vcov. = V, test = "F")
  f_m <- hm$F[2]
  tibble::tibble(
    teste = c("Teste F de efeitos individuais (pooling contra within)",
              "Breusch-Pagan de multiplicadores de Lagrange (efeitos individuais)",
              "Hausman (efeitos fixos contra efeitos aleatórios)",
              "Mundlak: médias por município = 0 (gl residuais)",
              "Mundlak: médias por município = 0 (gl do denominador = G - 1)",
              "Wooldridge de autocorrelação em painel (within)",
              "Breusch-Godfrey de painel, ordem 1 (within)"),
    hipotese_nula = c("sem efeitos individuais", "sem efeitos individuais",
                      "efeitos aleatórios consistentes", "efeito do município não correlacionado com X",
                      "efeito do município não correlacionado com X",
                      "sem autocorrelação de primeira ordem", "sem autocorrelação de ordem 1"),
    estatistica = c(unname(f_efeitos$statistic), unname(lm_bp$statistic), unname(hausman$statistic),
                    f_m, f_m, unname(wooldridge$statistic), unname(bg_painel$statistic)),
    graus_liberdade = c(paste(f_efeitos$parameter, collapse = "; "), as.character(lm_bp$parameter),
                        as.character(hausman$parameter), paste(hm$Df[2], hm$Res.Df[2], sep = "; "),
                        paste(hm$Df[2], GL_MUNICIPIOS, sep = "; "),
                        paste(wooldridge$parameter, collapse = "; "), as.character(bg_painel$parameter)),
    p_valor = c(f_efeitos$p.value, lm_bp$p.value, hausman$p.value, hm$`Pr(>F)`[2],
                stats::pf(f_m, hm$Df[2], GL_MUNICIPIOS, lower.tail = FALSE),
                wooldridge$p.value, bg_painel$p.value)
  )
}

autocorrelacao_por_modelo <- function(dados, ins) {
  id <- dados$id_municipio
  e_pool <- ins$pool$y - ins$pool$X %*% solve(crossprod(ins$pool$X), crossprod(ins$pool$X, ins$pool$y))
  e_fe   <- ins$fe$y - ins$fe$X %*% solve(crossprod(ins$fe$X), crossprod(ins$fe$X, ins$fe$y))
  e_mund <- ins$mundlak$y - ins$mundlak$X %*% solve(crossprod(ins$mundlak$X), crossprod(ins$mundlak$X, ins$mundlak$y))
  tibble::tibble(
    modelo = c("MQO empilhado (Modelo 2)", "Mundlak", "Efeitos fixos (within)"),
    rho_residuos_mesmo_municipio = c(rho_intramunicipal(as.numeric(e_pool), id),
                                     rho_intramunicipal(as.numeric(e_mund), id),
                                     rho_intramunicipal(as.numeric(e_fe), id))
  ) |>
    mutate(d_aproximado = 2 * (1 - rho_residuos_mesmo_municipio))
}

reset_por_modelo <- function(dados) {
  f_lsdv <- stats::lm(ln_salario_real ~ prop_superior + dom_industrial + shannon_diversificacao +
                        selic_real + factor(id_municipio), data = dados)
  f_mund <- stats::lm(ln_salario_real ~ prop_superior + dom_industrial + shannon_diversificacao +
                        selic_real + dist_curitiba_km + media_prop + media_dom + media_shannon,
                      data = dados)
  m2 <- stats::lm(FORMULA_M2, data = dados)
  purrr::imap_dfr(list("MQO empilhado (Modelo 2)" = m2, "Mundlak" = f_mund,
                       "Efeitos fixos (variáveis binárias de município)" = f_lsdv),
                  function(m, nome) {
    r <- lmtest::resettest(m, power = 2:3, type = "regressor")
    tibble::tibble(modelo = nome, estatistica_f = unname(r$statistic),
                   gl1 = unname(r$parameter[1]), gl2 = unname(r$parameter[2]),
                   p_valor = r$p.value, r2_ajustado = summary(m)$adj.r.squared)
  })
}


# -----------------------------------------------------------------------------
# 9. Bootstrap e p-valor conservador da Selic
# -----------------------------------------------------------------------------
bootstrap_todos <- function(ins) {
  alvos <- list(
    "MQO empilhado (Modelo 2)" = list(d = ins$pool, termos = REGRESSORES, k = ncol(ins$pool$X)),
    "Efeitos fixos (within)"   = list(d = ins$fe, termos = c(VARIAVEIS_TEMPO, "selic_real"),
                                      k = ncol(ins$fe$X)),
    "Mundlak"                  = list(d = ins$mundlak,
                                      termos = c(REGRESSORES, "media_prop", "media_dom", "media_shannon"),
                                      k = ncol(ins$mundlak$X))
  )
  purrr::imap_dfr(alvos, function(a, nome) {
    purrr::map_dfr(a$termos, function(termo) {
      j <- match(termo, colnames(a$d$X))
      r <- bootstrap_wild_cluster(a$d$y, a$d$X, a$d$id, j, k_ajuste = a$k)
      tibble::tibble(estimador = nome, termo = termo, estatistica_t = r[["t_observado"]],
                     p_bootstrap = r[["p_bootstrap"]], replicas = B_BOOTSTRAP)
    })
  })
}

selic_conservadora <- function(dados, ins) {
  ano <- dados$ano
  fe_x <- ins$fe$X
  purrr::imap_dfr(list(
    "MQO empilhado (Modelo 2)" = list(y = ins$pool$y, X = ins$pool$X, k = ncol(ins$pool$X)),
    "Efeitos fixos (within)"   = list(y = ins$fe$y, X = fe_x, k = ncol(fe_x)),
    "Mundlak"                  = list(y = ins$mundlak$y, X = ins$mundlak$X, k = ncol(ins$mundlak$X))
  ), function(a, nome) {
    t <- tabela_estimador(nome, a$y, a$X, ano, GL_ANOS, k_ajuste = a$k)
    t[t$termo == "selic_real", ] |>
      mutate(observacao = "agrupado por ano (10 grupos), t com 9 graus de liberdade")
  })
}


# -----------------------------------------------------------------------------
# 10. Figura: coeficientes por estimador
# -----------------------------------------------------------------------------
figura_estimadores <- function(tabela) {
  base <- tabela |>
    filter(termo %in% REGRESSORES,
           !estimador %in% c("Prais-Winsten")) |>
    mutate(
      termo_rotulo = factor(ROTULOS_TERMOS[termo], levels = ROTULOS_TERMOS),
      estimador = factor(estimador, levels = rev(unique(tabela$estimador))),
      principal = estimador != "MQO empilhado (Modelo 2)"
    )
  pooled <- base |> filter(termo == "prop_superior", estimador == "MQO empilhado (Modelo 2)")
  fe <- base |> filter(termo == "prop_superior", estimador == "Efeitos fixos (within)")

  g <- ggplot(base, aes(x = estimativa, y = estimador, colour = principal)) +
    geom_vline(xintercept = 0, linetype = "dashed", colour = "grey55") +
    geom_pointrange(aes(xmin = ic_inf_95, xmax = ic_sup_95), size = 0.45) +
    facet_wrap(~ termo_rotulo, scales = "free_x", ncol = 2) +
    scale_colour_manual(values = c(`TRUE` = "#B2182B", `FALSE` = "grey35"), name = "Estimador",
                        labels = c(`TRUE` = "Elimina o efeito do município\n(efeitos fixos, Mundlak, diferenças)", `FALSE` = "Não elimina (MQO empilhado)")) +
    scale_x_continuous(labels = scales::label_number(decimal.mark = ",", accuracy = NULL)) +
    labs(
      title = sprintf(
        "O efeito do ensino superior cai de %s para %s por ponto percentual ao controlar o município",
        scales::percent(exp(pooled$estimativa) - 1, accuracy = 0.01, decimal.mark = ","),
        scales::percent(exp(fe$estimativa) - 1, accuracy = 0.01, decimal.mark = ",")),
      subtitle = "Coeficientes sobre ln(salário real) com IC de 95% (erro agrupado por município, t com 28 gl); linha tracejada: efeito nulo",
      x = "Coeficiente estimado", y = NULL,
      caption = paste("290 observações (29 municípios x 10 anos), 2012 a 2021. X5 e X6 não são estimáveis onde são absorvidas por efeitos fixos.",
                      "Prais-Winsten (rho próximo de 1) está em calibracao_coeficientes.csv.", sep = "\n")
    ) +
    theme_minimal(base_size = 10) +
    theme(plot.title = element_text(face = "bold", size = 12),
          plot.subtitle = element_text(size = 8.5, colour = "grey25"),
          plot.caption = element_text(hjust = 0, size = 8, colour = "grey30"),
          panel.grid.minor = element_blank(), strip.text = element_text(face = "bold"),
          legend.position = "inside", legend.position.inside = c(0.78, 0.17),
          legend.title = element_text(face = "bold", size = 9.5), legend.text = element_text(size = 9))
  arquivo <- file.path(DIR_FIGURAS, paste0(PREFIXO, "coeficientes_estimadores.png"))
  ggsave(arquivo, g, width = 12, height = 7, dpi = 300, bg = "white")
  arquivo
}


# -----------------------------------------------------------------------------
# 11. Conferências internas
# -----------------------------------------------------------------------------
conferir_implementacao <- function(dados, res) {
  # a) A matriz agrupada própria coincide com sandwich::vcovCL no MQO empilhado.
  m2 <- stats::lm(FORMULA_M2, data = dados)
  V_s <- sandwich::vcovCL(m2, cluster = dados$id_municipio, type = "HC1")
  V_p <- ajuste_cluster(res$insumos$pool$y, res$insumos$pool$X, dados$id_municipio)$V
  dif_v <- max(abs(V_s - V_p))
  if (dif_v > 1e-10) stop("Matriz agrupada própria difere de sandwich::vcovCL: ", dif_v, call. = FALSE)

  # b) Os coeficientes de efeitos fixos coincidem com plm (within).
  pd <- plm::pdata.frame(as.data.frame(dados), index = c("id_municipio", "ano"))
  fe <- plm::plm(ln_salario_real ~ prop_superior + dom_industrial + shannon_diversificacao + selic_real,
                 data = pd, model = "within")
  b_fe <- res$tabela |> filter(estimador == "Efeitos fixos (within)") |> pull(estimativa)
  dif_b <- max(abs(unname(stats::coef(fe)) - b_fe))
  if (dif_b > 1e-8) stop("Coeficientes de efeitos fixos diferem de plm: ", dif_b, call. = FALSE)

  # c) Os efeitos de X2, X3 e X4 no Mundlak coincidem com os de efeitos fixos.
  b_m <- res$tabela |> filter(startsWith(estimador, "Mundlak"), termo %in% VARIAVEIS_TEMPO) |> pull(estimativa)
  b_f <- res$tabela |> filter(estimador == "Efeitos fixos (within)", termo %in% VARIAVEIS_TEMPO) |> pull(estimativa)
  dif_mf <- max(abs(b_m - b_f))
  if (dif_mf > 1e-8) stop("Mundlak e efeitos fixos divergem nas variáveis de tempo: ", dif_mf, call. = FALSE)

  message("Conferências internas: matriz agrupada (dif. ", format(dif_v, digits = 2),
          "), efeitos fixos contra plm (dif. ", format(dif_b, digits = 2),
          "), Mundlak contra efeitos fixos (dif. ", format(dif_mf, digits = 2), ").")
}


# -----------------------------------------------------------------------------
# 12. Execução
# -----------------------------------------------------------------------------
executar_etapa_6 <- function() {
  dados <- ler_painel()
  message("Painel: ", nrow(dados), " linhas, ", N_MUNICIPIOS, " municípios, ", N_ANOS, " anos.")
  m2 <- stats::lm(FORMULA_M2, data = dados)

  diag <- diagnosticos_complementares(dados, m2)
  res  <- estimadores(dados)
  conferir_implementacao(dados, res)
  painel <- testes_painel(dados, res$insumos)
  autoc  <- autocorrelacao_por_modelo(dados, res$insumos)
  reset  <- reset_por_modelo(dados)
  message("Bootstrap wild cluster: ", B_BOOTSTRAP, " réplicas por coeficiente...")
  boot   <- bootstrap_todos(res$insumos)
  selic  <- selic_conservadora(dados, res$insumos)

  gravar <- function(tabela, nome) {
    readr::write_csv(tabela, file.path(DIR_RESULTADOS, paste0(PREFIXO, nome, ".csv")))
  }
  gravar(res$tabela, "coeficientes")
  gravar(diag$gq, "goldfeld_quandt")
  gravar(diag$variancia_tamanho, "variancia_tamanho")
  gravar(diag$influencia, "influencia")
  gravar(painel, "testes_painel")
  gravar(autoc, "autocorrelacao")
  gravar(reset, "reset")
  gravar(boot, "bootstrap_wild_cluster")
  gravar(selic, "selic_agrupada_por_ano")
  figura_estimadores(res$tabela)

  message("\nCoeficientes (erro agrupado por município, t com 28 gl):")
  print(as.data.frame(res$tabela |>
                        mutate(across(c(estimativa, erro_padrao, estatistica_t, p_valor), \(v) round(v, 4))) |>
                        select(estimador, termo, estimativa, erro_padrao, estatistica_t, p_valor)),
        row.names = FALSE)
  message("\nTestes de painel:")
  print(as.data.frame(painel |> mutate(estatistica = round(estatistica, 4), p_valor = signif(p_valor, 3))),
        row.names = FALSE)
  message("\nAutocorrelação dos resíduos dentro do município:")
  print(as.data.frame(autoc |> mutate(across(where(is.numeric), \(v) round(v, 4)))), row.names = FALSE)
  message("\nRESET de Ramsey (potências 2 e 3):")
  print(as.data.frame(reset |> mutate(across(c(estatistica_f, r2_ajustado), \(v) round(v, 4)),
                                      p_valor = signif(p_valor, 3))), row.names = FALSE)
  message("\nGoldfeld-Quandt:")
  print(as.data.frame(diag$gq |> mutate(estatistica_f = round(estatistica_f, 4), p_valor = signif(p_valor, 3))),
        row.names = FALSE)
  message("\nObservações mais influentes (distância de Cook):")
  print(as.data.frame(head(diag$influencia |> mutate(across(where(is.numeric), \(v) round(v, 4))), 8)),
        row.names = FALSE)
  message("\nBootstrap wild cluster (p-valores):")
  print(as.data.frame(boot |> mutate(estatistica_t = round(estatistica_t, 4), p_bootstrap = round(p_bootstrap, 4))),
        row.names = FALSE)
  message("\nSelic real agrupada por ano (t com 9 gl):")
  print(as.data.frame(selic |> select(estimador, estimativa, erro_padrao, estatistica_t, p_valor) |>
                        mutate(across(where(is.numeric), \(v) round(v, 4)))), row.names = FALSE)

  invisible(list(coeficientes = res$tabela, testes_painel = painel, autocorrelacao = autoc,
                 reset = reset, bootstrap = boot, selic = selic, diagnosticos = diag))
}

resultados_etapa_6 <- executar_etapa_6()
