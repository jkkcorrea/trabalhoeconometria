# Especificação e métodos

Modelo principal (Modelo 2), estimado por MQO sobre o painel empilhado:

ln(Y_it) = b1 + b2 X2_it + b3 X3_it + b4 X4_it + b5 X5_t + b6 X6_i + u_it

Modelo 3 acrescenta a dummy de Curitiba; Modelo 3b acrescenta a interação X3 x X6.

## Métodos usados (todos ensinados na disciplina)

| Método | Uso no projeto | Fonte oficial |
|---|---|---|
| MQO e álgebra matricial | estimação e memorial | notas de regressão múltipla |
| t, F, ANOVA, R2 | inferência | notas de regressão múltipla |
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

Efeitos fixos e aleatórios, Mundlak, Hausman, erros agrupados por município, bootstrap, Newey-West e Prais-Winsten aplicados ao painel empilhado, Box-Cox, Jarque-Bera, smearing de Duan e a entropia de Shannon.

Fontes oficiais e IDs no Drive: `documentacao/06_fontes.md`.
