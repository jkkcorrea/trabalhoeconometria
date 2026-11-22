# Resumo dos resultados

Todos os números saem de `resultados_econometricos/`. Escopo: apenas métodos ensinados na disciplina.

## Modelo principal (Modelo 4: MQO com dummies de município e erro de White)

| Termo | Estimativa | Erro-padrão | t | p-valor |
|---|---|---|---|---|
| Constante | 7,2013 | 0,3621 | 19,89 | < 0,0001 |
| X2 ensino superior (%) | 0,0084 | 0,0019 | 4,42 | < 0,0001 |
| X3 dominância industrial (%) | -0,0006 | 0,0007 | -0,83 | 0,4086 |
| X4 concentração setorial (Gini) | 0,8653 | 0,4387 | 1,97 | 0,0496 |
| X5 Selic real (% a.a.) | 0,0039 | 0,0008 | 4,80 | < 0,0001 |

O Modelo 4 inclui 28 variáveis dummy de município (uma categoria de referência). Os coeficientes das dummies estão em `resultados_econometricos/coeficientes_modelos.csv`. X6 é constante dentro de cada município e não é identificada neste modelo.

F da ANOVA = 196,53 (p-valor < 0,0001); R2 = 0,9607.

## Modelo de comparação (Modelo 2: MQO com X6, erro de White)

| Termo | Estimativa | Erro-padrão | t | p-valor |
|---|---|---|---|---|
| Constante | 8,1064 | 0,1533 | 52,87 | < 0,0001 |
| X2 ensino superior (%) | 0,0150 | 0,0015 | 10,25 | < 0,0001 |
| X3 dominância industrial (%) | 0,0055 | 0,0007 | 8,13 | < 0,0001 |
| X4 concentração setorial (Gini) | -0,6548 | 0,1678 | -3,90 | 0,0001 |
| X5 Selic real (% a.a.) | 0,0065 | 0,0018 | 3,66 | 0,0003 |
| X6 distância a Curitiba (km) | -0,0016 | 0,0005 | -2,96 | 0,0033 |

## Diagnósticos

- Heterogeneidade entre municípios: F de acréscimo das dummies = 76,13 (p-valor < 0,0001).
- Forma funcional: RESET p-valor < 0,0001 no Modelo 2 e 0,7527 no Modelo 4.
- Multicolinearidade (Modelo 2): maior FIV = 2,3265 (limite 10).
- Heterocedasticidade (Breusch-Pagan-Godfrey): p-valor 0,0363 no Modelo 2 e 0,0002 no Modelo 4; inferência com White.
- Quebra estrutural (Chow): p-valor 0,1018; não rejeita.
- Autocorrelação: mediana do Durbin-Watson por município = 0,2504 no Modelo 2 e 1,3330 no Modelo 4.

Limitações e pontos a rever: 05_limitacoes.md.
