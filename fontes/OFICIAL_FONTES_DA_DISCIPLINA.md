# Fontes oficiais da disciplina e escopo permitido (SE614 / SE308, UFPR)

Pasta de origem: Drive `Econometria` (ID `1sCBAPMV_VzeYUrTIEe2MzlT03gaWwbh0`), acessada em 22/11/2026. Os IDs abaixo são de arquivos dessa pasta. Esta é a lista de fontes que podem embasar métodos, testes e textos do artigo.

## 1. Fontes oficiais (podem ser citadas)

| Fonte | Tipo | ID no Drive | Conteúdo relevante |
|---|---|---|---|
| Gujarati, D. N.; Porter, D. C. *Econometria Básica*. 5ª ed. AMGH, 2011 | Livro-base (bibliografia básica) | `1AGHwTDPs20RjdJbAINAyUnOkUJqz__z9` | Regressão, testes, heterocedasticidade, autocorrelação, multicolinearidade, especificação |
| Hoffmann, R.; Vieira, S. *Análise de Regressão: Introdução à Econometria*. 2ª ed. Hucitec, 1987 | Livro (bibliografia básica) | não está na pasta; citado no slide de Chow | Regressão linear múltipla e testes |
| `notas_RLM.pdf` (Hasegawa, 2015) | Notas de aula | `1ryaHWys0XjbHRjcmQpfe8HQlrXzusmcV` | Regressão linear múltipla, matriz X'X, ANOVA, t e F, R² e R² parcial, F com restrição |
| `se614_ideias_basicas.pdf`, `se614_rls_est.pdf`, `se614_rls_infer.pdf`, `se614_rls_notas.pdf` | Slides SE614 (Gujarati cap. 2, 3, 4) | `1qvrw9MKHYHCs73Kqr4SO-WzWId9NzQMG`, `1le4NZeK-WlTvPF-qKa6ozetjM88vW-Fi`, `1X-7lbv3RRjunciemYqlr6as_rufuy8Nn` | Regressão simples, estimação, inferência |
| `reglinmult1..4.pdf` | Slides de regressão múltipla | `1LVU0sKdR0nCWfnNxgl7vMWGU44nmmyxt`, `1YGzhz1YIkWsoZdhH8qa9gH7Ybllw_qF2` (4), `1t9zHS0E1EIlAOpa-m65iSPdM7fSEEabH` (3) | Regressão múltipla, testes e Chow |
| `multicolinear.pdf`, `multicolinear-UFPR-PC.pdf` | Slides (Gujarati cap. 10) | `1cg_s5SrrDe5xA_IyB42Ph6_7QMIEntG6`, `1UUhxVo-tYzQJbJlEhQx4f1gUgYzRM6Sj` | FIV e tolerância (regra FIV > 10) |
| `heterocedast.pdf`, `heterocedast2.pdf`, `heterocedast3.pdf` | Slides (Gujarati cap. 11) | `1cK-6ZxNTH-leP2QjteoLzO9kGbXRRptY`, `1DRrl8FfZ7Vd9bnmyl9ypMhr77igj4QEo`, `1xtec93xUIcPINJ_Nmn9ZtHfGJBogfawW` | Goldfeld-Quandt, White, Glejser, Park, Breusch-Pagan |
| `autocorrel.pdf`, `autocorrel2.pdf`, `autocorrel3.pdf` | Slides (Gujarati cap. 11/12) | `1WYCarnorspho-VZzBH7UncPzT4azDAgo`, `1c6OSVgOAFZ6CD6URr7yiutUh9la6O9eh`, `1R9nKPGyqAPp8glJQCZfsbpofL_4HIirp` | Teste das carreiras, Durbin-Watson, Breusch-Godfrey, Newey-West, medidas corretivas |
| `especificao_diagnostico.pdf` (cap. 13) | Slides | `14esRhmU2A667g_-gevQ2AcjC2eg2N38v` | Subespecificação, sobrespecificação, exame de resíduos, RESET, LM |
| `teste_Chow.pdf` (cap. 8) | Slides | `1_k-SeJGSX-efcfF508KyysrSBSrIoVE2` | Teste de Chow |
| `tabela_DW.pdf`, `tabela_DW_merged.pdf` | Tabela de Durbin-Watson | `1NjM4CxVFuspu7kFw4SUPsmjfdK775PMI`, `1WmHpDiBX3aKiJayz2Op2cJYUdvFkbUAU` | Valores de dL e dU |
| `tabela_distr_t.pdf`, `tabelas_estat_Sartoris2013.pdf`, `tabelas_sartoris2003.pdf`, `Wooldridge2003tablas.pdf` | Tabelas estatísticas | pasta `tabelas_valores_criticos` | t, F, qui-quadrado |
| Provas P1 e P2 de 2022 a 2025, com gabarito | Provas oficiais | pasta `provas_anos_anteriores` | Métodos cobrados: FIV, BPG, DW com ρ auxiliar, Cochrane-Orcutt, Prais-Winsten, Newey-West, White, MQP, Gini, Laspeyres e Paasche |
| `Guia Definitivo e Roteiro de Resolução: P2` (Google Doc) | Guia do professor | `1Z8WubHPgJ3z9LmJC9CMbjqodpvmdRCEBnc1iVWEsdGs` | Regras de decisão de FIV, BPG, DW, Gini e Pigou-Dalton; medidas corretivas (MQP, White, Cochrane-Orcutt, Prais-Winsten, Newey-West) |
| `Números-Índices.pdf`, `listaexerc_resp.pdf` | Slides e lista | pasta `1zkUMDegFR...` | Números-índices |

Observação: o `Guia P2` diz que Gujarati e Porter (2011) é a regra de bolso do FIV; as provas e o guia são fontes oficiais de método e de resolução.

## 2. Métodos ensinados (permitidos no projeto)

| Método | Onde é ensinado | Uso permitido no projeto |
|---|---|---|
| MQO e álgebra matricial (X'X, inversa, variância) | notas_RLM, reglinmult, Gujarati cap. 7 | Estimação do modelo |
| t, F, ANOVA, R² e R² ajustado | notas_RLM, reglinmult | Inferência |
| FIV e tolerância (limite 10) | multicolinear; Guia P2 | Multicolinearidade |
| Breusch-Pagan-Godfrey (`bptest`) | heterocedast; provas 2023 a 2025; Guia P2 | Heterocedasticidade |
| Goldfeld-Quandt | heterocedast (com 52 menções) | Heterocedasticidade |
| Matriz de White (erros robustos) | heterocedast; Guia P2 | Correção de erros-padrão |
| MQP (mínimos quadrados ponderados) | heterocedast; Guia P2 | Correção, se a forma da variância for conhecida |
| Durbin-Watson e ρ por regressão auxiliar AR(1) | autocorrel; tabela_DW; provas 2024 e 2025 | Autocorrelação (aplicado a cada série de município) |
| Breusch-Godfrey | autocorrel (lista de detecção) | Autocorrelação |
| Teste das carreiras | autocorrel | Autocorrelação |
| Cochrane-Orcutt e Prais-Winsten | Guia P2; Gujarati cap. 12 (PDF pp. 510 a 528). Não aparecem nos slides `autocorrel` lidos. | Correção de autocorrelação, com ρ comum dentro de cada município [presunção da modelagem] |
| Newey-West (HAC) | autocorrel, p. 97; Guia P2; Gujarati cap. 12 | Não aplicado: série temporal única; painel empilhado não atende |
| RESET de Ramsey | especificao_diagnostico | Forma funcional |
| Teste LM para acréscimo de variáveis | especificao_diagnostico | Omissão de variáveis |
| Teste de Chow | teste_Chow; reglinmult4 | Quebra estrutural |
| Variáveis dummy e interações | Gujarati (cap. 9) — confirmar no livro | Curitiba e efeitos de interação |
| Índice de Gini e condição de Pigou-Dalton | Guia P2, questão 3 | Medida de desigualdade |
| Números-índices (Laspeyres e Paasche) | Guia P2, questão 2 | Não é usado no modelo |

## 3. Métodos do projeto que NÃO aparecem nas fontes oficiais (saem do projeto)

| Método atual | Arquivo(s) afetado(s) | Situação |
|---|---|---|
| Efeitos fixos (within) e efeitos aleatórios | R/06, R/08, documentação 02 a 05 | Não ensinados |
| Mundlak (médias por município) | R/05, R/06, documentação 02 e 04 | Não ensinado |
| Teste de Hausman | R/06 | Não ensinado |
| Erros agrupados por município (cluster) e agrupados por município e ano | R/04, R/05, R/06 | Não ensinados |
| Bootstrap wild cluster, pesos de Webb, bootstrap exato por ano | R/06, R/08 | Não ensinados |
| Smearing de Duan | R/04 (simulação) | Não ensinado |
| Teste F com matriz agrupada (gl G−1 ou residual) | R/04, R/05 | Some junto com as matrizes agrupadas |
| Teste de Wooldridge de autocorrelação em painel (`pbgtest`/`pwartest`) | R/05, R/06 | Não ensinado para painel |
| Newey-West e Prais-Winsten aplicados ao painel empilhado | R/04, R/06 | O método é ensinado para série temporal; aplicá-lo ao painel empilhado não é válido. Sai do projeto. |
| Box-Cox | R/08 | Não encontrado nas fontes lidas. Sai, a menos que apareça no Gujarati. |
| Jarque-Bera | R/04, documentação | Volta ao escopo: Gujarati, cap. 5, seção 5.12 (PDF pp. 176 e 177). Não está nos slides lidos. Ver `VERIFICACAO_CORRECOES.md`. |
| Entropia de Shannon (X4) | R/02, variável do painel | Não ensinada. Sai, e X4 é substituída (seção 4). |
| Simulação com retransformação exp() | R/04 | Sai junto com o smearing. |

## 4. Substituições propostas (para aprovação)

| Variável ou teste | Substituição proposta | Fonte oficial |
|---|---|---|
| X4, diversificação setorial (entropia de Shannon) | Índice de Gini da participação setorial no emprego do município (CNAE, divisões). Mede concentração, não diversificação; o sinal esperado muda de direção. | Guia P2, questão 3 (Gini e Pigou-Dalton) |
| Modelo principal Mundlak, com efeitos fixos como robustez | MQO empilhado, como modelo principal. Inferência com erros-padrão de White (HC1), que é o método ensinado para erros robustos. | Guia P2 (matriz de White) |
| Autocorrelação no painel empilhado (DW de 2 dígitos inválido) | Durbin-Watson e Breusch-Godfrey aplicados à série de cada município (n = 10 anos), com a tabela de DW. | autocorrel; tabela_DW |
| Quebra estrutural e efeito de Curitiba | Teste de Chow com a amostra dividida por período (2012 a 2016 e 2017 a 2021) e a dummy de Curitiba como variável ensinada. | teste_Chow; reglinmult4 |
| Forma funcional | RESET de Ramsey e teste LM para acréscimo de variáveis. | especificao_diagnostico |
| Heterocedasticidade | Breusch-Pagan-Godfrey e Goldfeld-Quandt, com White para o erro-padrão. | heterocedast |
| Sensibilidade da Selic (bootstrap) | Sai. A Selic continua como variável; o teste de significância usa o t ensinado com erro de White. | — |

## 5. Ponto 3 da revisão: a regra do F com matriz agrupada

O F agrupado por município usava 281 ou 284 graus de liberdade (gl residual), mas a regra adotada no t era G − 1 = 28. Se a matriz agrupada sair do projeto, essa escolha deixa de existir. O F que sobra é o F clássico da ANOVA, com gl (k; n − k) = (5; 284), e o t com erro de White, com gl n − k = 284, que é a convenção usual para erros robustos a heterocedasticidade sem agrupamento. Esta é a regra proposta.

## 6. Origem da frase "uma metodologia não ensinada resulta em nota zero"

Está no slide 7 ("Metodologia e dados") do `instrucoes_ia/roteiro_powerpoint.md`, na seção "Alertas": "Utilizar apenas métodos ensinados na disciplina" e "Uma metodologia não ensinada na disciplina resulta em **nota zero**." O roteiro foi salvo a partir do `roteiro_powerpoint.docx` da pasta do projeto.
