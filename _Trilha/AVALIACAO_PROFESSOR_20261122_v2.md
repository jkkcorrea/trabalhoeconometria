# Avaliação como professor de Econometria I, versão 2 (22/11/2026)

Documento interno. Não entra no envio. Régua de 100 pontos da skill `professor-econometria`, aplicada à versão atual do modelo (Modelo 4 principal; Modelo 2 de referência). Evidências em `envio_professor/resultados_econometricos/` e `envio_professor/documentacao/`.

Nota estimada: 66 de 100 (faixa provável de 63 a 69). Em escala de 10, cerca de 6,6. Nota 10 exige 90 ou mais.

## 1. Nota por critério

| Critério | Pts | Nota | Evidência e motivo |
|---|---|---|---|
| 1. Especificação e coerência econômica | 10 | 6 | Hipóteses H1 a H5 e sinais aprovados. Gini (X4) tem r = −0,95 com o número de setores com emprego; o sinal do X4 muda entre Modelo 2 (−0,6548) e Modelo 4 (+0,8653). Forma funcional: RESET rejeita no Modelo 2 (p < 0,0001), não rejeita no Modelo 4 (p = 0,75). |
| 2. Dados e construção | 10 | 7 | Fontes, deflator e definições documentadas. Pontos perdidos: Gini com 87 divisões e zeros (escolha a confirmar); VAB negativo da Araucária (2012 e 2013) mantido; X5 e X6 com 10 e 29 valores distintos. |
| 3. Estimação e memorial matricial | 15 | 14 | Memorial matricial do Modelo 2 com conferência contra `lm()`. Falta memorial equivalente para o Modelo 4, que é o principal. |
| 4. Inferência clássica | 10 | 5 | Testes t, F e intervalos presentes. Pontos perdidos: H0 e Ha formais só aparecem em parte dos testes; t com 284 gl trata 290 observações como independentes e superestima a precisão de X5 (10 valores) e X6. |
| 5. Multicolinearidade | 5 | 5 | FIV máximo 2,33 (Modelo 2); tolerância mínima 0,43. Decisão registrada. |
| 6. Heterocedasticidade | 10 | 8 | Breusch-Pagan-Godfrey rejeita no Modelo 2 (p = 0,0363) e no Modelo 4 (p = 0,0002). Goldfeld-Quandt não rejeita (p = 0,39). Correção por erro de White, coerente com o diagnóstico. Perde 2 pontos por H0 e Ha não formais. |
| 7. Autocorrelação | 10 | 4 | Durbin-Watson, ρ auxiliar e Breusch-Godfrey por município: bem feito. Mas (a) dL = 0,243 e dU = 2,822 vieram de OCR e não foram conferidos; (b) a mediana do DW no Modelo 2 é 0,25, com 14 municípios positivos; (c) nenhuma correção aplicada, aceita como limitação. |
| 8. Normalidade, forma funcional e influência | 10 | 3 | Não há teste de normalidade nem medida de influência (Cook, DFBETAS). O cabeçalho do R/04 cita Jarque-Bera e Shapiro-Wilk, mas o código não os executa. RESET rejeita no Modelo 2 e o tratamento foi trocar de modelo. |
| 9. Painel, endogeneidade e robustez | 10 | 5 | Efeito de município (Modelo 4), teste F de acréscimo, Chow, robustez da X4 (duas definições) e robustez da Selic (agregada). Efeitos fixos, Mundlak, Hausman e exogeneidade ficam fora do escopo ensinado. |
| 10. Reprodutibilidade | 5 | 4 | Pipeline com caminhos relativos e cache; verificação 19 de 19. Perde 1 ponto pelo comentário desatualizado no R/04 (linha 10). |
| 11. Limitações e honestidade | 5 | 5 | Rejeições reportadas, limitações escritas, associação não tratada como causalidade. |
| **Total** | **100** | **66** | |

## 2. Erros (algo está errado)

- **E1. Tabela de Durbin-Watson não verificada.** `R/05_autocorrelacao_municipios.R` usa dL = 0,243 e dU = 2,822, lidos por OCR. Com esses valores, a regra de decisão de `decidir_dw` não tem zona de não rejeição, e as decisões por município (14 positivas no Modelo 2) dependem deles. Ação: substituir pela tabela D.5A do Gujarati (n = 10, k′ = 5, 5%) assim que o PDF estiver em `fontes/livros_artigos/`.
- **E2. Comentário desatualizado.** `R/04_modelagem_diagnosticos.R`, linha 10, cita Jarque-Bera e Shapiro-Wilk, que não são calculados. Corrigir o comentário e regerar o envio.

## 3. Faltas (algo esperado não está)

- **F1. H0 e Ha formais em cada teste diagnóstico** (critério 4, 6, 7 e 8). Hoje aparecem como "erros-padrão" ou "variância constante", sem a hipótese alternativa escrita.
- **F2. Normalidade dos resíduos.** Nenhum teste. Pelo escopo atual, Jarque-Bera foi removido (D-2026-11-22-02), mas o cabeçalho ainda o cita.
- **F3. Medida de influência.** Nenhuma (distância de Cook ou DFBETAS). Critério 8 fica quase zerado sem isso.
- **F4. Correção da autocorrelação.** Nenhuma. O critério 7 espera uma correção aplicada ou uma justificativa de por que não há como aplicar.
- **F5. Memorial do Modelo 4.** Principal modelo sem o passo a passo matricial.
- **F6. Páginas do Gujarati** para dummies (cap. 9) e Durbin-Watson (D.5A). Pendentes até o PDF ser copiado para `fontes/livros_artigos/`.

## 4. Riscos (frágil; um examinador questionaria)

- **R1. Dummies de município no modelo principal.** Não constam nos slides das aulas. Constam no trabalho de exemplo (seção 2.3), no Hoffmann (cap. 5) e no Gujarati (cap. 9). Decisão mantida pelo pesquisador (D-2026-11-22-07), a confirmar com o professor.
- **R2. X4 (Gini).** Mede sobretudo o número de setores com emprego (r = −0,95). Com as divisões ativas, o efeito dentro dos municípios deixa de ser significativo (p = 0,44). O sinal entre municípios (negativo) contraria a leitura de "diversificação" dos sinais aprovados em H3.
- **R3. Inferência da Selic.** No Modelo 2, p = 0,0018 com erro clássico e p = 0,0003 com White, com 290 observações. Na checagem agregada (10 anos), p = 0,19. A diferença é o ponto que mais enfraquece a conclusão sobre juros.
- **R4. Forma funcional do Modelo 2.** RESET rejeita (p < 0,0001). A troca para o Modelo 4 resolve o RESET, mas o Modelo 4 tem 32 parâmetros e não identifica X6.
- **R5. Projeção de 2021.** A retransformação por exp() sem correção subestima a média do salário. A tabela de projeção é coerente com o modelo (verificação C9), mas a média das previsões deve ser lida com essa ressalva.
- **R6. Heterocedasticidade no Modelo 4.** Breusch-Pagan rejeita fortemente (p = 0,0002). A inferência depende do erro de White.

## 5. Melhorias, por ganho em pontos

| Ordem | Ação | Critério | Ganho provável | Depende de |
|---|---|---|---|---|
| 1 | Trocar dL e dU pelos valores da tabela D.5A do Gujarati; regerar R/05 e o envio | 7 e 10 | +2 | PDF do Gujarati em `fontes/livros_artigos/` |
| 2 | H0 e Ha formais em todos os testes (1 linha por teste na documentação) | 4, 6, 7, 8 | +3 | nada (posso fazer agora) |
| 3 | Teste de normalidade e distância de Cook no Modelo 4, se o professor confirmar que estão no programa | 8 | +3 a +4 | confirmação do professor (item d da solicitação) |
| 4 | Correção da autocorrelação, se o professor aceitar um método ensinado (ex.: Cochrane-Orcutt, Gujarati cap. 12) | 7 | +3 a +5 | decisão de escopo do pesquisador e do professor |
| 5 | Memorial matricial do Modelo 4 | 3 | +1 | nada (posso fazer agora) |
| 6 | Inferência da Selic apresentada com a checagem agregada como principal | 4 | +1 | decisão do pesquisador |
| 7 | Corrigir o comentário do R/04 e regerar o envio | 10 | +1 | nada (posso fazer agora) |
| 8 | Escolher a definição do Gini e apresentar a outra como robustez na documentação | 1 e 2 | +1 a +2 | confirmação do professor (item e) |

Somando as ações 1, 2, 5, 6 e 7 (+8), a nota vai a cerca de 74. Com a ação 8 (+1 a +2), cerca de 76. Só chegar a 80 ou mais depende das ações 3 e 4 (+6 a +9 no total), que dependem do professor e do escopo. Nota 10 (90 pontos) não aparece como resultado realista nem com todas as ações, porque os critérios 1 e 9 têm limites que só uma reespecificação com método fora do escopo atual resolveria.

## 6. O que mais pesa

Pesa mais a combinação de normalidade e influência (critério 8, nota 3 de 10) com a autocorrelação sem correção (critério 7, nota 4 de 10). Ambas dependem de confirmar o escopo ensinado com o professor. A tabela de Durbin-Watson de OCR é um erro a corrigir de imediato.
