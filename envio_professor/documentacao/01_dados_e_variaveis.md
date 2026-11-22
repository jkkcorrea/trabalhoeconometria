# Dados e variáveis

Painel de 29 municípios da Região Metropolitana de Curitiba, de 2012 a 2021 (290 observações).

| Variável | Definição | Fonte |
|---|---|---|
| Y: ln do salário médio real | logaritmo do salário médio formal, em R$ de 2021 | RAIS (Ministério do Trabalho); IPCA (série 433 do Banco Central) |
| X2: ensino superior (%) | vínculos com ensino superior completo, sobre os vínculos com escolaridade informada | RAIS |
| X3: dominância industrial (%) | VAB da indústria sobre o VAB total, vezes 100 | IBGE, SIDRA (tabela 5938) |
| X4: concentração setorial (Gini) | Gini da participação de cada divisão CNAE no total de vínculos; 87 divisões, zeros incluídos | RAIS (divisão CNAE) |
| X5: Selic real (% a.a.) | Selic anual pela equação de Fisher com o IPCA | Banco Central (séries 4390 e 433) |
| X6: distância a Curitiba (km) | distância entre centroides; Curitiba igual a zero | malha municipal do IBGE (geobr) |

O Gini segue a fórmula do Guia P2 (questão 3): G = (2/n) soma(i x x_(i)) - (n+1)/n, com n = 87 divisões. Tratar divisões como indivíduos e o total de 87 divisões são escolhas a confirmar.

Estatísticas descritivas: `dados_processados/estatisticas_descritivas.csv`. Correlações: `dados_processados/matriz_correlacao_explicativas.csv`.
