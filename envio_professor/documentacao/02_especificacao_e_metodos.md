# Especificação e métodos

Três especificações, todas por MQO sobre o painel empilhado:

- **Modelo 2 (comparação, com X6):** ln(Y_it) = b1 + b2 X2 + b3 X3 + b4 X4 + b5 X5 + b6 X6 + u_it.
- **Modelos 3 e 3b:** Modelo 2 com a dummy de Curitiba; o 3b acrescenta a interação X3 x X6.
- **Modelo 4 (principal):** ln(Y_it) = b1 + b2 X2 + b3 X3 + b4 X4 + b5 X5 + dummies de município + u_it.

A escolha do Modelo 4 como principal se apoia nos testes da Etapa 6: o F de acréscimo das dummies rejeita e o RESET passa a não rejeitar. A forma funcional não era o problema; a heterogeneidade entre municípios era. Ver 04_diagnosticos.md.

Fontes do uso de variáveis dummy: Gujarati, cap. 9 (PDF pp. 332 a 352), e o trabalho de exemplo da disciplina (seção 2.3). Os slides das aulas lidos não tratam de dummies.

## Métodos usados (todos ensinados na disciplina)

| Método | Uso no projeto | Fonte oficial |
|---|---|---|
| MQO e álgebra matricial | estimação e memorial | notas de regressão múltipla |
| t, F, ANOVA, R2 | inferência e teste de acréscimo | notas de regressão múltipla |
| Variáveis dummy | controle de município (Modelo 4) e de Curitiba | Gujarati, cap. 9 (confirmar no livro) |
| FIV e tolerância (limite 10) | multicolinearidade | notas de multicolinearidade; Guia P2 |
| Breusch-Pagan-Godfrey | heterocedasticidade | notas de heterocedasticidade; provas 2023 a 2025 |
| Goldfeld-Quandt | heterocedasticidade | notas de heterocedasticidade |
| Erros-padrão de White (HC1) | inferência robusta | notas de heterocedasticidade; Guia P2 |
| Durbin-Watson e ρ por regressão auxiliar AR(1) | autocorrelação, série de cada município | Gujarati, cap. 12 (PDF pp. 495 a 499); Tabela D.5A (PDF p. 995); Guia P2 (cinco zonas) |
| Breusch-Godfrey (ordem 1) | autocorrelação, série de cada município | Gujarati, cap. 12 (PDF pp. 499 e 500); slides autocorrel |
| Teste das carreiras (runs) | aleatoriedade dos resíduos por município | Gujarati, cap. 12 (PDF p. 493); slides autocorrel pp. 79 a 93 |
| Prais-Winsten e Cochrane-Orcutt | correção da autocorrelação, ρ comum, dentro de cada município | Gujarati, cap. 12 (PDF pp. 510 a 528); Guia P2 (não aparecem nos slides autocorrel) |
| Jarque-Bera | normalidade dos resíduos | Gujarati, cap. 5, seção 5.12 (PDF pp. 176 e 177) |
| Alavancagem e resíduo padronizado | observações atípicas e influentes (sem teste formal) | Gujarati, cap. 13, Outliers, Leverage, and Influence (PDF pp. 568 e 569) |
| RESET de Ramsey | forma funcional | notas de especificação e diagnóstico |
| LM para variável omitida | acréscimo de tendência linear | notas de especificação e diagnóstico |
| Teste de Chow | quebra estrutural por período | notas do teste de Chow |

## Métodos removidos do projeto (não ensinados nas fontes oficiais)

Efeitos fixos e aleatórios como estimadores próprios, Mundlak, Hausman, erros agrupados por município, bootstrap e Box-Cox. Newey-West não é aplicado ao painel empilhado: ele corrige erros-padrão de uma série temporal única, e o painel empilhado não atende a essa condição (não aplicado; ver 04_diagnosticos.md). Smearing de Duan também não é usado.

A entropia de Shannon foi removida por engano: ela é ensinada (slides de medidas de desigualdade, pasta `aulas`). A X4 continua sendo o Gini; a entropia fica disponível como medida alternativa.

Fontes oficiais e IDs no Drive: `06_fontes.md`.
