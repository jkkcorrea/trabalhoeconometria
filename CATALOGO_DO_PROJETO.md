# Catálogo do projeto

Gerado por `_Trilha/ferramentas/gerar_catalogo.R` em 21/11/2026. Não edite à mão: rode o script de novo.

Projeto: salário médio real formal nos 29 municípios da Região Metropolitana de Curitiba, 2012 a 2021 (290 observações), Econometria I, UFPR.

## Números do projeto

- Scripts em `R/`: 9.
- Figuras e animações em `envio_professor/figuras_graficos/`: 15 arquivos.
- Arquivos em `envio_professor/resultados_econometricos/`: 56.
- Decisões registradas em `_Trilha/DECISOES.md`: 39 (vigentes na última coluna: 35).
- Pendências em `_Trilha/BACKLOG.md`: 3 abertas e 24 baixadas.

## Onde começar

1. `SUMARIO_DO_PROJETO.md` (uma página).
2. `instrucoes_ia/LEIA_PRIMEIRO.md` (regras para quem usa IA no projeto).
3. `envio_professor/documentacao/00_resumo.md` (resultados validados).

## Raiz do projeto

Arquivos soltos na raiz (instruções, guias e documentos do projeto).

| Arquivo | Tamanho | O que contém |
|---|---|---|
| `CATALOGO_DO_PROJETO.md` | 16 KB | Markdown: Catálogo do projeto |
| `CLAUDE.md` | 17 KB | Markdown: CLAUDE.md do Trabalho de Econometria (núcleo do harness do projeto) |
| `CONTRIBUIR.md` | 10 KB | Markdown: Como baixar e contribuir com o projeto |
| `R` | 4 KB |  |
| `README.md` | 5 KB | Markdown: Salário médio real formal na Região Metropolitana de Curitiba, 2012 a 2021 |
| `SUMARIO_DO_PROJETO.md` | 4 KB | Markdown: Sumário do projeto |
| `Trabalhos Referencias` | 4 KB |  |
| `_Trilha` | 4 KB |  |
| `backup_antes_alteracoes` | 4 KB |  |
| `dados_brutos` | 4 KB |  |
| `dados_processados` | 4 KB |  |
| `envio_professor` | 4 KB |  |
| `envio_professor.zip` | 8.0 MB |  |
| `figuras_graficos` | 4 KB |  |
| `instrucoes-claude-opus.md` | 8 KB | Markdown: INSTRUÇÕES DE SISTEMA E COMPORTAMENTO (SYSTEM PROMPT) — CLAUDE OPUS |
| `instrucoes_ia` | 4 KB |  |
| `prompt-1-extracao-apis.md` | 7 KB | Markdown: PROMPT 1: Extração Automatizada de Dados via APIs em R (Etapa 1 de 4) |
| `prompt-2-tratamento-painel.md` | 6 KB | Markdown: CONTEXTO E DIRETRIZES GERAIS |
| `prompt-3-aede-visualizacoes.md` | 7 KB | Markdown: CONTEXTO E DIRETRIZES DA ETAPA 3 |
| `prompt-4-modelagem-diagnosticos.md` | 8 KB | Markdown: PROMPT 4: MODELAGEM ECONOMÉTRICA, BATERIA DE DIAGNÓSTICOS DO MCRL E INFERÊNCIA ROBUSTA (UFPR) |
| `resultados_econometricos` | 4 KB |  |

## Scripts do projeto (`R/`, com comentários de processo)

| Arquivo | Tamanho | O que contém |
|---|---|---|
| `00_executar_tudo.R` | 2 KB | Script R: Uso, a partir da raiz do projeto:  Rscript R/00_executar_tudo.R |
| `01_extracao_dados.R` | 48 KB | Script R |
| `02_tratamento_painel.R` | 30 KB | Script R: Etapa 2: tratamento dos dados brutos e construção do painel mestre |
| `03_aede_visualizacoes.R` | 36 KB | Script R: Etapa 3: análise exploratória espacial e visualizações |
| `04_modelagem_diagnosticos.R` | 57 KB | Script R: Etapa 4: modelagem econométrica, diagnósticos do MCRL e inferência robusta |
| `05_robustez_mundlak.R` | 19 KB | Script R: Etapa 5: robustez da Etapa 4 (lista de alterações, itens B1, B2, B3 e C1) |
| `06_calibracao_modelo.R` | 29 KB | Script R: Etapa 6: calibração do modelo |
| `07_memorial_modelo_2.R` | 16 KB | Script R: Etapa 7: memorial de cálculo matricial do Modelo 2 |
| `08_fragilidades_modelo.R` | 32 KB | Script R: Etapa 8: tratamento das três fragilidades do modelo |

## Instruções para IA (`instrucoes_ia/`)

Prompts e regras para os colegas que usam IA. Não contêm texto do artigo.

| Arquivo | Tamanho | O que contém |
|---|---|---|
| `LEIA_PRIMEIRO.md` | 4 KB | Markdown: Leia primeiro: regras para usar IA neste projeto |
| `PROMPT_ARTIGO.md` | 8 KB | Markdown: Prompt para construir o artigo, seção por seção |
| `PROMPT_SLIDES.md` | 6 KB | Markdown: Prompt para construir a apresentação de slides |
| `VERIFICACAO_CONTEUDO.md` | 4 KB | Markdown: Verificação: o texto bate com o código? |

## Skills (`.claude/skills/`)

Cada skill é uma pasta com `SKILL.md`.

| Arquivo | Tamanho | O que contém |
|---|---|---|
| `boas-praticas-programacao/SKILL.md` | 3 KB | Markdown: Boas práticas de programação (R) neste projeto |
| `diagramacao-projeto/SKILL.md` | 3 KB | Markdown: Diagramação do projeto |
| `economia-de-tokens/SKILL.md` | 2 KB | Markdown: Economia de tokens |
| `escrita-cientifica/SKILL.md` | 3 KB | Markdown: Boas práticas de escrita científica (artigo de Econometria) |
| `estrutura-artigo-ufpr/SKILL.md` | 4 KB | Markdown: Estrutura de artigo de periódico no padrão UFPR |
| `formatacao-abnt/SKILL.md` | 6 KB | Markdown: Formatação ABNT para o artigo |
| `maximizacao-de-contexto/SKILL.md` | 2 KB | Markdown: Maximizar o contexto útil |
| `professor-econometria/SKILL.md` | 5 KB | Markdown: Correção do trabalho como professor de Econometria I |
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
| `gerar_documentacao.R` | 65 KB | Script R: Gera a documentação da pasta de envio a partir dos arquivos de resultado. |
| `limpar_comentarios.R` | 9 KB | Script R |
| `reconstruir_envio.sh` | 2 KB | Script de shell |
| `verificar_envio.R` | 30 KB | Script R: Uso (raiz do projeto): Rscript _Trilha/ferramentas/verificar_envio.R |

## Trilha de decisões e handoffs (`_Trilha/`)

| Arquivo | Tamanho | O que contém |
|---|---|---|
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
| `02_tratamento_painel.R` | 28 KB | Script R |
| `03_aede_visualizacoes.R` | 33 KB | Script R |
| `04_modelagem_diagnosticos.R` | 48 KB | Script R |
| `05_robustez_mundlak.R` | 18 KB | Script R |
| `06_calibracao_modelo.R` | 29 KB | Script R: Etapa 6: calibração do modelo |
| `07_memorial_modelo_2.R` | 16 KB | Script R: Etapa 7: memorial de cálculo matricial do Modelo 2 |
| `08_fragilidades_modelo.R` | 32 KB | Script R: Etapa 8: tratamento das três fragilidades do modelo |

## Pasta de envio: dados processados

| Arquivo | Tamanho | O que contém |
|---|---|---|
| `dados_painel_rmc.csv` | 82 KB | CSV, 290 linhas x 23 colunas: id_municipio, nome_municipio, ano, salario_medio_nominal, salario_medio_real, ln_salario_real, prop_superior, dom_industrial, … |
| `dados_painel_rmc.rds` | 22 KB | Objeto R serializado (.rds) |
| `estatisticas_descritivas.csv` | 948 B | CSV, 8 linhas x 7 colunas: variavel, n, media, desvio_padrao, mediana, minimo, maximo |
| `matriz_correlacao_explicativas.csv` | 595 B | CSV, 5 linhas x 6 colunas: variavel, prop_superior, dom_industrial, shannon_diversificacao, selic_real, dist_curitiba_km |

## Pasta de envio: resultados econométricos

| Arquivo | Tamanho | O que contém |
|---|---|---|
| `calibracao_autocorrelacao.csv` | 219 B | CSV, 3 linhas x 3 colunas: modelo, rho_residuos_mesmo_municipio, d_aproximado |
| `calibracao_bootstrap_wild_cluster.csv` | 1 KB | CSV, 17 linhas x 5 colunas: estimador, termo, estatistica_t, p_bootstrap, replicas |
| `calibracao_coeficientes.csv` | 7 KB | CSV, 33 linhas x 11 colunas: estimador, termo, estimativa, erro_padrao, estatistica_t, p_valor, ic_inf_95, ic_sup_95, … |
| `calibracao_goldfeld_quandt.csv` | 445 B | CSV, 3 linhas x 8 colunas: teste, ordenado_por, hipotese_nula, estatistica_f, gl_numerador, gl_denominador, p_valor, p_valor_bilateral |
| `calibracao_influencia.csv` | 28 KB | CSV, 290 linhas x 8 colunas: id_municipio, nome_municipio, ano, cook, alavancagem, max_dfbetas, cook_acima_4_sobre_n, dfbetas_acima_2_sobre_raiz_n |
| `calibracao_reset.csv` | 329 B | CSV, 3 linhas x 6 colunas: modelo, estatistica_f, gl1, gl2, p_valor, r2_ajustado |
| `calibracao_selic_agrupada_por_ano.csv` | 767 B | CSV, 3 linhas x 11 colunas: estimador, termo, estimativa, erro_padrao, estatistica_t, p_valor, ic_inf_95, ic_sup_95, … |
| `calibracao_testes_painel.csv` | 1001 B | CSV, 7 linhas x 5 colunas: teste, hipotese_nula, estatistica, graus_liberdade, p_valor |
| `calibracao_variancia_tamanho.csv` | 214 B | CSV, 1 linhas x 6 colunas: modelo, correlacao, inclinacao, estatistica_t, p_valor, leitura |
| `coeficientes_cinco_matrizes.csv` | 13 KB | CSV, 105 linhas x 7 colunas: modelo, matriz, termo, estimativa, erro_padrao, estatistica_t, p_valor |
| `diagnosticos_modelo_2.csv` | 2 KB | CSV, 17 linhas x 9 colunas: modelo, bloco, teste, hipotese_nula, estatistica, nome_estatistica, graus_liberdade, p_valor, … |
| `fiv_modelos_2_3_3b.csv` | 1 KB | CSV, 18 linhas x 5 colunas: modelo, termo, fiv, tolerancia, severa |
| `fragilidades_box_cox.csv` | 403 B | CSV, 2 linhas x 8 colunas: modelo, lambda_estimado, ic95_inf, ic95_sup, lr_logaritmo, p_logaritmo, lr_nivel, p_nivel |
| `fragilidades_exogeneidade_coeficientes.csv` | 2 KB | CSV, 11 linhas x 7 colunas: modelo, termo, estimativa, erro_padrao, estatistica_t, p_valor, n |
| `fragilidades_exogeneidade_teste.csv` | 175 B | CSV, 1 linhas x 5 colunas: teste, estatistica_f, gl_numerador, gl_denominador, p_valor |
| `fragilidades_fe_quadratico_coeficientes.csv` | 706 B | CSV, 7 linhas x 5 colunas: termo, estimativa, erro_padrao, estatistica_t, p_valor |
| `fragilidades_fe_quadratico_efeitos_marginais.csv` | 713 B | CSV, 3 linhas x 10 colunas: termo, media_do_regressor, efeito_marginal_medio, erro_padrao, estatistica_t, p_valor, vertice_da_parabola, minimo_observado, … |
| `fragilidades_fe_quadratico_teste_conjunto.csv` | 157 B | CSV, 1 linhas x 5 colunas: teste, estatistica_f, gl_numerador, gl_denominador, p_valor |
| `fragilidades_forma_funcional.csv` | 909 B | CSV, 4 linhas x 10 colunas: especificacao, r2_ajustado, aic, bic, reset_regressores_f, reset_regressores_gl, reset_regressores_p, reset_ajustados_f, … |
| `fragilidades_influencia_sensibilidade.csv` | 7 KB | CSV, 45 linhas x 10 colunas: cenario, observacoes_excluidas, n, municipios, modelo, termo, estimativa, erro_padrao, … |
| `fragilidades_quebra_curitiba.csv` | 271 B | CSV, 1 linhas x 6 colunas: teste, estatistica_f, gl_numerador, gl_denominador, p_valor, observacao |
| `fragilidades_reset_modelos_3_3b.csv` | 334 B | CSV, 2 linhas x 7 colunas: modelo, reset_regressores_f, reset_regressores_gl, reset_regressores_p, reset_ajustados_f, reset_ajustados_gl, reset_ajustados_p |
| `fragilidades_selic_bootstrap_exato_por_ano.csv` | 178 B | CSV, 2 linhas x 4 colunas: modelo, estatistica_t_por_ano, p_bootstrap_exato, combinacoes |
| `fragilidades_selic_bootstrap_webb.csv` | 220 B | CSV, 2 linhas x 5 colunas: modelo, estatistica_t_por_ano, p_bootstrap_webb, replicas, semente |
| `fragilidades_selic_decomposicao.csv` | 1 KB | CSV, 5 linhas x 8 colunas: modelo, termo, estimativa, erro_padrao, estatistica_t, p_valor, erro_padrao_por_ano, p_valor_por_ano |
| `fragilidades_selic_decomposicao_teste_fisher.csv` | 389 B | CSV, 2 linhas x 5 colunas: teste, agrupamento, soma_dos_coeficientes, estatistica_f, p_valor |
| `fragilidades_selic_sensibilidade.csv` | 2 KB | CSV, 15 linhas x 7 colunas: cenario, n, estimativa, erro_padrao, estatistica_t, p_valor, graus_liberdade |
| `fragilidades_simulacao_efeitos_fixos.csv` | 982 B | CSV, 6 linhas x 11 colunas: cenario, modelo, municipios, delta_pontos, variacao_pct, ic_inf_pct, ic_sup_pct, minimo_pct, … |
| `memorial_modelo_2.txt` | 10 KB | Texto simples |
| `memorial_modelo_2_anova.csv` | 299 B | CSV, 3 linhas x 7 colunas: fonte, graus_liberdade, soma_quadrados, quadrado_medio, estatistica_f, F_critico_5pct, p_valor |
| `memorial_modelo_2_coeficientes.csv` | 982 B | CSV, 6 linhas x 8 colunas: termo, estimativa, erro_padrao_classico, estatistica_t, p_valor, ic_inf_95, ic_sup_95, graus_liberdade |
| `memorial_modelo_2_determinacao_parcial.csv` | 786 B | CSV, 5 linhas x 4 colunas: variavel, estatistica_t, r2_parcial, leitura |
| `memorial_modelo_2_f_incremental.csv` | 626 B | CSV, 4 linhas x 8 colunas: bloco, restricoes, SQR_restrito, SQR_irrestrito, estatistica_f, F_critico_5pct, p_valor, decisao |
| `memorial_modelo_2_fiv.csv` | 593 B | CSV, 5 linhas x 5 colunas: variavel, R2_auxiliar, tolerancia, fiv, decisao |
| `memorial_modelo_2_previsao.csv` | 323 B | CSV, 2 linhas x 6 colunas: cenario, ln_previsto, ic_media_inf, ic_media_sup, ic_individual_inf, ic_individual_sup |
| `modelos_e_testes.rds` | 142 KB | Objeto R serializado (.rds) |
| `robustez_adicional_coeficientes.csv` | 2 KB | CSV, 15 linhas x 6 colunas: modelo, termo, estimativa, erro_padrao, p_valor, fiv_ajustado |
| `robustez_adicional_resumo.csv` | 226 B | CSV, 3 linhas x 4 colunas: modelo, n, r2, reset_p |
| `robustez_modelo_2_sem_x3_negativo.csv` | 2 KB | CSV, 6 linhas x 12 colunas: termo, coef_completo, ep_classico_completo, p_classico_completo, ep_agrupado_completo, p_agrupado_completo, coef_sem_x3neg, ep_classico_sem_x3neg, … |
| `robustez_mundlak_autocorrelacao_painel.csv` | 186 B | CSV, 1 linhas x 5 colunas: teste, estatistica, gl, p_valor, observacao |
| `robustez_mundlak_coeficientes.csv` | 2 KB | CSV, 15 linhas x 8 colunas: modelo, termo, estimativa, erro_padrao, estatistica_t, p_valor, ic_inf_95, ic_sup_95 |
| `robustez_mundlak_tabela.txt` | 3 KB | Texto simples |
| `robustez_mundlak_teste_mundlak.csv` | 185 B | CSV, 1 linhas x 6 colunas: hipotese, matriz, estatistica_f, gl_numerador, gl_denominador, p_valor |
| `selic_p_valor_conservador.csv` | 229 B | CSV, 1 linhas x 8 colunas: modelo, termo, matriz, graus_liberdade, estimativa, erro_padrao, estatistica_t, p_valor |
| `simulacao_cenarios_renda.csv` | 13 KB | CSV, 31 linhas x 24 colunas: cenario, id_municipio, nome_municipio, ano_base, variavel_choque, delta_pontos, valor_antes, valor_depois, … |
| `tabela_comparativa_modelos.html` | 21 KB | Tabela HTML |
| `tabela_comparativa_modelos.txt` | 10 KB | Texto simples |
| `tabela_modelo_2_cinco_matrizes.html` | 19 KB | Tabela HTML |
| `tabela_modelo_2_cinco_matrizes.txt` | 8 KB | Texto simples |
| `tabela_modelo_3_cinco_matrizes.html` | 20 KB | Tabela HTML |
| `tabela_modelo_3_cinco_matrizes.txt` | 10 KB | Texto simples |
| `tabela_modelo_3b_cinco_matrizes.html` | 21 KB | Tabela HTML |
| `tabela_modelo_3b_cinco_matrizes.txt` | 11 KB | Texto simples |
| `tabela_robustez_modelo_2.html` | 17 KB | Tabela HTML |
| `tabela_robustez_modelo_2.txt` | 7 KB | Texto simples |
| `teste_f_global_robusto.csv` | 2 KB | CSV, 15 linhas x 7 colunas: modelo, matriz, hipotese, estatistica_f, gl_numerador, gl_denominador, p_valor |

## Pasta de envio: figuras e animações

| Arquivo | Tamanho | O que contém |
|---|---|---|
| `animacao1_mapa_renda_rmc.gif` | 906 KB | Animação GIF |
| `animacao2_ranking_salario_municipios.gif` | 3.0 MB | Animação GIF |
| `calibracao_coeficientes_estimadores.png` | 344 KB | Figura PNG |
| `diag1_residuos_padronizados_vs_ajustados.png` | 284 KB | Figura PNG |
| `diag2_acf_residuos.png` | 131 KB | Figura PNG |
| `diag3_densidade_residuos.png` | 151 KB | Figura PNG |
| `diag4_qqplot_residuos.png` | 183 KB | Figura PNG |
| `fig1_matriz_correlacao.png` | 268 KB | Figura PNG |
| `fig2_ridgeplot_salario_anos.png` | 437 KB | Figura PNG |
| `fig3_dispersao_capital_humano_industria.png` | 616 KB | Figura PNG |
| `fragilidades_efeito_marginal_superior.png` | 184 KB | Figura PNG |
| `legenda_municipios_rmc.png` | 177 KB | Figura PNG |
| `mapa1_painel_espacial_rmc.png` | 1.2 MB | Figura PNG |
| `robustez_mundlak_coeficientes.png` | 76 KB | Figura PNG |
| `robustez_mundlak_dw_por_municipio.png` | 40 KB | Figura PNG |

## Pasta de envio: documentação validada

| Arquivo | Tamanho | O que contém |
|---|---|---|
| `00_resumo.md` | 3 KB | Markdown: Resumo dos resultados validados |
| `01_dados_e_variaveis.md` | 7 KB | Markdown: Dados e variáveis |
| `02_especificacao_e_metodos.md` | 7 KB | Markdown: Especificação e métodos |
| `03_resultados_modelos_classicos.md` | 14 KB | Markdown: Resultados dos modelos clássicos (script 04 e memorial do script 07) |
| `04_calibracao.md` | 14 KB | Markdown: Calibração do modelo (scripts 05 e 06) |
| `05_fragilidades.md` | 14 KB | Markdown: Tratamento das três fragilidades (script 08) |
| `06_limitacoes.md` | 6 KB | Markdown: Limitações e ressalvas |
| `07_criterios_da_disciplina.md` | 2 KB | Markdown: Critérios da disciplina e onde estão atendidos |
| `08_verificacao.md` | 7 KB | Markdown: Registro de verificação |
| `ambiente_r.csv` | 464 B | CSV, 25 linhas x 2 colunas: componente, versao |
| `dicionario_variaveis.csv` | 2 KB | CSV, 10 linhas x 5 colunas: Símbolo, Nome no painel, Definição, Fonte, Varia em |

