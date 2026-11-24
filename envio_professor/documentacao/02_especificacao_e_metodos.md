# Especificação e métodos

## Modelo

ln(salário real)_it = β0 + β1 X2_it + β2 X3_it + β3 X4_it + β4 X5_t + β5 X6_i + u_it

Estimação por mínimos quadrados ordinários (MQO) com as 290 observações empilhadas. Inferência com erros-padrão de White (HC1), com t de n − k graus de liberdade (284).

## Hipóteses

H0 geral: o salário médio real formal de um município não depende da sua escolaridade, da sua estrutura de emprego e da sua localização, controlados os efeitos comuns a todos os municípios.
Ha: pelo menos uma dessas condições afeta o salário.

| Hipótese | Variável | Sinal esperado |
|---|---|---|
| H1 | escolaridade (X2) | positivo |
| H2 | industrialização (X3) | positivo |
| H3 | diversificação setorial (X4, Gini invertido) | negativo para o Gini |
| H4 | Selic real (X5) | exploratória, sem sinal único |
| H5 | distância a Curitiba (X6) | negativo |

Critério: rejeita-se H0 no coeficiente quando p < 0,05.

## Métodos usados

| Método | Uso no trabalho | Referência (Gujarati, 4ª ed., PDF) |
|---|---|---|
| MQO e álgebra matricial | estimação e memorial | caps. 6 e 7 |
| Erros-padrão de White (HC1) | inferência | cap. 11, p. 442 em diante |
| Multicolinearidade (FIV e tolerância) | diagnóstico | cap. 10 |
| Breusch-Pagan-Godfrey | heterocedasticidade | cap. 11, pp. 439 e 440 |
| Goldfeld-Quandt | heterocedasticidade | cap. 11, pp. 436 a 440 |
| Shapiro-Wilk e gráfico Q-Q | normalidade dos resíduos | orientação do professor |
| RESET de Ramsey | forma funcional | cap. 13, pp. 549 a 552 |
| Teste LM para tendência linear | variável omitida (ano) | cap. 13 |
| Teste de Chow | quebra estrutural | cap. 8, pp. 303 a 309 |
| Durbin-Watson (tabela D.5A) | autocorrelação, série de cada município | cap. 12, pp. 495 a 499; Apêndice D, p. 995 |
| Breusch-Godfrey (ordem 1) | autocorrelação, série de cada município | cap. 12, pp. 499 e 500 |
| Retransformação do logaritmo | previsão em reais com correção exp(s²/2) | presunção da modelagem |

## Projeção

A projeção é uma previsão dentro da amostra para 2021, último ano com todas as variáveis publicadas. Não há previsão para 2026. A previsão é x0'b; o intervalo da média usa x0'(X'X)^-1 x0 σ², e o intervalo individual, σ²(1 + x0'(X'X)^-1 x0).

Viés da retransformação: a média em reais é exp(previsão + s²/2) sob erros normais. Aplicamos o fator exp(s²/2) = 1,0075. Como a normalidade é rejeitada, a correção é aproximada.

