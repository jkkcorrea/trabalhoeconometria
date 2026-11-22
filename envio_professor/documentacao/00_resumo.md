# Resumo dos resultados

Todos os números abaixo saem de `resultados_econometricos/`. Escopo: apenas métodos ensinados na disciplina.

## Modelo principal (MQO empilhado, erro de White)

| Termo | Estimativa | Erro-padrão | t | p-valor |
|---|---|---|---|---|
| Constante | 8,1064 | 0,1533 | 52,87 | < 0,0001 |
| X2 ensino superior (%) | 0,0150 | 0,0015 | 10,25 | < 0,0001 |
| X3 dominância industrial (%) | 0,0055 | 0,0007 | 8,13 | < 0,0001 |
| X4 concentração setorial (Gini) | -0,6548 | 0,1678 | -3,90 | 0,0001 |
| X5 Selic real (% a.a.) | 0,0065 | 0,0018 | 3,66 | 0,0003 |
| X6 distância a Curitiba (km) | -0,0016 | 0,0005 | -2,96 | 0,0033 |

F da ANOVA = 105,26 (p-valor < 0,0001); R2 = 0,6495.

## Diagnósticos

- Multicolinearidade: maior FIV = 2,3265 (limite 10).
- Heterocedasticidade (Breusch-Pagan-Godfrey): p-valor 0,0363.
- Forma funcional (RESET): p-valor < 0,0001; rejeita.
- Quebra estrutural (Chow): p-valor 0,1018; não rejeita.
- Autocorrelação positiva dentro dos municípios: 14 de 29 municípios pela tabela de Durbin-Watson.

Detalhes: 03_resultados_modelos.md, 04_diagnosticos.md, 05_limitacoes.md.
