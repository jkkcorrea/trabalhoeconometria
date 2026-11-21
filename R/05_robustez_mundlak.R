# =============================================================================
# Etapa 5: robustez da Etapa 4 (lista de alterações, itens B1, B2, B3 e C1)
#
# Especificação principal: pooled com erros agrupados por município
# (D-2026-11-16-10). Esta etapa acrescenta, como robustez:
#   - Mundlak (correlated random effects): médias por município das variáveis
#     que variam no tempo, com teste conjunto de nulidade (B1 e B2);
#   - bootstrap wild cluster: ver R/06_calibracao_modelo.R;
#   - teste de correlação serial de painel (Wooldridge, via plm::pbgtest) (C1);
#   - figuras de conferência, para o pesquisador ver os resultados no R.
#
# Este script não altera o painel nem as saídas da Etapa 4. Grava arquivos com
# o prefixo "robustez_mundlak_".
#
# Marcas usadas nos comentários:
#   [a confirmar]: assinatura de função de pacote não conferida na escrita do script.
#   [presunção da modelagem]: escolha metodológica sem fonte externa.
# =============================================================================


# -----------------------------------------------------------------------------
# 0. Conferência do diretório de trabalho
# -----------------------------------------------------------------------------
if (!dir.exists("R")) {
  stop(
    "O diretório de trabalho atual (", getwd(), ") não é a raiz do projeto. ",
    "Use setwd() ou abra o projeto no RStudio.", call. = FALSE
  )
}


# -----------------------------------------------------------------------------
# 1. Dependências
# -----------------------------------------------------------------------------
# Windows: %LOCALAPPDATA%/R/win-library; Linux e macOS: ~/R/library.
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
  "dplyr", "tibble", "purrr", "stringr", "ggplot2", "car", "lmtest",
  "sandwich", "modelsummary", "scales"
)
pacotes_ausentes <- pacotes_necessarios[
  !vapply(pacotes_necessarios, requireNamespace, logical(1), quietly = TRUE)
]
if (length(pacotes_ausentes) > 0) {
  stop("Pacotes ausentes: ", paste(pacotes_ausentes, collapse = ", "),
       ". Instale-os antes de rodar a Etapa 5; este script não instala pacotes.",
       call. = FALSE)
}

# Pacotes opcionais: a ausência não interrompe o script, só a parte que os usa.
pacotes_opcionais <- c("plm")
disponivel <- vapply(pacotes_opcionais, requireNamespace, logical(1), quietly = TRUE)
for (p in names(disponivel)[!disponivel]) {
  message("Pacote opcional ausente: ", p, ". A parte que o usa será pulada.")
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
PREFIXO         <- "robustez_mundlak_"

# Especificação principal (pooled), igual à Etapa 4, Modelo 2.
FORMULA_M2 <- ln_salario_real ~ prop_superior + dom_industrial +
  shannon_diversificacao + selic_real + dist_curitiba_km

# Mundlak: médias por município só das variáveis que variam no tempo.
# dist_curitiba_km já é invariante no tempo; selic_real é comum a todos os
# municípios e por isso não recebe média (seria colinear com o intercepto).
FORMULA_MUNDLAK <- ln_salario_real ~ prop_superior + dom_industrial +
  shannon_diversificacao + selic_real + dist_curitiba_km +
  media_prop + media_dom + media_shannon

# Para o teste de correlação serial de painel usa-se o modelo within, sem os
# termos invariantes no tempo (o teste de Wooldridge é feito sobre dados
# transformados dentro do município).
FORMULA_WITHIN <- ln_salario_real ~ prop_superior + dom_industrial +
  shannon_diversificacao + selic_real

TERMOS_BOOTSTRAP <- c("prop_superior", "dom_industrial", "shannon_diversificacao",
                      "selic_real", "dist_curitiba_km")


# -----------------------------------------------------------------------------
# 3. Leitura, validação e médias de Mundlak
# -----------------------------------------------------------------------------
ler_painel <- function() {
  if (!file.exists(ARQ_PAINEL)) {
    stop("Painel não encontrado em ", ARQ_PAINEL, ". Rode a Etapa 2 antes.", call. = FALSE)
  }
  dados <- readRDS(ARQ_PAINEL) |>
    tibble::as_tibble() |>
    mutate(
      id_municipio = stringr::str_pad(as.character(id_municipio), 7, pad = "0"),
      ano          = as.integer(ano)
    ) |>
    arrange(id_municipio, ano)

  if (nrow(dados) != LINHAS_PAINEL) {
    stop("O painel tem ", nrow(dados), " linhas; esperado ", LINHAS_PAINEL, ".", call. = FALSE)
  }
  if (dplyr::n_distinct(dados$id_municipio) != N_MUNICIPIOS) {
    stop("O painel não tem ", N_MUNICIPIOS, " municípios.", call. = FALSE)
  }
  if (anyDuplicated(dados[, c("id_municipio", "ano")]) > 0) {
    stop("O painel tem pares município e ano repetidos.", call. = FALSE)
  }
  dados
}

# Médias por município (x̄_i) das variáveis que variam no tempo [B1].
adicionar_medias_mundlak <- function(dados) {
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
# 4. Estimação e matrizes
# -----------------------------------------------------------------------------
# Matriz agrupada por município, tipo HC1 (mesmo critério da Etapa 4).
matriz_agrupada <- function(modelo, dados) {
  stopifnot(nrow(dados) == stats::nobs(modelo))
  sandwich::vcovCL(modelo, cluster = dados$id_municipio, type = "HC1")
}

# Tabela de coeficientes sob uma matriz, com intervalo de 95%.
tabela_coeficientes <- function(modelo, V, nome_modelo) {
  # Intervalo e p-valor pelo erro-padrão da matriz V, com t de G - 1 graus de liberdade
  # (confint.default não aceita a matriz de covariância e usaria o erro clássico).
  gl <- N_MUNICIPIOS - 1L
  est <- unname(stats::coef(modelo))
  termos_coef <- names(stats::coef(modelo))
  ep <- sqrt(diag(V))
  tv <- est / ep
  tc <- stats::qt(0.975, gl)
  tibble::tibble(
    modelo      = nome_modelo,
    termo       = termos_coef,
    estimativa  = est,
    erro_padrao = unname(ep),
    estatistica_t = unname(tv),
    p_valor     = 2 * stats::pt(-abs(unname(tv)), gl),
    ic_inf_95   = est - tc * unname(ep),
    ic_sup_95   = est + tc * unname(ep)
  )
}


# -----------------------------------------------------------------------------
# 5. Teste conjunto de Mundlak [B2]
# -----------------------------------------------------------------------------
# H0: os coeficientes das médias por município são todos zero. Não rejeitar H0
# indica que o efeito não observado não está correlacionado com os regressores,
# e o pooled com erros agrupados é consistente; rejeitar indica que o pooled
# é viesado e o Mundlak (ou FE, no que varia no tempo) é preferível.
teste_mundlak <- function(modelo, V) {
  hipotese <- c("media_prop = 0", "media_dom = 0", "media_shannon = 0")
  resultado <- car::linearHypothesis(modelo, hipotese, vcov. = V, test = "F")
  tibble::tibble(
    hipotese       = "media_prop = media_dom = media_shannon = 0",
    matriz         = "Agrupado por município (HC1)",
    estatistica_f  = resultado$F[2],
    gl_numerador   = resultado$Df[2],
    gl_denominador = resultado$Res.Df[2],
    p_valor        = resultado$`Pr(>F)`[2]
  )
}


# -----------------------------------------------------------------------------
# 7. Autocorrelação de painel [C1]
# -----------------------------------------------------------------------------
# Teste de Breusch-Godfrey para painel (Wooldridge, 2002, 2010), via plm.
# Usa o modelo within, sem termos invariantes no tempo. A ordem 1 é o teste
# equivalente ao DW no painel, sem cruzar fronteiras entre municípios.
teste_autocorrelacao_painel <- function(dados) {
  if (!disponivel[["plm"]]) {
    return(tibble::tibble(teste = "pbgtest (plm)", observacao = "pacote ausente"))
  }
  pdados <- plm::pdata.frame(as.data.frame(dados), index = c("id_municipio", "ano"))
  within <- plm::plm(FORMULA_WITHIN, data = pdados, model = "within")
  resultado <- plm::pbgtest(within, order = 1)
  tibble::tibble(
    teste       = "Breusch-Godfrey de painel, ordem 1 (within; Wooldridge)",
    estatistica = unname(resultado$statistic),
    gl          = unname(resultado$parameter),
    p_valor     = resultado$p.value,
    observacao  = "modelo within sem termos invariantes no tempo"
  )
}


# -----------------------------------------------------------------------------
# 8. Diagnóstico por município: d de Durbin-Watson (A1), para a figura
# -----------------------------------------------------------------------------
d_por_municipio <- function(modelo, dados) {
  e_all <- stats::residuals(modelo)
  purrr::map_dfr(split(seq_len(nrow(dados)), dados$id_municipio), function(i) {
    e <- e_all[i]
    tibble::tibble(d = sum(diff(e)^2) / sum(e^2))
  }, .id = "id_municipio")
}


# -----------------------------------------------------------------------------
# 9. Figuras de conferência (para o pesquisador ver no R)
# -----------------------------------------------------------------------------
figura_coeficientes <- function(tab_pooled, tab_mundlak) {
  rotulos <- c(prop_superior = "X2 ensino superior (%)", dom_industrial = "X3 dominância industrial (%)",
               shannon_diversificacao = "X4 diversificação (Shannon)", selic_real = "X5 Selic real (% a.a.)",
               dist_curitiba_km = "X6 distância a Curitiba (km)")
  tabela <- dplyr::bind_rows(tab_pooled, tab_mundlak) |>
    dplyr::filter(termo %in% TERMOS_BOOTSTRAP) |>
    dplyr::mutate(termo = factor(rotulos[termo], levels = rotulos),
                  modelo = factor(modelo, levels = c("Pooled (principal)", "Mundlak (robustez)")))
  grafico <- ggplot(tabela, aes(x = estimativa, y = modelo, colour = modelo)) +
    geom_vline(xintercept = 0, linetype = "dashed", colour = "grey55") +
    geom_pointrange(aes(xmin = ic_inf_95, xmax = ic_sup_95), size = 0.45) +
    facet_wrap(~ termo, scales = "free_x", ncol = 2) +
    scale_colour_manual(values = c("Pooled (principal)" = "grey35", "Mundlak (robustez)" = "#B2182B"),
                        labels = c("Pooled (principal)" = "MQO empilhado", "Mundlak (robustez)" = "Mundlak (controla o município)"),
                        name = NULL) +
    scale_y_discrete(labels = NULL, breaks = NULL) +
    scale_x_continuous(labels = scales::label_number(decimal.mark = ",", accuracy = NULL)) +
    labs(
      title = "Coeficientes sobre ln(salário real) com IC de 95%",
      subtitle = "Erro agrupado por município, t com 28 graus de liberdade; linha tracejada: efeito nulo",
      x = "Estimativa", y = NULL
    ) +
    theme_minimal(base_size = 11) +
    theme(plot.title = element_text(face = "bold"), strip.text = element_text(face = "bold"),
          legend.position = "inside", legend.position.inside = c(0.75, 0.13),
          panel.grid.minor = element_blank(), panel.spacing.x = unit(1.4, "cm"))
  arquivo <- file.path(DIR_FIGURAS, paste0(PREFIXO, "coeficientes.png"))
  ggsave(arquivo, grafico, width = 9, height = 6.5, dpi = 150, bg = "white")
  print(grafico)
  message("Figura gravada: ", arquivo)
  invisible(grafico)
}

figura_dw_municipios <- function(d_tab, d_empilhado) {
  old <- options(OutDec = ",")
  on.exit(options(old), add = TRUE)
  grafico <- ggplot(d_tab, aes(x = d)) +
    geom_histogram(bins = 12, fill = "#2c7fb8", colour = "white") +
    geom_vline(xintercept = 2, linetype = "dashed", colour = "grey30") +
    geom_vline(xintercept = d_empilhado, colour = "#c0392b") +
    annotate("text", x = d_empilhado, y = Inf, label = "d empilhado (inválido)",
             hjust = -0.05, vjust = 1.5, colour = "#c0392b", size = 3) +
    labs(
      title = "Durbin-Watson por município, resíduos do Modelo 2 (MQO empilhado)",
      subtitle = "Linha tracejada: d = 2 (sem autocorrelação de ordem 1)",
      x = "d por município", y = "Municípios"
    ) +
    theme_minimal(base_size = 11)
  arquivo <- file.path(DIR_FIGURAS, paste0(PREFIXO, "dw_por_municipio.png"))
  ggsave(arquivo, grafico, width = 7, height = 4.5, dpi = 150)
  print(grafico)
  message("Figura gravada: ", arquivo)
  invisible(grafico)
}


# -----------------------------------------------------------------------------
# 9b. Modelos adicionais: Modelo 3c (3b com interação centrada) e Modelo 4
# (Modelo 2 com tendência linear no ano). Não substituem os modelos 2, 3 e 3b.
#   - Modelo 3c: centralizar dom_industrial e dist_curitiba_km antes da
#     interação não muda o ajuste nem o coeficiente da interação; muda o
#     significado dos termos principais (efeito de cada variável na média da
#     outra) e reduz o FIV. O script confere que o ajuste é idêntico ao do 3b.
#   - Modelo 4: se o efeito da Selic real fosse só uma tendência de tempo, o
#     coeficiente perderia força quando entra a tendência. Selic e ano não são
#     colineares exatos, porque a Selic varia em série e não em linha reta.
#   - Coeficientes com erro agrupado por município (HC1) e p-valor com t de
#     G - 1 = 28 graus de liberdade.
#   - RESET de Ramsey (potências 2 e 3) para verificar a forma funcional.
ajustar_robustez_adicional <- function(dados) {
  media_industria <- mean(dados$dom_industrial)
  media_distancia <- mean(dados$dist_curitiba_km)
  dados_c <- dados |>
    mutate(
      dom_c     = dom_industrial - media_industria,
      dist_c    = dist_curitiba_km - media_distancia,
      tendencia = ano - min(ano)
    )

  f_3b <- ln_salario_real ~ prop_superior + dom_industrial + shannon_diversificacao +
    selic_real + dist_curitiba_km + dummy_curitiba + dom_industrial:dist_curitiba_km
  f_3c <- ln_salario_real ~ prop_superior + dom_c + shannon_diversificacao +
    selic_real + dist_c + dummy_curitiba + dom_c:dist_c
  f_4  <- ln_salario_real ~ prop_superior + dom_industrial + shannon_diversificacao +
    selic_real + dist_curitiba_km + tendencia

  m3b <- lm(f_3b, data = dados_c)
  m3c <- lm(f_3c, data = dados_c)
  m4  <- lm(f_4,  data = dados_c)

  diferenca <- max(abs(stats::fitted(m3b) - stats::fitted(m3c)))
  if (diferenca > 1e-8) {
    stop("Centralizar a interação mudou os valores ajustados (diferença ",
         format(diferenca), "). Verifique a construção de dom_c e dist_c.", call. = FALSE)
  }
  message("Modelo 3c: ajuste idêntico ao 3b (diferença máxima nos ajustados = ",
          format(diferenca, digits = 2), ").")

  tabela_modelo <- function(modelo, nome_modelo) {
    V  <- sandwich::vcovCL(modelo, cluster = dados_c$id_municipio, type = "HC1")
    ct <- lmtest::coeftest(modelo, vcov. = V, df = N_MUNICIPIOS - 1L)
    # type = "predictor": FIV por variável explicativa, como recomendado pelo
    # próprio car quando há termos de interação; o FIV da interação não é reportado.
    fiv <- car::vif(modelo, type = "predictor")
    if (is.data.frame(fiv) || is.matrix(fiv)) {
      # Coluna pelo nome: a última coluna é texto ("Other Predictors").
      fiv <- stats::setNames(as.numeric(fiv[["GVIF^(1/(2*Df))"]]), rownames(fiv))
    }
    tibble::tibble(
      modelo          = nome_modelo,
      termo           = rownames(ct),
      estimativa      = unname(ct[, 1]),
      erro_padrao     = unname(ct[, 2]),
      p_valor         = unname(ct[, 4]),
      fiv_ajustado    = as.numeric(unlist(fiv)[match(rownames(ct), names(fiv))])
    )
  }

  coeficientes <- dplyr::bind_rows(
    tabela_modelo(m3c, "Modelo 3c (3b com interação centrada)"),
    tabela_modelo(m4,  "Modelo 4 (Modelo 2 com tendência)")
  )
  resumo <- tibble::tibble(
    modelo   = c("Modelo 3b (referência)", "Modelo 3c (3b centrado)", "Modelo 4 (tendência)"),
    n        = c(stats::nobs(m3b), stats::nobs(m3c), stats::nobs(m4)),
    r2       = c(summary(m3b)$r.squared, summary(m3c)$r.squared, summary(m4)$r.squared),
    reset_p  = c(lmtest::resettest(m3b, power = 2:3, type = "regressor")$p.value,
                 lmtest::resettest(m3c, power = 2:3, type = "regressor")$p.value,
                 lmtest::resettest(m4,  power = 2:3, type = "regressor")$p.value)
  )

  readr::write_csv(coeficientes, file.path(DIR_RESULTADOS, "robustez_adicional_coeficientes.csv"))
  readr::write_csv(resumo, file.path(DIR_RESULTADOS, "robustez_adicional_resumo.csv"))
  message("Robustez adicional gravada em ", DIR_RESULTADOS, ".")
  invisible(list(coeficientes = coeficientes, resumo = resumo, m3c = m3c, m4 = m4))
}


# -----------------------------------------------------------------------------
# 10. Execução
# -----------------------------------------------------------------------------
executar_etapa_5 <- function() {
  dados <- ler_painel() |> adicionar_medias_mundlak()
  message("Painel: ", nrow(dados), " linhas, ", N_MUNICIPIOS, " municípios, ", N_ANOS, " anos.")

  mod_pooled  <- lm(FORMULA_M2, data = dados)
  mod_mundlak <- lm(FORMULA_MUNDLAK, data = dados)
  V_pooled    <- matriz_agrupada(mod_pooled, dados)
  V_mundlak   <- matriz_agrupada(mod_mundlak, dados)

  tab_pooled  <- tabela_coeficientes(mod_pooled, V_pooled, "Pooled (principal)")
  tab_mundlak <- tabela_coeficientes(mod_mundlak, V_mundlak, "Mundlak (robustez)")
  f_mundlak   <- teste_mundlak(mod_mundlak, V_mundlak)
  autocorr     <- teste_autocorrelacao_painel(dados)
  d_tab        <- d_por_municipio(mod_pooled, dados)
  robustez_adicional <- ajustar_robustez_adicional(dados)

  # Gravação das tabelas.
  readr::write_csv(dplyr::bind_rows(tab_pooled, tab_mundlak),
                   file.path(DIR_RESULTADOS, paste0(PREFIXO, "coeficientes.csv")))
  readr::write_csv(f_mundlak, file.path(DIR_RESULTADOS, paste0(PREFIXO, "teste_mundlak.csv")))
  readr::write_csv(autocorr, file.path(DIR_RESULTADOS, paste0(PREFIXO, "autocorrelacao_painel.csv")))

  modelsummary::modelsummary(
    list("Pooled (principal)" = mod_pooled, "Mundlak (robustez)" = mod_mundlak),
    vcov   = list(V_pooled, V_mundlak),
    output = file.path(DIR_RESULTADOS, paste0(PREFIXO, "tabela.txt")),
    stars  = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
    gof_map = c("nobs", "r.squared", "adj.r.squared"),
    title  = "Pooled com erros agrupados e Mundlak (robustez)"
  )

  # Figuras para conferência.
  # d empilhado, só para comparação na figura: o valor que o DW da Etapa 4 usa.
  e_pooled <- stats::residuals(mod_pooled)
  d_empilhado <- sum(diff(e_pooled)^2) / sum(e_pooled^2)
  figura_coeficientes(tab_pooled, tab_mundlak)
  figura_dw_municipios(d_tab, d_empilhado)

  message("\nTeste de Mundlak (H0: médias por município = 0):")
  message("  F = ", round(f_mundlak$estatistica_f, 3), ", p-valor = ",
          format.pval(f_mundlak$p_valor, digits = 3))
  invisible(list(pooled = mod_pooled, mundlak = mod_mundlak, V_pooled = V_pooled,
                 V_mundlak = V_mundlak, teste_mundlak = f_mundlak,
                 autocorrelacao = autocorr, d_municipios = d_tab))
}

# Execução ao rodar o arquivo inteiro; comente a linha para carregar só as funções.
resultados_etapa_5 <- executar_etapa_5()
