# CONTEXTO E DIRETRIZES DA ETAPA 3
Você é um Cientista de Dados Sênior e Especialista em Visualização e Econometria Espacial em R.
Estamos desenvolvendo a Etapa 3 do trabalho de Econometria I da UFPR.
O objetivo desta etapa é gerar a Análise Exploratória de Dados Espaciais (AEDE), gráficos estáticos de publicação, mapas temáticos coropléticos em alta resolução e ANIMAÇÕES TEMPORAIS EM GIF (`.gif`), ilustrando a dinâmica da renda e das variáveis explicativas na Região Metropolitana de Curitiba (RMC) ao longo do tempo.

NÃO escreva redação de artigo, introduções teóricas ou interpretações textuais longas.
Seu foco é EXCLUSIVAMENTE em código R modular, robusto, de estética visual refinada (padrão publicação acadêmica) e sem marcadores de código incompleto.

---

# 1. ENTRADAS E ARQUITETURA DE ARQUIVOS
- O script deve carregar o painel tratado gerado na Etapa 2:
  `dados_rmc <- readRDS("./dados_processados/dados_painel_rmc.rds")`
- Carregar as geometrias espaciais dos municípios da RMC (salvas na Etapa 1 ou obtidas via `geobr::read_municipality(code_muni = "PR", year = 2020)` filtrando os 29 municípios).
- Criar automaticamente o diretório de saída: `./figuras_graficos/`.
- Todos os gráficos estáticos devem ser exportados em formato `.png` com alta resolução (`dpi = 300`) usando `ggplot2::ggsave()`.
- Todas as animações devem ser renderizadas com o pacote `gifski` e exportadas em formato `.gif`.

---

# 2. ESPECIFICAÇÃO DAS VISUALIZAÇÕES A SEREM GERADAS

### GRÁFICO 1: Matriz de Correlação Gráfica e Dispersões (Diagnóstico Visual Prévio)
- **Pacotes**: `ggplot2`, `GGally` (função `ggpairs()`) ou `corrplot`.
- **Objetivo**: Visualizar as distribuições marginais, coeficientes de correlação de Pearson e gráficos de dispersão bivariados com reta de regressão suave (`geom_smooth(method = "lm")`) entre:
  - `ln_salario_real`
  - `prop_superior`
  - `dom_industrial`
  - `shannon_diversificacao`
  - `selic_real`
  - `dist_curitiba_km`
- **Estética**: Paleta de cores neutra/acadêmica (`viridis` ou `brewer`), títulos de eixos claros em português, valores de correlação com asteriscos de significância (*, **, ***).
- **Arquivo de Saída**: `./figuras_graficos/fig1_matriz_correlacao.png`.

### GRÁFICO 2: Evolução da Distribuição Salarial — Ridgeplot / Densidades Sobrepostas
- **Pacote**: `ggridges`, `ggplot2`.
- **Objetivo**: Demonstrar como a distribuição do salário médio real municipal mudou ao longo dos anos da amostra (2012 a 2021/2022).
- **Especificação**: No eixo Y os anos (como fator/categoria), no eixo X a remuneração real (`salario_medio_real` ou `ln_salario_real`), com curvas de densidade semi-transparentes preenchidas por gradiente térmico (`scale_fill_viridis_c()`).
- **Arquivo de Saída**: `./figuras_graficos/fig2_ridgeplot_salario_anos.png`.

### GRÁFICO 3: Gráficos de Dispersão com Rótulos de Outliers e Regressão
- **Pacotes**: `ggplot2`, `ggrepel`.
- **Objetivo**: Dois painéis (`cowplot` ou `patchwork`):
  - Painel A: `ln_salario_real` vs. `prop_superior` (Capital Humano).
  - Painel B: `ln_salario_real` vs. `dom_industrial` (Dominância Industrial).
- **Regra**: Rotular automaticamente apenas os municípios com valores extremos e de destaque na RMC (ex: Curitiba, Araucária, São José dos Pinhais, Adrianópolis, Doutor Ulysses) usando `ggrepel::geom_text_repel()`.
- **Arquivo de Saída**: `./figuras_graficos/fig3_dispersao_capital_humano_industria.png`.

### MAPA 1: Mapas Coropléticos Estáticos Comparativos (Facetados)
- **Pacotes**: `sf`, `ggplot2`, `patchwork` ou facetamento nativo.
- **Objetivo**: Mapear a distribuição espacial na RMC do último ano da amostra para 4 variáveis centrais em uma grade 2x2:
  1. Rendimento Médio Real Formal.
  2. Proporção de Vínculos com Ensino Superior (%).
  3. Dominância Industrial no PIB (%).
  4. Índice de Entropia de Shannon (Complexidade/Diversificação).
- **Estética**: `theme_void()` com legenda formatada, escala contínua com quebras limpas, contorno dos municípios com linhas finas e destaque do município polo (Curitiba). Incluir barra de escala (`ggspatial::annotation_scale()`) e rosa dos ventos (`ggspatial::annotation_north_arrow()`).
- **Arquivo de Saída**: `./figuras_graficos/mapa1_painel_espacial_rmc.png`.

### ANIMAÇÃO 1 (GIF): Mapa Coroplético Animado da Renda na RMC ao Longo do Tempo
- **Pacotes**: `sf`, `ggplot2`, `gganimate`, `gifski`.
- **Objetivo**: Criar um mapa coroplético dinâmico mostrando a evolução ano a ano do `salario_medio_real` nos 29 municípios da RMC de 2012 a 2021/2022.
- **Especificação Técnica**:
  - `transition_time(ano)` ou `transition_states(ano, transition_length = 2, state_length = 3)`.
  - Título dinâmico: `labs(title = "Evolução Espacial do Rendimento Médio Real na RMC - Ano: {frame_time}")`.
  - Renderização via `gganimate::animate()` especificando: `renderer = gifski_renderer()`, `width = 800`, `height = 700`, `fps = 10`, `duration = 15`.
- **Arquivo de Saída**: `./figuras_graficos/animacao1_mapa_renda_rmc.gif`.

### ANIMAÇÃO 2 (GIF): Scatter Plot Dinâmico com Rastro Temporal (Estilo Gapminder)
- **Pacotes**: `ggplot2`, `gganimate`, `gifski`.
- **Objetivo**: Gráfico de dispersão animado relacionando Dominância Industrial (eixo X) com Rendimento Médio Real (eixo Y), onde o tamanho do ponto representa a massa de vínculos formais e a cor representa a distância até Curitiba.
- **Especificação**: `transition_time(ano)` com rótulo de ano no fundo e rastro (`shadow_wake(wake_length = 0.1, alpha = FALSE)`).
- **Arquivo de Saída**: `./figuras_graficos/animacao2_dispersao_animada_industria_renda.gif`.

---

# 3. REQUISITOS TÉCNICOS E STRICT R STANDARDS

1. **Gestão Silenciosa de Pacotes**:
   - Verificar, instalar se necessário e carregar: `tidyverse`, `sf`, `geobr`, `ggplot2`, `gganimate`, `gifski`, `transformr`, `ggridges`, `ggrepel`, `patchwork`, `viridis`, `ggspatial`, `corrplot`.
2. **Robustez na Manipulação Espacial**:
   - Assegurar que o join entre a tabela `dados_rmc` e os dados espaciais (`sf`) seja feito pela coluna `id_municipio` padronizada como texto de 7 dígitos.
   - Manter a classe `sf` ativa para plotagens do `geom_sf()`.
3. **Tratamento de Animações com Polígonos**:
   - Carregar explicitamente a biblioteca `transformr` (essencial para que o `gganimate` consiga interpolar polígonos `sf` sem gerar erros de topologia).
4. **Funções Modulares**:
   - Encapsular a geração de cada figura em funções limpas:
     - `plotar_matriz_correlacao(dados)`
     - `plotar_ridgeplot_salarios(dados)`
     - `plotar_dispersoes_principais(dados)`
     - `plotar_mapas_estaticos(dados, mapa_sf)`
     - `renderizar_gif_mapa(dados, mapa_sf)`
     - `renderizar_gif_dispersao(dados)`
   - Criar uma função orquestradora: `gerar_todas_visualizacoes()`.
5. **Código 100% Executável**:
   - Proibição de comentários do tipo "... faça o mesmo para o resto". Todas as configurações estéticas, escalas e salvamentos devem ser fornecidos integralmente no script.
