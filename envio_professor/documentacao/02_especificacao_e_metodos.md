# Especificação e métodos

## Modelos estimados

Notação: i indexa o município (i = 1, ..., 29), t o ano (2012 a 2021). X2 a X6 são definidas em `01_dados_e_variaveis.md`.

| Modelo | Equação | Script |
|---|---|---|
| 1 | Y_it = b1 + b2 X2_it + u_it (nível) | 04 |
| 2 | ln Y_it = b1 + b2 X2_it + b3 X3_it + b4 X4_it + b5 X5_t + b6 X6_i + u_it | 04 |
| 3 | Modelo 2 + b7 D_Curitiba_i | 04 |
| 3b | Modelo 3 + b8 (X3_it x X6_i) | 04 |
| 3c | Modelo 3b com X3 e X6 centradas nas médias amostrais | 05 |
| 4 | Modelo 2 + b7 Tendência_t (ano - 2012) | 05 |
| Mundlak | Modelo 2 + g2 mean_i(X2) + g3 mean_i(X3) + g4 mean_i(X4) | 05 e 06 |
| Efeitos fixos (within) | ln Y_it = a_i + b2 X2_it + b3 X3_it + b4 X4_it + b5 X5_t + u_it | 06 |
| Efeitos fixos de município e ano | ln Y_it = a_i + l_t + b2 X2_it + b3 X3_it + b4 X4_it + u_it | 06 |
| Prais-Winsten | Modelo 2 transformado por (y_t - r y_t-1) dentro de cada município, com a primeira observação multiplicada por raiz(1 - r^2); r comum, iterado até convergir | 06 |
| Primeiras diferenças | d ln Y_it = c + b2 d X2_it + b3 d X3_it + b4 d X4_it + b5 d X5_t + e_it | 06 |
| Efeitos fixos com quadráticos | ln Y_it = a_i + b2 X2_it + b3 X3_it + b4 X4_it + b5 X5_t + c2 X2_it^2 + c3 X3_it^2 + c4 X4_it^2 + u_it | 08 |
| Efeitos fixos com valores futuros | Efeitos fixos linear + d2 X2_i,t+1 + d3 X3_i,t+1 + d4 X4_i,t+1 (teste de exogeneidade estrita) | 08 |
| Efeitos fixos com regressores defasados | ln Y_it = a_i + b2 X2_i,t-1 + b3 X3_i,t-1 + b4 X4_i,t-1 + b5 X5_t + u_it | 08 |

No modelo de efeitos fixos, X6 e a indicadora de Curitiba são absorvidas pelo efeito de município; no modelo com efeitos de ano, X5 também é absorvida. O modelo de Mundlak preserva X5 e X6 e estima, para X2, X3 e X4, os mesmos coeficientes do modelo de efeitos fixos.

## Estimação por mínimos quadrados ordinários

Estimador b = (X'X)^-1 X'y; soma dos quadrados dos resíduos SQR = y'y - b'X'y; variância estimada s^2 = SQR/(n - k); matriz de variância e covariância clássica s^2 (X'X)^-1. O cálculo matricial completo do Modelo 2 está em `resultados_econometricos/memorial_modelo_2.txt`, conferido contra `lm()`.

## Matrizes de covariância dos estimadores

- Clássica: s^2 (X'X)^-1.
- White (HC1): corrige heterocedasticidade de forma desconhecida.
- Newey-West: corrige heterocedasticidade e autocorrelação de uma única série temporal; no painel empilhado serve apenas como referência, porque cruza fronteiras entre municípios (28 pares de observações vizinhas pertencem a municípios diferentes).
- Agrupada por município (HC1): robusta a heterocedasticidade e a correlação arbitrária dentro de cada município. Fórmula: G/(G-1) x (n-1)/(n-k) x (X'X)^-1 [soma dos X_g' e_g e_g' X_g] (X'X)^-1, com G = 29. Os testes t usam G - 1 = 28 graus de liberdade nas tabelas de calibração (script 06) e os graus de liberdade residuais nas tabelas do script 04.
- Agrupada por município e ano: dois eixos, tipo HC1.
- Agrupada por ano (G = 10, t com 9 graus de liberdade): usada apenas para X5, porque X5 varia só entre anos e a dependência entre municípios no mesmo ano não é captada pelo agrupamento por município.

## Testes e regras de decisão (nível de significância de 5%)

| Teste | H0 | Ha | Critério a 5% |
|---|---|---|---|
| Fator de inflação da variância (FIV) | sem multicolinearidade severa | multicolinearidade severa | FIV > 10 indica multicolinearidade severa (TOL < 0,10) |
| Breusch-Pagan-Godfrey (studentizado) | homocedasticidade | heterocedasticidade | rejeita H0 se p-valor < 0,05 |
| White | homocedasticidade | heterocedasticidade | rejeita H0 se p-valor < 0,05 |
| Goldfeld-Quandt | homocedasticidade | variância crescente com a variável de ordenação (unilateral) | rejeita H0 se p-valor < 0,05 |
| Durbin-Watson | sem autocorrelação de ordem 1 | autocorrelação de ordem 1 (bilateral) | rejeita H0 se p-valor < 0,05 (no painel empilhado o teste cruza fronteiras entre municípios) |
| Breusch-Godfrey | sem autocorrelação até a ordem 1 | autocorrelação até a ordem 1 | rejeita H0 se p-valor < 0,05 |
| Jarque-Bera | resíduos normais | resíduos não normais | rejeita H0 se p-valor < 0,05 |
| Shapiro-Wilk | resíduos normais | resíduos não normais | rejeita H0 se p-valor < 0,05 |
| RESET de Ramsey | forma funcional correta | forma funcional incorreta | rejeita H0 se p-valor < 0,05 |
| Teste F de efeitos individuais | sem efeitos individuais | existem efeitos individuais | rejeita H0 se p-valor < 0,05 |
| Breusch-Pagan de multiplicadores de Lagrange | sem efeitos individuais | existem efeitos individuais | rejeita H0 se p-valor < 0,05 |
| Hausman | efeitos aleatórios consistentes | efeitos aleatórios inconsistentes | rejeita H0 se p-valor < 0,05; rejeição favorece efeitos fixos |
| Mundlak | médias por município com coeficientes nulos (efeito do município não correlacionado com X) | alguma média por município com coeficiente não nulo | rejeita H0 se p-valor < 0,05; rejeição indica que o MQO empilhado é viesado nas variáveis que variam no tempo |
| Wooldridge e Breusch-Godfrey de painel | sem autocorrelação de primeira ordem (modelo within) | autocorrelação de primeira ordem (modelo within) | rejeita H0 se p-valor < 0,05 |
| Exogeneidade estrita | valores futuros de X2, X3 e X4 com coeficientes nulos | alguma defasagem futura com coeficiente não nulo | rejeita H0 se p-valor < 0,05; rejeição indica retroalimentação ou antecipação |
| Termos quadráticos conjuntos | quadráticos de X2, X3 e X4 com coeficientes nulos | algum quadrático com coeficiente não nulo | rejeita H0 se p-valor < 0,05 (F com 3 e 28 gl) |
| Box-Cox | lambda igual a 0 (logaritmo) ou a 1 (nível) | forma de Y em nível ou em logaritmo rejeitada (razão de verossimilhança) | rejeita H0 se a razão de verossimilhança excede o qui-quadrado de 1 gl (3,8415) |
| Chow (Curitiba) | coeficientes de X2 a X5 iguais em Curitiba e nos demais | coeficientes diferentes em Curitiba | rejeita H0 se p-valor < 0,05 (F com 5 e 280 gl, teste clássico) |

## Bootstrap wild cluster

Procedimento restrito de Cameron, Gelbach e Miller (2008) com pesos de Rademacher: para H0: b_j = 0, estima o modelo sem a variável j, gera y* = ajustado_restrito + w_g x resíduo_restrito, com w_g igual a -1 ou +1 por município, reestima o modelo completo e compara a estatística t agrupada de cada réplica com a observada. 9.999 réplicas, 29 clusters, semente fixa. Implementação própria em `R/06_calibracao_modelo.R`. Com 10 grupos (Selic por ano) usam-se também o bootstrap exato, com as 2^10 combinações de sinais, e o bootstrap com pesos de Webb (seis pontos, 9.999 réplicas), que é o padrão com poucos grupos; em cada réplica de um modelo within a variável dependente é transformada de novo por município.

## Convenções

- Nível de significância: 5%.
- Valores em quatro casas decimais nas tabelas desta documentação; os arquivos CSV trazem a precisão completa.
- Coeficientes de modelos em ln Y: a variação percentual aproximada de Y associada a uma unidade de X é 100 x (exp(b) - 1).
