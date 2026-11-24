# Dados e variáveis

Unidades: os 29 municípios da Região Metropolitana de Curitiba (código IBGE 05501), de 2012 a 2021. Painel balanceado com 290 observações.

## Fontes

| Dado | Origem | Observação |
|---|---|---|
| Salário médio formal | RAIS (Ministério do Trabalho), microdados públicos | Remuneração média dos vínculos |
| Escolaridade (X2) | RAIS | Proporção dos vínculos com ensino superior completo |
| Industrialização (X3) | IBGE, SIDRA, tabela 5938 | VAB da indústria sobre o VAB total |
| Gini setorial (X4) | RAIS | Vínculos por divisão da CNAE (87 divisões) |
| Selic real (X5) | Banco Central, SGS (séries 4390 e 433) | Selic acumulada no ano, deflacionada pelo IPCA |
| Distância a Curitiba (X6) | IBGE, malha municipal | Distância entre centroides, em km; Curitiba = 0 |
| Deflator | IBGE, IPCA (série 433 do Banco Central) | Salários em reais de 2021 |

## Variáveis e estatísticas descritivas

| Variável | Média | Mínimo | Máximo |
|---|---|---|---|
| salario_medio_real | 2651,2452 | 1792,6963 | 4501,1183 |
| ln_salario_real | 7,8609 | 7,4915 | 8,4121 |
| prop_superior | 15,2523 | 2,7798 | 35,9181 |
| dom_industrial | 25,6705 | -14,0686 | 67,5915 |
| gini_setorial | 0,8537 | 0,7328 | 0,9740 |
| selic_real | 2,2707 | -5,1111 | 7,2824 |
| dist_curitiba_km | 45,9174 | 0,0000 | 94,8916 |

Observação: VAB industrial negativo em Araucária (2012 e 2013), mantido como publicado pelo IBGE e marcado no painel. Adrianópolis tem salto da participação industrial entre 2014 e 2015, confirmado na fonte.

Os salários estão em reais de 2021. O logaritmo natural é usado porque os salários são positivos e a distribuição é assimétrica à direita; o coeficiente de uma variável explicativa então indica variação relativa (%) do salário.
