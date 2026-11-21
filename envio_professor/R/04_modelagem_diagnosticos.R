# =============================================================================
# Modelos de regressão linear, diagnósticos do modelo clássico e inferência robusta
#
# Modelo 1: salário médio real (nível) sobre X2
# Modelo 2: ln do salário médio real sobre X2, X3, X4, X5 e X6
# Modelo 3: Modelo 2 com indicadora de Curitiba
# Modelo 3b: Modelo 3 com a interação X3:X6
#
# Diagnósticos do Modelo 2: fator de inflação da variância, Breusch-Pagan,
# White, Durbin-Watson, Breusch-Godfrey, Jarque-Bera, Shapiro-Wilk e RESET.
# Erros-padrão: clássico, White (HC1), Newey-West, agrupado por município e
# agrupado por município e ano. Simulação de cenários com o Modelo 2.
#
# Lê:    ./dados_processados/dados_painel_rmc.rds
# Grava: ./resultados_econometricos/ (tabelas, testes e simulação) e
#        ./figuras_graficos/diag1 a diag4 (gráficos dos resíduos)
# =============================================================================

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
if (dir.exists(biblioteca_usuario)) {
  .libPaths(c(biblioteca_usuario, .libPaths()))
}

pacotes_necessarios <- c(
  "dplyr", "tidyr", "purrr", "readr", "tibble", "stringr", "ggplot2", "car",
  "lmtest", "sandwich", "tseries", "modelsummary", "broom", "patchwork", "scales"
)
pacotes_ausentes <- pacotes_necessarios[
  !vapply(pacotes_necessarios, requireNamespace, logical(1), quietly = TRUE)
]
if (length(pacotes_ausentes) > 0) {
  stop("Pacotes ausentes: ", paste(pacotes_ausentes, collapse = ", "),
       ". Instale-os antes de rodar a Etapa 4; este script não instala pacotes.")
}

# Só os pacotes de manipulação e o ggplot2 são anexados; os demais são chamados
# com "::" para evitar conflitos de nomes (car::recode contra dplyr::recode).
invisible(lapply(
  c("tibble", "stringr", "readr", "purrr", "tidyr", "dplyr", "ggplot2"),
  function(p) suppressPackageStartupMessages(library(p, character.only = TRUE))
))


# -----------------------------------------------------------------------------
# 2. Parâmetros
# -----------------------------------------------------------------------------
DIR_PROCESSADOS <- "./dados_processados"
DIR_RESULTADOS  <- "./resultados_econometricos"
DIR_FIGURAS     <- "./figuras_graficos"
ARQ_PAINEL      <- file.path(DIR_PROCESSADOS, "dados_painel_rmc.rds")
ARQ_RESULTADOS  <- file.path(DIR_RESULTADOS, "modelos_e_testes.rds")
N_MUNICIPIOS    <- 29L
N_ANOS          <- 10L
LINHAS_PAINEL   <- N_MUNICIPIOS * N_ANOS
ANO_BASE_SIM    <- 2021L
NIVEL_CONFIANCA <- 0.95
ALFA_TESTES     <- 0.05
LAG_MAX_ACF     <- 20L

ARQUIVOS_ETAPA_3 <- c(
  "fig1_matriz_correlacao.png", "fig2_ridgeplot_salario_anos.png",
  "fig3_dispersao_capital_humano_industria.png", "mapa1_painel_espacial_rmc.png",
  "animacao1_mapa_renda_rmc.gif", "animacao2_dispersao_animada_industria_renda.gif"
)

# Municípios do Cenário 1, pelo código IBGE.
CODIGOS_CENARIO_1 <- c(
  "4107652",  # Fazenda Rio Grande
  "4100400"   # Almirante Tamandaré
)
DELTA_INDUSTRIA    <- 10  # pontos percentuais em dom_industrial
DELTA_ESCOLARIDADE <- 5   # pontos percentuais em prop_superior

REGRESSORES_M2 <- c("prop_superior", "dom_industrial", "shannon_diversificacao",
                    "selic_real", "dist_curitiba_km")

FORMULA_M1  <- salario_medio_real ~ prop_superior
FORMULA_M2  <- ln_salario_real ~ prop_superior + dom_industrial +
  shannon_diversificacao + selic_real + dist_curitiba_km
FORMULA_M3  <- ln_salario_real ~ prop_superior + dom_industrial +
  shannon_diversificacao + selic_real + dist_curitiba_km + dummy_curitiba
FORMULA_M3B <- ln_salario_real ~ prop_superior + dom_industrial +
  shannon_diversificacao + selic_real + dist_curitiba_km + dummy_curitiba +
  dom_industrial:dist_curitiba_km

FORMULA_WHITE_REDUZIDO <- ~ prop_superior + dom_industrial + shannon_diversificacao +
  selic_real + dist_curitiba_km + I(prop_superior^2) + I(dom_industrial^2) +
  I(shannon_diversificacao^2)
FORMULA_WHITE_COMPLETO <- ~ (prop_superior + dom_industrial + shannon_diversificacao +
  selic_real + dist_curitiba_km)^2 + I(prop_superior^2) + I(dom_industrial^2) +
  I(shannon_diversificacao^2) + I(selic_real^2) + I(dist_curitiba_km^2)

# Rótulos das cinco matrizes de covariância.
ROTULOS_MATRIZ <- c(
  classico         = "Clássico (MQO)",
  hc1              = "White HC1",
  newey_west       = "Newey-West",
  agrupado         = "Agrupado por município",
  agrupado_mun_ano = "Agrupado por município e ano"
)

# Termo excluído do teste F robusto dos Modelos 3 e 3b.
TERMO_EXCLUIDO_F_ROBUSTO <- "dummy_curitiba"
MODELOS_F_SEM_INDICADORA <- c("modelo_3", "modelo_3b")

# P-valor conservador da Selic: graus de liberdade G - 1.
GL_SELIC_CONSERVADOR <- N_ANOS - 1L
GL_MUNICIPIOS_CONSERVADOR <- N_MUNICIPIOS - 1L

ESTRELAS <- c("*" = 0.1, "**" = 0.05, "***" = 0.01)

fmt_num <- function(x, casas = 4) formatC(x, format = "f", digits = casas, decimal.mark = ",")


# -----------------------------------------------------------------------------
# 3. Leitura e validação do painel
# -----------------------------------------------------------------------------
carregar_painel <- function() {
  dados <- tryCatch(
    {
      if (!file.exists(ARQ_PAINEL)) stop("arquivo não encontrado")
      readRDS(ARQ_PAINEL)
    },
    error = function(e) {
      stop("Falha ao ler o painel tratado em ", ARQ_PAINEL, ": ", conditionMessage(e),
           ". Rode a Etapa 2 antes da Etapa 4.", call. = FALSE)
    }
  )

  colunas_numericas <- c("salario_medio_real", "ln_salario_real", "prop_superior",
                         "dom_industrial", "shannon_diversificacao", "selic_real",
                         "dist_curitiba_km", "dummy_curitiba")
  colunas_necessarias <- c("id_municipio", "nome_municipio", "ano", "x3_negativo",
                           colunas_numericas)
  colunas_faltantes <- setdiff(colunas_necessarias, names(dados))
  if (length(colunas_faltantes) > 0) {
    stop("O painel não tem as colunas: ", paste(colunas_faltantes, collapse = ", "), call. = FALSE)
  }

  # Conversão forçada para numérico das variáveis econômicas.
  dados <- dados |>
    tibble::as_tibble() |>
    mutate(
      id_municipio = stringr::str_pad(as.character(id_municipio), 7, pad = "0"),
      ano          = as.integer(ano),
      x3_negativo  = as.logical(x3_negativo),
      across(all_of(colunas_numericas), \(v) suppressWarnings(as.numeric(v)))
    ) |>
    arrange(id_municipio, ano)

  # Validação da dimensão do painel: 290 linhas, 29 municípios, 10 anos, sem
  # duplicidade de município e ano.
  if (nrow(dados) != LINHAS_PAINEL) {
    stop("O painel tem ", nrow(dados), " linhas; esperado ", LINHAS_PAINEL, ".", call. = FALSE)
  }
  if (n_distinct(dados$id_municipio) != N_MUNICIPIOS) {
    stop("O painel tem ", n_distinct(dados$id_municipio), " municípios; esperado ",
         N_MUNICIPIOS, ".", call. = FALSE)
  }
  if (n_distinct(dados$ano) != N_ANOS) {
    stop("O painel tem ", n_distinct(dados$ano), " anos; esperado ", N_ANOS, ".", call. = FALSE)
  }
  if (anyDuplicated(dados[, c("id_municipio", "ano")]) > 0) {
    stop("O painel tem pares município e ano repetidos.", call. = FALSE)
  }

  # Relato de NA, NaN e Inf nas variáveis usadas.
  problemas <- dados |>
    summarise(across(all_of(colunas_numericas),
                     \(v) sum(is.na(v) | is.nan(v) | is.infinite(v)))) |>
    tidyr::pivot_longer(everything(), names_to = "variavel", values_to = "n_problemas") |>
    filter(n_problemas > 0)
  if (nrow(problemas) > 0) {
    stop("Valores NA, NaN ou Inf no painel: ",
         paste0(problemas$variavel, " (", problemas$n_problemas, ")", collapse = "; "),
         ". A estimação descartaria linhas em silêncio; corrija a Etapa 2.", call. = FALSE)
  }
  message("Painel: ", nrow(dados), " linhas, ", n_distinct(dados$id_municipio),
          " municípios, ", n_distinct(dados$ano), " anos (", min(dados$ano), " a ",
          max(dados$ano), "), sem NA, NaN ou Inf nas variáveis usadas.")
  message("Observações com x3_negativo == TRUE: ", sum(dados$x3_negativo), ".")
  dados
}

# Conta quantos pares de linhas vizinhas, no painel ordenado por município e ano,
# ligam o último ano de um município ao primeiro ano do seguinte.
contar_pares_cruzados <- function(dados) {
  sum(dados$id_municipio[-1] != dados$id_municipio[-nrow(dados)])
}


# -----------------------------------------------------------------------------
# 4. Estimação
# -----------------------------------------------------------------------------
estimar_modelo <- function(formula, dados, nome) {
  modelo <- tryCatch(
    stats::lm(formula, data = dados),
    error = function(e) stop("Falha ao estimar o ", nome, ": ", conditionMessage(e), call. = FALSE)
  )
  if (stats::nobs(modelo) != nrow(dados)) {
    stop("O ", nome, " usou ", stats::nobs(modelo), " observações; esperado ", nrow(dados), ".",
         call. = FALSE)
  }
  if (anyNA(stats::coef(modelo))) {
    stop("O ", nome, " tem coeficiente NA (colinearidade perfeita).", call. = FALSE)
  }
  message(nome, ": ", stats::nobs(modelo), " observações, R2 = ",
          fmt_num(summary(modelo)$r.squared, 4), ".")
  modelo
}

estimar_modelos <- function(dados) {
  dados_sem_x3neg <- dados |> filter(!x3_negativo)
  if (nrow(dados_sem_x3neg) != LINHAS_PAINEL - 2L) {
    stop("A amostra sem x3_negativo tem ", nrow(dados_sem_x3neg),
         " linhas; esperado ", LINHAS_PAINEL - 2L, " (duas observações de Araucária).",
         call. = FALSE)
  }
  list(
    modelo_1       = estimar_modelo(FORMULA_M1, dados, "Modelo 1"),
    modelo_2       = estimar_modelo(FORMULA_M2, dados, "Modelo 2"),
    modelo_3       = estimar_modelo(FORMULA_M3, dados, "Modelo 3"),
    modelo_3b      = estimar_modelo(FORMULA_M3B, dados, "Modelo 3b"),
    modelo_2_sem_x3_negativo = estimar_modelo(FORMULA_M2, dados_sem_x3neg,
                                              "Modelo 2 sem x3_negativo")
  )
}


# -----------------------------------------------------------------------------
# 5. Matrizes de covariância
# -----------------------------------------------------------------------------
calcular_newey_west <- function(modelo) {
  saida <- utils::capture.output(V <- sandwich::NeweyWest(modelo, verbose = TRUE))
  linha_lag <- grep("[Ll]ag", saida, value = TRUE)
  attr(V, "lag_escolhido") <- if (length(linha_lag) > 0) {
    suppressWarnings(as.numeric(stringr::str_extract(linha_lag[1], "(?<=:)\\s*[0-9.]+")))
  } else {
    NA_real_
  }
  V
}

calcular_matrizes <- function(modelo, dados_modelo, nome) {
  if (nrow(dados_modelo) != stats::nobs(modelo)) {
    stop("Os dados de agrupamento do ", nome, " não têm o mesmo número de linhas do modelo.",
         call. = FALSE)
  }
  matrizes <- tryCatch(
    list(
      classico         = stats::vcov(modelo),
      hc1              = sandwich::vcovHC(modelo, type = "HC1"),
      newey_west       = calcular_newey_west(modelo),
      agrupado         = sandwich::vcovCL(modelo, cluster = dados_modelo$id_municipio,
                                          type = "HC1"),
      agrupado_mun_ano = sandwich::vcovCL(modelo,
                                          cluster = as.data.frame(dados_modelo[, c("id_municipio", "ano")]),
                                          type = "HC1", multi0 = FALSE)
    ),
    error = function(e) stop("Falha ao calcular as matrizes do ", nome, ": ",
                             conditionMessage(e), call. = FALSE)
  )
  problemas <- purrr::keep(matrizes, \(V) any(!is.finite(V)))
  if (length(problemas) > 0) {
    stop("Matriz com NA, NaN ou Inf no ", nome, ": ", paste(names(problemas), collapse = ", "),
         call. = FALSE)
  }
  message("Matrizes do ", nome, ": cinco calculadas; lag de Newey-West = ",
          attr(matrizes$newey_west, "lag_escolhido"), ".")
  matrizes
}

# Coeficientes, erros-padrão, t e p de um modelo sob cada matriz (coeftest).
coeficientes_por_matriz <- function(modelo, matrizes, nome_modelo) {
  purrr::imap(matrizes, function(V, nome_matriz) {
    ct <- lmtest::coeftest(modelo, vcov. = V)
    tibble::tibble(
      modelo      = nome_modelo,
      matriz      = ROTULOS_MATRIZ[[nome_matriz]],
      termo       = rownames(ct),
      estimativa  = unname(ct[, 1]),
      erro_padrao = unname(ct[, 2]),
      estatistica_t = unname(ct[, 3]),
      p_valor     = unname(ct[, 4])
    )
  }) |>
    purrr::list_rbind()
}

# Teste F de significância conjunta sob uma matriz de covariância, por
# car::linearHypothesis com matriz de restrição. Por padrão, todas as
# inclinações iguais a zero; os termos em "excluir" ficam fora da hipótese
# (por exemplo, dummy_curitiba nos Modelos 3 e 3b sob matrizes robustas).
teste_f_global <- function(modelo, V, nome_modelo, nome_matriz, excluir = character(0)) {
  nomes <- names(stats::coef(modelo))
  testados <- setdiff(nomes[nomes != "(Intercept)"], excluir)
  restricao <- matrix(0, nrow = length(testados), ncol = length(nomes),
                      dimnames = list(NULL, nomes))
  restricao[cbind(seq_along(testados), match(testados, nomes))] <- 1
  hipotese <- if (length(excluir) == 0) {
    "todas as inclinações = 0"
  } else {
    paste("inclinações = 0, exceto", paste(excluir, collapse = ", "))
  }
  resultado <- tryCatch(
    car::linearHypothesis(modelo, hypothesis.matrix = restricao, rhs = rep(0, length(testados)),
                          vcov. = V, test = "F"),
    error = function(e) {
      warning("Teste F global falhou no ", nome_modelo, " (", nome_matriz, "): ",
              conditionMessage(e))
      NULL
    }
  )
  if (is.null(resultado)) {
    return(tibble::tibble(modelo = nome_modelo, matriz = ROTULOS_MATRIZ[[nome_matriz]],
                          hipotese = hipotese, estatistica_f = NA_real_, gl_numerador = NA_real_,
                          gl_denominador = NA_real_, p_valor = NA_real_))
  }
  tibble::tibble(
    modelo         = nome_modelo,
    matriz         = ROTULOS_MATRIZ[[nome_matriz]],
    hipotese       = hipotese,
    estatistica_f  = resultado$F[2],
    gl_numerador   = resultado$Df[2],
    gl_denominador = resultado$Res.Df[2],
    p_valor        = resultado$`Pr(>F)`[2]
  )
}

# Termos excluídos do F robusto conforme o modelo e a matriz:
# só nos Modelos 3 e 3b e só nas matrizes robustas; o F clássico fica completo.
termos_excluidos_f <- function(chave_modelo, chave_matriz) {
  if (chave_modelo %in% MODELOS_F_SEM_INDICADORA && chave_matriz != "classico") {
    TERMO_EXCLUIDO_F_ROBUSTO
  } else {
    character(0)
  }
}

# P-valor conservador da Selic: matriz agrupada só por ano
# (10 grupos, tipo HC1) e distribuição t com G - 1 = 9 graus de liberdade.
selic_conservadora <- function(modelo, dados_modelo) {
  V_ano <- tryCatch(
    sandwich::vcovCL(modelo, cluster = dados_modelo$ano, type = "HC1"),
    error = function(e) stop("Falha na matriz agrupada por ano: ", conditionMessage(e), call. = FALSE)
  )
  ct <- lmtest::coeftest(modelo, vcov. = V_ano, df = GL_SELIC_CONSERVADOR)
  list(
    matriz = V_ano,
    coeftest = ct,
    tabela = tibble::tibble(
      modelo          = "Modelo 2",
      termo           = "selic_real",
      matriz          = "Agrupado por ano (vcovCL, HC1, 10 grupos)",
      graus_liberdade = GL_SELIC_CONSERVADOR,
      estimativa      = ct["selic_real", 1],
      erro_padrao     = ct["selic_real", 2],
      estatistica_t   = ct["selic_real", 3],
      p_valor         = ct["selic_real", 4]
    )
  )
}


calcular_fiv <- function(modelo, nome_modelo) {
  # O car::vif emite uma mensagem (não um aviso) quando há interação; a mensagem
  # original em inglês é substituída por uma explicação em português.
  fiv <- withCallingHandlers(
    car::vif(modelo, type = "terms"),
    message = function(m) {
      if (grepl("higher-order terms", conditionMessage(m))) {
        message("Nota do car::vif no ", nome_modelo, ": o modelo tem interação; o FIV ",
                "foi calculado termo a termo (type = \"terms\"), e o pacote sugere ",
                "type = \"predictor\" como alternativa.")
        invokeRestart("muffleMessage")
      }
    }
  )
  tabela <- tibble::tibble(
    modelo     = nome_modelo,
    termo      = names(fiv),
    fiv        = unname(fiv),
    tolerancia = 1 / unname(fiv)
  ) |>
    mutate(severa = fiv > 10 | tolerancia < 0.10)
  if (any(tabela$severa)) {
    message(nome_modelo, ": HÁ evidência de multicolinearidade severa (FIV > 10 ou TOL < 0,10) em: ",
            paste(tabela$termo[tabela$severa], collapse = ", "),
            ". A especificação não é alterada por esse motivo.")
  } else {
    message(nome_modelo, ": NÃO há evidência de multicolinearidade severa; maior FIV = ",
            fmt_num(max(tabela$fiv), 2), " (", tabela$termo[which.max(tabela$fiv)], ").")
  }
  tabela
}

# Executa um teste que devolve objeto htest e o converte em linha de tabela.
linha_teste <- function(bloco, teste, hipotese_nula, expressao) {
  resultado <- tryCatch(
    expressao,
    error = function(e) {
      warning("Teste ", teste, " falhou: ", conditionMessage(e))
      NULL
    }
  )
  if (is.null(resultado)) {
    return(list(
      linha = tibble::tibble(modelo = "Modelo 2", bloco = bloco, teste = teste,
                             hipotese_nula = hipotese_nula, estatistica = NA_real_,
                             nome_estatistica = NA_character_, graus_liberdade = NA_character_,
                             p_valor = NA_real_, decisao_5pct = "teste falhou"),
      objeto = NULL
    ))
  }
  gl <- if (is.null(resultado$parameter)) {
    NA_character_
  } else {
    paste(names(resultado$parameter), "=", round(resultado$parameter, 4), collapse = "; ")
  }
  list(
    linha = tibble::tibble(
      modelo           = "Modelo 2",
      bloco            = bloco,
      teste            = teste,
      hipotese_nula    = hipotese_nula,
      estatistica      = unname(resultado$statistic),
      nome_estatistica = names(resultado$statistic),
      graus_liberdade  = gl,
      p_valor          = resultado$p.value,
      decisao_5pct     = ifelse(resultado$p.value < ALFA_TESTES, "rejeita H0", "não rejeita H0")
    ),
    objeto = resultado
  )
}

diagnosticar_modelo_2 <- function(modelo, dados) {
  residuos <- stats::residuals(modelo)

  testes <- list(
    breusch_pagan = linha_teste(
      "B. Heterocedasticidade", "Breusch-Pagan-Godfrey (studentizado)", "homocedasticidade",
      lmtest::bptest(modelo, studentize = TRUE)
    ),
    white_reduzido = linha_teste(
      "B. Heterocedasticidade", "White reduzido (regressores e quadrados de X2, X3 e X4)",
      "homocedasticidade",
      lmtest::bptest(modelo, varformula = FORMULA_WHITE_REDUZIDO, studentize = TRUE, data = dados)
    ),
    white_completo = linha_teste(
      "B. Heterocedasticidade", "White completo (regressores, quadrados e produtos cruzados)",
      "homocedasticidade",
      lmtest::bptest(modelo, varformula = FORMULA_WHITE_COMPLETO, studentize = TRUE, data = dados)
    ),
    durbin_watson = linha_teste(
      "C. Autocorrelação", "Durbin-Watson empilhado (inválido no painel)",
      "ausência de autocorrelação de ordem 1",
      lmtest::dwtest(modelo, alternative = "two.sided")
    ),
    breusch_godfrey = linha_teste(
      "C. Autocorrelação", "Breusch-Godfrey (ordem 1), painel empilhado: inválido como evidência; referência válida em calibracao_autocorrelacao.csv e nos testes de painel do script 06", "ausência de autocorrelação até a ordem 1",
      lmtest::bgtest(modelo, order = 1)
    ),
    jarque_bera = linha_teste(
      "D. Normalidade", "Jarque-Bera", "resíduos normais",
      tseries::jarque.bera.test(residuos)
    ),
    shapiro_wilk = linha_teste(
      "D. Normalidade", "Shapiro-Wilk", "resíduos normais",
      stats::shapiro.test(residuos)
    ),
    reset = linha_teste(
      "E. Especificação", "RESET de Ramsey (potências 2 e 3 dos regressores)",
      "forma funcional correta",
      lmtest::resettest(modelo, power = 2:3, type = "regressor")
    )
  )

  d_dw <- if (is.null(testes$durbin_watson$objeto)) NA_real_ else
    unname(testes$durbin_watson$objeto$statistic)
  rho_dw <- 1 - d_dw / 2

  # Complemento: correlação entre resíduos vizinhos só dentro do mesmo município,
  # sem os pares que cruzam municípios.
  mesmo_municipio <- dados$id_municipio[-1] == dados$id_municipio[-nrow(dados)]
  rho_intra <- stats::cor(residuos[-1][mesmo_municipio], residuos[-length(residuos)][mesmo_municipio])

  d_municipios <- purrr::map_dbl(
    split(seq_along(residuos), dados$id_municipio),
    function(i) {
      e <- residuos[i]
      sum(diff(e)^2) / sum(e^2)
    }
  )
  d_intra_medio <- mean(d_municipios)
  rho_intra_d   <- 1 - d_intra_medio / 2

  linhas_rho <- tibble::tibble(
    modelo = "Modelo 2",
    bloco  = "C. Autocorrelação",
    teste  = c(
      "rho aproximado, 1 - d/2 (empilhado, inválido no painel)",
      "rho dos resíduos vizinhos no mesmo município",
      "d de Durbin-Watson médio por município",
      "rho aproximado, 1 - d/2, a partir do d por município"
    ),
    hipotese_nula = NA_character_,
    estatistica = c(rho_dw, rho_intra, d_intra_medio, rho_intra_d),
    nome_estatistica = c("rho", "rho", "d", "rho"),
    graus_liberdade = c(NA_character_, paste("pares =", sum(mesmo_municipio)),
                        paste("municípios =", length(d_municipios)), NA_character_),
    p_valor = NA_real_,
    decisao_5pct = NA_character_
  )

  tabela <- purrr::map(testes, "linha") |>
    purrr::list_rbind() |>
    bind_rows(linhas_rho) |>
    arrange(bloco)

  message("\nDiagnósticos do Modelo 2 (nível de 5%):")
  purrr::pwalk(tabela, function(teste, estatistica, p_valor, decisao_5pct, ...) {
    if (is.na(p_valor)) {
      message("  ", teste, ": ", fmt_num(estatistica, 4))
    } else {
      message("  ", teste, ": estatística = ", fmt_num(estatistica, 4), ", p-valor = ",
              format.pval(p_valor, digits = 4), " -> ", decisao_5pct)
    }
  })

  list(tabela = tabela, objetos = purrr::map(testes, "objeto"), rho_dw = rho_dw,
       rho_intra_municipio = rho_intra)
}


# -----------------------------------------------------------------------------
# 7. Robustez sem as observações com x3_negativo
# -----------------------------------------------------------------------------
comparar_robustez <- function(modelo_completo, modelo_sem, mat_completo, mat_sem) {
  extrair <- function(modelo, V, sufixo) {
    ct <- lmtest::coeftest(modelo, vcov. = V)
    tibble::tibble(termo = rownames(ct), estimativa = ct[, 1], erro_padrao = ct[, 2],
                   p_valor = ct[, 4]) |>
      rename_with(\(n) paste0(n, "_", sufixo), -termo)
  }
  extrair(modelo_completo, mat_completo$classico, "completo_classico") |>
    left_join(extrair(modelo_completo, mat_completo$agrupado, "completo_agrupado"), by = "termo") |>
    left_join(extrair(modelo_sem, mat_sem$classico, "sem_x3neg_classico"), by = "termo") |>
    left_join(extrair(modelo_sem, mat_sem$agrupado, "sem_x3neg_agrupado"), by = "termo") |>
    transmute(
      termo,
      coef_completo        = estimativa_completo_classico,
      ep_classico_completo = erro_padrao_completo_classico,
      p_classico_completo  = p_valor_completo_classico,
      ep_agrupado_completo = erro_padrao_completo_agrupado,
      p_agrupado_completo  = p_valor_completo_agrupado,
      coef_sem_x3neg        = estimativa_sem_x3neg_classico,
      ep_classico_sem_x3neg = erro_padrao_sem_x3neg_classico,
      p_classico_sem_x3neg  = p_valor_sem_x3neg_classico,
      ep_agrupado_sem_x3neg = erro_padrao_sem_x3neg_agrupado,
      p_agrupado_sem_x3neg  = p_valor_sem_x3neg_agrupado,
      variacao_coef_pct     = 100 * (coef_sem_x3neg - coef_completo) / abs(coef_completo)
    )
}


# -----------------------------------------------------------------------------
# 8. Tabelas de regressão (modelsummary, HTML e texto)
# -----------------------------------------------------------------------------
# Cada coluna é descrita por uma lista com modelo, matriz e rótulo da matriz.
# As linhas extras trazem a matriz usada, o F conjunto sob essa matriz, a
# hipótese testada por esse F e o erro padrão residual s; o modelsummary
# acrescenta N, R2 e R2 ajustado.
linhas_extras <- function(colunas) {
  valores <- purrr::map(colunas, function(col) {
    f <- teste_f_global(col$modelo, col$V, "tabela", col$chave_matriz, excluir = col$excluir)
    c(
      ROTULOS_MATRIZ[[col$chave_matriz]],
      # Ponto decimal, como o restante da tabela gerada pelo modelsummary.
      paste0(formatC(f$estatistica_f, format = "f", digits = 3), " (p = ",
             format.pval(f$p_valor, digits = 3, eps = 1e-4), ")"),
      if (length(col$excluir) == 0) "todas as inclinações" else
        paste("inclinações sem", paste(col$excluir, collapse = ", ")),
      formatC(stats::sigma(col$modelo), format = "f", digits = 4)
    )
  })
  tabela <- tibble::tibble(term = c("Erros-padrão", "Estatística F conjunta (p)",
                                    "Hipótese do F", "Erro padrão residual (s)"))
  for (nome in names(valores)) tabela[[nome]] <- valores[[nome]]
  as.data.frame(tabela)
}

gravar_tabela <- function(colunas, nome_base, titulo, nota) {
  arquivos <- file.path(DIR_RESULTADOS, paste0(nome_base, c(".html", ".txt")))
  modelos <- purrr::map(colunas, "modelo")
  matrizes <- unname(purrr::map(colunas, "V"))
  extras <- linhas_extras(colunas)
  situacao <- purrr::map_chr(arquivos, function(arquivo) {
    tryCatch(
      {
        modelsummary::modelsummary(
          modelos,
          output    = arquivo,
          vcov      = matrizes,
          # Quatro algarismos significativos: com casas decimais fixas, o
          # coeficiente da interação do Modelo 3b apareceria como 0.0000.
          fmt       = modelsummary::fmt_significant(4),
          stars     = ESTRELAS,
          gof_map   = c("nobs", "r.squared", "adj.r.squared"),
          add_rows  = extras,
          title     = titulo,
          notes     = nota
        )
        "ok"
      },
      error = function(e) {
        warning("Falha ao gravar ", arquivo, ": ", conditionMessage(e))
        paste("falha:", conditionMessage(e))
      }
    )
  })
  tibble::tibble(arquivo = arquivos, situacao = situacao)
}

gravar_tabelas <- function(modelos, matrizes) {
  coluna <- function(nome_modelo, chave) {
    list(modelo = modelos[[nome_modelo]], V = matrizes[[nome_modelo]][[chave]],
         chave_matriz = chave, excluir = termos_excluidos_f(nome_modelo, chave))
  }
  nota_ep <- paste("Erros-padrão entre parênteses, pela matriz indicada na linha \"Erros-padrão\".",
                   "Agrupado por município: sandwich::vcovCL, tipo HC1, 29 grupos.",
                   "Agrupado por município e ano: sandwich::vcovCL com as duas dimensões,",
                   "tipo HC1, multi0 = FALSE.",
                   "Newey-West é apenas referência: assume série temporal única e não",
                   "vale para o painel empilhado.")
  # Nota das tabelas dos Modelos 3 e 3b sobre a indicadora de Curitiba.
  nota_indicadora <- paste(
    "Nos Modelos 3 e 3b, dummy_curitiba isola um único município: os resíduos de",
    "Curitiba somam zero, e o erro-padrão robusto (em especial o agrupado) da indicadora",
    "não é confiável. Por isso o F conjunto sob matrizes robustas exclui dummy_curitiba;",
    "o F clássico mantém todas as inclinações, como referência."
  )

  cinco_matrizes <- function(nome_modelo, rotulo) {
    purrr::map(names(ROTULOS_MATRIZ), \(chave) coluna(nome_modelo, chave)) |>
      purrr::set_names(paste0(rotulo, " (", ROTULOS_MATRIZ, ")"))
  }

  list(
    gravar_tabela(
      list(
        "Modelo 1 (MQO padrão)"          = coluna("modelo_1", "classico"),
        "Modelo 2 (MQO padrão)"          = coluna("modelo_2", "classico"),
        "Modelo 2 (Newey-West)"          = coluna("modelo_2", "newey_west"),
        "Modelo 3 (dummy, Newey-West)"   = coluna("modelo_3", "newey_west"),
        "Modelo 3b (interação, Newey-West)" = coluna("modelo_3b", "newey_west")
      ),
      "tabela_comparativa_modelos",
      "Tabela comparativa: Modelos 1, 2, 3 e 3b",
      paste(nota_ep, "Modelo 1 em nível (salario_medio_real); demais em ln_salario_real.",
            nota_indicadora)
    ),
    gravar_tabela(cinco_matrizes("modelo_2", "M2"), "tabela_modelo_2_cinco_matrizes",
                  "Modelo 2 sob cinco matrizes de covariância", nota_ep),
    gravar_tabela(cinco_matrizes("modelo_3", "M3"), "tabela_modelo_3_cinco_matrizes",
                  "Modelo 3 sob cinco matrizes de covariância", paste(nota_ep, nota_indicadora)),
    gravar_tabela(cinco_matrizes("modelo_3b", "M3b"), "tabela_modelo_3b_cinco_matrizes",
                  "Modelo 3b sob cinco matrizes de covariância", paste(nota_ep, nota_indicadora)),
    gravar_tabela(
      list(
        "M2 completo (clássico)"       = coluna("modelo_2", "classico"),
        "M2 completo (agrupado)"       = coluna("modelo_2", "agrupado"),
        "M2 sem x3_negativo (clássico)" = coluna("modelo_2_sem_x3_negativo", "classico"),
        "M2 sem x3_negativo (agrupado)" = coluna("modelo_2_sem_x3_negativo", "agrupado")
      ),
      "tabela_robustez_modelo_2",
      "Modelo 2 com e sem as observações de Araucária com VAB industrial negativo",
      paste(nota_ep, "Sem x3_negativo: 288 observações (Araucária 2012 e 2013 excluídas).")
    )
  ) |>
    purrr::list_rbind()
}


# -----------------------------------------------------------------------------
# 9. Simulação contrafactual
# -----------------------------------------------------------------------------
# Função pura: recebe o modelo, a base de um único ano e as matrizes, e devolve
# a tabela de cenários sem efeitos colaterais.
# Previsão da média na escala do log: x'b; erro-padrão sqrt(x' V x); intervalo
# x'b +/- t * sqrt(x' V x), com t de G - 1 graus de liberdade (G = número de
# municípios). Conversão para reais por exp() multiplicado pelo fator de
# retransformação de Duan, a média de exp(resíduo); a variação percentual entre
# cenários não depende desse fator.
simular_cenarios_renda <- function(modelo, base_dados, delta_industria, delta_escolaridade,
                                   codigos_industria, vcov_principal, vcov_comparacao,
                                   nivel = NIVEL_CONFIANCA) {
  if (n_distinct(base_dados$ano) != 1L) {
    stop("A base da simulação deve ter um único ano.", call. = FALSE)
  }
  if (!all(codigos_industria %in% base_dados$id_municipio)) {
    stop("Código do Cenário 1 ausente da base: ",
         paste(setdiff(codigos_industria, base_dados$id_municipio), collapse = ", "), call. = FALSE)
  }

  termos <- stats::delete.response(stats::terms(modelo))
  beta <- stats::coef(modelo)
  t_critico <- stats::qt(1 - (1 - nivel) / 2, df = GL_MUNICIPIOS_CONSERVADOR)
  fator_smear <- mean(exp(stats::residuals(modelo)))

  ep_linear <- function(X, V) sqrt(rowSums((X %*% V) * X))

  cenarios <- list(
    list(
      cenario  = "Cenário 1: choque de industrialização",
      variavel = "dom_industrial",
      delta    = delta_industria,
      linhas   = base_dados$id_municipio %in% codigos_industria
    ),
    list(
      cenario  = "Cenário 2: choque de capital humano",
      variavel = "prop_superior",
      delta    = delta_escolaridade,
      linhas   = rep(TRUE, nrow(base_dados))
    )
  )

  purrr::map(cenarios, function(cen) {
    antes  <- base_dados[cen$linhas, , drop = FALSE]
    depois <- antes
    depois[[cen$variavel]] <- depois[[cen$variavel]] + cen$delta
    if (any(depois[[cen$variavel]] > 100)) {
      warning(cen$cenario, ": ", cen$variavel, " passa de 100 após o choque em ",
              paste(depois$nome_municipio[depois[[cen$variavel]] > 100], collapse = ", "), ".")
    }

    X0 <- stats::model.matrix(termos, data = antes)
    X1 <- stats::model.matrix(termos, data = depois)
    D  <- X1 - X0
    ln0 <- as.vector(X0 %*% beta)
    ln1 <- as.vector(X1 %*% beta)
    dif <- ln1 - ln0

    ep0_ag <- ep_linear(X0, vcov_principal);  ep1_ag <- ep_linear(X1, vcov_principal)
    ep0_cl <- ep_linear(X0, vcov_comparacao); ep1_cl <- ep_linear(X1, vcov_comparacao)
    epd_ag <- ep_linear(D, vcov_principal);   epd_cl <- ep_linear(D, vcov_comparacao)

    tibble::tibble(
      cenario                  = cen$cenario,
      id_municipio             = antes$id_municipio,
      nome_municipio           = antes$nome_municipio,
      ano_base                 = antes$ano,
      variavel_choque          = cen$variavel,
      delta_pontos             = cen$delta,
      valor_antes              = antes[[cen$variavel]],
      valor_depois             = depois[[cen$variavel]],
      salario_observado        = antes$salario_medio_real,
      salario_prev_antes       = fator_smear * exp(ln0),
      ic_inf_antes_agrupado    = fator_smear * exp(ln0 - t_critico * ep0_ag),
      ic_sup_antes_agrupado    = fator_smear * exp(ln0 + t_critico * ep0_ag),
      ic_inf_antes_classico    = fator_smear * exp(ln0 - t_critico * ep0_cl),
      ic_sup_antes_classico    = fator_smear * exp(ln0 + t_critico * ep0_cl),
      salario_prev_depois      = fator_smear * exp(ln1),
      ic_inf_depois_agrupado   = fator_smear * exp(ln1 - t_critico * ep1_ag),
      ic_sup_depois_agrupado   = fator_smear * exp(ln1 + t_critico * ep1_ag),
      ic_inf_depois_classico   = fator_smear * exp(ln1 - t_critico * ep1_cl),
      ic_sup_depois_classico   = fator_smear * exp(ln1 + t_critico * ep1_cl),
      variacao_pct             = 100 * (exp(dif) - 1),
      ic_inf_variacao_pct_agrupado = 100 * (exp(dif - t_critico * epd_ag) - 1),
      ic_sup_variacao_pct_agrupado = 100 * (exp(dif + t_critico * epd_ag) - 1),
      ic_inf_variacao_pct_classico = 100 * (exp(dif - t_critico * epd_cl) - 1),
      ic_sup_variacao_pct_classico = 100 * (exp(dif + t_critico * epd_cl) - 1)
    )
  }) |>
    purrr::list_rbind()
}


# -----------------------------------------------------------------------------
# 10. Figuras de diagnóstico (PNG a 300 dpi)
# -----------------------------------------------------------------------------
tema_base <- theme_bw(base_size = 11) +
  theme(plot.title = element_text(face = "bold"),
        plot.caption = element_text(hjust = 0, size = 8, colour = "grey30"))

NOTA_MODELO_2 <- paste("Modelo 2: ln_salario_real sobre prop_superior, dom_industrial,",
                       "shannon_diversificacao, selic_real e dist_curitiba_km; 290 observações.")

# Junta os trechos da nota de rodapé e quebra a linha para caber na figura.
legenda <- function(...) stringr::str_wrap(paste(...), width = 120)

caminho_figura <- function(nome) {
  if (nome %in% ARQUIVOS_ETAPA_3) {
    stop("O nome ", nome, " pertence à Etapa 3 e não pode ser sobrescrito.", call. = FALSE)
  }
  file.path(DIR_FIGURAS, nome)
}

figura_residuos_ajustados <- function(modelo) {
  arquivo <- caminho_figura("diag1_residuos_padronizados_vs_ajustados.png")
  df <- tibble::tibble(ajustado = stats::fitted(modelo), residuo = stats::rstandard(modelo))
  g <- ggplot(df, aes(ajustado, residuo)) +
    geom_hline(yintercept = 0, colour = "grey40", linetype = "dashed") +
    geom_point(alpha = 0.6, colour = "#1f4e79") +
    geom_smooth(method = "loess", formula = y ~ x, se = FALSE, colour = "#c0392b") +
    labs(title = "Resíduos padronizados contra valores ajustados",
         x = "Valor ajustado de ln(salário médio real)", y = "Resíduo padronizado",
         caption = legenda(NOTA_MODELO_2, "Curva LOESS em vermelho.")) +
    tema_base
  ggsave(arquivo, g, width = 8, height = 5.5, dpi = 300)
  arquivo
}

figura_acf <- function(modelo) {
  arquivo <- caminho_figura("diag2_acf_residuos.png")
  residuos <- stats::residuals(modelo)
  acf_obj <- stats::acf(residuos, lag.max = LAG_MAX_ACF, plot = FALSE)
  limite <- stats::qnorm(1 - (1 - NIVEL_CONFIANCA) / 2) / sqrt(length(residuos))
  df <- tibble::tibble(defasagem = as.vector(acf_obj$lag), acf = as.vector(acf_obj$acf)) |>
    filter(defasagem > 0)
  g <- ggplot(df, aes(defasagem, acf)) +
    geom_hline(yintercept = 0, colour = "grey40") +
    geom_hline(yintercept = c(-limite, limite), colour = "#c0392b", linetype = "dashed") +
    geom_segment(aes(xend = defasagem, yend = 0), colour = "#1f4e79", linewidth = 0.9) +
    scale_x_continuous(breaks = seq(1, LAG_MAX_ACF, 1)) +
    labs(title = "Função de autocorrelação dos resíduos do Modelo 2",
         x = "Defasagem", y = "Autocorrelação",
         caption = legenda(NOTA_MODELO_2, "Linhas tracejadas: limites de 95% (+/- 1,96/raiz de n).",
                         "Resíduos na ordem município e ano; 28 pares vizinhos cruzam municípios; a partir da defasagem 10 todos os pares cruzam municípios.")) +
    tema_base
  ggsave(arquivo, g, width = 8, height = 5, dpi = 300)
  arquivo
}

figura_densidade <- function(modelo) {
  arquivo <- caminho_figura("diag3_densidade_residuos.png")
  residuos <- stats::residuals(modelo)
  df <- tibble::tibble(residuo = residuos)
  g <- ggplot(df, aes(residuo)) +
    geom_histogram(aes(y = after_stat(density)), bins = 30, fill = "grey85", colour = "grey60") +
    geom_density(colour = "#1f4e79", linewidth = 1) +
    stat_function(fun = stats::dnorm, args = list(mean = 0, sd = stats::sd(residuos)),
                  colour = "#c0392b", linewidth = 1, linetype = "dashed") +
    labs(title = "Densidade dos resíduos do Modelo 2 e curva normal teórica",
         x = "Resíduo", y = "Densidade",
         caption = legenda(NOTA_MODELO_2, "Azul: densidade estimada; vermelho tracejado:",
                         "normal com média zero e desvio-padrão dos resíduos.")) +
    tema_base
  ggsave(arquivo, g, width = 8, height = 5, dpi = 300)
  arquivo
}

figura_qq <- function(modelo) {
  arquivo <- caminho_figura("diag4_qqplot_residuos.png")
  grDevices::png(arquivo, width = 7, height = 6, units = "in", res = 300)
  on.exit(grDevices::dev.off(), add = TRUE)
  car::qqPlot(stats::residuals(modelo), distribution = "norm", envelope = NIVEL_CONFIANCA,
              id = FALSE, ylab = "Resíduos do Modelo 2", xlab = "Quantis da normal",
              main = "Q-Q normal dos resíduos do Modelo 2 (envelope de 95%)")
  arquivo
}

gerar_figuras <- function(modelo) {
  old <- options(OutDec = ",")
  on.exit(options(old), add = TRUE)
  tarefas <- list(
    residuos_ajustados = figura_residuos_ajustados,
    acf                = figura_acf,
    densidade          = figura_densidade,
    qq                 = figura_qq
  )
  purrr::imap(tarefas, function(funcao, nome) {
    situacao <- tryCatch({ funcao(modelo); "ok" },
                         error = function(e) {
                           warning("Figura ", nome, " falhou: ", conditionMessage(e))
                           paste("falha:", conditionMessage(e))
                         })
    tibble::tibble(figura = nome, situacao = situacao)
  }) |>
    purrr::list_rbind()
}


# -----------------------------------------------------------------------------
# 11. Função principal
# -----------------------------------------------------------------------------
gravar_csv <- function(tabela, nome) {
  arquivo <- file.path(DIR_RESULTADOS, nome)
  tryCatch(readr::write_csv(tabela, arquivo, na = ""),
           error = function(e) stop("Falha ao gravar ", arquivo, ": ", conditionMessage(e),
                                    call. = FALSE))
  arquivo
}

executar_etapa_4 <- function() {
  if (!dir.exists(DIR_RESULTADOS)) dir.create(DIR_RESULTADOS, recursive = TRUE)
  if (!dir.exists(DIR_FIGURAS)) dir.create(DIR_FIGURAS, recursive = TRUE)

  dados <- carregar_painel()

  pares_cruzados <- contar_pares_cruzados(dados)
  message("Pares de linhas vizinhas que cruzam de um município para outro: ", pares_cruzados,
          " (esperado ", N_MUNICIPIOS - 1L, ").")
  if (pares_cruzados != N_MUNICIPIOS - 1L) {
    warning("O número de pares que cruzam municípios difere de ", N_MUNICIPIOS - 1L, ".")
  }

  # Modelos.
  message("\nEstimação:")
  modelos <- estimar_modelos(dados)
  dados_sem_x3neg <- dados |> filter(!x3_negativo)

  # Matrizes de covariância dos modelos com inferência robusta.
  message("\nMatrizes de covariância:")
  matrizes <- list(
    modelo_1  = list(classico = stats::vcov(modelos$modelo_1)),
    modelo_2  = calcular_matrizes(modelos$modelo_2, dados, "Modelo 2"),
    modelo_3  = calcular_matrizes(modelos$modelo_3, dados, "Modelo 3"),
    modelo_3b = calcular_matrizes(modelos$modelo_3b, dados, "Modelo 3b"),
    modelo_2_sem_x3_negativo = calcular_matrizes(modelos$modelo_2_sem_x3_negativo,
                                                 dados_sem_x3neg,
                                                 "Modelo 2 sem x3_negativo")
  )

  # Coeficientes sob as cinco matrizes (Modelos 2, 3 e 3b).
  rotulos_modelos <- c(modelo_2 = "Modelo 2", modelo_3 = "Modelo 3", modelo_3b = "Modelo 3b")
  coeficientes <- purrr::imap(rotulos_modelos, \(rotulo, chave)
                              coeficientes_por_matriz(modelos[[chave]], matrizes[[chave]], rotulo)) |>
    purrr::list_rbind()

  message("\nModelo 2: coeficientes, erros-padrão e p-valores sob as cinco matrizes:")
  coeficientes |>
    filter(modelo == "Modelo 2") |>
    mutate(across(c(estimativa, erro_padrao, estatistica_t), \(v) signif(v, 5)),
           p_valor = signif(p_valor, 4)) |>
    as.data.frame() |>
    print(row.names = FALSE)

  # P-valor conservador da Selic.
  selic_cons <- selic_conservadora(modelos$modelo_2, dados)
  message("\nSelic real no Modelo 2, p-valor conservador (agrupado por ano, t com ",
          GL_SELIC_CONSERVADOR, " graus de liberdade): coeficiente = ",
          fmt_num(selic_cons$tabela$estimativa, 6), ", erro-padrão = ",
          fmt_num(selic_cons$tabela$erro_padrao, 6), ", t = ",
          fmt_num(selic_cons$tabela$estatistica_t, 4), ", p-valor = ",
          format.pval(selic_cons$tabela$p_valor, digits = 4), ".")

  # Teste F conjunto sob cada matriz; nos Modelos 3 e 3b, as matrizes robustas
  # excluem dummy_curitiba da hipótese.
  testes_f <- purrr::imap(rotulos_modelos, function(rotulo, chave) {
    purrr::imap(matrizes[[chave]], \(V, nome_matriz)
                teste_f_global(modelos[[chave]], V, rotulo, nome_matriz,
                               excluir = termos_excluidos_f(chave, nome_matriz))) |>
      purrr::list_rbind()
  }) |>
    purrr::list_rbind()
  message("\nTeste F de significância conjunta (hipótese indicada em cada linha):")
  print(as.data.frame(testes_f |> mutate(across(where(is.numeric), \(v) signif(v, 5)))),
        row.names = FALSE)

  # Diagnósticos.
  message("\nFator de inflação da variância:")
  fiv <- purrr::imap(rotulos_modelos, \(rotulo, chave) calcular_fiv(modelos[[chave]], rotulo)) |>
    purrr::list_rbind()
  print(as.data.frame(fiv |> mutate(across(where(is.numeric), \(v) round(v, 4)))), row.names = FALSE)

  diagnosticos <- diagnosticar_modelo_2(modelos$modelo_2, dados)

  # A tabela consolidada de auditoria junta os testes do Modelo 2 e os FIV.
  tabela_diagnosticos <- bind_rows(
    fiv |>
      filter(modelo == "Modelo 2") |>
      transmute(modelo, bloco = "A. Multicolinearidade",
                teste = paste("FIV de", termo), hipotese_nula = NA_character_,
                estatistica = fiv, nome_estatistica = "FIV",
                graus_liberdade = paste("TOL =", fmt_num(tolerancia, 4)),
                p_valor = NA_real_,
                decisao_5pct = ifelse(severa, "multicolinearidade severa (FIV > 10 ou TOL < 0,10)",
                                      "sem multicolinearidade severa")),
    diagnosticos$tabela
  )

  # Robustez sem Araucária 2012 e 2013.
  robustez <- comparar_robustez(modelos$modelo_2, modelos$modelo_2_sem_x3_negativo,
                                matrizes$modelo_2, matrizes$modelo_2_sem_x3_negativo)
  message("\nModelo 2 com e sem as observações com x3_negativo (coeficientes e p-valores):")
  print(as.data.frame(robustez |>
                        select(termo, coef_completo, p_agrupado_completo, coef_sem_x3neg,
                               p_agrupado_sem_x3neg, variacao_coef_pct) |>
                        mutate(across(where(is.numeric), \(v) signif(v, 4)))),
        row.names = FALSE)

  # Simulação.
  base_2021 <- dados |> filter(ano == ANO_BASE_SIM)
  if (nrow(base_2021) != N_MUNICIPIOS) {
    stop("A base de ", ANO_BASE_SIM, " tem ", nrow(base_2021), " linhas; esperado ",
         N_MUNICIPIOS, ".", call. = FALSE)
  }
  simulacao <- tryCatch(
    simular_cenarios_renda(
      modelo             = modelos$modelo_2,
      base_dados         = base_2021,
      delta_industria    = DELTA_INDUSTRIA,
      delta_escolaridade = DELTA_ESCOLARIDADE,
      codigos_industria  = CODIGOS_CENARIO_1,
      vcov_principal     = matrizes$modelo_2$agrupado,
      vcov_comparacao    = matrizes$modelo_2$classico
    ),
    error = function(e) stop("Falha na simulação: ", conditionMessage(e), call. = FALSE)
  )
  message("\nSimulação, Cenário 1 (", ANO_BASE_SIM, ", R$ de 2021):")
  print(as.data.frame(simulacao |>
                        filter(stringr::str_starts(cenario, "Cenário 1")) |>
                        select(nome_municipio, valor_antes, valor_depois, salario_prev_antes,
                               ic_inf_antes_agrupado, ic_sup_antes_agrupado, salario_prev_depois,
                               ic_inf_depois_agrupado, ic_sup_depois_agrupado, variacao_pct) |>
                        mutate(across(where(is.numeric), \(v) round(v, 2)))),
        row.names = FALSE)
  resumo_c2 <- simulacao |>
    filter(stringr::str_starts(cenario, "Cenário 2")) |>
    summarise(municipios = n(),
              variacao_pct = mean(variacao_pct),
              ic_inf_var_agrupado = mean(ic_inf_variacao_pct_agrupado),
              ic_sup_var_agrupado = mean(ic_sup_variacao_pct_agrupado),
              ganho_medio_reais = mean(salario_prev_depois - salario_prev_antes),
              ganho_min_reais = min(salario_prev_depois - salario_prev_antes),
              ganho_max_reais = max(salario_prev_depois - salario_prev_antes))
  message("Simulação, Cenário 2 (resumo dos 29 municípios):")
  print(as.data.frame(resumo_c2 |> mutate(across(where(is.numeric), \(v) round(v, 2)))),
        row.names = FALSE)

  # Gravações em CSV.
  arquivos_csv <- c(
    gravar_csv(tabela_diagnosticos, "diagnosticos_modelo_2.csv"),
    gravar_csv(fiv, "fiv_modelos_2_3_3b.csv"),
    gravar_csv(coeficientes, "coeficientes_cinco_matrizes.csv"),
    gravar_csv(testes_f, "teste_f_global_robusto.csv"),
    gravar_csv(selic_cons$tabela, "selic_p_valor_conservador.csv"),
    gravar_csv(robustez, "robustez_modelo_2_sem_x3_negativo.csv"),
    gravar_csv(simulacao, "simulacao_cenarios_renda.csv")
  )

  # Tabelas de regressão e figuras.
  message("\nGravando tabelas de regressão e figuras.")
  placar_tabelas <- gravar_tabelas(modelos, matrizes)
  placar_figuras <- gerar_figuras(modelos$modelo_2)

  # Objeto R com tudo.
  lista_resultados <- list(
    modelos                 = modelos,
    matrizes_covariancia    = matrizes,
    coeficientes            = coeficientes,
    testes_f_global         = testes_f,
    selic_p_valor_conservador = selic_cons$tabela,
    selic_coeftest_agrupado_ano = selic_cons$coeftest,
    matriz_agrupada_ano_modelo_2 = selic_cons$matriz,
    fiv                     = fiv,
    diagnosticos_modelo_2   = tabela_diagnosticos,
    objetos_testes          = diagnosticos$objetos,
    rho_durbin_watson       = diagnosticos$rho_dw,
    rho_intra_municipio     = diagnosticos$rho_intra_municipio,
    pares_cruzados          = pares_cruzados,
    lag_newey_west_modelo_2 = attr(matrizes$modelo_2$newey_west, "lag_escolhido"),
    robustez_sem_x3_negativo = robustez,
    simulacao               = simulacao,
    data_execucao           = Sys.time()
  )
  tryCatch(saveRDS(lista_resultados, ARQ_RESULTADOS),
           error = function(e) stop("Falha ao gravar ", ARQ_RESULTADOS, ": ",
                                    conditionMessage(e), call. = FALSE))

  # Placar final.
  arquivos <- c(ARQ_RESULTADOS, arquivos_csv, placar_tabelas$arquivo,
                file.path(DIR_FIGURAS, c("diag1_residuos_padronizados_vs_ajustados.png",
                                         "diag2_acf_residuos.png",
                                         "diag3_densidade_residuos.png",
                                         "diag4_qqplot_residuos.png")))
  placar <- tibble::tibble(
    arquivo    = arquivos,
    existe     = file.exists(arquivos),
    tamanho_kb = round(file.size(arquivos) / 1024, 1)
  )
  message("\nPlacar da Etapa 4:")
  print(as.data.frame(placar), row.names = FALSE, right = FALSE)
  n_falhas <- sum(!placar$existe) + sum(placar_tabelas$situacao != "ok") +
    sum(placar_figuras$situacao != "ok")
  if (n_falhas > 0) {
    warning(n_falhas, " gravação(ões) falharam; veja o placar acima.")
  } else {
    message("Todos os ", nrow(placar), " arquivos da Etapa 4 foram gravados.")
  }
  invisible(lista_resultados)
}

executar_etapa_4()
