# Dados e variáveis

## Escopo

- Unidades: 29 municípios da Região Metropolitana de Curitiba (composição oficial, código 05501 da API de localidades do IBGE).
- Período: 2012 a 2021 (10 anos).
- Observações: 290 (painel balanceado, 29 municípios x 10 anos), sem valores ausentes nas variáveis do modelo.
- Unidade de análise: município-ano.

## Municípios (numeração usada nos mapas)

| Número | Código IBGE | Município |
|---|---|---|
| 1 | 4100202 | Adrianópolis |
| 2 | 4100301 | Agudos do Sul |
| 3 | 4100400 | Almirante Tamandaré |
| 4 | 4101804 | Araucária |
| 5 | 4102307 | Balsa Nova |
| 6 | 4103107 | Bocaiúva do Sul |
| 7 | 4104006 | Campina Grande do Sul |
| 8 | 4104204 | Campo Largo |
| 9 | 4104253 | Campo Magro |
| 10 | 4104105 | Campo do Tenente |
| 11 | 4105201 | Cerro Azul |
| 12 | 4105805 | Colombo |
| 13 | 4106209 | Contenda |
| 14 | 4106902 | Curitiba |
| 15 | 4128633 | Doutor Ulysses |
| 16 | 4107652 | Fazenda Rio Grande |
| 17 | 4111258 | Itaperuçu |
| 18 | 4113205 | Lapa |
| 19 | 4114302 | Mandirituba |
| 20 | 4119152 | Pinhais |
| 21 | 4119509 | Piraquara |
| 22 | 4119103 | Piên |
| 23 | 4120804 | Quatro Barras |
| 24 | 4121208 | Quitandinha |
| 25 | 4122206 | Rio Branco do Sul |
| 26 | 4122305 | Rio Negro |
| 27 | 4125506 | São José dos Pinhais |
| 28 | 4127601 | Tijucas do Sul |
| 29 | 4127882 | Tunas do Paraná |

## Dicionário de variáveis

| Símbolo | Nome no painel | Definição | Fonte | Varia em |
|---|---|---|---|---|
| Y | salario_medio_real | Remuneração média nominal dos vínculos ativos em 31/12, multiplicada pelo fator de deflação (índice acumulado do IPCA, média anual, base 2021). Reais de 2021. | RAIS (Ministério do Trabalho); IPCA, SGS/Banco Central, série 433 | município e ano |
| ln Y | ln_salario_real | Logaritmo natural de Y. | derivada | município e ano |
| X2 | prop_superior | Vínculos ativos com superior completo, mestrado ou doutorado, divididos pelos vínculos ativos com escolaridade informada, em %. | RAIS (Ministério do Trabalho) | município e ano |
| X3 | dom_industrial | Valor adicionado bruto da indústria dividido pelo valor adicionado bruto total (soma dos quatro setores), em %. | PIB dos Municípios, IBGE (SIDRA, tabela 5938) | município e ano |
| X4 | shannon_diversificacao | Entropia de Shannon, -soma(p ln p), da distribuição dos vínculos ativos pelas divisões da CNAE 2.0 (87 divisões). | RAIS (Ministério do Trabalho) | município e ano |
| X5 | selic_real | Selic real anual pela equação de Fisher: ((1 + Selic)/(1 + IPCA) - 1) x 100, com Selic e IPCA do ano compostos a partir dos 12 valores mensais. | Banco Central, SGS, séries 4390 (Selic) e 433 (IPCA) | ano (igual para todos os municípios) |
| X6 | dist_curitiba_km | Distância em km entre o centroide do município e o centroide de Curitiba, em SIRGAS 2000 / UTM 22S (EPSG 31982). | Malha municipal do IBGE | município (constante no tempo) |
| Indicadora | dummy_curitiba | 1 para Curitiba, 0 para os demais. | derivada | município |
| x3_negativo | x3_negativo | Verdadeiro quando X3 < 0 (valor adicionado da indústria negativo na fonte). | derivada | município e ano |
| shannon_normalizado | shannon_normalizado | X4 dividido por ln(87); varia entre 0 e 1. | derivada | município e ano |

Variação das variáveis explicativas:

- X5 assume 10 valores distintos, um por ano, iguais para todos os municípios.
- X6 é constante no tempo dentro de cada município; Curitiba tem distância zero.
- X2, X3 e X4 variam entre municípios e no tempo.

Selic real por ano:

| Ano | Selic real (% a.a.) |
|---|---|
| 2012 | 2,4979 |
| 2013 | 2,1740 |
| 2014 | 4,2313 |
| 2015 | 2,3604 |
| 2016 | 7,2824 |
| 2017 | 6,8076 |
| 2018 | 2,5794 |
| 2019 | 1,5722 |
| 2020 | -1,6873 |
| 2021 | -5,1111 |

## Estatísticas descritivas

| Variável | N | Média | Desvio-padrão | Mediana | Mínimo | Máximo |
|---|---|---|---|---|---|---|
| Y salário médio real (R$ de 2021) | 290 | 2.651,2452 | 589,0471 | 2.541,4292 | 1.792,6963 | 4.501,1183 |
| ln Y | 290 | 7,8609 | 0,2046 | 7,8405 | 7,4915 | 8,4121 |
| X2 ensino superior (%) | 290 | 15,2523 | 5,7988 | 15,1200 | 2,7798 | 35,9181 |
| X3 dominância industrial (%) | 290 | 25,6705 | 16,4609 | 22,6422 | -14,0686 | 67,5915 |
| X4 diversificação (Shannon) | 290 | 2,6513 | 0,5446 | 2,6954 | 0,9874 | 3,4156 |
| X4 normalizado (0 a 1) | 290 | 0,5937 | 0,1219 | 0,6036 | 0,2211 | 0,7648 |
| X5 Selic real (% a.a.) | 290 | 2,2707 | 3,4752 | 2,4291 | -5,1111 | 7,2824 |
| X6 distância (km) | 290 | 45,9174 | 23,0810 | 44,0070 | 0,0000 | 94,8916 |

## Correlação de Pearson entre as variáveis do modelo

| Variável | ln Y | X2 | X3 | X4 | X5 | X6 |
|---|---|---|---|---|---|---|
| ln Y | 1,0000 | 0,4898 | 0,4792 | 0,5622 | 0,0648 | -0,5330 |
| X2 | 0,4898 | 1,0000 | -0,1078 | 0,1649 | -0,0475 | -0,3229 |
| X3 | 0,4792 | -0,1078 | 1,0000 | 0,3616 | -0,0460 | -0,1375 |
| X4 | 0,5622 | 0,1649 | 0,3616 | 1,0000 | -0,0317 | -0,7398 |
| X5 | 0,0648 | -0,0475 | -0,0460 | -0,0317 | 1,0000 | 2,395e-21 |
| X6 | -0,5330 | -0,3229 | -0,1375 | -0,7398 | 2,395e-21 | 1,0000 |

A correlação de X4 com X6 é -0,7398, a maior em módulo entre as variáveis explicativas. X5 varia só no tempo e X6 só entre municípios, por isso a correlação entre elas é 2,395e-21.

## Observações com valor adicionado da indústria negativo

O valor publicado pelo IBGE para o valor adicionado bruto da indústria é negativo nas duas observações abaixo. O painel mantém o valor da fonte e as marca em `x3_negativo`; o Modelo 2 é reestimado sem elas como teste de robustez.

| Município | Ano | X3 (%) |
|---|---|---|
| Araucária | 2012 | -14,0686 |
| Araucária | 2013 | -5,1965 |

## Construção do painel

1. Remuneração média: média da remuneração média nominal entre os vínculos ativos em 31/12 com remuneração maior que zero, por município e ano (média simples, sem ponderar pelos meses trabalhados).
2. Escolaridade: vínculos com superior completo, mestrado ou doutorado (códigos 9, 10 e 11 da RAIS).
3. Divisão da CNAE 2.0: dois primeiros dígitos da classe de cinco dígitos. Todos os vínculos têm divisão válida (nenhum vínculo sem divisão) e o conjunto de divisões distintas observadas no período é 87.
4. Deflator: índice de preços com base 100 no primeiro mês da amostra, acumulando a variação mensal do IPCA (série 433); o valor anual é a média dos 12 meses; fator de deflação = índice de 2021 dividido pelo índice do ano.
5. Verificações do painel: 290 linhas, 29 municípios, 10 anos, sem duplicidade de município e ano, sem NA, NaN ou Inf nas variáveis do modelo, X5 constante entre municípios em cada ano, X6 constante no tempo em cada município, Curitiba com distância zero.

Os arquivos `dados_processados/dados_painel_rmc.csv` e `.rds` contêm o painel completo, com as colunas auxiliares (`selic_nominal_ano`, `ipca_ano`, `indice_ipca_medio`, `vinculos_ativos`, `vinculos_superior`, `vinculos_escolaridade_na`, `pib`, `vab_total_soma`, `vab_industria`).
