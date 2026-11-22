# Resultados dos modelos

Coeficientes com erro de White (HC1) e t com n - k graus de liberdade. Erro clássico em `coeficientes_modelos.csv`.

## Modelo 4 (principal), erro de White

| Termo | Estimativa | Erro-padrão | t | p-valor |
|---|---|---|---|---|
| Constante | 7,2013 | 0,3621 | 19,89 | < 0,0001 |
| X2 ensino superior (%) | 0,0084 | 0,0019 | 4,42 | < 0,0001 |
| X3 dominância industrial (%) | -0,0006 | 0,0007 | -0,83 | 0,4086 |
| X4 concentração setorial (Gini) | 0,8653 | 0,4387 | 1,97 | 0,0496 |
| X5 Selic real (% a.a.) | 0,0039 | 0,0008 | 4,80 | < 0,0001 |

O Modelo 4 inclui 28 variáveis dummy de município (uma categoria de referência). Os coeficientes das dummies estão em `resultados_econometricos/coeficientes_modelos.csv`. X6 é constante dentro de cada município e não é identificada neste modelo.

## Modelo 2 (comparação), erro de White

| Termo | Estimativa | Erro-padrão | t | p-valor |
|---|---|---|---|---|
| Constante | 8,1064 | 0,1533 | 52,87 | < 0,0001 |
| X2 ensino superior (%) | 0,0150 | 0,0015 | 10,25 | < 0,0001 |
| X3 dominância industrial (%) | 0,0055 | 0,0007 | 8,13 | < 0,0001 |
| X4 concentração setorial (Gini) | -0,6548 | 0,1678 | -3,90 | 0,0001 |
| X5 Selic real (% a.a.) | 0,0065 | 0,0018 | 3,66 | 0,0003 |
| X6 distância a Curitiba (km) | -0,0016 | 0,0005 | -2,96 | 0,0033 |

## Modelo 3, erro de White

| Termo | Estimativa | Erro-padrão | t | p-valor |
|---|---|---|---|---|
| Constante | 8,1137 | 0,1568 | 51,74 | < 0,0001 |
| X2 ensino superior (%) | 0,0120 | 0,0016 | 7,62 | < 0,0001 |
| X3 dominância industrial (%) | 0,0056 | 0,0007 | 8,09 | < 0,0001 |
| X4 concentração setorial (Gini) | -0,6361 | 0,1738 | -3,66 | 0,0003 |
| X5 Selic real (% a.a.) | 0,0063 | 0,0017 | 3,77 | 0,0002 |
| X6 distância a Curitiba (km) | -0,0013 | 0,0005 | -2,38 | 0,0182 |
| Dummy de Curitiba | 0,2023 | 0,0390 | 5,19 | < 0,0001 |

## Modelo 3b, erro de White

| Termo | Estimativa | Erro-padrão | t | p-valor |
|---|---|---|---|---|
| Constante | 8,1421 | 0,1647 | 49,44 | < 0,0001 |
| X2 ensino superior (%) | 0,0120 | 0,0016 | 7,43 | < 0,0001 |
| X3 dominância industrial (%) | 0,0039 | 0,0019 | 2,05 | 0,0412 |
| X4 concentração setorial (Gini) | -0,6166 | 0,1679 | -3,67 | 0,0003 |
| X5 Selic real (% a.a.) | 0,0063 | 0,0017 | 3,77 | 0,0002 |
| X6 distância a Curitiba (km) | -0,0021 | 0,0010 | -2,13 | 0,0345 |
| Dummy de Curitiba | 0,1911 | 0,0431 | 4,43 | < 0,0001 |
| X3 x X6 (interação) | 0,0000 | 0,0000 | 1,03 | 0,3043 |

## Significância conjunta (F da ANOVA)

| Modelo | F | gl | p-valor | R2 | R2 ajustado |
|---|---|---|---|---|---|
| Modelo 2 | 105,26 | 5; 284 | < 0,0001 | 0,6495 | 0,6433 |
| Modelo 3 | 95,95 | 6; 283 | < 0,0001 | 0,6704 | 0,6634 |
| Modelo 3b | 83,27 | 7; 282 | < 0,0001 | 0,6740 | 0,6659 |
| Modelo 4 | 196,53 | 32; 257 | < 0,0001 | 0,9607 | 0,9558 |

## Leitura dos coeficientes

- X2 é positivo nos dois modelos e significativo a 5%: a associação não depende de comparar municípios diferentes.
- X3 é positivo entre municípios (Modelo 2) e não significativo dentro deles (Modelo 4).
- X4 tem sinal negativo no Modelo 2 e positivo no Modelo 4, consistente com a correlação de -0,95 com o número de setores ativos (ver 04_diagnosticos.md).
- X5 é significativo no Modelo 4, mas a inferência usa 257 graus de liberdade com apenas 10 valores de Selic (ver 04_diagnosticos.md).
