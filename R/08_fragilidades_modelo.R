# =============================================================================
# Etapa 8: tratamento das três fragilidades do modelo
#
#   1. Forma funcional: o RESET rejeita a forma linear. Estima-se o modelo de
#      efeitos fixos com termos quadráticos em X2, X3 e X4, testa-se a forma
#      funcional de cada especificação e calculam-se os efeitos marginais.
#   2. Selic real (X5): só 10 valores distintos, um por ano. Sensibilidade do
#      coeficiente: retirada de cada ano, retirada de 2020 e 2021, tendência
#      linear, erro agrupado por ano e bootstrap wild cluster por ano com as
#      2^10 = 1024 combinações de sinais (exato).
#   3. Exogeneidade e causalidade: teste de exogeneidade estrita (valores
#      futuros dos regressores não devem afetar o salário corrente) e modelo
#      com regressores defasados em um ano.
#
# Lê:    ./dados_processados/dados_painel_rmc.rds
# Grava: ./resultados_econometricos/fragilidades_*.csv
#        ./figuras_graficos/fragilidades_efeito_marginal_superior.png
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

pacotes_necessarios <- c("dplyr", "tibble", "purrr", "stringr", "readr", "ggplot2", "car", "lmtest", "scales")
ausentes <- pacotes_necessarios[!vapply(pacotes_necessarios, requireNamespace, logical(1), quietly = TRUE)]
if (length(ausentes) > 0) stop("Pacotes ausentes: ", paste(ausentes, collapse = ", "), call. = FALSE)
suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
})

DIR_RESULTADOS <- "./resultados_econometricos"
DIR_FIGURAS    <- "./figuras_graficos"
ARQ_PAINEL     <- "./dados_processados/dados_painel_rmc.rds"
N_MUNICIPIOS   <- 29L
N_ANOS         <- 10L
GL_MUNICIPIOS  <- N_MUNICIPIOS - 1L
GL_ANOS        <- N_ANOS - 1L
PREFIXO        <- "fragilidades_"
SEMENTE_WEBB   <- 20261122L
fmt4 <- function(x) formatC(x, format = "f", digits = 4, decimal.mark = ",")


# -----------------------------------------------------------------------------
# 1. Dados
# -----------------------------------------------------------------------------
ler_painel <- function() {
  dados <- readRDS(ARQ_PAINEL) |>
    tibble::as_tibble() |>
    mutate(id_municipio = stringr::str_pad(as.character(id_municipio), 7, pad = "0"), ano = as.integer(ano)) |>
    arrange(id_municipio, ano)
  if (nrow(dados) != N_MUNICIPIOS * N_ANOS || any(table(dados$id_municipio) != N_ANOS)) {
    stop("O painel deve ter 29 municípios em 10 anos, balanceado.", call. = FALSE)
  }
  dados |>
    mutate(
      sup2 = prop_superior^2, dom2 = dom_industrial^2, sha2 = shannon_diversificacao^2,
      ln_vinculos = log(vinculos_ativos)
    )
}


# -----------------------------------------------------------------------------
# 2. Ferramentas: erro agrupado HC1 e transformação within
# -----------------------------------------------------------------------------
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
  dimnames(V) <- list(colnames(X), colnames(X))
  list(beta = beta, V = V, e = e, G = G, n = n)
}

dentro <- function(x, grupo) x - stats::ave(x, grupo)

# Dados within para um conjunto de termos; devolve y e X sem intercepto.
montar_within <- function(dados, termos) {
  X <- sapply(termos, function(v) dentro(dados[[v]], dados$id_municipio))
  colnames(X) <- termos
  list(y = dentro(dados$ln_salario_real, dados$id_municipio), X = X)
}

resumo_coef <- function(a, gl, termos = names(a$beta)) {
  ep <- sqrt(diag(a$V))[termos]
  est <- a$beta[termos]
  tv <- est / ep
  tibble::tibble(termo = termos, estimativa = unname(est), erro_padrao = unname(ep),
                 estatistica_t = unname(tv), p_valor = 2 * stats::pt(-abs(unname(tv)), gl))
}


# -----------------------------------------------------------------------------
# 3. Fragilidade 1: forma funcional
# -----------------------------------------------------------------------------
TERMOS_LINEARES <- c("prop_superior", "dom_industrial", "shannon_diversificacao", "selic_real")
TERMOS_QUAD     <- c(TERMOS_LINEARES, "sup2", "dom2", "sha2")

# RESET de Ramsey com potências 2 e 3. Os graus de liberdade usam o posto da matriz:
# com termos quadráticos no modelo, o quadrado de X2 (por exemplo) é exatamente
# colinear com o regressor sup2, e lmtest::resettest contaria como parâmetros
# colunas que não acrescentam informação.
reset_posto <- function(modelo, tipo = c("regressores", "ajustados")) {
  tipo <- match.arg(tipo)
  M0 <- stats::model.matrix(modelo)
  y <- stats::model.response(stats::model.frame(modelo))
  base <- if (tipo == "regressores") M0[, colnames(M0) != "(Intercept)", drop = FALSE] else matrix(stats::fitted(modelo), ncol = 1)
  M1 <- cbind(M0, base^2, base^3)
  rss <- function(M) sum(stats::lm.fit(M, y)$residuals^2)
  r0 <- qr(M0)$rank
  r1 <- qr(M1)$rank
  n <- nrow(M0)
  f <- ((rss(M0) - rss(M1)) / (r1 - r0)) / (rss(M1) / (n - r1))
  c(estatistica = f, gl1 = r1 - r0, gl2 = n - r1, p_valor = stats::pf(f, r1 - r0, n - r1, lower.tail = FALSE))
}

especificacoes_forma <- function(dados) {
  fs <- list(
    "Efeitos fixos linear" = ln_salario_real ~ prop_superior + dom_industrial + shannon_diversificacao + selic_real + factor(id_municipio),
    "Efeitos fixos linear com ln dos vínculos" = ln_salario_real ~ prop_superior + dom_industrial + shannon_diversificacao + selic_real + ln_vinculos + factor(id_municipio),
    "Efeitos fixos com quadráticos de X2, X3 e X4" = ln_salario_real ~ prop_superior + dom_industrial + shannon_diversificacao + selic_real + sup2 + dom2 + sha2 + factor(id_municipio),
    "Efeitos fixos de município e ano com quadráticos" = ln_salario_real ~ prop_superior + dom_industrial + shannon_diversificacao + sup2 + dom2 + sha2 + factor(id_municipio) + factor(ano)
  )
  purrr::imap_dfr(fs, function(f, nome) {
    m <- stats::lm(f, data = dados)
    r_reg <- reset_posto(m, "regressores")
    r_fit <- reset_posto(m, "ajustados")
    tibble::tibble(
      especificacao = nome, r2_ajustado = summary(m)$adj.r.squared, aic = stats::AIC(m), bic = stats::BIC(m),
      reset_regressores_f = r_reg[["estatistica"]], reset_regressores_gl = paste(r_reg[["gl1"]], r_reg[["gl2"]], sep = "; "),
      reset_regressores_p = r_reg[["p_valor"]],
      reset_ajustados_f = r_fit[["estatistica"]], reset_ajustados_gl = paste(r_fit[["gl1"]], r_fit[["gl2"]], sep = "; "),
      reset_ajustados_p = r_fit[["p_valor"]]
    )
  })
}

fe_quadratico <- function(dados) {
  w <- montar_within(dados, TERMOS_QUAD)
  a <- ajuste_cluster(w$y, w$X, dados$id_municipio, k_ajuste = ncol(w$X))
  coef <- resumo_coef(a, GL_MUNICIPIOS)

  # Efeito marginal médio: b + 2 c x_media, com variância pelo método delta.
  marg <- purrr::map_dfr(
    list(list(v = "prop_superior", q = "sup2", rot = "X2 ensino superior"),
         list(v = "dom_industrial", q = "dom2", rot = "X3 dominância industrial"),
         list(v = "shannon_diversificacao", q = "sha2", rot = "X4 diversificação")),
    function(p) {
      xm <- mean(dados[[p$v]])
      L <- stats::setNames(c(1, 2 * xm), c(p$v, p$q))
      est <- sum(L * a$beta[names(L)])
      ep <- sqrt(as.numeric(t(L) %*% a$V[names(L), names(L)] %*% L))
      tibble::tibble(termo = p$rot, media_do_regressor = xm, efeito_marginal_medio = est, erro_padrao = ep,
                     estatistica_t = est / ep, p_valor = 2 * stats::pt(-abs(est / ep), GL_MUNICIPIOS),
                     vertice_da_parabola = -a$beta[p$v] / (2 * a$beta[p$q]),
                     minimo_observado = min(dados[[p$v]]), maximo_observado = max(dados[[p$v]]),
                     vertice_dentro_do_suporte = (-a$beta[p$v] / (2 * a$beta[p$q])) >= min(dados[[p$v]]) &
                       (-a$beta[p$v] / (2 * a$beta[p$q])) <= max(dados[[p$v]]))
    }
  )

  # Teste conjunto dos três termos quadráticos (Wald, F com 3 e G - 1 graus de liberdade).
  idx <- c("sup2", "dom2", "sha2")
  b <- a$beta[idx]
  Vq <- a$V[idx, idx]
  Fq <- as.numeric(t(b) %*% solve(Vq) %*% b) / length(idx)
  conj <- tibble::tibble(
    teste = "Termos quadráticos de X2, X3 e X4 conjuntamente nulos", estatistica_f = Fq,
    gl_numerador = length(idx), gl_denominador = GL_MUNICIPIOS,
    p_valor = stats::pf(Fq, length(idx), GL_MUNICIPIOS, lower.tail = FALSE)
  )
  list(coef = coef, marg = marg, conj = conj, a = a, w = w)
}

figura_efeito_marginal <- function(dados, fq) {
  a <- fq$a
  grade <- seq(min(dados$prop_superior), max(dados$prop_superior), length.out = 100)
  b <- a$beta[c("prop_superior", "sup2")]
  V <- a$V[c("prop_superior", "sup2"), c("prop_superior", "sup2")]
  tc <- stats::qt(0.975, GL_MUNICIPIOS)
  curva <- tibble::tibble(x = grade) |>
    mutate(
      efeito = b[1] + 2 * b[2] * x,
      ep = sqrt(V[1, 1] + 4 * x * V[1, 2] + 4 * x^2 * V[2, 2]),
      inf = efeito - tc * ep, sup = efeito + tc * ep
    )
  media <- mean(dados$prop_superior)
  g <- ggplot(curva, aes(x, efeito)) +
    geom_hline(yintercept = 0, linetype = "dashed", colour = "grey55") +
    geom_ribbon(aes(ymin = inf, ymax = sup), fill = "#B2182B", alpha = 0.18) +
    geom_line(colour = "#B2182B", linewidth = 1) +
    geom_rug(data = dados, aes(x = prop_superior, y = NULL), sides = "b", alpha = 0.25, inherit.aes = FALSE) +
    scale_x_continuous(labels = scales::label_number(suffix = "%", decimal.mark = ",", accuracy = 1)) +
    scale_y_continuous(labels = scales::label_number(decimal.mark = ",", accuracy = 0.001)) +
    labs(
      title = "Efeito marginal do ensino superior sobre ln(salário real), por nível de X2",
      subtitle = sprintf("Efeitos fixos com termo quadrático; faixa: IC de 95%% (erro agrupado por município, t com 28 gl). Efeito na média amostral de X2 (%s%%): %s",
                         formatC(media, format = "f", digits = 1, decimal.mark = ","), fmt4(b[1] + 2 * b[2] * media)),
      x = "Vínculos com ensino superior (% dos vínculos)", y = "Variação em ln(salário) por ponto percentual",
      caption = "290 observações (29 municípios x 10 anos), 2012 a 2021. Marcas no eixo: valores observados de X2."
    ) +
    theme_minimal(base_size = 11) +
    theme(plot.title = element_text(face = "bold", size = 12), plot.subtitle = element_text(size = 9, colour = "grey25"),
          plot.caption = element_text(hjust = 0, size = 8, colour = "grey30"), panel.grid.minor = element_blank())
  arquivo <- file.path(DIR_FIGURAS, paste0(PREFIXO, "efeito_marginal_superior.png"))
  ggsave(arquivo, g, width = 9, height = 5.5, dpi = 300, bg = "white")
  arquivo
}


# -----------------------------------------------------------------------------
# 4. Fragilidade 2: sensibilidade da Selic real
# -----------------------------------------------------------------------------
coef_selic <- function(dados, termos, cluster = "id_municipio", gl = GL_MUNICIPIOS, rotulo) {
  w <- montar_within(dados, termos)
  a <- ajuste_cluster(w$y, w$X, dados[[cluster]], k_ajuste = ncol(w$X))
  r <- resumo_coef(a, gl, "selic_real")
  tibble::tibble(cenario = rotulo, n = nrow(dados), estimativa = r$estimativa, erro_padrao = r$erro_padrao,
                 estatistica_t = r$estatistica_t, p_valor = r$p_valor, graus_liberdade = gl)
}

# Bootstrap wild cluster por ano, restrito, com todas as 2^10 combinações de sinais.
bootstrap_exato_por_ano <- function(dados, termos) {
  w <- montar_within(dados, termos)
  g <- as.integer(factor(dados$ano))
  G <- max(g)
  n <- nrow(w$X)
  X <- w$X
  id <- dados$id_municipio
  j <- match("selic_real", colnames(X))
  XtXi <- solve(crossprod(X))
  fator <- (G / (G - 1)) * ((n - 1) / (n - ncol(X)))
  estat <- function(yy) {
    # Os sinais variam por ano dentro de cada município; y* deixa de ter média zero
    # por município e precisa passar de novo pela transformação within.
    yy <- yy - stats::ave(yy, id)
    beta <- as.numeric(XtXi %*% crossprod(X, yy))
    e <- as.numeric(yy - X %*% beta)
    S <- rowsum(X * e, g)
    V <- fator * XtXi %*% crossprod(S) %*% XtXi
    beta[j] / sqrt(V[j, j])
  }
  t_obs <- estat(w$y)
  Xr <- X[, -j, drop = FALSE]
  ajuste_r <- as.numeric(Xr %*% solve(crossprod(Xr), crossprod(Xr, w$y)))
  u_r <- w$y - ajuste_r
  sinais <- as.matrix(expand.grid(rep(list(c(-1, 1)), G)))
  t_b <- apply(sinais, 1, function(s) estat(ajuste_r + s[g] * u_r))
  c(t_observado = t_obs, p_bootstrap = mean(abs(t_b) >= abs(t_obs) - 1e-9), combinacoes = nrow(sinais))
}

sensibilidade_selic <- function(dados) {
  termos <- TERMOS_LINEARES
  base <- coef_selic(dados, termos, rotulo = "Efeitos fixos, todos os anos (erro agrupado por município)")
  sem_ano <- purrr::map_dfr(sort(unique(dados$ano)), function(a0) {
    coef_selic(dados[dados$ano != a0, ], termos, rotulo = paste("Sem o ano", a0))
  })
  sem_covid <- coef_selic(dados[dados$ano <= 2019, ], termos, rotulo = "Sem 2020 e 2021")
  dados <- dados |> mutate(tendencia = ano - min(ano))
  com_tend <- coef_selic(dados, c(termos, "tendencia"), rotulo = "Com tendência linear no ano")
  por_ano <- coef_selic(dados, termos, cluster = "ano", gl = GL_ANOS, rotulo = "Erro agrupado por ano (10 grupos, t com 9 gl)")
  quad <- coef_selic(dados, TERMOS_QUAD, rotulo = "Com termos quadráticos de X2, X3 e X4")
  tabela <- dplyr::bind_rows(base, sem_ano, sem_covid, com_tend, por_ano, quad)
  b1 <- bootstrap_exato_por_ano(dados, termos)
  b2 <- bootstrap_exato_por_ano(dados, TERMOS_QUAD)
  boot <- tibble::tibble(
    modelo = c("Efeitos fixos linear", "Efeitos fixos com quadráticos"),
    estatistica_t_por_ano = c(b1[["t_observado"]], b2[["t_observado"]]),
    p_bootstrap_exato = c(b1[["p_bootstrap"]], b2[["p_bootstrap"]]),
    combinacoes = c(b1[["combinacoes"]], b2[["combinacoes"]])
  )
  list(tabela = tabela, boot = boot)
}


# -----------------------------------------------------------------------------
# 5. Fragilidade 3: exogeneidade estrita e regressores defasados
# -----------------------------------------------------------------------------
exogeneidade <- function(dados) {
  dd <- dados |>
    group_by(id_municipio) |>
    arrange(ano) |>
    mutate(
      sup_futuro = dplyr::lead(prop_superior), dom_futuro = dplyr::lead(dom_industrial), sha_futuro = dplyr::lead(shannon_diversificacao),
      sup_defas = dplyr::lag(prop_superior), dom_defas = dplyr::lag(dom_industrial), sha_defas = dplyr::lag(shannon_diversificacao)
    ) |>
    ungroup()
  # Todas as tabelas de efeitos fixos usam a transformação within e k igual ao número de regressores.
  estimar <- function(d, termos, rotulo) {
    w <- montar_within(d, termos)
    a <- ajuste_cluster(w$y, w$X, d$id_municipio, k_ajuste = ncol(w$X))
    list(a = a, tabela = resumo_coef(a, GL_MUNICIPIOS, termos) |> mutate(modelo = rotulo, n = nrow(d), .before = 1))
  }
  # Valores futuros: H0 de exogeneidade estrita, os três coeficientes são nulos.
  termos_f <- c("prop_superior", "dom_industrial", "shannon_diversificacao", "selic_real", "sup_futuro", "dom_futuro", "sha_futuro")
  ef <- estimar(dd |> filter(!is.na(sup_futuro)), termos_f, "Efeitos fixos com valores futuros dos regressores (2012 a 2020)")
  idx <- c("sup_futuro", "dom_futuro", "sha_futuro")
  Fh <- as.numeric(t(ef$a$beta[idx]) %*% solve(ef$a$V[idx, idx]) %*% ef$a$beta[idx]) / length(idx)
  teste <- tibble::tibble(teste = "Exogeneidade estrita: valores futuros de X2, X3 e X4 conjuntamente nulos",
                          estatistica_f = Fh, gl_numerador = length(idx), gl_denominador = GL_MUNICIPIOS,
                          p_valor = stats::pf(Fh, length(idx), GL_MUNICIPIOS, lower.tail = FALSE))
  # Regressores defasados em um ano.
  ed <- estimar(dd |> filter(!is.na(sup_defas)), c("sup_defas", "dom_defas", "sha_defas", "selic_real"),
                "Efeitos fixos com X2, X3 e X4 defasados em um ano (2013 a 2021)")
  list(coef = dplyr::bind_rows(ef$tabela, ed$tabela) |> dplyr::select(modelo, termo, estimativa, erro_padrao, estatistica_t, p_valor, n),
       teste = teste)
}


# -----------------------------------------------------------------------------
# 5b. Simulação com efeitos fixos, observações influentes e escolha da forma de Y
# -----------------------------------------------------------------------------
# Variação percentual de Y para os cenários da simulação (+10 pontos em X3 em dois
# municípios; +5 pontos em X2 nos 29 municípios), com os coeficientes de efeitos fixos.
simulacao_efeitos_fixos <- function(dados, fq) {
  w <- montar_within(dados, TERMOS_LINEARES)
  a <- ajuste_cluster(w$y, w$X, dados$id_municipio, k_ajuste = ncol(w$X))
  tc <- stats::qt(0.975, GL_MUNICIPIOS)
  linha <- function(cenario, modelo, variavel, delta, termo) {
    b <- a$beta[termo]; ep <- sqrt(a$V[termo, termo])
    tibble::tibble(cenario = cenario, modelo = modelo, municipios = NA_integer_, delta_pontos = delta,
                   variacao_pct = 100 * (exp(delta * b) - 1),
                   ic_inf_pct = 100 * (exp(delta * (b - tc * ep)) - 1), ic_sup_pct = 100 * (exp(delta * (b + tc * ep)) - 1))
  }
  x_pool <- cbind(1, as.matrix(as.data.frame(dados)[, c("prop_superior", "dom_industrial", "shannon_diversificacao", "selic_real", "dist_curitiba_km")]))
  b_pool <- solve(crossprod(x_pool), crossprod(x_pool, dados$ln_salario_real))
  ano_base <- dados |> filter(ano == max(ano))
  b <- fq$a$beta
  quad_x2 <- 100 * (exp(b["prop_superior"] * 5 + b["sup2"] * ((ano_base$prop_superior + 5)^2 - ano_base$prop_superior^2)) - 1)
  c1 <- ano_base |> filter(id_municipio %in% c("4107652", "4100400"))
  quad_x3 <- 100 * (exp(b["dom_industrial"] * 10 + b["dom2"] * ((c1$dom_industrial + 10)^2 - c1$dom_industrial^2)) - 1)
  dplyr::bind_rows(
    tibble::tibble(cenario = "Cenário 1: +10 pontos em X3", modelo = "MQO empilhado (Modelo 2)", municipios = NA_integer_, delta_pontos = 10,
                   variacao_pct = 100 * (exp(10 * b_pool["dom_industrial", 1]) - 1), ic_inf_pct = NA_real_, ic_sup_pct = NA_real_),
    linha("Cenário 1: +10 pontos em X3", "Efeitos fixos linear", "dom_industrial", 10, "dom_industrial"),
    tibble::tibble(cenario = "Cenário 1: +10 pontos em X3", modelo = "Efeitos fixos com quadráticos (média dos dois municípios, base 2021)", municipios = 2L, delta_pontos = 10,
                   variacao_pct = mean(quad_x3), ic_inf_pct = NA_real_, ic_sup_pct = NA_real_,
                   minimo_pct = min(quad_x3), maximo_pct = max(quad_x3),
                   municipio_do_minimo = c1$nome_municipio[which.min(quad_x3)], municipio_do_maximo = c1$nome_municipio[which.max(quad_x3)]),
    tibble::tibble(cenario = "Cenário 2: +5 pontos em X2", modelo = "MQO empilhado (Modelo 2)", municipios = NA_integer_, delta_pontos = 5,
                   variacao_pct = 100 * (exp(5 * b_pool["prop_superior", 1]) - 1), ic_inf_pct = NA_real_, ic_sup_pct = NA_real_),
    linha("Cenário 2: +5 pontos em X2", "Efeitos fixos linear", "prop_superior", 5, "prop_superior"),
    tibble::tibble(cenario = "Cenário 2: +5 pontos em X2", modelo = "Efeitos fixos com quadráticos (média dos 29 municípios, base 2021)", municipios = nrow(ano_base), delta_pontos = 5,
                   variacao_pct = mean(quad_x2), ic_inf_pct = NA_real_, ic_sup_pct = NA_real_,
                   minimo_pct = min(quad_x2), maximo_pct = max(quad_x2),
                   municipio_do_minimo = ano_base$nome_municipio[which.min(quad_x2)], municipio_do_maximo = ano_base$nome_municipio[which.max(quad_x2)])
  )
}

# Reestimação sem as observações influentes do Modelo 2 (distância de Cook > 4/n),
# sem Lapa 2016 e sem o município de Adrianópolis.
sensibilidade_influencia <- function(dados) {
  m2 <- stats::lm(ln_salario_real ~ prop_superior + dom_industrial + shannon_diversificacao + selic_real + dist_curitiba_km, data = dados)
  cook <- stats::cooks.distance(m2)
  cenarios <- list(
    "Amostra completa" = rep(FALSE, nrow(dados)),
    "Sem Araucária 2012 e 2013" = dados$x3_negativo,
    "Sem as observações com Cook > 4/n" = unname(cook) > 4 / nrow(dados),
    "Sem Lapa 2016" = dados$id_municipio == "4113205" & dados$ano == 2016,
    "Sem Adrianópolis (município inteiro)" = dados$id_municipio == "4100202"
  )
  purrr::imap_dfr(cenarios, function(fora, nome) {
    d <- dados[!fora, ]
    X <- cbind(`(Intercept)` = 1, as.matrix(as.data.frame(d)[, c("prop_superior", "dom_industrial", "shannon_diversificacao", "selic_real", "dist_curitiba_km")]))
    a <- ajuste_cluster(d$ln_salario_real, X, d$id_municipio)
    ols <- resumo_coef(a, a$G - 1, setdiff(names(a$beta), "(Intercept)")) |> mutate(modelo = "MQO empilhado")
    w <- montar_within(d, TERMOS_LINEARES)
    af <- ajuste_cluster(w$y, w$X, d$id_municipio, k_ajuste = ncol(w$X))
    fe <- resumo_coef(af, af$G - 1) |> mutate(modelo = "Efeitos fixos")
    dplyr::bind_rows(ols, fe) |> mutate(cenario = nome, observacoes_excluidas = sum(fora), n = nrow(d), municipios = af$G)
  }) |>
    dplyr::select(cenario, observacoes_excluidas, n, municipios, modelo, termo, estimativa, erro_padrao, estatistica_t, p_valor)
}

# Box-Cox: razão de verossimilhança para a forma de Y (lambda = 0 é o logaritmo; lambda = 1, o nível).
box_cox <- function(dados) {
  y <- dados$salario_medio_real
  gm <- exp(mean(log(y)))
  n <- length(y)
  Xp <- cbind(1, as.matrix(as.data.frame(dados)[, c("prop_superior", "dom_industrial", "shannon_diversificacao", "selic_real", "dist_curitiba_km")]))
  Xf <- cbind(as.matrix(as.data.frame(dados)[, TERMOS_LINEARES]), stats::model.matrix(~ factor(dados$id_municipio) - 1))
  transformar <- function(l) if (abs(l) < 1e-9) gm * log(y) else (y^l - 1) / (l * gm^(l - 1))
  verossimilhanca <- function(X, l) -n / 2 * log(sum(stats::lm.fit(X, transformar(l))$residuals^2))
  grade <- seq(-3, 2, by = 0.01)
  purrr::imap_dfr(list("MQO empilhado" = Xp, "Efeitos fixos (variáveis binárias de município)" = Xf), function(X, nome) {
    ll <- vapply(grade, \(l) verossimilhanca(X, l), numeric(1))
    l_hat <- stats::optimize(function(l) -verossimilhanca(X, l), interval = c(min(grade), max(grade)))$minimum
    lmax <- verossimilhanca(X, l_hat)
    dentro <- grade[ll >= lmax - stats::qchisq(0.95, 1) / 2]
    lr0 <- 2 * (lmax - verossimilhanca(X, 0))
    lr1 <- 2 * (lmax - verossimilhanca(X, 1))
    tibble::tibble(modelo = nome, lambda_estimado = l_hat, ic95_inf = min(dentro), ic95_sup = max(dentro),
                   lr_logaritmo = lr0, p_logaritmo = stats::pchisq(lr0, 1, lower.tail = FALSE),
                   lr_nivel = lr1, p_nivel = stats::pchisq(lr1, 1, lower.tail = FALSE))
  })
}


# -----------------------------------------------------------------------------
# 5c. Selic real e deflator, bootstrap com pesos de Webb, quebra em Curitiba, RESET dos Modelos 3 e 3b
# -----------------------------------------------------------------------------
# X5 = ((1 + Selic)/(1 + IPCA) - 1) x 100 e Y é deflacionado pelo mesmo IPCA: o coeficiente de X5 pode
# carregar o canal da deflação. Separa-se X5 em Selic nominal e IPCA do ano (efeitos fixos).
decomposicao_selic <- function(dados) {
  d <- dados |> mutate(selic_nominal = selic_nominal_ano, ipca = ipca_ano)
  termos <- c("prop_superior", "dom_industrial", "shannon_diversificacao", "selic_nominal", "ipca")
  w <- montar_within(d, termos)
  a_mun <- ajuste_cluster(w$y, w$X, d$id_municipio, k_ajuste = ncol(w$X))
  a_ano <- ajuste_cluster(w$y, w$X, d$ano, k_ajuste = ncol(w$X))
  tab <- resumo_coef(a_mun, GL_MUNICIPIOS) |>
    mutate(modelo = "Efeitos fixos com Selic nominal e IPCA do ano separados", .before = 1) |>
    mutate(erro_padrao_por_ano = sqrt(diag(a_ano$V))[termo],
           p_valor_por_ano = 2 * stats::pt(-abs(a_ano$beta[termo] / erro_padrao_por_ano), GL_ANOS))
  # Restrição de Fisher: se X5 tem um efeito próprio, b_Selic nominal = - b_IPCA.
  R <- c(0, 0, 0, 1, 1)
  wald <- function(a, gl) {
    est <- sum(R * a$beta); ep <- sqrt(as.numeric(t(R) %*% a$V %*% R)); tv <- est / ep
    c(soma = est, f = tv^2, p = 2 * stats::pt(-abs(tv), gl))
  }
  wm <- wald(a_mun, GL_MUNICIPIOS); wa <- wald(a_ano, GL_ANOS)
  teste <- tibble::tibble(
    teste = "Restrição de Fisher: coeficiente da Selic nominal + coeficiente do IPCA = 0",
    agrupamento = c("por município (t com 28 gl)", "por ano (t com 9 gl)"),
    soma_dos_coeficientes = c(wm[["soma"]], wa[["soma"]]), estatistica_f = c(wm[["f"]], wa[["f"]]), p_valor = c(wm[["p"]], wa[["p"]])
  )
  list(tabela = tab, teste = teste)
}

# Bootstrap wild cluster por ano com pesos de Webb (seis pontos), mais adequado que Rademacher com 10 grupos.
bootstrap_webb_por_ano <- function(dados, termos, B = 9999L, semente = SEMENTE_WEBB) {
  w <- montar_within(dados, termos)
  g <- as.integer(factor(dados$ano)); G <- max(g); n <- nrow(w$X); X <- w$X; id <- dados$id_municipio
  j <- match("selic_real", colnames(X)); XtXi <- solve(crossprod(X))
  fator <- (G / (G - 1)) * ((n - 1) / (n - ncol(X)))
  estat <- function(yy) {
    yy <- yy - stats::ave(yy, id)
    beta <- as.numeric(XtXi %*% crossprod(X, yy)); e <- as.numeric(yy - X %*% beta)
    S <- rowsum(X * e, g); V <- fator * XtXi %*% crossprod(S) %*% XtXi
    beta[j] / sqrt(V[j, j])
  }
  t_obs <- estat(w$y)
  Xr <- X[, -j, drop = FALSE]; fit_r <- as.numeric(Xr %*% solve(crossprod(Xr), crossprod(Xr, w$y))); u_r <- w$y - fit_r
  pesos <- c(-sqrt(1.5), -1, -sqrt(0.5), sqrt(0.5), 1, sqrt(1.5))
  set.seed(semente)
  t_b <- vapply(seq_len(B), function(b) estat(fit_r + sample(pesos, G, replace = TRUE)[g] * u_r), numeric(1))
  c(t_observado = t_obs, p_bootstrap = mean(abs(t_b) >= abs(t_obs) - 1e-9))
}

# Teste de Chow: os coeficientes de X2 a X5 são os mesmos em Curitiba e nos demais municípios?
# X6 não entra porque é constante (zero) dentro de Curitiba.
teste_quebra_curitiba <- function(dados) {
  f2 <- ln_salario_real ~ prop_superior + dom_industrial + shannon_diversificacao + selic_real + dist_curitiba_km
  m_r <- stats::lm(f2, data = dados)
  # Modelo irrestrito: deslocamento do intercepto e interações da indicadora com X2 a X5
  # (X6 é constante, igual a zero, em Curitiba; sua interação seria colinear com a indicadora).
  m_u <- stats::lm(update(f2, . ~ . + dummy_curitiba + dummy_curitiba:prop_superior + dummy_curitiba:dom_industrial +
                            dummy_curitiba:shannon_diversificacao + dummy_curitiba:selic_real), data = dados)
  gl1 <- 5L
  gl2 <- stats::nobs(m_u) - sum(!is.na(stats::coef(m_u)))
  F <- ((sum(stats::residuals(m_r)^2) - sum(stats::residuals(m_u)^2)) / gl1) / (sum(stats::residuals(m_u)^2) / gl2)
  tibble::tibble(teste = "Chow: Modelo 2 contra o modelo com indicadora de Curitiba e suas interações com X2 a X5",
                 estatistica_f = F, gl_numerador = gl1, gl_denominador = gl2,
                 p_valor = stats::pf(F, gl1, gl2, lower.tail = FALSE),
                 observacao = "Curitiba tem 10 observações; teste clássico, sem erro agrupado")
}

reset_modelos_3_3b <- function(dados) {
  f3 <- ln_salario_real ~ prop_superior + dom_industrial + shannon_diversificacao + selic_real + dist_curitiba_km + dummy_curitiba
  f3b <- update(f3, . ~ . + dom_industrial:dist_curitiba_km)
  purrr::imap_dfr(list("Modelo 3" = f3, "Modelo 3b" = f3b), function(f, nome) {
    m <- stats::lm(f, data = dados)
    a <- reset_posto(m, "regressores"); b <- reset_posto(m, "ajustados")
    tibble::tibble(modelo = nome,
                   reset_regressores_f = a[["estatistica"]], reset_regressores_gl = paste(a[["gl1"]], a[["gl2"]], sep = "; "), reset_regressores_p = a[["p_valor"]],
                   reset_ajustados_f = b[["estatistica"]], reset_ajustados_gl = paste(b[["gl1"]], b[["gl2"]], sep = "; "), reset_ajustados_p = b[["p_valor"]])
  })
}

# -----------------------------------------------------------------------------
# 6. Conferências internas
# -----------------------------------------------------------------------------
conferir <- function(dados, fq) {
  m <- stats::lm(ln_salario_real ~ prop_superior + dom_industrial + shannon_diversificacao + selic_real +
                   sup2 + dom2 + sha2 + factor(id_municipio), data = dados)
  dif <- max(abs(unname(stats::coef(m)[TERMOS_QUAD]) - fq$a$beta[TERMOS_QUAD]))
  if (dif > 1e-8) stop("Efeitos fixos quadráticos diferem de lm() com variáveis binárias: ", dif, call. = FALSE)
  message("Conferência: coeficientes within contra lm() com variáveis binárias (dif. ", format(dif, digits = 2), ").")
}


# -----------------------------------------------------------------------------
# 7. Execução
# -----------------------------------------------------------------------------
executar_etapa_8 <- function() {
  dados <- ler_painel()
  message("Painel: ", nrow(dados), " linhas.")
  forma <- especificacoes_forma(dados)
  fq <- fe_quadratico(dados)
  conferir(dados, fq)
  sel <- sensibilidade_selic(dados)
  exo <- exogeneidade(dados)
  sim_fe <- simulacao_efeitos_fixos(dados, fq)
  infl <- sensibilidade_influencia(dados)
  bc <- box_cox(dados)
  dec_lista <- decomposicao_selic(dados)
  dec <- dec_lista$tabela
  wb <- bootstrap_webb_por_ano(dados, TERMOS_LINEARES)
  wq <- bootstrap_webb_por_ano(dados, TERMOS_QUAD)
  webb <- tibble::tibble(modelo = c("Efeitos fixos linear", "Efeitos fixos com quadráticos"), estatistica_t_por_ano = c(wb[["t_observado"]], wq[["t_observado"]]), p_bootstrap_webb = c(wb[["p_bootstrap"]], wq[["p_bootstrap"]]), replicas = 9999L, semente = SEMENTE_WEBB)
  chow <- teste_quebra_curitiba(dados)
  reset_cl <- reset_modelos_3_3b(dados)
  figura_efeito_marginal(dados, fq)

  gravar <- function(tabela, nome) readr::write_csv(tabela, file.path(DIR_RESULTADOS, paste0(PREFIXO, nome, ".csv")))
  gravar(forma, "forma_funcional")
  gravar(fq$coef, "fe_quadratico_coeficientes")
  gravar(fq$marg, "fe_quadratico_efeitos_marginais")
  gravar(fq$conj, "fe_quadratico_teste_conjunto")
  gravar(sel$tabela, "selic_sensibilidade")
  gravar(sel$boot, "selic_bootstrap_exato_por_ano")
  gravar(exo$coef, "exogeneidade_coeficientes")
  gravar(exo$teste, "exogeneidade_teste")
  gravar(sim_fe, "simulacao_efeitos_fixos")
  gravar(infl, "influencia_sensibilidade")
  gravar(bc, "box_cox")
  gravar(dec, "selic_decomposicao")
  gravar(dec_lista$teste, "selic_decomposicao_teste_fisher")
  gravar(webb, "selic_bootstrap_webb")
  gravar(chow, "quebra_curitiba")
  gravar(reset_cl, "reset_modelos_3_3b")

  arred <- function(d) mutate(d, across(where(is.numeric), \(v) signif(v, 4)))
  message("\nForma funcional:")
  print(as.data.frame(arred(forma)), row.names = FALSE)
  message("\nEfeitos fixos com quadráticos (erro agrupado, t com 28 gl):")
  print(as.data.frame(arred(fq$coef)), row.names = FALSE)
  message("\nEfeitos marginais médios:")
  print(as.data.frame(arred(fq$marg)), row.names = FALSE)
  print(as.data.frame(arred(fq$conj)), row.names = FALSE)
  message("\nSensibilidade da Selic:")
  print(as.data.frame(arred(sel$tabela)), row.names = FALSE)
  print(as.data.frame(arred(sel$boot)), row.names = FALSE)
  message("\nExogeneidade e defasagens:")
  print(as.data.frame(arred(exo$coef)), row.names = FALSE)
  print(as.data.frame(arred(exo$teste)), row.names = FALSE)
  message("\nSimulação com efeitos fixos:")
  print(as.data.frame(arred(sim_fe)), row.names = FALSE)
  message("\nSensibilidade a observações influentes:")
  print(as.data.frame(arred(infl)), row.names = FALSE)
  message("\nSelic decomposta:")
  print(as.data.frame(arred(dec)), row.names = FALSE)
  print(as.data.frame(arred(dec_lista$teste)), row.names = FALSE)
  print(as.data.frame(arred(webb)), row.names = FALSE)
  message("\nChow e RESET dos Modelos 3 e 3b:")
  print(as.data.frame(arred(chow)), row.names = FALSE)
  print(as.data.frame(arred(reset_cl)), row.names = FALSE)
  message("\nBox-Cox:")
  print(as.data.frame(arred(bc)), row.names = FALSE)
  invisible(list(forma = forma, fq = fq, selic = sel, exogeneidade = exo))
}

resultados_etapa_8 <- executar_etapa_8()
