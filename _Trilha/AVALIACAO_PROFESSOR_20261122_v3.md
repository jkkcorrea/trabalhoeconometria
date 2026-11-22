# Avaliação como professor de Econometria I, versão 3 (22/11/2026)

Documento interno. Não entra no envio. Régua de 100 pontos da skill `professor-econometria`, aplicada após: H0 e Ha formais em todos os testes; normalidade (Jarque-Bera) e influência; teste de autocorrelação por município; correções Prais-Winsten e Cochrane-Orcutt; verificação de existência de cada método na aula e no Gujarati. Evidências em `envio_professor/resultados_econometricos/` e `envio_professor/documentacao/`. Verificação: 23 de 23.

Nota estimada: 77 de 100 (faixa provável de 72 a 80). Em escala de 10, cerca de 7,7 (antes 6,6).

## 1. Nota por critério

| Critério | Pts | v2 | v3 | Evidência e motivo |
|---|---|---|---|---|
| 1. Especificação e coerência econômica | 10 | 6 | 6 | Hipóteses aprovadas. Com Prais-Winsten, o Modelo 2 perde significância em X3 (p = 0,2242) e X4 (p = 0,8814): a associação entre municípios é menos robusta do que o modelo sem correção sugeria. |
| 2. Dados e construção | 10 | 7 | 7 | Adrianópolis 2012 tem resíduo padronizado de −6,88 e a industrialização salta de 7% para 45% em 2015 (só nesse município). Dado pendente de conferência na fonte. |
| 3. Estimação e memorial matricial | 15 | 14 | 13 | Memorial do Modelo 2 com conferência contra `lm()`. A transformação de Prais-Winsten está verificada (C11), mas sem memorial escrito. Falta memorial do Modelo 4. |
| 4. Inferência clássica | 10 | 5 | 7 | H0 e Ha formais em todos os testes, com critério a 5%. Pontos perdidos: t com 290 observações tratadas como independentes, e erros-padrão corrigidos sem memorial. |
| 5. Multicolinearidade | 5 | 5 | 5 | FIV máximo 2,33. |
| 6. Heterocedasticidade | 10 | 8 | 9 | BP (rejeita nos dois modelos), GQ (não rejeita), White. H0 e Ha formais. |
| 7. Autocorrelação | 10 | 4 | 7 | Durbin-Watson com dL e dU conferidos na Tabela D.5A (C12). Breusch-Godfrey por município. Carreiras declarada não aplicável (N ≤ 10). Prais-Winsten e Cochrane-Orcutt aplicados com ρ comum (C11). Newey-West não aplicado, com justificativa. Pontos perdidos: correção é extensão ao painel [presunção]. |
| 8. Normalidade, forma funcional e influência | 10 | 3 | 7 | Jarque-Bera (rejeita nos dois modelos), gráfico de probabilidade normal, RESET, alavancagem, resíduo padronizado e sensibilidade (C13). Pontos perdidos: sem teste formal de influência (Cook e DFBETAS não são do programa), e a normalidade rejeitada não tem tratamento. |
| 9. Painel, endogeneidade e robustez | 10 | 5 | 6 | Robustez do X4 (duas definições), Selic (agregada), correções de autocorrelação e sensibilidade a pontos influentes. Mundlak e Hausman fora do programa. |
| 10. Reprodutibilidade | 5 | 4 | 5 | Pipeline completo; verificador com 23 checagens, incluindo C10 a C13; comentário do R/04 corrigido. |
| 11. Limitações e honestidade | 5 | 5 | 5 | Rejeições reportadas (normalidade, RESET, BP, DW), fragilidade da correção declarada, presunções marcadas. |
| **Total** | **100** | **66** | **77** | |

## 2. Erros que restam

- **E1. Adrianópolis 2012 e industrialização.** O salto de 7% para 45% (2014 para 2015) está só nesse município. Precisa ser conferido em `SIDRA 5938` antes de qualquer conclusão. Não há erro comprovado, mas o dado é suspeito.
- **E2. Coerência entre modelo principal e correção.** O Modelo 4 é o principal, mas o Modelo 2 é o de referência para X6. Com Prais-Winsten, a conclusão sobre X3 e X4 no Modelo 2 não se sustenta. O texto precisa dizer isso com clareza.

## 3. Faltas que restam

- **F1. Memorial matricial do Modelo 4 e da transformação de Prais-Winsten.** Critério 3 (até +2).
- **F2. Tratamento da não normalidade.** O Jarque-Bera rejeita com S = 1,74 e K = 8,52 no Modelo 2. O livro dá a regra de amostra grande, mas nenhum procedimento de correção do próprio modelo. Declarado como limitação, sem correção.
- **F3. Confirmação do professor para as presunções:** dummies, ρ comum no painel, limiares de influência, quebra de 2016, Gini.

## 4. Riscos

- **R1. Prais-Winsten com ρ = 0,944 no Modelo 2** é um valor próximo de raiz unitária. A transformação remove quase toda a variação entre anos; o coeficiente de escolaridade passa de 0,0150 para 0,0038. Um examinador pode questionar se a estimativa ainda mede o que o trabalho pretende.
- **R2. Teste das carreiras não aplicável** em todas as 58 séries. Um examinador pode perguntar por que não foi usado outro procedimento.
- **R3. Gini e Modelo 4.** Com Prais-Winsten, o Gini deixa de ser significativo a 5% (p = 0,0977). Sem os dois pontos influentes, o coeficiente sobe para 1,15.
- **R4. Edição do Gujarati.** Usamos só a 4ª edição (2004). A paginação pode diferir da edição citada pela disciplina.

## 5. Melhorias que faltam, por ganho

| Ação | Critério | Ganho provável | Depende de |
|---|---|---|---|
| Memorial matricial do Modelo 4 e da transformação de Prais-Winsten, em `R/07` | 3 | +2 | nada (posso fazer) |
| Conferir Adrianópolis 2012 na fonte SIDRA; corrigir se for erro | 2 | +1 a +2 | acesso à API (cache) |
| Texto explicitando que o Modelo 2 não se sustenta após a correção de autocorrelação | 1 e 4 | +1 | decisão de modelo de referência |
| Confirmação do professor sobre dummies, ρ comum e limiares de influência | 1, 7 e 8 | +2 a +3 | professor |
| Procedimento para normalidade rejeitada, se o professor indicar | 8 | +1 a +2 | professor |

Com os quatro primeiros itens, a nota chega a cerca de 80. Acima disso, depende de confirmação do professor.

## 6. O que mais pesa agora

Pesa mais a dependência da conclusão do Modelo 2 em relação à correção de autocorrelação (critério 1 e 7). A correção é o método certo para a disciplina, mas o resultado mostra que a associação entre municípios não é robusta. Isso é um achado, e precisa estar no texto.
