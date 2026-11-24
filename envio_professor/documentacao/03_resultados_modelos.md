# Resultados do modelo principal

## Coeficientes com erro de White (HC1)

| Variável | Coeficiente | EP (White) | t | p-valor | IC 95% inferior | IC 95% superior |
|---|---|---|---|---|---|---|
| X2 escolaridade (proporção com superior completo, %) | 0,0150 | 0,0015 | 10,25 | < 0,0001 | 0,0122 | 0,0179 |
| X3 industrialização (VAB da indústria / VAB total, %) | 0,0055 | 0,0007 | 8,13 | < 0,0001 | 0,0042 | 0,0069 |
| X4 Gini setorial (vínculos entre 87 divisões CNAE) | -0,6548 | 0,1678 | -3,90 | 0,0001 | -0,9851 | -0,3244 |
| X5 Selic real (% a.a.) | 0,0065 | 0,0018 | 3,66 | 0,0003 | 0,0030 | 0,0101 |
| X6 distância a Curitiba (km) | -0,0016 | 0,0005 | -2,96 | 0,0033 | -0,0026 | -0,0005 |
| Intercepto | 8,1064 | 0,1533 | 52,87 | < 0,0001 | 7,8046 | 8,4082 |

## Coeficientes com erro clássico (comparação)

| Variável | Coeficiente | EP (clássico) | p-valor (clássico) |
|---|---|---|---|
| X2 escolaridade (proporção com superior completo, %) | 0,0150 | 0,0013 | < 0,0001 |
| X3 industrialização (VAB da indústria / VAB total, %) | 0,0055 | 0,0005 | < 0,0001 |
| X4 Gini setorial (vínculos entre 87 divisões CNAE) | -0,6548 | 0,1640 | < 0,0001 |
| X5 Selic real (% a.a.) | 0,0065 | 0,0021 | 0,0018 |
| X6 distância a Curitiba (km) | -0,0016 | 0,0005 | 0,0007 |
| Intercepto | 8,1064 | 0,1356 | < 0,0001 |

## Efeito da Selic

Cada ponto percentual a mais da Selic real está associado a um salário 0,66% maior (efeito ln = 0,0065; IC 95% [0,0030; 0,0101]; gl 284; p-valor 0,0003).

## Robustez da X4: definição do Gini

| Definição | Coeficiente | p-valor | R2 ajustado | AIC |
|---|---|---|---|---|
| 87 divisões (zeros incluídos) | -0,6548 | 0,0001 | 0,6433 | -388,30 |
| somente divisões com vínculo | -0,6378 | 0,0011 | 0,6356 | -382,07 |

A definição com as 87 divisões (zeros incluídos) é a usada no modelo principal. A versão só com as divisões que têm vínculo é apresentada como verificação; a definição final depende de orientação do professor.

Correlação entre o Gini e o número de divisões com vínculo: -0,9497.

## Projeção de 2021

| Cenário | Selic (% a.a.) | Média prevista sem correção (R$) | Média prevista com correção (R$) |
|---|---|---|---|
| Selic de 2021 | -5,11 | 2602,47 | 2621,97 |
| Selic de 2021 + 1 p.p. | -4,11 | 2619,55 | 2639,18 |
| Selic de 2021 - 1 p.p. | -6,11 | 2585,50 | 2604,87 |

O fator de correção exp(s²/2) é 1,0075. Com a correção, a previsão média em reais sobe nessa proporção.

