# =============================================================================
# Etapa 3: análise exploratória espacial e visualizações
# Trabalho de Econometria I (UFPR): salário médio real formal nos 29 municípios
# da Região Metropolitana de Curitiba, 2012 a 2021 (290 observações).
#
# Lê:    ./dados_processados/dados_painel_rmc.rds
#        ./dados_brutos/malha_rmc.rds (objeto sf já em SIRGAS 2000 / UTM 22S)
# Grava: ./figuras_graficos/fig1_matriz_correlacao.png
#        ./figuras_graficos/fig2_ridgeplot_salario_anos.png
#        ./figuras_graficos/fig3_dispersao_capital_humano_industria.png
#        ./figuras_graficos/mapa1_painel_espacial_rmc.png
#        ./figuras_graficos/animacao1_mapa_renda_rmc.gif
#        ./figuras_graficos/legenda_municipios_rmc.png
#        ./figuras_graficos/animacao2_ranking_salario_municipios.gif
#
# Execução: a partir da raiz do projeto, no RStudio (source) ou pelo Rscript.
# O script não consulta nenhuma API. As duas animações levam alguns minutos.
#
# Desvios em relação ao prompt 3 (prompt-3-aede-visualizacoes.md) e escolhas:
#  1. Malha: o prompt admite o geobr. Este script usa a malha gravada pela
#     Etapa 1 em dados_brutos/malha_rmc.rds e não chama o geobr.
#  2. Pacotes: o prompt cita tidyverse, geobr, corrplot e cowplot. Este script
#     carrega só dplyr, tidyr, purrr, readr, tibble e stringr (no lugar do
#     tidyverse), usa mapa de calor em ggplot2 no lugar do corrplot e patchwork no lugar do
#     cowplot; geobr não é usado. Nada é instalado: o script para se faltar
#     algum pacote.
#  3. Nomes de variáveis: valem os nomes gravados no painel da Etapa 2.
#  4. Figura 1: matriz de correlação em triângulo inferior (mapa de calor), com
#     o coeficiente de Pearson de cada par e sem asteriscos. Os p-valores não
#     são exibidos, porque as 290 observações não são independentes. GGally
#     deixou de ser usado; a figura anterior, com ggpairs, saiu muito poluída.
#  5. Figura 2: densidades por ano do salario_medio_real em reais de 2021,
#     preenchidas por gradiente do valor (scale_fill_viridis_c). O gradiente do
#     ggridges não aceita transparência, por isso as curvas são opacas.
#  6. Figura 3: dois painéis com patchwork, 290 observações cada, reta de lm;
#     rótulos só nos pontos de 2021 de Curitiba, Araucária, São José dos
#     Pinhais, Adrianópolis e Doutor Ulysses, selecionados pelo código IBGE.
#     Os rótulos usam ggrepel::geom_label_repel (fundo branco translúcido) no
#     lugar de geom_text_repel, porque o texto simples ficava ilegível sobre a
#     nuvem de pontos.
#     No painel de dominância industrial, os dois pontos com x3_negativo
#     (Araucária em 2012 e 2013, valor adicionado da indústria negativo na
#     fonte) recebem cor e forma próprias.
#  7. Mapa 1: grade 2x2 do último ano do painel, obtido por max(ano); cada
#     mapa com escala de cor, legenda, barra de escala e seta do norte próprias.
#  8. Numeração: os 29 municípios recebem números de 1 a 29 pela ordem alfabética.
#     Cada um aparece no mapa como círculo de contorno preto, fundo branco e
#     número preto, no centroide do polígono. A legenda com número e nome sai em
#     legenda_municipios_rmc.png e ao lado do mapa 1.
#  9. Animação 1: escala de cor fixa para todos os anos, título com o ano
#     arredondado e números dos municípios.
# 10. Animação 2: substituiu a dispersão animada no estilo Gapminder por um
#     ranking animado do salário médio real. Barras ordenadas, número e nome
#     dentro de cada barra e valor no fim, sem escala extra de cor ou tamanho.
# =============================================================================


# -----------------------------------------------------------------------------
# 1. Dependências
# -----------------------------------------------------------------------------
# A biblioteca do usuário é colocada à frente em .libPaths(), como nas etapas
# anteriores, porque os pacotes instalados ficam lá. Este script não instala nada.
biblioteca_usuario <- Sys.getenv("R_LIBS_USER")
if (!nzchar(biblioteca_usuario)) {
  biblioteca_usuario <- file.path(
    Sys.getenv("LOCALAPPDATA"), "R", "win-library",
    paste(R.version$major, strsplit(R.version$minor, ".", fixed = TRUE)[[1]][1], sep = ".")
  )
}
if (dir.exists(biblioteca_usuario)) {
  .libPaths(c(biblioteca_usuario, .libPaths()))
}

pacotes_necessarios <- c(
  "dplyr", "tidyr", "purrr", "readr", "tibble", "stringr", "sf", "ggplot2",
  "gganimate", "gifski", "transformr", "ggridges", "ggrepel", "patchwork",
  "viridis", "ggspatial", "scales", "png"
)
pacotes_ausentes <- pacotes_necessarios[
  !vapply(pacotes_necessarios, requireNamespace, logical(1), quietly = TRUE)
]
if (length(pacotes_ausentes) > 0) {
  stop("Pacotes ausentes: ", paste(pacotes_ausentes, collapse = ", "),
       ". Instale-os antes de rodar a Etapa 3; este script não instala pacotes.")
}

# O transformr é carregado explicitamente porque o gganimate depende dele para
# interpolar polígonos sf entre os quadros da animação.
invisible(lapply(
  c("tibble", "stringr", "readr", "purrr", "tidyr", "dplyr", "sf", "ggplot2",
    "gganimate", "gifski", "transformr", "ggridges", "ggrepel", "patchwork",
    "viridis", "ggspatial", "scales"),
  function(p) suppressPackageStartupMessages(library(p, character.only = TRUE))
))


# -----------------------------------------------------------------------------
# 2. Parâmetros
# -----------------------------------------------------------------------------
DIR_BRUTOS      <- "./dados_brutos"
DIR_PROCESSADOS <- "./dados_processados"
DIR_FIGURAS     <- "./figuras_graficos"
ARQ_PAINEL      <- file.path(DIR_PROCESSADOS, "dados_painel_rmc.rds")
ARQ_MALHA       <- file.path(DIR_BRUTOS, "malha_rmc.rds")
N_MUNICIPIOS    <- 29L
N_ANOS          <- 10L
LINHAS_PAINEL   <- N_MUNICIPIOS * N_ANOS
EPSG_UTM22S     <- 31982L
COD_CURITIBA    <- "4106902"

# Municípios rotulados na figura 3, selecionados pelo código IBGE.
MUNICIPIOS_ROTULADOS <- c(
  "4106902",  # Curitiba
  "4101804",  # Araucária
  "4125506",  # São José dos Pinhais
  "4100202",  # Adrianópolis
  "4128633"   # Doutor Ulysses
)

# Parâmetros comuns das duas animações (prompt 3).
ANIM_LARGURA <- 800
ANIM_ALTURA  <- 700
ANIM_FPS     <- 10
ANIM_DURACAO <- 15

# Notas de fonte usadas nas legendas das figuras.
FONTE_SALARIO <- "Salário: RAIS (Ministério do Trabalho), deflacionado pelo IPCA (série 433 do Banco Central), em R$ de 2021."
FONTE_RAIS    <- "Escolaridade e Gini setorial: RAIS (Ministério do Trabalho)."
FONTE_PIB     <- "Dominância industrial: PIB dos Municípios (IBGE, SIDRA)."
FONTE_SELIC   <- "Selic real: Banco Central (séries 4390 e 433)."
FONTE_MALHA   <- "Malha municipal e distância a Curitiba: IBGE."

# Formatadores numéricos no padrão brasileiro.
fmt_reais   <- scales::label_number(prefix = "R$ ", big.mark = ".", decimal.mark = ",", accuracy = 1)
fmt_num1    <- scales::label_number(big.mark = ".", decimal.mark = ",", accuracy = 0.1)
fmt_num2    <- scales::label_number(big.mark = ".", decimal.mark = ",", accuracy = 0.01)
fmt_inteiro <- scales::label_number(big.mark = ".", decimal.mark = ",", accuracy = 1)
fmt_pct     <- scales::label_number(suffix = "%", big.mark = ".", decimal.mark = ",", accuracy = 1)


# -----------------------------------------------------------------------------
# 3. Leitura e validação dos insumos
# -----------------------------------------------------------------------------
ler_rds_obrigatorio <- function(caminho, descricao) {
  tryCatch(
    {
      if (!file.exists(caminho)) stop("arquivo não encontrado")
      readRDS(caminho)
    },
    error = function(e) {
      stop("Falha ao ler ", descricao, " em ", caminho, ": ", conditionMessage(e),
           ". Rode as etapas anteriores antes da Etapa 3.", call. = FALSE)
    }
  )
}

carregar_painel <- function() {
  dados <- ler_rds_obrigatorio(ARQ_PAINEL, "o painel tratado da Etapa 2")

  colunas_necessarias <- c(
    "id_municipio", "nome_municipio", "ano", "salario_medio_real", "ln_salario_real",
    "prop_superior", "dom_industrial", "gini_setorial", "selic_real",
    "dist_curitiba_km", "x3_negativo", "vinculos_ativos"
  )
  colunas_faltantes <- setdiff(colunas_necessarias, names(dados))
  if (length(colunas_faltantes) > 0) {
    stop("O painel não tem as colunas: ", paste(colunas_faltantes, collapse = ", "), call. = FALSE)
  }

  colunas_numericas <- c("salario_medio_real", "ln_salario_real", "prop_superior",
                         "dom_industrial", "gini_setorial", "selic_real",
                         "dist_curitiba_km", "vinculos_ativos")
  dados <- dados |>
    tibble::as_tibble() |>
    mutate(
      id_municipio = stringr::str_pad(as.character(id_municipio), 7, pad = "0"),
      ano          = as.integer(ano),
      x3_negativo  = as.logical(x3_negativo),
      across(all_of(colunas_numericas), \(v) suppressWarnings(as.numeric(v)))
    )

  if (nrow(dados) != LINHAS_PAINEL) {
    stop("O painel tem ", nrow(dados), " linhas; esperado ", LINHAS_PAINEL, ".", call. = FALSE)
  }
  if (n_distinct(dados$id_municipio) != N_MUNICIPIOS || n_distinct(dados$ano) != N_ANOS) {
    stop("O painel não tem 29 municípios em 10 anos.", call. = FALSE)
  }

  problemas <- dados |>
    summarise(across(all_of(colunas_numericas),
                     \(v) sum(is.na(v) | is.nan(v) | is.infinite(v)))) |>
    tidyr::pivot_longer(everything(), names_to = "variavel", values_to = "n_problemas") |>
    filter(n_problemas > 0)
  if (nrow(problemas) > 0) {
    warning("Valores NA, NaN ou Inf no painel: ",
            paste0(problemas$variavel, " (", problemas$n_problemas, ")", collapse = "; "))
  } else {
    message("Painel: ", nrow(dados), " linhas, sem NA, NaN ou Inf nas variáveis usadas.")
  }
  dados
}

carregar_malha <- function(dados) {
  malha <- ler_rds_obrigatorio(ARQ_MALHA, "a malha municipal da Etapa 1")
  if (!inherits(malha, "sf")) stop("A malha lida não é um objeto sf.", call. = FALSE)

  malha <- malha |>
    mutate(id_municipio = stringr::str_pad(as.character(id_municipio), 7, pad = "0")) |>
    select(id_municipio, geometry)

  epsg_malha <- sf::st_crs(malha)$epsg
  if (is.na(epsg_malha) || epsg_malha != EPSG_UTM22S) {
    message("Malha fora do EPSG 31982; reprojetando para SIRGAS 2000 / UTM 22S.")
    malha <- sf::st_transform(malha, EPSG_UTM22S)
  }

  codigos_painel <- sort(unique(dados$id_municipio))
  sem_malha  <- setdiff(codigos_painel, malha$id_municipio)
  sem_painel <- setdiff(malha$id_municipio, codigos_painel)
  if (nrow(malha) != N_MUNICIPIOS || length(sem_malha) > 0 || length(sem_painel) > 0) {
    stop("Malha e painel não casam pelo id_municipio. Sem malha: ",
         paste(sem_malha, collapse = ", "), ". Sem painel: ",
         paste(sem_painel, collapse = ", "), ". Linhas na malha: ", nrow(malha), ".",
         call. = FALSE)
  }
  message("Malha: ", nrow(malha), " polígonos, todos casados com o painel.")
  malha
}

# Junta o painel (ou um recorte dele) à malha e confere que nada se perdeu.
juntar_malha <- function(dados, mapa_sf) {
  unido <- mapa_sf |> inner_join(dados, by = "id_municipio")
  if (nrow(unido) != nrow(dados)) {
    stop("O join com a malha devolveu ", nrow(unido), " linhas; esperado ",
         nrow(dados), ".", call. = FALSE)
  }
  unido
}


# -----------------------------------------------------------------------------
# 4. Tema comum
# -----------------------------------------------------------------------------
tema_base <- theme_bw(base_size = 11) +
  theme(
    plot.title      = element_text(face = "bold"),
    plot.caption    = element_text(hjust = 0, size = 8, colour = "grey30"),
    panel.grid.minor = element_blank()
  )


# -----------------------------------------------------------------------------
# 5. Figura 1: matriz de correlação em triângulo (mapa de calor)
# Triângulo inferior, um coeficiente de Pearson por par de variáveis, sem
# asteriscos. Os p-valores de cor.test tratam as 290 observações como
# independentes, embora cada município apareça dez vezes; por isso não são
# exibidos nesta figura [presunção da modelagem]. A ressalva fica na legenda.
plotar_matriz_correlacao <- function(dados) {
  arquivo <- file.path(DIR_FIGURAS, "fig1_matriz_correlacao.png")
  variaveis <- c("ln_salario_real", "prop_superior", "dom_industrial",
                 "gini_setorial", "selic_real", "dist_curitiba_km")
  rotulos <- c("Ln do salário\nreal", "Ensino superior\n(%)", "Dominância\nindustrial (%)",
               "Concentração\nsetorial (Gini)", "Selic real\n(% a.a.)", "Distância a\nCuritiba (km)")

  m <- stats::cor(as.data.frame(dados)[, variaveis], use = "pairwise.complete.obs")
  ordem <- seq_along(variaveis)

  pares <- tidyr::crossing(linha = ordem, coluna = ordem) |>
    dplyr::filter(linha > coluna) |>
    dplyr::mutate(
      r = m[cbind(linha, coluna)],
      rotulo_r = formatC(r, format = "f", digits = 2, decimal.mark = ","),
      cor_texto = ifelse(abs(r) >= 0.6, "white", "grey15")
    )
  if (nrow(pares) != choose(length(variaveis), 2)) {
    stop("A matriz de correlação não tem o número esperado de pares.", call. = FALSE)
  }

  grafico <- ggplot(pares, aes(x = coluna, y = linha, fill = r)) +
    geom_tile(colour = "white", linewidth = 1.2) +
    geom_text(aes(label = rotulo_r, colour = cor_texto), size = 4, fontface = "bold") +
    scale_colour_identity() +
    scale_fill_gradient2(low = "#2166AC", mid = "white", high = "#B2182B",
                         limits = c(-1, 1), name = "Correlação de Pearson",
                         labels = fmt_num1,
                         guide = guide_colourbar(direction = "horizontal", title.position = "top",
                                                 barwidth = unit(6.5, "cm"), barheight = unit(0.45, "cm"))) +
    scale_x_continuous(breaks = ordem[-length(ordem)], labels = rotulos[-length(ordem)],
                       position = "bottom", expand = expansion(add = 0.5)) +
    scale_y_reverse(breaks = ordem[-1], labels = rotulos[-1],
                    expand = expansion(add = 0.5)) +
    coord_fixed() +
    labs(
      title    = "Correlação entre as variáveis do modelo, RMC, 2012 a 2021",
      subtitle = "Coeficiente de Pearson sobre 290 observações (29 municípios x 10 anos). Azul: correlação negativa; vermelho: positiva.",
      caption  = paste(
        "Sem asteriscos de significância: como cada município aparece dez vezes, as 290 observações não são independentes.",
        stringr::str_wrap(paste(FONTE_SALARIO, FONTE_RAIS, FONTE_PIB, FONTE_SELIC, FONTE_MALHA), width = 135),
        sep = "\n"
      )
    ) +
    theme_minimal(base_size = 11) +
    theme(
      plot.title       = element_text(face = "bold", size = 13),
      plot.subtitle    = element_text(size = 9, colour = "grey25"),
      plot.caption     = element_text(hjust = 0, size = 7.5, colour = "grey30"),
      axis.title       = element_blank(),
      axis.text        = element_text(size = 9, colour = "grey15"),
      panel.grid       = element_blank(),
      legend.position  = "inside",
      legend.position.inside = c(0.72, 0.80),
      legend.title     = element_text(size = 9.5, face = "bold"),
      legend.text      = element_text(size = 9)
    )

  ggsave(arquivo, grafico, width = 9, height = 7.5, units = "in", dpi = 300, bg = "white")
  arquivo
}

# -----------------------------------------------------------------------------
# 6. Figura 2: ridgeplot do salário médio real por ano
# -----------------------------------------------------------------------------
plotar_ridgeplot_salarios <- function(dados) {
  arquivo <- file.path(DIR_FIGURAS, "fig2_ridgeplot_salario_anos.png")
  dados_plot <- dados |> mutate(ano_fator = factor(ano, levels = sort(unique(ano))))

  grafico <- ggplot(dados_plot, aes(x = salario_medio_real, y = ano_fator,
                                    fill = after_stat(x))) +
    ggridges::geom_density_ridges_gradient(scale = 1.8, rel_min_height = 0.01,
                                           from = min(dados_plot$salario_medio_real), to = max(dados_plot$salario_medio_real),
                                           colour = "grey25", linewidth = 0.3) +
    scale_fill_viridis_c(name = "Salário médio real\n(R$ de 2021)", option = "C",
                         labels = fmt_reais, guide = "none") +
    scale_x_continuous(labels = fmt_reais, expand = expansion(mult = c(0.01, 0.03))) +
    scale_y_discrete(expand = expansion(add = c(0.3, 1.9))) +
    labs(
      title    = "Distribuição do salário médio real formal entre os municípios da RMC, por ano",
      subtitle = "Densidade dos 29 municípios em cada ano, 2012 a 2021. A cor acompanha o valor do salário no eixo horizontal (mais claro, maior).",
      x        = "Salário médio real (R$ de 2021)",
      y        = "Ano",
      caption  = FONTE_SALARIO
    ) +
    tema_base +
    theme(legend.position = "right", panel.grid.major.y = element_blank())

  ggsave(arquivo, grafico, width = 10, height = 8, units = "in", dpi = 300, bg = "white")
  arquivo
}


# -----------------------------------------------------------------------------
# 7. Figura 3: dispersões de capital humano e dominância industrial
# -----------------------------------------------------------------------------
plotar_dispersoes_principais <- function(dados) {
  arquivo <- file.path(DIR_FIGURAS, "fig3_dispersao_capital_humano_industria.png")
  ultimo_ano <- max(dados$ano)

  rotulados <- dados |>
    filter(ano == ultimo_ano, id_municipio %in% MUNICIPIOS_ROTULADOS)
  if (nrow(rotulados) != length(MUNICIPIOS_ROTULADOS)) {
    stop("A figura 3 esperava ", length(MUNICIPIOS_ROTULADOS),
         " pontos rotulados em ", ultimo_ano, " e achou ", nrow(rotulados), ".", call. = FALSE)
  }

  dados_b <- dados |>
    mutate(destaque = if_else(x3_negativo,
                              "VAB da indústria negativo na fonte (Araucária, 2012 e 2013)",
                              "Demais observações"))
  if (sum(dados_b$x3_negativo) != 2) {
    warning("A figura 3 esperava 2 observações com x3_negativo e achou ",
            sum(dados_b$x3_negativo), "; a legenda do destaque cita Araucária em 2012 e 2013.")
  }

  cor_pontos <- viridis::viridis(1, begin = 0.3)
  cor_reta   <- viridis::viridis(1, begin = 0.75)
  cor_rotulo <- "grey10"

  painel_a <- ggplot(dados, aes(x = prop_superior, y = ln_salario_real)) +
    geom_point(alpha = 0.5, size = 1.6, colour = cor_pontos) +
    geom_smooth(method = "lm", formula = y ~ x, colour = cor_reta, fill = "grey80",
                linewidth = 0.8) +
    geom_point(data = rotulados, shape = 21, size = 2.6, fill = "white",
               colour = cor_rotulo, stroke = 0.9) +
    ggrepel::geom_label_repel(data = rotulados,
                              aes(label = paste0(nome_municipio, " (", ano, ")")),
                              size = 3.2, colour = cor_rotulo, fill = alpha("white", 0.85),
                              label.size = 0, label.padding = unit(0.15, "lines"),
                              min.segment.length = 0, box.padding = 0.6, seed = 42,
                              max.overlaps = Inf) +
    scale_x_continuous(labels = fmt_pct) +
    scale_y_continuous(labels = fmt_num1) +
    labs(
      title = "A. Capital humano",
      x     = "Vínculos com ensino superior completo (% dos vínculos)",
      y     = "Ln do salário médio real (R$ de 2021)"
    ) +
    tema_base

  painel_b <- ggplot(dados_b, aes(x = dom_industrial, y = ln_salario_real)) +
    geom_point(aes(colour = destaque, shape = destaque), alpha = 0.7, size = 1.8) +
    geom_smooth(method = "lm", formula = y ~ x, colour = cor_reta, fill = "grey80",
                linewidth = 0.8) +
    geom_point(data = rotulados, shape = 21, size = 2.6, fill = "white",
               colour = cor_rotulo, stroke = 0.9) +
    ggrepel::geom_label_repel(data = rotulados,
                              aes(label = paste0(nome_municipio, " (", ano, ")")),
                              size = 3.2, colour = cor_rotulo, fill = alpha("white", 0.85),
                              label.size = 0, label.padding = unit(0.15, "lines"),
                              min.segment.length = 0, box.padding = 0.6, seed = 42,
                              max.overlaps = Inf) +
    ggrepel::geom_label_repel(
      data = dados_b |> filter(x3_negativo) |>
        summarise(dom_industrial = mean(dom_industrial), ln_salario_real = mean(ln_salario_real)),
      colour = "#D7301F", fill = alpha("white", 0.9), size = 3.1, label.size = 0,
      nudge_x = 17, nudge_y = -0.06, min.segment.length = 0, seed = 42, inherit.aes = FALSE,
      mapping = aes(x = dom_industrial, y = ln_salario_real, label = "VAB da indústria negativo\nna fonte (Araucária,\n2012 e 2013)")
    ) +
    scale_colour_manual(
      name   = NULL,
      values = c("Demais observações" = cor_pontos,
                 "VAB da indústria negativo na fonte (Araucária, 2012 e 2013)" = "#D7301F")
    ) +
    scale_shape_manual(
      name   = NULL,
      values = c("Demais observações" = 16,
                 "VAB da indústria negativo na fonte (Araucária, 2012 e 2013)" = 17)
    ) +
    scale_x_continuous(labels = fmt_pct) +
    scale_y_continuous(labels = fmt_num1) +
    labs(
      title = "B. Dominância industrial",
      x     = "VAB da indústria sobre o VAB total (%)",
      y     = "Ln do salário médio real (R$ de 2021)"
    ) +
    tema_base +
    theme(legend.position = "none")

  grafico <- (painel_a | painel_b) +
    patchwork::plot_annotation(
      title    = "Salário médio real, capital humano e dominância industrial na RMC, 2012 a 2021",
      subtitle = paste0("290 observações (29 municípios x 10 anos) com reta de mínimos quadrados; rótulos nos pontos de ",
                        ultimo_ano, " de cinco municípios de destaque"),
      caption  = paste(FONTE_SALARIO, paste(FONTE_RAIS, FONTE_PIB), sep = "\n"),
      theme    = theme(
        plot.title    = element_text(face = "bold", size = 14),
        plot.caption  = element_text(hjust = 0, size = 8, colour = "grey30")
      )
    )

  ggsave(arquivo, grafico, width = 14, height = 7.5, units = "in", dpi = 300, bg = "white")
  arquivo
}


# -----------------------------------------------------------------------------
# 8. Numeração dos municípios, mapas e animações
# A numeração segue a ordem alfabética dos nomes, para a legenda ser fácil de
# consultar [presunção da modelagem]. O mesmo número aparece nos mapas, nas
# animações e na legenda. Cada município é marcado com um círculo de contorno
# preto e fundo branco, com o número em preto, no centroide do polígono.
numerar_municipios <- function(dados) {
  dados |>
    distinct(id_municipio, nome_municipio) |>
    arrange(nome_municipio) |>
    mutate(numero = row_number())
}

# Pontos (centroides) de cada município, em UTM 22S, já com o número.
pontos_municipios <- function(mapa_sf, numeracao) {
  # Centroide só sobre a geometria, para não emitir o aviso de atributos constantes.
  pontos <- sf::st_sf(
    id_municipio = mapa_sf$id_municipio,
    geometry     = sf::st_centroid(sf::st_geometry(mapa_sf))
  ) |>
    inner_join(numeracao, by = "id_municipio")
  if (nrow(pontos) != N_MUNICIPIOS) {
    stop("Os centroides não casam com os 29 municípios da numeração.", call. = FALSE)
  }
  pontos
}

# Camada de marcadores: círculo preto com fundo branco e número preto dentro.
camada_numeros <- function(pontos, tamanho_circulo = 4.2, tamanho_texto = 2.3) {
  list(
    geom_sf(data = pontos, shape = 21, size = tamanho_circulo, fill = "white",
            colour = "black", stroke = 0.6, inherit.aes = FALSE),
    geom_sf_text(data = pontos, aes(label = numero), colour = "black",
                 size = tamanho_texto, fontface = "bold", inherit.aes = FALSE)
  )
}

# Legenda: número e nome dos municípios em faixa horizontal compacta, preenchida por coluna.
painel_legenda <- function(numeracao, colunas = 5, titulo = NULL) {
  linhas <- ceiling(nrow(numeracao) / colunas)
  dados_leg <- numeracao |>
    mutate(coluna = (numero - 1) %/% linhas, linha = (numero - 1) %% linhas, x_marca = coluna * 4 + 0.6)
  g <- ggplot(dados_leg, aes(y = -linha)) +
    geom_point(aes(x = x_marca), shape = 21, size = 4.6, fill = "white", colour = "black", stroke = 0.6) +
    geom_text(aes(x = x_marca, label = numero), size = 2.5, fontface = "bold", colour = "black") +
    geom_text(aes(x = x_marca + 0.4, label = nome_municipio), hjust = 0, size = 3.2, colour = "grey10") +
    scale_x_continuous(limits = c(0, colunas * 4), expand = expansion(0)) +
    scale_y_continuous(expand = expansion(add = 0.6)) +
    theme_void(base_size = 10) +
    theme(plot.margin = margin(2, 6, 2, 6), plot.title = element_text(face = "bold", size = 10.5))
  if (!is.null(titulo)) g <- g + labs(title = titulo)
  g
}

gravar_legenda <- function(dados) {
  arquivo <- file.path(DIR_FIGURAS, "legenda_municipios_rmc.png")
  numeracao <- numerar_municipios(dados)
  grafico <- painel_legenda(numeracao, titulo = "Legenda: número e município")
  ggsave(arquivo, grafico, width = 11, height = 2.7, units = "in", dpi = 300, bg = "white")
  arquivo
}

# Mapa individual de uma variável: barra de cor horizontal abaixo do mapa; escala e seta do norte
# só no primeiro painel.
mapa_individual <- function(mapa_ano, contorno_curitiba, pontos, variavel, titulo,
                            nome_legenda, rotulos, opcao_viridis, primeiro = FALSE) {
  g <- ggplot(mapa_ano) +
    geom_sf(aes(fill = .data[[variavel]]), colour = "grey35", linewidth = 0.12) +
    geom_sf(data = contorno_curitiba, fill = NA, colour = "black", linewidth = 0.9) +
    camada_numeros(pontos) +
    scale_fill_viridis_c(name = nome_legenda, option = opcao_viridis, labels = rotulos,
                         breaks = scales::breaks_pretty(n = 4),
                         guide = guide_colourbar(position = "bottom", title.position = "top", title.hjust = 0.5,
                                                 barwidth = unit(6.5, "cm"), barheight = unit(0.35, "cm"))) +
    labs(title = titulo) +
    theme_void(base_size = 10) +
    theme(
      plot.title      = element_text(face = "bold", size = 11, hjust = 0.5),
      legend.title    = element_text(size = 8.5),
      legend.text     = element_text(size = 8),
      plot.margin     = margin(2, 4, 2, 4)
    )
  if (primeiro) {
    g <- g +
      ggspatial::annotation_scale(location = "bl", width_hint = 0.3, text_cex = 0.6, height = unit(0.15, "cm")) +
      ggspatial::annotation_north_arrow(location = "tr", which_north = "true",
                                        height = unit(0.9, "cm"), width = unit(0.7, "cm"),
                                        style = ggspatial::north_arrow_fancy_orienteering(text_size = 7))
  }
  g
}

plotar_mapas_estaticos <- function(dados, mapa_sf) {
  arquivo <- file.path(DIR_FIGURAS, "mapa1_painel_espacial_rmc.png")
  ultimo_ano <- max(dados$ano)

  mapa_ano <- juntar_malha(dados |> filter(ano == ultimo_ano), mapa_sf)
  contorno_curitiba <- mapa_ano |> filter(id_municipio == COD_CURITIBA)
  if (nrow(contorno_curitiba) != 1) stop("Curitiba não encontrada na malha.", call. = FALSE)

  numeracao <- numerar_municipios(dados)
  pontos <- pontos_municipios(mapa_sf, numeracao)

  especificacao <- tibble::tribble(
    ~variavel,                ~titulo,                                           ~nome_legenda,                 ~rotulos,    ~opcao,
    "salario_medio_real",     "Salário médio real formal",                       "R$ de 2021",                  list(fmt_reais), "C",
    "prop_superior",          "Vínculos com ensino superior completo",           "% dos vínculos",              list(fmt_pct),   "D",
    "dom_industrial",         "Dominância industrial (VAB da indústria)",        "% do VAB total",              list(fmt_pct),   "E",
    "gini_setorial",          "Concentração setorial do emprego (Gini)",         "Índice (0 a 1)",                      list(fmt_num2),  "G"
  )

  mapas <- purrr::pmap(especificacao |> mutate(primeiro = row_number() == 1),
                       function(variavel, titulo, nome_legenda, rotulos, opcao, primeiro) {
    mapa_individual(mapa_ano, contorno_curitiba, pontos, variavel, titulo, nome_legenda,
                    rotulos[[1]], opcao, primeiro)
  })

  grade <- patchwork::wrap_plots(mapas, ncol = 2, nrow = 2)
  grafico <- (grade / painel_legenda(numeracao)) +
    patchwork::plot_layout(heights = c(10.2, 2.1)) +
    patchwork::plot_annotation(
      title    = paste0("Distribuição espacial das variáveis centrais na RMC, ", ultimo_ano),
      subtitle = "29 municípios da Região Metropolitana de Curitiba, numerados (legenda abaixo); contorno preto destaca Curitiba",
      caption  = paste(FONTE_SALARIO, paste(FONTE_RAIS, FONTE_PIB, FONTE_MALHA), sep = "\n"),
      theme    = theme(
        plot.title    = element_text(face = "bold", size = 15, hjust = 0.5),
        plot.subtitle = element_text(size = 10, hjust = 0.5),
        plot.caption  = element_text(hjust = 0, size = 8, colour = "grey30")
      )
    )

  ggsave(arquivo, grafico, width = 12, height = 13.2, units = "in", dpi = 300, bg = "white")
  arquivo
}


# -----------------------------------------------------------------------------
# 9. Animação 1: mapa coroplético do salário médio real, 2012 a 2021, com números
# -----------------------------------------------------------------------------
renderizar_gif_mapa <- function(dados, mapa_sf) {
  arquivo <- file.path(DIR_FIGURAS, "animacao1_mapa_renda_rmc.gif")
  mapa_painel <- juntar_malha(dados, mapa_sf)
  contorno_curitiba <- mapa_sf |> filter(id_municipio == COD_CURITIBA)
  limites <- range(dados$salario_medio_real)
  numeracao <- numerar_municipios(dados)
  pontos <- pontos_municipios(mapa_sf, numeracao)

  grafico <- ggplot(mapa_painel) +
    geom_sf(aes(fill = salario_medio_real), colour = "grey35", linewidth = 0.15) +
    geom_sf(data = contorno_curitiba, fill = NA, colour = "black", linewidth = 0.9) +
    camada_numeros(pontos, tamanho_circulo = 5.4, tamanho_texto = 3.1) +
    scale_fill_viridis_c(name = "Salário médio real\n(R$ de 2021)", option = "C",
                         limits = limites, labels = fmt_reais,
                         breaks = scales::breaks_pretty(n = 3),
                         guide = guide_colourbar(position = "bottom", title.position = "top", title.hjust = 0.5,
                                                 barwidth = unit(8, "cm"), barheight = unit(0.4, "cm"))) +
    labs(
      title    = "Rendimento médio real na RMC, {round(frame_time)}",
      subtitle = "Escala de cor fixa para todos os anos. Contorno preto: Curitiba. Legenda dos números abaixo do mapa.",
      caption  = paste(FONTE_SALARIO, FONTE_MALHA, sep = "\n")
    ) +
    theme_void(base_size = 13) +
    theme(
      plot.title      = element_text(face = "bold", size = 15),
      plot.subtitle   = element_text(size = 10),
      plot.caption    = element_text(hjust = 0, size = 8, colour = "grey30", margin = margin(t = 12)),
      legend.text     = element_text(size = 9),
      legend.margin   = margin(b = 6),
      plot.background = element_rect(fill = "white", colour = NA),
      plot.margin     = margin(10, 10, 10, 10)
    ) +
    gganimate::transition_time(ano) +
    gganimate::ease_aes("linear")

  # Os quadros do mapa são gravados em PNG e recebem, abaixo, a legenda estática de
  # número e município; o GIF é montado com o gifski a partir dos quadros compostos.
  dir_quadros <- tempfile("quadros_mapa_")
  dir.create(dir_quadros)
  on.exit(unlink(dir_quadros, recursive = TRUE), add = TRUE)
  gganimate::animate(
    grafico, renderer = gganimate::file_renderer(dir = dir_quadros, prefix = "q", overwrite = TRUE),
    width = ANIM_LARGURA, height = ANIM_ALTURA, fps = ANIM_FPS, duration = ANIM_DURACAO
  )
  quadros <- sort(list.files(dir_quadros, pattern = "\\.png$", full.names = TRUE))
  if (length(quadros) != ANIM_FPS * ANIM_DURACAO) {
    stop("Número de quadros inesperado: ", length(quadros), call. = FALSE)
  }

  altura_legenda <- 250
  arq_legenda <- file.path(dir_quadros, "legenda_fixa.png")
  ggsave(arq_legenda, painel_legenda(numeracao, colunas = 4), width = ANIM_LARGURA / 100,
         height = altura_legenda / 100, units = "in", dpi = 100, bg = "white")
  img_legenda <- png::readPNG(arq_legenda)[, , 1:3, drop = FALSE]
  if (dim(img_legenda)[2] != ANIM_LARGURA) stop("Largura da legenda diferente da dos quadros.", call. = FALSE)

  quadros_compostos <- file.path(dir_quadros, sprintf("c_%04d.png", seq_along(quadros)))
  for (i in seq_along(quadros)) {
    img <- png::readPNG(quadros[i])[, , 1:3, drop = FALSE]
    png::writePNG(abind_vertical(img, img_legenda), quadros_compostos[i])
  }
  gifski::gifski(quadros_compostos, gif_file = arquivo, width = ANIM_LARGURA,
                 height = ANIM_ALTURA + altura_legenda, delay = 1 / ANIM_FPS, progress = FALSE)
  arquivo
}

# Empilha duas imagens (arrays altura x largura x 3) na vertical.
abind_vertical <- function(topo, base) {
  out <- array(0, dim = c(dim(topo)[1] + dim(base)[1], dim(topo)[2], 3))
  out[seq_len(dim(topo)[1]), , ] <- topo
  out[dim(topo)[1] + seq_len(dim(base)[1]), , ] <- base
  out
}


# -----------------------------------------------------------------------------
# 10. Animação 2: ranking animado do salário médio real por município
# Barras ordenadas do maior para o menor salário em cada ano; cada barra traz o
# número e o nome do município dentro e o valor no fim. Uma cor só, sem escala
# extra, para a leitura ser direta.
# -----------------------------------------------------------------------------
renderizar_gif_ranking <- function(dados) {
  arquivo <- file.path(DIR_FIGURAS, "animacao2_ranking_salario_municipios.gif")
  numeracao <- numerar_municipios(dados)

  barras <- dados |>
    left_join(numeracao, by = c("id_municipio", "nome_municipio")) |>
    group_by(ano) |>
    mutate(posicao = rank(-salario_medio_real, ties.method = "first")) |>
    ungroup() |>
    # Rótulos como fator: o gganimate interpola texto como cor; fator usa transição discreta.
    mutate(rotulo_nome = factor(paste0(numero, "  ", nome_municipio)),
           rotulo_valor = factor(fmt_reais(salario_medio_real)))
  if (any(barras$posicao < 1 | barras$posicao > N_MUNICIPIOS)) {
    stop("Posição de ranking fora do intervalo 1 a 29.", call. = FALSE)
  }

  grafico <- ggplot(barras, aes(group = id_municipio)) +
    geom_rect(aes(xmin = 0, xmax = salario_medio_real,
                  ymin = posicao - 0.42, ymax = posicao + 0.42),
              fill = "#4D4D4D", colour = NA) +
    geom_text(aes(x = 0, y = posicao, label = rotulo_nome),
              hjust = 0, nudge_x = max(dados$salario_medio_real) * 0.01,
              colour = "white", size = 3.4, fontface = "bold") +
    geom_text(aes(x = salario_medio_real, y = posicao, label = rotulo_valor),
              hjust = -0.08, colour = "grey15", size = 3.4) +
    scale_y_reverse(breaks = NULL) +
    scale_x_continuous(labels = fmt_reais, expand = expansion(mult = c(0, 0.18))) +
    labs(
      title    = "Salário médio real por município da RMC, {closest_state}",
      subtitle = "Municípios ordenados do maior para o menor salário em cada ano",
      x        = "Salário médio real (R$ de 2021)",
      y        = NULL,
      caption  = paste(FONTE_SALARIO, FONTE_MALHA, sep = "\n")
    ) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title       = element_text(face = "bold", size = 14),
      plot.subtitle    = element_text(size = 10),
      plot.caption     = element_text(hjust = 0, size = 8, colour = "grey30"),
      panel.grid.major.y = element_blank(),
      panel.grid.minor = element_blank(),
      axis.text.y      = element_blank(),
      plot.background  = element_rect(fill = "white", colour = NA)
    ) +
    # Cada ano fica parado por 4 unidades e a troca de posições dura 1: os rótulos só se
    # sobrepõem na transição curta, e o ano exibido é o do estado mais próximo.
    gganimate::transition_states(ano, transition_length = 1, state_length = 4) +
    gganimate::ease_aes("cubic-in-out")

  animacao <- gganimate::animate(
    grafico, renderer = gganimate::gifski_renderer(),
    width = ANIM_LARGURA, height = ANIM_ALTURA, fps = ANIM_FPS, duration = ANIM_DURACAO
  )
  gganimate::anim_save(arquivo, animation = animacao)
  arquivo
}

# -----------------------------------------------------------------------------
# 11. Orquestração
# -----------------------------------------------------------------------------
# Cada figura roda dentro de tryCatch: a falha de uma não impede as demais.
executar_figura <- function(nome, funcao) {
  message("Gerando ", nome, "...")
  inicio <- Sys.time()
  # Os avisos de cada figura são relatados na hora, com o nome da figura, e
  # silenciados em seguida. Na primeira execução, um aviso das animações
  # guardado para o fim da sessão interrompia o Rscript ao ser impresso
  # ("objeto 'tarefas' não encontrado").
  resultado <- tryCatch(
    withCallingHandlers(
      list(situacao = "ok", arquivo = funcao()),
      warning = function(w) {
        message("  Aviso em ", nome, ": ", conditionMessage(w))
        invokeRestart("muffleWarning")
      }
    ),
    error = function(e) list(situacao = paste("falha:", conditionMessage(e)), arquivo = NA_character_)
  )
  segundos <- as.numeric(difftime(Sys.time(), inicio, units = "secs"))
  tamanho_kb <- if (!is.na(resultado$arquivo) && file.exists(resultado$arquivo)) {
    round(file.size(resultado$arquivo) / 1024, 1)
  } else {
    NA_real_
  }
  tibble::tibble(figura = nome, situacao = resultado$situacao,
                 tamanho_kb = tamanho_kb, segundos = round(segundos, 1))
}

gerar_todas_visualizacoes <- function() {
  if (!dir.exists(DIR_FIGURAS)) dir.create(DIR_FIGURAS, recursive = TRUE)

  dados   <- carregar_painel()
  mapa_sf <- carregar_malha(dados)

  tarefas <- list(
    "fig1_matriz_correlacao.png"                    = function() plotar_matriz_correlacao(dados),
    "fig2_ridgeplot_salario_anos.png"               = function() plotar_ridgeplot_salarios(dados),
    "fig3_dispersao_capital_humano_industria.png"   = function() plotar_dispersoes_principais(dados),
    "mapa1_painel_espacial_rmc.png"                 = function() plotar_mapas_estaticos(dados, mapa_sf),
    "animacao1_mapa_renda_rmc.gif"                  = function() renderizar_gif_mapa(dados, mapa_sf),
    "legenda_municipios_rmc.png"                    = function() gravar_legenda(dados),
    "animacao2_ranking_salario_municipios.gif"      = function() renderizar_gif_ranking(dados)
  )

  placar <- purrr::imap(tarefas, \(funcao, nome) executar_figura(nome, funcao)) |>
    purrr::list_rbind()

  message("\nPlacar da Etapa 3:")
  print(as.data.frame(placar), row.names = FALSE, right = FALSE)
  n_falhas <- sum(placar$situacao != "ok")
  if (n_falhas > 0) {
    warning(n_falhas, " figura(s) falharam; veja o placar acima.")
  } else {
    message("As seis figuras foram gravadas em ", DIR_FIGURAS, ".")
  }
  invisible(placar)
}

gerar_todas_visualizacoes()
