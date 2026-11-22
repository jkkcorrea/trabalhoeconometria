# =============================================================================
# Etapa 4: modelagem por MQO e diagnósticos ensinados na disciplina
# Trabalho de Econometria I (UFPR): salário médio real formal nos 29 municípios
# da Região Metropolitana de Curitiba, 2012 a 2021 (290 observações).
#
# Escopo: somente métodos das fontes oficiais da disciplina (ver
# fontes/OFICIAL_FONTES_DA_DISCIPLINA.md). Nesta etapa:
#   - MQO empilhado (Modelo 2, principal), Modelo 3 (dummy de Curitiba) e
#     Modelo 3b (interação dominância industrial x distância);
#   - erros-padrão clássicos e de White (HC1), com t de n - k graus de liberdade;
#   - FIV e tolerância (multicolinearidade, regra FIV > 10);
#   - Breusch-Pagan-Godfrey e Goldfeld-Quandt (heterocedasticidade);
#   - F da ANOVA para a significância conjunta.
#
# Lê:    ./dados_processados/dados_painel_rmc.rds
# Grava: ./resultados_econometricos/coeficientes_modelos.csv
#        ./resultados_econometricos/testes_diagnostico.csv
#        ./resultados_econometricos/vif_tolerancia.csv
#        ./resultados_econometricos/anova_f_modelos.csv
#        ./figuras_graficos/diag1_residuos_vs_ajustados.png
#        ./figuras_graficos/diag2_residuos_por_municipio.png
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
  biblioteca_usuario <- file.path(base_usuario,
    paste(R.version$major, strsplit(R.version$minor, ".", fixed = TRUE)[[1]][1], sep = "."))
}
if (dir.exists(biblioteca_usuario)) .libPaths(c(biblioteca_usuario, .libPaths()))

PACOTES <- c("dplyr", "readr", "tibble", "stringr", "purrr", "ggplot2", "car", "lmtest", "sandwich")
ausentes <- PACOTES[!vapply(PACOTES, requireNamespace, logical(1), quietly = TRUE)]
if (length(ausentes) > 0) {
  stop("Pacotes ausentes: ", paste(ausentes, collapse = ", "), ". Este script não instala pacotes.", call. = FALSE)
}
invisible(lapply(PACOTES, function(p) suppressPackageStartupMessages(library(p, character.only = TRUE))))

DIR_PROCESSADOS <- "./dados_processados"
DIR_RESULTADOS  <- "./resultados_econometricos"
DIR_FIGURAS     <- "./figuras_graficos"
ARQ_PAINEL      <- file.path(DIR_PROCESSADOS, "dados_painel_rmc.rds")
N_MUNICIPIOS    <- 29L
N_ANOS          <- 10L
ALFA            <- 0.05

for (d in c(DIR_RESULTADOS, DIR_FIGURAS)) if (!dir.exists(d)) dir.create(d, recursive = TRUE)

# -----------------------------------------------------------------------------
# 1. Painel e validação
# -----------------------------------------------------------------------------
carregar_painel <- function() {
  if (!file.exists(ARQ_PAINEL)) stop("Painel ausente: ", ARQ_PAINEL, ". Rode a Etapa 2.", call. = FALSE)
  painel <- readRDS(ARQ_PAINEL)
  necessarias <- c("id_municipio", "ano", "ln_salario_real", "prop_superior", "dom_industrial",
                   "gini_setorial", "selic_real", "dist_curitiba_km", "dummy_curitiba")
  faltam <- setdiff(necessarias, names(painel))
  if (length(faltam) > 0) stop("Painel sem colunas: ", paste(faltam, collapse = ", "), call. = FALSE)
  if (nrow(painel) != N_MUNICIPIOS * N_ANOS) {
    stop("Painel com ", nrow(painel), " linhas; esperado ", N_MUNICIPIOS * N_ANOS, ".", call. = FALSE)
  }
  for (v in necessarias[-(1:2)]) {
    nao_finitos <- sum(!is.finite(as.numeric(painel[[v]])))
    if (nao_finitos > 0) stop("Variável ", v, " com ", nao_finitos, " valores não finitos.", call. = FALSE)
    painel[[v]] <- as.numeric(painel[[v]])
  }
  message("Painel: ", nrow(painel), " linhas, sem NA, NaN ou Inf nas variáveis usadas.")
  painel
}

# -----------------------------------------------------------------------------
# 2. Modelos (fórmulas)
# -----------------------------------------------------------------------------
FORMULA_M2 <- ln_salario_real ~ prop_superior + dom_industrial + gini_setorial + selic_real + dist_curitiba_km
FORMULA_M3 <- update(FORMULA_M2, . ~ . + dummy_curitiba)
FORMULA_M3B <- update(FORMULA_M3, . ~ . + dom_industrial:dist_curitiba_km)
# Modelo 4: variáveis dummy de município (Gujarati, cap. 9). Absorve X6 (constante dentro do município)
# e controla a heterogeneidade entre municípios, que o teste F de acréscimo rejeita fortemente (Etapa 6).
FORMULA_M4 <- ln_salario_real ~ prop_superior + dom_industrial + gini_setorial + selic_real + factor(id_municipio)

ajustar_modelos <- function(painel) {
  list(
    "Modelo 2" = lm(FORMULA_M2, data = painel),
    "Modelo 3" = lm(FORMULA_M3, data = painel),
    "Modelo 3b" = lm(FORMULA_M3B, data = painel),
    "Modelo 4" = lm(FORMULA_M4, data = painel)
  )
}

# -----------------------------------------------------------------------------
# 3. Coeficientes: classico e White (HC1), com t de n - k graus de liberdade
# -----------------------------------------------------------------------------
tabela_coeficientes <- function(modelos) {
  purrr::imap_dfr(modelos, function(m, nome) {
    # As 28 dummies de município são gravadas no CSV; a documentação mostra só as variáveis do modelo.
    gl <- df.residual(m)
    matrizes <- list(classico = stats::vcov(m), white = sandwich::vcovHC(m, type = "HC1"))
    purrr::imap_dfr(matrizes, function(V, tipo) {
      est <- stats::coef(m)
      ep  <- sqrt(diag(V))
      tt  <- est / ep
      tibble::tibble(modelo = nome, matriz = tipo, termo = names(est),
                     estimativa = unname(est), erro_padrao = unname(ep),
                     estatistica_t = unname(tt),
                     p_valor = 2 * stats::pt(-abs(tt), df = gl),
                     ic_inf_95 = unname(est - stats::qt(1 - ALFA / 2, gl) * ep),
                     ic_sup_95 = unname(est + stats::qt(1 - ALFA / 2, gl) * ep),
                     gl = gl)
    })
  })
}

# -----------------------------------------------------------------------------
# 4. Testes ensinados
# -----------------------------------------------------------------------------
decisao <- function(p) ifelse(p < ALFA, "rejeita H0", "não rejeita H0")

testes_diagnostico <- function(modelos, painel) {
  m2 <- modelos[["Modelo 2"]]
  lista <- list()
  for (nome in names(modelos)) {
    m <- modelos[[nome]]
    bp <- lmtest::bptest(m)
    lista[[length(lista) + 1]] <- tibble::tibble(
      modelo = nome, teste = "Breusch-Pagan-Godfrey (bptest, studentized)",
      hipotese_nula = "H0: Var(u_t) = sigma^2 para todo t (erros homocedásticos; inclinações da regressão auxiliar dos resíduos ao quadrado iguais a zero)",
      hipotese_alternativa = "Ha: Var(u_t) depende de ao menos um regressor (heterocedasticidade); critério BP ~ qui-quadrado com k - 1 gl",
      estatistica = unname(bp$statistic),
      gl = as.character(unname(bp$parameter)), p_valor = bp$p.value
    )
  }
  # Goldfeld-Quandt: ordenação pela distância a Curitiba, fração central omitida 0,2.
  # Ordenar por dist_curitiba_km e alternativa "greater" são [presunção da modelagem]: a
  # variável de ordenação deve ser a que se suspeita causar a heterocedasticidade.
  gq <- lmtest::gqtest(m2, order.by = painel$dist_curitiba_km, fraction = 0.2, alternative = "greater")
  lista[[length(lista) + 1]] <- tibble::tibble(
    modelo = "Modelo 2", teste = "Goldfeld-Quandt (gqtest, unilateral; ordenado por dist_curitiba_km)",
    hipotese_nula = "H0: sigma_1^2 = sigma_2^2 (variância constante entre os dois segmentos)",
    hipotese_alternativa = "Ha: sigma_2^2 > sigma_1^2 (variância cresce com a distância); estatística F = SQR2/SQR1 com gl (n - omitidas)/2 - k",
    estatistica = unname(gq$statistic),
    gl = paste(unname(gq$parameter), collapse = "; "), p_valor = gq$p.value
  )
  dplyr::bind_rows(lista) |>
    dplyr::mutate(decisao_5pct = decisao(p_valor))
}

vif_tabela <- function(modelos) {
  purrr::imap_dfr(modelos[c("Modelo 2", "Modelo 3")], function(m, nome) {
    v <- car::vif(m)
    if (is.matrix(v)) v <- v[, "GVIF"]
    tibble::tibble(modelo = nome, variavel = names(v), fiv = unname(v),
                   tolerancia = 1 / unname(v), decisao_fiv_10 = ifelse(v > 10, "multicolinearidade elevada", "sem problema (FIV <= 10)"))
  })
}

anova_f <- function(modelos) {
  purrr::imap_dfr(modelos, function(m, nome) {
    s <- summary(m)
    f <- unname(s$fstatistic)
    tibble::tibble(modelo = nome, estatistica_f = f[1], gl_numerador = f[2], gl_denominador = f[3],
                   p_valor = stats::pf(f[1], f[2], f[3], lower.tail = FALSE), r2 = s$r.squared,
                   r2_ajustado = s$adj.r.squared)
  })
}

# -----------------------------------------------------------------------------
# 5. Figuras de diagnóstico (método gráfico ensinado)
# -----------------------------------------------------------------------------
gerar_figuras <- function(m2, painel) {
  base <- tibble::tibble(ajustado = fitted(m2), residuo = residuals(m2),
                         municipio = painel$id_municipio, ano = painel$ano)
  g1 <- ggplot(base, aes(ajustado, residuo)) +
    geom_hline(yintercept = 0, colour = "grey50") +
    geom_point(alpha = 0.6, colour = "#3C6A6D") +
    labs(title = "Resíduos contra valores ajustados (Modelo 2)",
         subtitle = "Dispersão constante em torno de zero sugere variância constante",
         x = "Valor ajustado de ln(salário real)", y = "Resíduo") +
    theme_bw(base_size = 11)
  ggsave(file.path(DIR_FIGURAS, "diag1_residuos_vs_ajustados.png"), g1, width = 8, height = 5, dpi = 200, bg = "white")

  g2 <- ggplot(base, aes(ano, residuo, group = municipio)) +
    geom_hline(yintercept = 0, colour = "grey50") +
    geom_line(alpha = 0.35, colour = "#496785") +
    labs(title = "Resíduos do Modelo 2 ao longo do tempo, por município",
         subtitle = "Uma linha por município; sequências do mesmo sinal indicam autocorrelação dentro do município",
         x = "Ano", y = "Resíduo") +
    theme_bw(base_size = 11)
  ggsave(file.path(DIR_FIGURAS, "diag2_residuos_por_municipio.png"), g2, width = 8, height = 5, dpi = 200, bg = "white")
  invisible(TRUE)
}


# -----------------------------------------------------------------------------
# 5b. Normalidade dos resíduos: Jarque-Bera (Gujarati, cap. 5, seção 5.12)
# -----------------------------------------------------------------------------
# S = assimetria e K = curtose com momentos centrais de n (Gujarati, apêndice A);
# JB = n [S^2/6 + (K - 3)^2/24], assintoticamente qui-quadrado com 2 gl.
# H0: resíduos normais. Ha: resíduos não normais. Decisão a 5%.
jarque_bera <- function(e) {
  n <- length(e)
  e <- e - mean(e)
  m2 <- mean(e^2); m3 <- mean(e^3); m4 <- mean(e^4)
  S <- m3 / m2^1.5
  K <- m4 / m2^2
  JB <- n * (S^2 / 6 + (K - 3)^2 / 24)
  list(S = S, K = K, JB = JB, p = stats::pchisq(JB, df = 2, lower.tail = FALSE))
}

testes_normalidade <- function(modelos) {
  purrr::imap_dfr(modelos[c("Modelo 2", "Modelo 4")], function(m, nome) {
    jb <- jarque_bera(stats::residuals(m))
    tibble::tibble(
      modelo = nome, teste = "Jarque-Bera (Gujarati, cap. 5, seção 5.12)",
      hipotese_nula = "H0: os resíduos têm distribuição normal (S = 0 e K = 3)",
      hipotese_alternativa = "Ha: os resíduos não têm distribuição normal (S diferente de 0 ou K diferente de 3)",
      estatistica = jb$JB, gl = "2", p_valor = jb$p, decisao_5pct = decisao(jb$p),
      assimetria_S = jb$S, curtose_K = jb$K
    )
  })
}

# -----------------------------------------------------------------------------
# 5c. Influência: outliers, alavancagem e pontos influentes (Gujarati, cap. 13, "Outliers, Leverage, and Influence")
# -----------------------------------------------------------------------------
# O Gujarati define os três conceitos e não apresenta teste formal (distância de Cook e DFBETAS não
# constam do material). Aqui: alavancagem (diagonal da matriz chapéu H = X (X'X)^-1 X'), resíduo padronizado
# e variação de cada coeficiente ao retirar a observação, em erros-padrão do modelo completo.
# Limiares (2k/n para alavancagem, |r| > 2 para outlier, 1 erro-padrão para influência) são [presunção da modelagem].
diagnosticos_influencia <- function(modelo, nome, painel, variaveis_foco) {
  n <- stats::nobs(modelo)
  k <- length(stats::coef(modelo))
  h <- stats::hatvalues(modelo)
  r <- stats::rstandard(modelo)
  b <- stats::coef(modelo)
  ep <- sqrt(diag(stats::vcov(modelo)))
  formula_m <- stats::formula(modelo)
  var_maxima <- numeric(n); var_nome <- character(n)
  for (i in seq_len(n)) {
    bi <- stats::coef(stats::lm(formula_m, data = painel[-i, ]))
    dif <- abs(bi[variaveis_foco] - b[variaveis_foco]) / ep[variaveis_foco]
    var_maxima[i] <- max(dif)
    var_nome[i] <- names(dif)[which.max(dif)]
  }
  tibble::tibble(
    modelo = nome, id_municipio = painel$id_municipio, nome_municipio = painel$nome_municipio, ano = painel$ano,
    alavancagem = unname(h), residuo_padronizado = unname(r),
    alavancagem_alta = h > 2 * k / n, outlier = abs(r) > 2,
    variacao_max_ep = var_maxima, coeficiente_mais_afetado = var_nome,
    influente = var_maxima > 1
  )
}

influencia_modelos <- function(modelos, painel) {
  foco_m2 <- c("prop_superior", "dom_industrial", "gini_setorial", "selic_real", "dist_curitiba_km")
  foco_m4 <- c("prop_superior", "dom_industrial", "gini_setorial", "selic_real")
  dplyr::bind_rows(
    diagnosticos_influencia(modelos[["Modelo 2"]], "Modelo 2", painel, foco_m2),
    diagnosticos_influencia(modelos[["Modelo 4"]], "Modelo 4", painel, foco_m4)
  )
}

# Sensibilidade: coeficientes com e sem as observações marcadas como influentes (Gujarati, cap. 13).
sensibilidade_influentes <- function(modelos, painel, influencia) {
  focais <- c("prop_superior", "dom_industrial", "gini_setorial", "selic_real", "dist_curitiba_km")
  purrr::map_dfr(c("Modelo 2", "Modelo 4"), function(nome) {
    inf <- influencia[influencia$modelo == nome & influencia$influente, ]
    if (nrow(inf) == 0) return(NULL)
    m <- modelos[[nome]]
    retirar <- paste(painel$id_municipio, painel$ano) %in% paste(inf$id_municipio, inf$ano)
    m_sem <- stats::update(m, data = painel[!retirar, ])
    cc <- stats::coef(m); cs <- stats::coef(m_sem)
    termos <- intersect(focais, names(cc))
    tibble::tibble(
      modelo = nome,
      observacoes_retiradas = paste(paste(inf$nome_municipio, inf$ano, sep = " "), collapse = "; "),
      termo = termos,
      coef_completo = unname(cc[termos]),
      coef_sem_influentes = unname(cs[termos]),
      variacao_percentual = 100 * (unname(cs[termos]) - unname(cc[termos])) / abs(unname(cc[termos]))
    )
  })
}

figura_normalidade <- function(modelo4) {
  g <- ggplot2::ggplot(data.frame(e = stats::residuals(modelo4)), ggplot2::aes(sample = e)) +
    ggplot2::stat_qq(colour = "#5F7F62", alpha = 0.7) +
    ggplot2::stat_qq_line(colour = "grey40") +
    ggplot2::labs(title = "Gráfico de probabilidade normal dos resíduos (Modelo 4)",
                  subtitle = "Pontos sobre a reta indicam resíduos aproximadamente normais (Gujarati, cap. 5)",
                  x = "Quantis teóricos da normal", y = "Quantis dos resíduos") +
    ggplot2::theme_bw(base_size = 11)
  ggplot2::ggsave(file.path(DIR_FIGURAS, "diag5_normalidade_npp.png"), g, width = 7, height = 5, dpi = 200, bg = "white")
}

# -----------------------------------------------------------------------------
# 6. Execução
# -----------------------------------------------------------------------------
executar_etapa_4 <- function() {
  painel <- carregar_painel()
  modelos <- ajustar_modelos(painel)

  coeficientes <- tabela_coeficientes(modelos)
  readr::write_csv(coeficientes, file.path(DIR_RESULTADOS, "coeficientes_modelos.csv"))

  testes <- testes_diagnostico(modelos, painel)
  readr::write_csv(testes, file.path(DIR_RESULTADOS, "testes_diagnostico.csv"))

  vif <- vif_tabela(modelos)
  readr::write_csv(vif, file.path(DIR_RESULTADOS, "vif_tolerancia.csv"))

  anova <- anova_f(modelos)
  readr::write_csv(anova, file.path(DIR_RESULTADOS, "anova_f_modelos.csv"))

  gerar_figuras(modelos[["Modelo 2"]], painel)

  normalidade <- testes_normalidade(modelos)
  readr::write_csv(normalidade, file.path(DIR_RESULTADOS, "normalidade_residuos.csv"))
  figura_normalidade(modelos[["Modelo 4"]])

  influencia <- influencia_modelos(modelos, painel)
  readr::write_csv(influencia, file.path(DIR_RESULTADOS, "influencia_observacoes.csv"))
  sensibilidade <- sensibilidade_influentes(modelos, painel, influencia)
  readr::write_csv(sensibilidade, file.path(DIR_RESULTADOS, "influencia_sensibilidade.csv"))

  message("Etapa 4 concluída: coeficientes, testes, VIF, ANOVA e figuras de diagnóstico gravados.")
  invisible(list(modelos = modelos, coeficientes = coeficientes, testes = testes, vif = vif, anova = anova,
                 normalidade = normalidade, influencia = influencia))
}

executar_etapa_4()
