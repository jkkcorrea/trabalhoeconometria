# Especificação e métodos

Três especificações, todas por MQO sobre o painel empilhado:

- **Modelo 2 (comparação, com X6):** ln(Y_it) = b1 + b2 X2 + b3 X3 + b4 X4 + b5 X5 + b6 X6 + u_it.
- **Modelos 3 e 3b:** Modelo 2 com a dummy de Curitiba; o 3b acrescenta a interação X3 x X6.
- **Modelo 4 (principal):** ln(Y_it) = b1 + b2 X2 + b3 X3 + b4 X4 + b5 X5 + dummies de município + u_it.

A escolha do Modelo 4 como principal se apoia nos testes da Etapa 6: o F de acréscimo das dummies rejeita e o RESET passa a não rejeitar. A forma funcional não era o problema; a heterogeneidade entre municípios era. Ver 04_diagnosticos.md.

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
| Durbin-Watson e ρ por regressão auxiliar AR(1) | autocorrelação, série de cada município | notas de autocorrelação; tabela de DW |
| Breusch-Godfrey | autocorrelação, série de cada município | notas de autocorrelação |
| RESET de Ramsey | forma funcional | notas de especificação e diagnóstico |
| LM para variável omitida | acréscimo de tendência linear | notas de especificação e diagnóstico |
| Teste de Chow | quebra estrutural por período | notas do teste de Chow |

## Métodos removidos do projeto (não ensinados nas fontes oficiais)

Efeitos fixos e aleatórios como estimadores próprios, Mundlak, Hausman, erros agrupados por município, bootstrap, Newey-West e Prais-Winsten aplicados ao painel empilhado, Box-Cox, Jarque-Bera, smearing de Duan e a entropia de Shannon.

Fontes oficiais e IDs no Drive: `06_fontes.md`.
