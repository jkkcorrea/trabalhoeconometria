# PROMPT 1: Extração Automatizada de Dados via APIs em R (Etapa 1 de 4)

> **Instruções de Uso:** Copie todo o conteúdo deste bloco e envie diretamente ao Claude Opus após carregar as diretrizes de comportamento do arquivo `instrucoes-claude-opus.md`.

---

```markdown
# CONTEXTO E DIRETRIZES OPERACIONAIS
Você é um Cientista de Dados Sênior especializado em Econometria e Programação em R.
Estamos desenvolvendo a infraestrutura computacional de um trabalho empírico para a disciplina de Econometria I da Universidade Federal do Paraná (UFPR).
O objetivo é coletar dados públicos via APIs no R para analisar a economia dos 29 municípios da Região Metropolitana de Curitiba (RMC) no período de 2012 a 2021 (ou 2022).

NÃO gere textos de redação acadêmica, resumos, artigos, justificativas teóricas ou conclusões.
Seu foco é EXCLUSIVAMENTE em engenharia de código em R: robusto, modular, elegantemente comentado, defensivo, auditável e à prova de falhas de conexão.

---

# 1. ESCOPO ESPACIAL E TEMPORAL
A base de dados é composta estritamente pelos 29 municípios oficiais da Região Metropolitana de Curitiba (RMC), identificados pelos seguintes códigos IBGE (7 dígitos):
- 4100400 (Almirante Tamandaré), 4101804 (Araucária), 4102901 (Balsa Nova), 4103107 (Bocaiúva do Sul),
- 4104006 (Campina Grande do Sul), 4104204 (Campo do Tenente), 4104253 (Campo Largo), 4104303 (Campo Magro),
- 4105201 (Cerro Azul), 4105805 (Colombo), 4106209 (Contenda), 4106902 (Curitiba - Polo Metropolitano),
- 4107538 (Doutor Ulysses), 4107652 (Fazenda Rio Grande), 4111258 (Itaperuçu), 4113205 (Lapa),
- 4114302 (Mandirituba), 4119152 (Pinhais), 4119509 (Piraquara), 4120804 (Quatro Barras),
- 4122206 (Rio Branco do Sul), 4122305 (Rio Negro), 4125506 (São José dos Pinhais), 4127601 (Tijucas do Sul),
- 4127882 (Adrianópolis), 4100202 (Agudos do Sul), 4101101 (Quitandinha), 4118501 (Pien),
- 4112108 (Jaguariaíva / conformação regional de controle).

Recorte Temporal: Anos de 2012 a 2021 (ou 2022, caso PIB municipal e RAIS estejam consolidados).

---

# 2. ESPECIFICAÇÃO DAS FONTES E APIs A SEREM COLETADAS

Implemente rotinas autônomas, modulares e blindadas por blocos `tryCatch` para consultar as seguintes fontes oficiais:

### A. IBGE / SIDRA (Pacote: `sidrar`)
- Tabela: 5938 (Produto Interno Bruto dos Municípios a preços correntes).
- Variáveis a extrair para cada um dos 29 municípios e cada ano:
  1. Valor Adicionado Bruto da Agropecuária a preços correntes (R$ mil).
  2. Valor Adicionado Bruto da Indústria a preços correntes (R$ mil).
  3. Valor Adicionado Bruto dos Serviços, exclusive administração pública (R$ mil).
  4. Valor Adicionado Bruto da Administração, Defesa, Educação e Saúde Públicas (R$ mil).
  5. Impostos sobre produtos líquidos de subsídios a preços correntes (R$ mil).
  6. Produto Interno Bruto Total a preços correntes (R$ mil).
- A requisição da API SIDRA deve ser construída e paginada/dividida caso necessário para evitar limites de payload do servidor do IBGE, retornando um `tibble` estruturado com identificador do município, ano e os valores numéricos limpos.

### B. Banco Central do Brasil / SGS (Pacote: `rbcb`)
- Coletar séries temporais de frequência anual (ou mensal agregada):
  1. Série 432: Taxa de juros - Selic acumulada no ano (% a.a.).
  2. Série 433: Índice Nacional de Preços ao Consumidor Amplo (IPCA) acumulado no ano (% a.a.).
  3. Série 189: Índice de preços ao consumidor (IPCA - número índice dez/1993 = 100), necessário para o deflacionamento posterior da massa salarial e valores correntes a preços constantes do último ano.
- Intervalo: 2012-01-01 a 2022-12-31.

### C. Mercado de Trabalho Formal e Escolaridade (MTE / RAIS)
- Estratégia de Coleta via API:
  1. Opção Primária (`basedosdados`):
     - Forneça a query SQL via `basedosdados::read_sql()` consultando a tabela `basedosdados.br_me_rais.microdados_vinculos`.
     - Filtre por `sigla_uf = 'PR'` e pelos códigos dos 29 municípios da RMC para anos >= 2012.
     - Agregue por `ano` e `id_municipio`, calculando:
       - Remuneração média mensal nominal dos trabalhadores formais.
       - Total de trabalhadores com Ensino Superior completo ou pós-graduação (`grau_instrucao_apos_2005 >= 9`).
       - Total geral de vínculos formais ativos.
       - Contagem/proporção de vínculos por divisão ou seção da CNAE 2.0 (essencial para o cômputo da diversificação setorial via Índice de Shannon na Etapa 2).
  2. Opção Secundária (Fallback Defensivo via `ipeadatar` / tabelas agregadas do IBGE):
     - Crie uma rotina de contingência: caso o usuário não tenha um `billing_id` configurado no Google Cloud Platform (`basedosdados::set_billing_id()`), o código deve emitir um `warning()` explicativo e acionar uma rotina alternativa via `ipeadatar` para baixar o emprego formal e a massa salarial municipal agregada sem interromper o script.

### D. Geoprocessamento e Distâncias Espaciais (Pacotes: `geobr` e `sf`)
- Baixar a malha vetorial municipal oficial do Paraná via `geobr::read_municipality(code_muni = "PR", year = 2020)`.
- Filtrar estritamente os 29 municípios da RMC e converter o Sistema de Referência de Coordenadas (CRS) para projeção métrica adequada (SIRGAS 2000 / UTM zone 22S - EPSG: 31982).
- Extrair o centroide geométrico de Curitiba (Marco Zero / Praça Tiradentes) e os centroides dos outros 28 municípios.
- Calcular a distância geodésica em quilômetros (`sf::st_distance`) de cada município até o marco zero de Curitiba.

---

# 3. REQUISITOS TÉCNICOS E QUALIDADE DO CÓDIGO (STRICT R STANDARDS)

1. **Automação de Dependências:**
   - O script deve iniciar com um bloco que verifica se os pacotes necessários estão instalados (`tidyverse`, `sidrar`, `rbcb`, `ipeadatar`, `basedosdados`, `geobr`, `sf`, `lubridate`, `fs`). Se faltar algum pacote, deve instalar e carregar em modo silencioso (`suppressPackageStartupMessages`).
2. **Arquitetura Modular em Funções Puras:**
   - Crie uma função dedicada para cada fonte de dados:
     - `get_pib_sidra(cod_municipios, anos)`
     - `get_macro_bacen(anos)`
     - `get_rais_data(cod_municipios, anos, billing_id = NULL)`
     - `get_spatial_data(cod_municipios)`
   - Crie uma função orquestradora: `executar_extracao_completa(anos = 2012:2021)`.
3. **Persistência em Cache e Prevenção de Sobrecarga de APIs:**
   - Crie um diretório local `./dados_brutos/`.
   - Antes de cada requisição via API, o código deve verificar se o respectivo arquivo `.rds` já existe localmente. Se existir, carrega com `readRDS()`. Caso contrário, executa a chamada na API e salva com `saveRDS()`.
4. **Validação e Auditoria Dupla dos Dados Brutos:**
   - Cada função deve conter validações defensivas no final da sua execução:
     - Checagem de dimensionalidade esperada (número de municípios × número de anos).
     - Relatório no console exibindo a contagem de valores ausentes (`NA`) por coluna.
     - Confirmação de tipos de dados (garantir que colunas numéricas não venham como `character`).
5. **Legibilidade e Comentários:**
   - Utilize a sintaxe moderna do R (`|>` ou `%>%`).
   - Comentários cirúrgicos em cada bloco explicando o propósito técnico da chamada.
6. **Zero Placeholders:**
   - Não use atalhos como `# adicione o restante aqui`, `...` ou omissões. O código deve ser entregue 100% completo e pronto para ser executado via Copy & Paste no RStudio.
```
