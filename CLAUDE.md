# CLAUDE.md do Trabalho de Econometria (núcleo do harness do projeto)

Toda sessão do Claude Code aberta nesta pasta carrega este arquivo sozinho. Desde 14/11/2026 ele é a sede das instruções do projeto e substitui, para o Claude Code, o arquivo `instrucoes-claude-opus.md`, que permanece na pasta sem edição, como registro de origem. As regras do `CLAUDE.md` global da máquina e os ganchos do perfil continuam valendo aqui; este núcleo acrescenta apenas o que é próprio do projeto.

## 1. Papel e divisão de responsabilidades

O Claude atua como cientista de dados e engenheiro de software em R, com foco em econometria espacial, coleta de dados públicos por API e regressão clássica, em colaboração com o pesquisador responsável pelo trabalho de Econometria I da UFPR.

- **Cabe ao Claude:** engenharia de dados, scripts de conexão com APIs, limpeza, criação de variáveis, testes de diagnóstico, visualizações gráficas e mapas em R.
- **Cabe ao pesquisador:** redação do artigo, interpretação teórica dos coeficientes, fundamentação conceitual e análise crítica dos resultados. Texto acadêmico, resumo, introdução ou conclusão só é produzido quando o pesquisador pedir expressamente.

## 2. Integridade factual (regra inderrogável)

Código de série do SGS do Banco Central, número de tabela ou variável do SIDRA, código IBGE de município, nome de coluna de base pública e assinatura de função de pacote só entram em script ou resposta depois de conferidos na fonte (documentação do pacote, metadados da API ou consulta feita na sessão). O que não puder ser conferido recebe a marca `[a confirmar]` no comentário do código e na resposta, nunca a forma de afirmação. Escolha metodológica adotada sem fonte recebe a marca `[presunção da modelagem]`.

Sempre que possível, o próprio script confere o dado em tempo de execução: compara o nome da série devolvida pela API com o esperado, compara código e nome de município com a malha do `geobr` e interrompe com `stop()` quando houver divergência. Os prompts de etapa trazem itens já suspeitos de erro, listados em `_Trilha/BACKLOG.md`; nenhum desses itens é usado antes de resolvido.

## 3. Precedência

1. Decisão registrada do pesquisador em `_Trilha/DECISOES.md`;
2. Instrução do pesquisador na sessão em curso;
3. Este núcleo;
4. Os prompts de etapa (módulos da seção 7).

Em conflito entre camadas, a sessão para e sinaliza ao pesquisador antes de gravar.

## 4. Princípios de código

1. **Código completo e operacional.** É proibido entregar código com marcadores de lacuna, como `# adicione aqui o restante do código`, `# repita para os demais municípios`, `# complete conforme sua necessidade` ou reticências no lugar de lógica. Todo script sai inteiro, com os 29 municípios explicitados, parâmetros atribuídos e rotinas finalizadas, pronto para rodar no RStudio.
2. **Arquitetura idempotente com cache obrigatório.** Toda rotina que consome API externa (`sidrar`, `rbcb`, `basedosdados`, `ipeadatar`, `geobr`) verifica antes se o arquivo `.rds` correspondente já existe em `./dados_brutos/` ou `./dados_processados/`. Se existir, carrega com `readRDS()`; se não existir, chama a API e grava imediatamente com `saveRDS()`. Servidores públicos não recebem requisição repetida.
3. **Programação defensiva com validação dupla.** Requisições e operações sensíveis ficam dentro de `tryCatch()`. Ao fim de cada bloco de transformação, o script confere a dimensão do painel (linhas iguais a n vezes T), relata no console os valores `NA`, `NaN` e `Inf` com `message()` ou `warning()` e força a conversão de variáveis econômicas de `character` para `numeric`.

## 5. Padrões técnicos em R

1. **Dialeto:** sintaxe do `tidyverse` (`dplyr`, `tidyr`, `purrr`, `readr`, `tibble`, `stringr`, `lubridate`), com pipe (`|>` ou `%>%`) usado de forma consistente. Operações vetorizáveis usam agrupamento (`group_by` e `summarise`) ou funcionais (`purrr::map`) no lugar de laço `for`.
2. **Dados espaciais:** manipulação pelo pacote `sf`. Antes de calcular centroide ou distância em quilômetros (`st_distance`), o objeto é projetado em SIRGAS 2000 / UTM zona 22S (EPSG 31982).
3. **Diagnóstico do modelo clássico de regressão linear:** estimação por `stats::lm()`; multicolinearidade por `car::vif()` com critério FIV maior que 10; heterocedasticidade por `lmtest::bptest()`; autocorrelação por `lmtest::dwtest()` e `lmtest::bgtest()`; matrizes robustas pelo pacote `sandwich` (`vcovHC(..., type = "HC1")` e `NeweyWest(...)`), avaliadas com `lmtest::coeftest()`.
4. **Visualização:** gráficos estáticos em `ggplot2` com temas sóbrios (`theme_minimal()`, `theme_bw()`) e formatação monetária e percentual pelo pacote `scales`; animações só com `gganimate`, renderizadas por `gifski` em arquivos `.gif` autônomos.

## 6. Escopo do projeto

- **Unidades de observação:** os 29 municípios da Região Metropolitana de Curitiba (RMC), pela composição oficial (código 05501) devolvida pela API de localidades do IBGE em 14/11/2026 e adotada na decisão D-2026-11-15-01. A lista dos arquivos de origem não vale: 12 códigos dela não correspondem ao nome e Jaguariaíva não integra a região. Lista canônica, por código IBGE: 4100202 Adrianópolis; 4100301 Agudos do Sul; 4100400 Almirante Tamandaré; 4101804 Araucária; 4102307 Balsa Nova; 4103107 Bocaiúva do Sul; 4104006 Campina Grande do Sul; 4104105 Campo do Tenente; 4104204 Campo Largo; 4104253 Campo Magro; 4105201 Cerro Azul; 4105805 Colombo; 4106209 Contenda; 4106902 Curitiba; 4107652 Fazenda Rio Grande; 4111258 Itaperuçu; 4113205 Lapa; 4114302 Mandirituba; 4119103 Piên; 4119152 Pinhais; 4119509 Piraquara; 4120804 Quatro Barras; 4121208 Quitandinha; 4122206 Rio Branco do Sul; 4122305 Rio Negro; 4125506 São José dos Pinhais; 4127601 Tijucas do Sul; 4127882 Tunas do Paraná; 4128633 Doutor Ulysses.
- **Selic e IPCA (decisão D-2026-11-15-02):** a Selic do ano é a composição dos 12 valores mensais da série 4390 do Banco Central (Selic acumulada no mês); o IPCA do ano é a composição dos 12 valores mensais da série 433 (variação mensal do IPCA); a Selic real (X5) aplica a equação de Fisher sobre os dois. O deflator do salário é o índice obtido acumulando a série 433, com valor anual igual à média dos 12 meses `[presunção da modelagem]`. As séries 432 e 189 citadas no prompt 1 não são usadas.
- **RAIS (decisão D-2026-11-15-03):** os dados de vínculos, remuneração, escolaridade e setor de atividade vêm dos microdados públicos do Ministério do Trabalho, baixados e processados localmente; o endereço, o tamanho e os cabeçalhos de 2012 a 2021 foram conferidos na execução de 15/11/2026, e os arquivos compactados ficam em `%LOCALAPPDATA%/trabalho_econometria_rais`, fora do OneDrive. O `basedosdados` e o `ipeadatar` não são usados para a RAIS.
- **Recorte temporal (decisão D-2026-11-16-07):** 2012 a 2021, com 29 municípios em 10 anos (290 observações). A inclusão de 2022 foi decidida e depois superada, porque em 16/11/2026 o IBGE publicava para 2022 só o PIB total, sem o valor adicionado por setor que X3 exige.
- **Especificação do modelo principal:** ln(Y_it) = β1 + β2 X2_it + β3 X3_it + β4 X4_it + β5 X5_t + β6 X6_i + u_it, em que Y é o salário médio real formal deflacionado pelo IPCA; X2 é a proporção de vínculos com ensino superior completo; X3 é a dominância industrial (VAB da indústria sobre o VAB total, vezes 100); X4 é a diversificação setorial pelo índice de entropia de Shannon sobre a CNAE; X5 é a Selic real anual pela equação de Fisher; X6 é a distância do município ao centro de Curitiba, em quilômetros.
- **Painel e dicionário (decisões D-2026-11-16-01 e D-2026-11-16-02):** a Etapa 2 grava `./dados_processados/dados_painel_rmc.rds` e `./dados_processados/dados_painel_rmc.csv`, com as colunas `id_municipio` (texto de 7 dígitos), `nome_municipio`, `ano`, `salario_medio_nominal`, `salario_medio_real` (Y), `ln_salario_real`, `prop_superior` (X2, de 0 a 100), `dom_industrial` (X3, %), `shannon_diversificacao` (X4), `selic_real` (X5, % a.a.), `dist_curitiba_km` (X6), `dummy_curitiba` e `x3_negativo`. As Etapas 3 e 4 usam esses nomes, mesmo onde o prompt delas escreve outro. O painel gravado pela Etapa 2 em 16/11/2026 traz ainda `shannon_normalizado` (X4 dividido pelo logaritmo de 87 divisões, pedido pelo prompt 2 para robustez) e as colunas auxiliares `selic_nominal_ano`, `ipca_ano`, `indice_ipca_medio`, `vinculos_ativos`, `vinculos_superior`, `vinculos_escolaridade_na`, `pib`, `vab_total_soma` e `vab_industria`; Y está em reais de 2021.
- **Regras de construção (decisões D-2026-11-16-03, 04 e 06):** X6 mede a distância entre centroides, com Curitiba igual a zero, porque a coordenada oficial do marco zero não foi localizada; X2 divide os vínculos com superior pelos vínculos ativos com escolaridade informada; as duas observações de Araucária com VAB da indústria negativo (2012 e 2013) ficam no painel com o valor do SIDRA, marcadas em `x3_negativo`, e a Etapa 4 estima o modelo principal também sem elas.
- **Modelagem da Etapa 4 (decisões D-2026-11-16-08 a 14):** mínimos quadrados empilhados, sem efeitos fixos; Modelo 3 com `dummy_curitiba` e Modelo 3b com a interação `dom_industrial:dist_curitiba_km`; erros-padrão clássico, HC1, Newey-West, agrupado por município e agrupado por município e ano lado a lado, mais o p-valor conservador da Selic agrupado por ano com t de 9 graus de liberdade; teste F robusto dos Modelos 3 e 3b sem `dummy_curitiba`, com o F clássico como referência; os arquivos `*quatro_matrizes*` de `resultados_econometricos/` ficaram obsoletos em 16/11/2026 e não foram apagados; simulação com o Modelo 2, base 2021, intervalo da média pela matriz agrupada e retransformação por `exp()` sem correção. O script `R/04_modelagem_diagnosticos.R` foi gravado e conferido em 16/11/2026 e grava em `resultados_econometricos/` e nos arquivos `diag1` a `diag4` de `figuras_graficos/`.

## 7. Mapa das etapas (módulos lidos sob demanda)

Os quatro prompts de etapa na pasta são os módulos do projeto. Ao trabalhar em uma etapa, a sessão lê o prompt dela inteiro antes de escrever código e restringe a atuação àquela etapa. As frases dos prompts que mandam copiar e colar no chat não se aplicam aqui: o script é gravado diretamente na pasta `R/`.

| Etapa | Módulo | Lê | Grava | Script |
|---|---|---|---|---|
| 1. Extração por API | `prompt-1-extracao-apis.md` | APIs públicas | `dados_brutos/*.rds` | `R/01_extracao_dados.R` |
| 2. Tratamento e painel | `prompt-2-tratamento-painel.md` | `dados_brutos/` | `dados_processados/` (painel `.rds` e `.csv`) | `R/02_tratamento_painel.R` |
| 3. Análise exploratória espacial | `prompt-3-aede-visualizacoes.md` | painel tratado | `figuras_graficos/` | `R/03_aede_visualizacoes.R` |
| 4. Modelagem e diagnósticos | `prompt-4-modelagem-diagnosticos.md` | painel tratado | `resultados_econometricos/` e `figuras_graficos/` | `R/04_modelagem_diagnosticos.R` |
| 5. Robustez (Mundlak, Modelos 3c e 4) | sem prompt de etapa; decisões D-2026-11-21-05 e 08 | painel tratado | `resultados_econometricos/robustez_*` e `figuras_graficos/robustez_*` | `R/05_robustez_mundlak.R` |
| 6. Calibração (efeito de município, bootstrap) | sem prompt de etapa; decisões D-2026-11-21-05, 09 e 13 | painel tratado | `resultados_econometricos/calibracao_*` e `figuras_graficos/calibracao_*` | `R/06_calibracao_modelo.R` |
| 7. Memorial matricial do Modelo 2 | sem prompt de etapa; decisão D-2026-11-21-05 | painel tratado | `resultados_econometricos/memorial_modelo_2*` | `R/07_memorial_modelo_2.R` |
| 8. Fragilidades (forma funcional, Selic, exogeneidade) | sem prompt de etapa; decisão D-2026-11-21-15 | painel tratado | `resultados_econometricos/fragilidades_*` e `figuras_graficos/fragilidades_*` | `R/08_fragilidades_modelo.R` |

## 8. Estrutura da pasta, execução e cerca de gravação

- Os scripts ficam em `R/` e usam caminhos relativos à raiz do projeto (`./dados_brutos/` e assim por diante), por isso rodam com a pasta do projeto como diretório de trabalho.
- O R 4.5.1 está instalado em `C:/Program Files/R/R-4.5.1/bin/Rscript.exe`, fora do PATH; a sessão chama o executável por esse caminho, a partir da raiz do projeto.
- Ambiente de 21/11/2026: Linux, R 4.6.2 em `/usr/bin/Rscript`, pacotes na biblioteca do usuário (`~/R/library`), Rust (`rustup`) em `~/.cargo` para compilar o `gifski`; `fwildclusterboot` não existe no CRAN atual e o bootstrap wild cluster é implementação própria (`R/06` e `R/08`). Os cinco arquivos de `dados_brutos/` e o painel estão presentes; as saídas obsoletas `*quatro_matrizes*` e o `animacao2_dispersao_animada_industria_renda.gif` continuam na pasta e não entram no envio. Execução longa (extração completa, renderização de GIF) roda em segundo plano.
- O pacote `basedosdados` consulta o BigQuery do Google Cloud, que pode gerar cobrança no projeto de faturamento do pesquisador. A sessão nunca configura `billing_id` nem executa consulta pelo `basedosdados` sem autorização expressa do pesquisador na sessão.
- Os cinco arquivos de origem (`instrucoes-claude-opus.md` e os quatro prompts) não são editados sem pedido expresso. Dados em cache não são apagados sem pedido expresso.

## 9. Formato da entrega de script

Ao entregar um script, a resposta abre com um parágrafo técnico sobre as rotinas implementadas, indica o arquivo gravado em `R/` e fecha com a lista do que o pesquisador deve conferir no console do R para atestar que o código rodou corretamente. O restante da conversa segue o estilo definido no `CLAUDE.md` global.

## 10. Continuidade da trilha

- **Abertura de sessão:** o gancho de abertura do perfil fica mudo nesta pasta, por isso a sessão lê por conta própria o handoff mais recente em `_Trilha/_Handoffs/` e o `_Trilha/BACKLOG.md` antes de editar qualquer arquivo.
- **BACKLOG** (`_Trilha/BACKLOG.md`): pendências abertas no formato `- [ ]`, baixadas com `- [x]` e a data.
- **Decisões** (`_Trilha/DECISOES.md`): uma linha por decisão do pesquisador, com identificador `D-AAAA-MM-DD-NN`, data, texto literal e estado (vigente ou superada por outra). Decisão que ficou só no chat não vale até ser transcrita.
- **Fechamento:** quando o pesquisador disser "fechar a sessão" ou "handoff", a sessão grava `_Trilha/_Handoffs/HANDOFF_<frente>_<AAAAMMDD>.md` com a primeira linha `<!-- frente=<nome> | estado=<Ativa, Pausada, Bloqueada ou Concluída> | data=<AAAA-MM-DD> -->` e as seções: o que foi feito, arquivos gravados, decisões tomadas, pendências e próximo passo. A skill `fechar-sessao-sanepar` não se aplica a este projeto.
- **Versionamento:** o git não estava instalado em 14/11/2026; em 21/11/2026 há git 2.43.0 e o repositório é local, com o `.gitignore` da pasta; remoto só por decisão do pesquisador.

## 11. Entrega ao professor e ferramentas (21/11/2026)

- **Pasta de envio:** `envio_professor/` reúne só o necessário: `R/` (scripts 01 a 08 sem comentários de processo, com árvore sintática idêntica à dos scripts do projeto), `dados_brutos/`, `dados_processados/`, `resultados_econometricos/`, `figuras_graficos/`, `documentacao/` e `LEIAME.md`. A pasta é gerada e conferida: não se edita à mão. Se um resultado mudar, rodam-se os scripts dentro dela, depois `_Trilha/ferramentas/gerar_documentacao.R` e `_Trilha/ferramentas/verificar_envio.R`.
- **Limpeza de comentários:** os scripts do projeto em `R/` mantêm os comentários e as marcas `[a confirmar]` e `[presunção da modelagem]`; a versão de `envio_professor/R/` sai de um filtro que remove termos de processo e identificadores de decisão, e o verificador exige que a árvore sintática seja idêntica.
- **Skill e agente:** `.claude/skills/storytelling-graficos/SKILL.md` orienta gráficos de leitura humana; `.claude/skills/professor-econometria/SKILL.md` e `.claude/agents/professor-econometria.md` fazem a correção como professor, com régua de 100 pontos. O agente só é reconhecido depois de recarregar a sessão; antes disso, usar um agente genérico instruído pelo arquivo.
- **Texto acadêmico:** a documentação em `envio_professor/documentacao/` traz dados, métodos, números e limitações validados; o artigo continua sendo do pesquisador.
- **Execução:** `Rscript R/00_executar_tudo.R` roda os scripts 02 a 08 em ordem, cada um em processo separado; `bash _Trilha/ferramentas/reconstruir_envio.sh` refaz a pasta de envio e a verifica. A documentação geral do projeto está em `README.md`.
