# CONTEXTO E DIRETRIZES GERAIS
Você é um Cientista de Dados Sênior especializado em Econometria e Manipulação de Dados em R.
Estamos na **ETAPA 2** da construção da infraestrutura computacional do trabalho empírico para a disciplina de Econometria I da Universidade Federal do Paraná (UFPR).

A Etapa 1 coletou e persistiu os dados brutos na pasta local `./dados_brutos/`.
Seu objetivo nesta **ETAPA 2** é EXCLUSIVAMENTE desenvolver um script em R robusto, modular, elegantemente comentado e testável para:
1. Carregar os dados brutos salvos (`.rds`).
2. Executar toda a engenharia de variáveis, tratamentos, deflacionamentos e cálculos matemáticos específicos (Índice de Shannon, Dominância Industrial, Selic Real e Distâncias).
3. Consolidar um **Painel Mestre Balanceado** (`dados_painel_rmc.rds`) com as $N = 29$ cidades da RMC e $T$ anos (2012 a 2021/2022).
4. Gerar estatísticas descritivas completas e matriz de correlação preliminar para auditoria econométrica.

NÃO gere redação acadêmica, resumos de literatura ou textos interpretativos.
Seu foco é 100% em código em R de alto padrão, auditável e sem placeholders.

---

# 1. ESCOPO DAS VARIÁVEIS E FÓRMULAS DE ENGENHARIA DE DADOS

O script deve carregar os objetos brutos e aplicar rigorosamente as seguintes transformações:

### A. Deflacionamento e Transformação da Variável Dependente ($Y$)
- **Rendimento Médio Real do Trabalho Formal ($W_{it}^{\text{real}}$):**
  Deflacionar a remuneração nominal utilizando o número-índice do IPCA (Série 189 do BACEN) trazendo todos os valores para preços constantes do último ano da amostra ($T_{\text{max}}$):
  $$W_{it}^{\text{real}} = W_{it}^{\text{nominal}} \times \left( \frac{\text{IPCA}_{T_{\text{max}}}}{\text{IPCA}_t} \right)$$
- **Transformação Logarítmica:**
  Calcular $\ln(Y_{it}) = \ln(W_{it}^{\text{real}})$.
  *Propósito econométrico:* Linearizar a relação, estabilizar a variância dos resíduos contra heterocedasticidade severa causada pelos polos econômicos (Curitiba e Araucária) e permitir interpretações em semi-elasticidade.

### B. Variável $X_2$: Capital Humano / Escolaridade Superior
- **Proporção de Emprego com Nível Superior ($X_{2,it}$):**
  $$X_{2,it} = \left( \frac{\text{Vínculos com Ensino Superior Completo ou Pós}_{it}}{\text{Total de Vínculos Formais Ativos}_{it}} \right) \times 100$$
  *Formatação:* Variável expressa em percentual (0 a 100%).

### C. Variável $X_3$: Dominância Industrial no PIB Municipal
- **Participação do VAB da Indústria no VAB Total ($X_{3,it}$):**
  A partir da Tabela 5938 do SIDRA:
  $$\text{VAB Total}_{it} = \text{VAB Agro}_{it} + \text{VAB Ind}_{it} + \text{VAB Serv}_{it} + \text{VAB Adm Pública}_{it}$$
  $$X_{3,it} = \left( \frac{\text{VAB Indústria}_{it}}{\text{VAB Total}_{it}} \right) \times 100$$
  *Nota de auditoria:* Verificar se $(\text{VAB Total}_{it} + \text{Impostos Líquidos}_{it}) \approx \text{PIB Total}_{it}$.

### D. Variável $X_4$: Complexidade e Diversificação Setorial (Índice de Shannon-Wiener)
- **Cálculo da Entropia de Shannon nas Classes/Divisões CNAE ($X_{4,it}$):**
  A partir da contagem de empregos formais por divisão/seção CNAE ($s = 1, \dots, S$) no município $i$ e ano $t$:
  1. Proporção do emprego no setor $s$:
     $$p_{s,it} = \frac{E_{s,it}}{\sum_{k=1}^S E_{k,it}}$$
  2. Índice de Entropia de Shannon:
     $$H_{it} = - \sum_{s=1}^S \left[ p_{s,it} \cdot \ln(p_{s,it}) \right]$$
     *Tratamento matemático:* Caso $p_{s,it} = 0$, atribuir convencionalmente $0 \cdot \ln(0) = 0$.
  3. Adicionar também o cálculo do Índice Normalizado ($H_{\text{norm}} = \frac{H_{it}}{\ln(S)}$) para checagens de robustez.

### E. Variável $X_5$: Ciclo Macroeconômico / Taxa Selic Real Anual
- **Equação de Fisher Ex-Post ($X_{5,t}$):**
  A partir das taxas percentuais anuais da Selic ($i_t$) e do IPCA ($\pi_t$):
  $$r_t = \left( \frac{1 + i_t/100}{1 + \pi_t/100} - 1 \right) \times 100$$
  *Propósito econométrico:* Variável puramente temporal invariante entre municípios em cada ano $t$.

### F. Variável $X_6$: Centralidade Espacial / Distância a Curitiba
- **Distância Geodésica Euclidiana ao Polo ($X_{6,i}$):**
  Calcular a distância geodésica em quilômetros entre o centroide de cada município e o centroide de Curitiba utilizando o CRS SIRGAS 2000 / UTM zone 22S (EPSG: 31982) via `sf::st_distance()`:
  $$X_{6,i} = \frac{\text{distância em metros}}{1000}$$
  *Propósito econométrico:* Variável puramente transversal invariante no tempo para cada município $i$ (Curitiba $= 0,0$ km).

---

# 2. DIRETRIZES ESTRITAS DE ARQUITETURA DE CÓDIGO (R STANDARDS)

1. **Gestão de Dependências:**
   - Carregar em modo silencioso: `tidyverse` (`dplyr`, `tidyr`, `readr`, `purrr`), `sf`, `fs`, `skimr`, `corrplot`.
2. **Modularização Funcional:**
   - Crie funções puras e encadeadas:
     - `tratar_dados_macro(dados_bacen_raw)`
     - `tratar_dados_pib(dados_sidra_raw)`
     - `tratar_dados_mercado_trabalho(dados_rais_raw)`
     - `tratar_dados_espaciais(dados_geobr_raw)`
     - `consolidar_painel_mestre(df_macro, df_pib, df_rais, df_geo)`
     - `auditar_painel(df_painel)`
3. **Tratamento de Exceções e Auditoria Dupla dos Dados:**
   - Implementar checagens com alertas assertivos (`stopifnot` ou `warning`):
     - Conferir se todas as 29 cidades possuem exatamente a mesma grade de anos (painel estritamente balanceado: $N \times T$ linhas).
     - Relatório de valores faltantes (`NA`, `NaN`, `Inf`) por variável tratada.
     - Detecção de inconsistências (ex: percentuais negativos ou superiores a 100% em $X_2$ ou $X_3$).
4. **Persistência do Painel Processado:**
   - Criar o diretório `./dados_processados/`.
   - Salvar o painel limpo final em formatos duplos:
     - `./dados_processados/dados_painel_rmc.rds` (formato binário otimizado para R).
     - `./dados_processados/dados_painel_rmc.csv` (formato aberto com codificação UTF-8).
5. **Sumário Estatístico e Matriz de Correlação Pré-Regressão:**
   - Gerar uma tabela com as estatísticas descritivas clássicas (Média, Desvio Padrão, Mediana, Mínimo e Máximo) para todas as variáveis do modelo.
   - Calcular e exibir no console a Matriz de Correlação de Pearson entre as variáveis explicativas ($X_2, X_3, X_4, X_5, X_6$), permitindo uma primeira checagem visual de riscos de multicolinearidade antes da modelagem econométrica formal.

Gere o código completo, sem omissões de blocos, sem placeholders e pronto para execução direta no RStudio.
