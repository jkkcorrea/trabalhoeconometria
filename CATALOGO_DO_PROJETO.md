# Catálogo do projeto

Gerado por `_Trilha/ferramentas/gerar_catalogo.R` em 23/11/2026. Não edite à mão: rode o script de novo.

Projeto: salário médio real formal nos 29 municípios da Região Metropolitana de Curitiba, 2012 a 2021 (290 observações), Econometria I, UFPR.

## Números do projeto

- Scripts em `R/`: 9.
- Figuras e animações em `envio_professor/figuras_graficos/`: 12 arquivos.
- Arquivos em `envio_professor/resultados_econometricos/`: 22.
- Decisões registradas em `_Trilha/DECISOES.md`: 62 (vigentes na última coluna: 53).
- Pendências em `_Trilha/BACKLOG.md`: 28 abertas e 39 baixadas.

## Onde começar

1. `SUMARIO_DO_PROJETO.md` (uma página).
2. `instrucoes_ia/LEIA_PRIMEIRO.md` (regras para quem usa IA no projeto).
3. `envio_professor/documentacao/00_resumo.md` (resultados validados).

## Raiz do projeto

Arquivos soltos na raiz (instruções, guias e documentos do projeto).

| Arquivo | Tamanho | O que contém |
|---|---|---|
| `CATALOGO_DO_PROJETO.md` | 14 KB | Markdown: Catálogo do projeto |
| `CLAUDE.md` | 18 KB | Markdown: CLAUDE.md do Trabalho de Econometria (núcleo do harness do projeto) |
| `CONTRIBUIR.md` | 10 KB | Markdown: Como baixar e contribuir com o projeto |
| `Gujarati_Basic_Econometrics.pdf` | 6.0 MB |  |
| `R` | 4 KB |  |
| `README.md` | 5 KB | Markdown: Salário médio real formal na Região Metropolitana de Curitiba, 2012 a 2021 |
| `RESPOSTA_AO_PROFESSOR.txt` | 7 KB | Texto simples |
| `REVISAO_PELOS_COLEGAS.md` | 5 KB | Markdown: Revisão pelos colegas: artigo, slides e roteiro |
| `SUMARIO_DO_PROJETO.md` | 5 KB | Markdown: Sumário do projeto |
| `Trabalhos Referencias` | 4 KB |  |
| `_Trilha` | 4 KB |  |
| `apresentacao` | 4 KB |  |
| `artigo` | 4 KB |  |
| `backup_antes_alteracoes` | 4 KB |  |
| `dados_brutos` | 4 KB |  |
| `dados_processados` | 4 KB |  |
| `envio_professor` | 4 KB |  |
| `envio_professor.zip` | 5.6 MB |  |
| `figuras_graficos` | 4 KB |  |
| `fontes` | 4 KB |  |
| `hoffmann2006_cap17_desiguald.pdf` | 18.3 MB |  |
| `instrucoes-claude-opus.md` | 8 KB | Markdown: INSTRUÇÕES DE SISTEMA E COMPORTAMENTO (SYSTEM PROMPT) — CLAUDE OPUS |
| `instrucoes_ia` | 4 KB |  |
| `pdfcoffee.com_328786889-econometria-basica-gujarati-pdfpdf-7-pdf-free.pdf` | 24.1 MB |  |
| `prompt-1-extracao-apis.md` | 7 KB | Markdown: PROMPT 1: Extração Automatizada de Dados via APIs em R (Etapa 1 de 4) |
| `prompt-2-tratamento-painel.md` | 6 KB | Markdown: CONTEXTO E DIRETRIZES GERAIS |
| `prompt-3-aede-visualizacoes.md` | 7 KB | Markdown: CONTEXTO E DIRETRIZES DA ETAPA 3 |
| `prompt-4-modelagem-diagnosticos.md` | 8 KB | Markdown: PROMPT 4: MODELAGEM ECONOMÉTRICA, BATERIA DE DIAGNÓSTICOS DO MCRL E INFERÊNCIA ROBUSTA (UFPR) |
| `resultados_econometricos` | 4 KB |  |
| `roteiro_powerpoint.docx` | 32 KB |  |
| `se305_medidasdesigualdade_.pdf` | 464 KB |  |

## Scripts do projeto (`R/`, com comentários de processo)

| Arquivo | Tamanho | O que contém |
|---|---|---|
| `00_executar_tudo.R` | 2 KB | Script R: Uso, a partir da raiz do projeto:  Rscript R/00_executar_tudo.R |
| `01_extracao_dados.R` | 48 KB | Script R |
| `01b_extracao_pam.R` | 4 KB | Script R: Etapa 1b: produção agrícola municipal (PAM), valor da produção, dos 29 municípios |
| `02_tratamento_painel.R` | 32 KB | Script R: Etapa 2: tratamento dos dados brutos e construção do painel mestre |
| `03_aede_visualizacoes.R` | 38 KB | Script R: Etapa 3: análise exploratória espacial e visualizações |
| `04_modelagem_diagnosticos.R` | 11 KB | Script R: Etapa 4: modelo principal (MQO empilhado) e diagnósticos ensinados |
| `05_autocorrelacao_municipios.R` | 7 KB | Script R: Etapa 5: autocorrelação dos resíduos, por município (testes paramétricos) |
| `06_especificacao_chow.R` | 14 KB | Script R: Etapa 6: especificação, estabilidade estrutural e previsão do modelo principal |
| `07_memorial_modelo_2.R` | 15 KB | Script R: Etapa 7: memorial de cálculo matricial do Modelo 2 |

## Instruções para IA (`instrucoes_ia/`)

Prompts e regras para os colegas que usam IA. Não contêm texto do artigo.

| Arquivo | Tamanho | O que contém |
|---|---|---|
| `LEIA_PRIMEIRO.md` | 4 KB | Markdown: Leia primeiro: regras para usar IA neste projeto |
| `PROMPT_ARTIGO.md` | 8 KB | Markdown: Prompt para construir o artigo, seção por seção |
| `PROMPT_SLIDES.md` | 6 KB | Markdown: Prompt para construir a apresentação de slides |
| `VERIFICACAO_CONTEUDO.md` | 4 KB | Markdown: Verificação: o texto bate com o código? |
| `roteiro_powerpoint.md` | 9 KB | Markdown |

## Skills (`.claude/skills/`)

Cada skill é uma pasta com `SKILL.md`.

| Arquivo | Tamanho | O que contém |
|---|---|---|
| `boas-praticas-programacao/SKILL.md` | 3 KB | Markdown: Boas práticas de programação (R) neste projeto |
| `diagramacao-projeto/SKILL.md` | 3 KB | Markdown: Diagramação do projeto |
| `economia-de-tokens/SKILL.md` | 2 KB | Markdown: Economia de tokens |
| `escrita-cientifica/SKILL.md` | 3 KB | Markdown: Boas práticas de escrita científica (artigo de Econometria) |
| `estrutura-artigo-ufpr/SKILL.md` | 4 KB | Markdown: Estrutura de artigo de periódico no padrão UFPR |
| `formatacao-abnt/SKILL.md` | 7 KB | Markdown: Formatação ABNT para o artigo |
| `maximizacao-de-contexto/SKILL.md` | 2 KB | Markdown: Maximizar o contexto útil |
| `professor-econometria/SKILL.md` | 4 KB | Markdown: Correção do trabalho como professor de Econometria I |
| `storytelling-graficos/SKILL.md` | 6 KB | Markdown: Storytelling com gráficos estatísticos (orientado à leitura humana) |
| `sumario-do-projeto/SKILL.md` | 2 KB | Markdown: Sumário e catálogo do projeto |

## Agentes (`.claude/agents/`)

| Arquivo | Tamanho | O que contém |
|---|---|---|
| `construtor-artigo.md` | 2 KB | Markdown |
| `designer-storytelling-slides.md` | 2 KB | Markdown |
| `professor-econometria.md` | 2 KB | Markdown |

## Ferramentas (`_Trilha/ferramentas/`)

| Arquivo | Tamanho | O que contém |
|---|---|---|
| `conferir_numeros.R` | 4 KB | Script R: Uso (na raiz do projeto): Rscript _Trilha/ferramentas/conferir_numeros.R rascunho.md |
| `gerar_catalogo.R` | 6 KB | Script R: Gera CATALOGO_DO_PROJETO.md a partir do conteúdo real das pastas. |
| `gerar_documentacao.R` | 24 KB | Script R: Gera envio_professor/documentacao/ e envio_professor/LEIAME.md a partir dos resultados do modelo principal. |
| `limpar_comentarios.R` | 8 KB | Script R |
| `reconstruir_envio.sh` | 2 KB | Script de shell |
| `verificar_envio.R` | 17 KB | Script R: Uso (raiz do projeto): Rscript _Trilha/ferramentas/verificar_envio.R |

## Trilha de decisões e handoffs (`_Trilha/`)

| Arquivo | Tamanho | O que contém |
|---|---|---|
| `HANDOFF_artigo-slides_20261123.md` | 4 KB | Markdown: HANDOFF: artigo, slides e roteiro para apreciação dos colegas (23/11/2026) |
| `HANDOFF_calibracao-envio_20261121.md` | 5 KB | Markdown: HANDOFF: calibração do modelo, fragilidades e pasta de envio (21/11/2026) |
| `HANDOFF_implantacao-harness_20261114.md` | 1 KB | Markdown: Handoff da frente de implantação do harness (14/11/2026) |
| `HANDOFF_vscode_20261121.md` | 5 KB | Markdown: HANDOFF — retomada no VS Code (21/11/2026) |
| `PROMPT_claude_code_vscode.md` | 3 KB | Markdown: Prompt para o Claude Code no VS Code — retomada do projeto "trabalho econometria" |

## Pasta de envio: scripts (`envio_professor/R/`)

Gerada; não editar à mão.

| Arquivo | Tamanho | O que contém |
|---|---|---|
| `00_executar_tudo.R` | 2 KB | Script R: Uso, a partir da raiz do projeto:  Rscript R/00_executar_tudo.R |
| `01_extracao_dados.R` | 36 KB | Script R |
| `01b_extracao_pam.R` | 4 KB | Script R: Etapa 1b: produção agrícola municipal (PAM), valor da produção, dos 29 municípios |
| `02_tratamento_painel.R` | 29 KB | Script R |
| `03_aede_visualizacoes.R` | 35 KB | Script R |
| `04_modelagem_diagnosticos.R` | 10 KB | Script R |
| `05_autocorrelacao_municipios.R` | 6 KB | Script R: Etapa 5: autocorrelação dos resíduos, por município (testes paramétricos) |
| `06_especificacao_chow.R` | 14 KB | Script R: Etapa 6: especificação, estabilidade estrutural e previsão do modelo principal |
| `07_memorial_modelo_2.R` | 15 KB | Script R: Etapa 7: memorial de cálculo matricial do Modelo 2 |

## Pasta de envio: dados processados

| Arquivo | Tamanho | O que contém |
|---|---|---|
| `dados_painel_rmc.csv` | 83 KB | CSV, 290 linhas x 23 colunas: id_municipio, nome_municipio, ano, salario_medio_nominal, salario_medio_real, ln_salario_real, prop_superior, dom_industrial, … |
| `dados_painel_rmc.rds` | 23 KB | Objeto R serializado (.rds) |
| `estatisticas_descritivas.csv` | 821 B | CSV, 7 linhas x 7 colunas: variavel, n, media, desvio_padrao, mediana, minimo, maximo |
| `matriz_correlacao_explicativas.csv` | 577 B | CSV, 5 linhas x 6 colunas: variavel, prop_superior, dom_industrial, gini_setorial, selic_real, dist_curitiba_km |

## Pasta de envio: resultados econométricos

| Arquivo | Tamanho | O que contém |
|---|---|---|
| `anova_f_modelo.csv` | 178 B | CSV, 1 linhas x 7 colunas: modelo, estatistica_f, gl_numerador, gl_denominador, p_valor, r2, r2_ajustado |
| `autocorrelacao_por_municipio.csv` | 10 KB | CSV, 29 linhas x 13 colunas: id_municipio, nome_municipio, n, durbin_watson, decisao_dw_tabela, rho_auxiliar, breusch_godfrey_estatistica, breusch_godfrey_gl, … |
| `autocorrelacao_resumo.csv` | 162 B | CSV, 1 linhas x 8 colunas: municipios, durbin_watson_mediano, rho_auxiliar_mediano, dw_positiva, dw_inconclusiva, dw_nao_rejeita, dw_negativa, breusch_godfrey_rejeita |
| `chow_quebra_periodo.csv` | 721 B | CSV, 2 linhas x 12 colunas: modelo, corte, teste, hipotese_nula, hipotese_alternativa, n1, n2, k, … |
| `coeficientes_modelos.csv` | 2 KB | CSV, 12 linhas x 10 colunas: modelo, matriz, termo, estimativa, erro_padrao, estatistica_t, p_valor, ic_inf_95, … |
| `efeito_selic_m2.csv` | 275 B | CSV, 1 linhas x 9 colunas: termo, efeito_ln_por_pp, efeito_percentual_por_pp, ic95_inf_ln, ic95_sup_ln, gl, p_valor, fator_correcao_vies, … |
| `especificacao_lm_tendencia.csv` | 334 B | CSV, 1 linhas x 8 colunas: modelo, teste, hipotese_nula, hipotese_alternativa, estatistica, gl, p_valor, decisao_5pct |
| `especificacao_reset.csv` | 353 B | CSV, 1 linhas x 8 colunas: modelo, teste, hipotese_nula, hipotese_alternativa, estatistica_f, gl, p_valor, decisao_5pct |
| `medida_gini_checagem.csv` | 145 B | CSV, 3 linhas x 2 colunas: indicador, valor |
| `memorial_modelo_2.txt` | 11 KB | Texto simples |
| `memorial_modelo_2_anova.csv` | 299 B | CSV, 3 linhas x 7 colunas: fonte, graus_liberdade, soma_quadrados, quadrado_medio, estatistica_f, F_critico_5pct, p_valor |
| `memorial_modelo_2_coeficientes.csv` | 1000 B | CSV, 6 linhas x 8 colunas: termo, estimativa, erro_padrao_classico, estatistica_t, p_valor, ic_inf_95, ic_sup_95, graus_liberdade |
| `memorial_modelo_2_determinacao_parcial.csv` | 802 B | CSV, 5 linhas x 4 colunas: variavel, estatistica_t, r2_parcial, leitura |
| `memorial_modelo_2_f_incremental.csv` | 628 B | CSV, 4 linhas x 8 colunas: bloco, restricoes, SQR_restrito, SQR_irrestrito, estatistica_f, F_critico_5pct, p_valor, decisao |
| `memorial_modelo_2_fiv.csv` | 613 B | CSV, 5 linhas x 5 colunas: variavel, R2_auxiliar, tolerancia, fiv, decisao |
| `memorial_modelo_2_previsao.csv` | 323 B | CSV, 2 linhas x 6 colunas: cenario, ln_previsto, ic_media_inf, ic_media_sup, ic_individual_inf, ic_individual_sup |
| `normalidade_residuos.csv` | 336 B | CSV, 1 linhas x 10 colunas: modelo, teste, hipotese_nula, hipotese_alternativa, estatistica, gl, p_valor, decisao_5pct, … |
| `projecao_selic_m2.csv` | 16 KB | CSV, 87 linhas x 11 colunas: cenario, selic, id_municipio, nome_municipio, ln_previsto, salario_previsto_sem_correcao, salario_previsto_corrigido, ic_media_inf_ln, … |
| `robustez_porte_e_negativos.csv` | 2 KB | CSV, 13 linhas x 8 colunas: especificacao, n, termo, coeficiente, erro_padrao_white, p_valor, r2_ajustado, cor_gini_ln_vinculos |
| `robustez_x4_definicao_gini.csv` | 372 B | CSV, 2 linhas x 7 colunas: modelo, definicao_x4, coef_x4, p_valor_x4, r2_ajustado, aic, reset_p |
| `testes_diagnostico.csv` | 665 B | CSV, 2 linhas x 8 colunas: modelo, teste, hipotese_nula, hipotese_alternativa, estatistica, gl, p_valor, decisao_5pct |
| `vif_tolerancia.csv` | 535 B | CSV, 5 linhas x 5 colunas: modelo, variavel, fiv, tolerancia, decisao_fiv_10 |

## Pasta de envio: figuras e animações

| Arquivo | Tamanho | O que contém |
|---|---|---|
| `animacao1_mapa_renda_rmc.gif` | 1.1 MB | Animação GIF |
| `animacao2_ranking_salario_municipios.gif` | 1.3 MB | Animação GIF |
| `diag1_residuos_vs_ajustados.png` | 137 KB | Figura PNG |
| `diag2_residuos_por_municipio.png` | 122 KB | Figura PNG |
| `diag3_residuos_defasados.png` | 118 KB | Figura PNG |
| `diag5_normalidade_qq.png` | 98 KB | Figura PNG |
| `diag6_variaveis_no_tempo.png` | 171 KB | Figura PNG |
| `fig1_matriz_correlacao.png` | 271 KB | Figura PNG |
| `fig2_ridgeplot_salario_anos.png` | 437 KB | Figura PNG |
| `fig3_dispersao_capital_humano_industria.png` | 615 KB | Figura PNG |
| `legenda_municipios_rmc.png` | 177 KB | Figura PNG |
| `mapa1_painel_espacial_rmc.png` | 1.2 MB | Figura PNG |

## Pasta de envio: documentação validada

| Arquivo | Tamanho | O que contém |
|---|---|---|
| `00_resumo.md` | 2 KB | Markdown: Resumo |
| `01_dados_e_variaveis.md` | 2 KB | Markdown: Dados e variáveis |
| `02_especificacao_e_metodos.md` | 2 KB | Markdown: Especificação e métodos |
| `03_resultados_modelos.md` | 3 KB | Markdown: Resultados do modelo principal |
| `04_diagnosticos.md` | 4 KB | Markdown: Diagnósticos do modelo principal |
| `05_limitacoes.md` | 1 KB | Markdown: Limitações |
| `06_fontes.md` | 1 KB | Markdown: Fontes e referências |
| `07_criterios_da_disciplina.md` | 575 B | Markdown: Critérios de correção |
| `08_verificacao.md` | 3 KB | Markdown: Verificação do envio |
| `ambiente_r.csv` | 154 B | CSV, 3 linhas x 2 colunas: item, valor |
| `dicionario_variaveis.csv` | 1 KB | CSV, 23 linhas x 2 colunas: variavel, descricao |

