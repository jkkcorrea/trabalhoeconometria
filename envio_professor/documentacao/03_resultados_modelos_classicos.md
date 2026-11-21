# Resultados dos modelos clássicos (script 04 e memorial do script 07)

Todas as tabelas foram geradas a partir dos arquivos de `resultados_econometricos/`. As colunas "clássico" usam s^2 (X'X)^-1; as "agrupado", a matriz agrupada por município (HC1). Nesta seção os p-valores agrupados usam os graus de liberdade residuais do `coeftest`; as tabelas de calibração (`04_calibracao.md`) usam 28 graus de liberdade.

## Ajuste dos modelos

| Modelo | N | Parâmetros | R² | R² ajustado | F (gl) | p do F | Erro-padrão residual |
|---|---|---|---|---|---|---|---|
| 1 (Y em nível) | 290 | 2 | 0,2539 | 0,2513 | 98,0000 (1; 288) | < 0,0001 | 509,6890 |
| 2 | 290 | 6 | 0,6456 | 0,6393 | 103,4549 (5; 284) | < 0,0001 | 0,1229 |
| 3 | 290 | 7 | 0,6692 | 0,6622 | 95,4352 (6; 283) | < 0,0001 | 0,1189 |
| 3b | 290 | 8 | 0,6706 | 0,6624 | 82,0185 (7; 282) | < 0,0001 | 0,1189 |

## Modelo 1 (nível)

| Termo | Estimativa | EP clássico | t clássico | p clássico |
|---|---|---|---|---|
| Intercepto | 1.870,5763 | 84,3482 | 22,1768 | < 0,0001 |
| X2 ensino superior (%) | 51,1836 | 5,1703 | 9,8995 | < 0,0001 |

## Modelo 2

| Termo | Estimativa | EP clássico | t clássico | p clássico | EP agrupado | t agrupado | p agrupado | Variação % de Y |
|---|---|---|---|---|---|---|---|---|
| Intercepto | 7,3341 | 0,0787 | 93,2368 | < 0,0001 | 0,2007 | 36,5462 | < 0,0001 |  |
| X2 ensino superior (%) | 0,0159 | 0,0013 | 11,8917 | < 0,0001 | 0,0031 | 5,1023 | < 0,0001 | 1,61 |
| X3 dominância industrial (%) | 0,0054 | 0,0005 | 11,1393 | < 0,0001 | 0,0011 | 4,8333 | < 0,0001 | 0,54 |
| X4 diversificação (Shannon) | 0,0762 | 0,0215 | 3,5491 | 0,0005 | 0,0520 | 1,4647 | 0,1441 | 7,92 |
| X5 Selic real (% a.a.) | 0,0066 | 0,0021 | 3,1782 | 0,0016 | 0,0016 | 4,0711 | < 0,0001 | 0,67 |
| X6 distância a Curitiba (km) | -0,0016 | 0,0005 | -3,1733 | 0,0017 | 0,0016 | -0,9719 | 0,3320 | -0,16 |

## Modelo 3 (com indicadora de Curitiba)

| Termo | Estimativa | EP clássico | t clássico | p clássico | EP agrupado | t agrupado | p agrupado | Variação % de Y |
|---|---|---|---|---|---|---|---|---|
| Intercepto | 7,3448 | 0,0762 | 96,4398 | < 0,0001 | 0,2050 | 35,8237 | < 0,0001 |  |
| X2 ensino superior (%) | 0,0126 | 0,0015 | 8,5034 | < 0,0001 | 0,0031 | 4,0878 | < 0,0001 | 1,27 |
| X3 dominância industrial (%) | 0,0055 | 0,0005 | 11,6182 | < 0,0001 | 0,0011 | 4,9375 | < 0,0001 | 0,55 |
| X4 diversificação (Shannon) | 0,0801 | 0,0208 | 3,8537 | 0,0001 | 0,0542 | 1,4794 | 0,1402 | 8,34 |
| X5 Selic real (% a.a.) | 0,0064 | 0,0020 | 3,1696 | 0,0017 | 0,0016 | 4,0992 | < 0,0001 | 0,64 |
| X6 distância a Curitiba (km) | -0,0011 | 0,0005 | -2,2911 | 0,0227 | 0,0017 | -0,6779 | 0,4984 | -0,11 |
| Indicadora de Curitiba | 0,2154 | 0,0479 | 4,5010 | < 0,0001 | 0,0924 | 2,3318 | 0,0204 | 24,03 |

Nos Modelos 3 e 3b a indicadora isola um único município e os resíduos de Curitiba somam zero; o erro-padrão robusto da indicadora não é confiável. Por isso o teste F sob matrizes robustas exclui a indicadora da hipótese (tabela de testes F abaixo); o F clássico mantém todas as inclinações.

## Modelo 3b (com interação X3 x X6, sem centralizar)

| Termo | Estimativa | EP clássico | t clássico | p clássico | EP agrupado | t agrupado | p agrupado | Variação % de Y |
|---|---|---|---|---|---|---|---|---|
| Intercepto | 7,3920 | 0,0878 | 84,2222 | < 0,0001 | 0,2027 | 36,4747 | < 0,0001 |  |
| X2 ensino superior (%) | 0,0127 | 0,0015 | 8,5268 | < 0,0001 | 0,0032 | 3,9735 | < 0,0001 | 1,28 |
| X3 dominância industrial (%) | 0,0044 | 0,0011 | 4,1285 | < 0,0001 | 0,0019 | 2,2762 | 0,0236 | 0,44 |
| X4 diversificação (Shannon) | 0,0743 | 0,0215 | 3,4616 | 0,0006 | 0,0532 | 1,3972 | 0,1634 | 7,72 |
| X5 Selic real (% a.a.) | 0,0064 | 0,0020 | 3,1595 | 0,0018 | 0,0016 | 4,0795 | < 0,0001 | 0,64 |
| X6 distância a Curitiba (km) | -0,0018 | 0,0008 | -2,2965 | 0,0224 | 0,0015 | -1,1725 | 0,2420 | -0,18 |
| Indicadora de Curitiba | 0,2075 | 0,0484 | 4,2880 | < 0,0001 | 0,0910 | 2,2802 | 0,0233 | 23,06 |
| X3 x X6 (interação) | 2,132e-05 | 1,969e-05 | 1,0823 | 0,2800 | 2,946e-05 | 0,7235 | 0,4700 |  |

## Diagnósticos do Modelo 2

| Bloco | Teste | H0 | Ha | Estatística | Valor crítico (5%) | Graus de liberdade | p-valor | Decisão a 5% |
|---|---|---|---|---|---|---|---|---|
| A. Multicolinearidade | FIV de prop_superior |  |  | 1,1548 |  | TOL = 0,8660 |  | sem multicolinearidade severa |
| A. Multicolinearidade | FIV de dom_industrial |  |  | 1,2238 |  | TOL = 0,8171 |  | sem multicolinearidade severa |
| A. Multicolinearidade | FIV de shannon_diversificacao |  |  | 2,6166 |  | TOL = 0,3822 |  | sem multicolinearidade severa |
| A. Multicolinearidade | FIV de selic_real |  |  | 1,0068 |  | TOL = 0,9932 |  | sem multicolinearidade severa |
| A. Multicolinearidade | FIV de dist_curitiba_km |  |  | 2,5019 |  | TOL = 0,3997 |  | sem multicolinearidade severa |
| B. Heterocedasticidade | Breusch-Pagan-Godfrey (studentizado) | homocedasticidade | heterocedasticidade | 13,0536 | 11,0705 | df = 5 | 0,0229 | rejeita H0 |
| B. Heterocedasticidade | White reduzido (regressores e quadrados de X2, X3 e X4) | homocedasticidade | heterocedasticidade | 47,8403 | 15,5073 | df = 8 | < 0,0001 | rejeita H0 |
| B. Heterocedasticidade | White completo (regressores, quadrados e produtos cruzados) | homocedasticidade | heterocedasticidade | 114,6801 | 31,4104 | df = 20 | < 0,0001 | rejeita H0 |
| C. Autocorrelação | Durbin-Watson empilhado (inválido no painel) | ausência de autocorrelação de ordem 1 | autocorrelação de ordem 1 (bilateral) | 0,4227 |  |  | < 0,0001 | rejeita H0 |
| C. Autocorrelação | Breusch-Godfrey (ordem 1), painel empilhado: inválido como evidência; referência válida em calibracao_autocorrelacao.csv e nos testes de painel do script 06 | ausência de autocorrelação até a ordem 1 | autocorrelação até a ordem 1 | 177,3971 | 3,8415 | df = 1 | < 0,0001 | rejeita H0 |
| C. Autocorrelação | rho aproximado, 1 - d/2 (empilhado, inválido no painel) |  |  | 0,7887 |  |  |  |  |
| C. Autocorrelação | rho dos resíduos vizinhos no mesmo município |  |  | 0,8846 |  | pares = 261 |  |  |
| C. Autocorrelação | d de Durbin-Watson médio por município |  |  | 0,4643 |  | municípios = 29 |  |  |
| C. Autocorrelação | rho aproximado, 1 - d/2, a partir do d por município |  |  | 0,7679 |  |  |  |  |
| D. Normalidade | Jarque-Bera | resíduos normais | resíduos não normais | 517,5486 | 5,9915 | df = 2 | < 0,0001 | rejeita H0 |
| D. Normalidade | Shapiro-Wilk | resíduos normais | resíduos não normais | 0,8614 |  |  | < 0,0001 | rejeita H0 |
| E. Especificação | RESET de Ramsey (potências 2 e 3 dos regressores) | forma funcional correta | forma funcional incorreta | 18,4638 | 4,9646 | df1 = 10; df2 = 274 | < 0,0001 | rejeita H0 |

Observação: o Durbin-Watson e o Breusch-Godfrey do painel empilhado tratam as 290 linhas como uma única série e cruzam fronteiras entre municípios; a evidência válida de autocorrelação está em `04_calibracao.md` (autocorrelação dentro do município e testes de painel).

Notas: (1) o White completo tem 20 graus de liberdade e inclui X5, que só varia no tempo, e X6, que só varia entre municípios; (2) a matriz de dois eixos (município e ano) do Modelo 3b não é semidefinida positiva (menor autovalor -1,44e-07), de modo que o erro da interação e o F robusto dessa coluna são pouco confiáveis; além disso o agrupamento por ano tem só 10 grupos; (3) o Goldfeld-Quandt unilateral (variância crescente) ordenado por vínculos rejeita a 5% (p-valor = 0,0306) e ordenado por X2 e X3 não rejeita; ele testa uma ordenação específica e tem menos poder contra outras formas de heterocedasticidade que o Breusch-Pagan e o White.

## Multicolinearidade (FIV)

| Modelo | Termo | FIV | Tolerância | FIV > 10 |
|---|---|---|---|---|
| Modelo 2 | X2 ensino superior (%) | 1,1548 | 0,8660 | não |
| Modelo 2 | X3 dominância industrial (%) | 1,2238 | 0,8171 | não |
| Modelo 2 | X4 diversificação (Shannon) | 2,6166 | 0,3822 | não |
| Modelo 2 | X5 Selic real (% a.a.) | 1,0068 | 0,9932 | não |
| Modelo 2 | X6 distância a Curitiba (km) | 2,5019 | 0,3997 | não |
| Modelo 3 | X2 ensino superior (%) | 1,5202 | 0,6578 | não |
| Modelo 3 | X3 dominância industrial (%) | 1,2245 | 0,8166 | não |
| Modelo 3 | X4 diversificação (Shannon) | 2,6212 | 0,3815 | não |
| Modelo 3 | X5 Selic real (% a.a.) | 1,0075 | 0,9926 | não |
| Modelo 3 | X6 distância a Curitiba (km) | 2,6108 | 0,3830 | não |
| Modelo 3 | Indicadora de Curitiba | 1,5633 | 0,6397 | não |
| Modelo 3b | X2 ensino superior (%) | 1,5208 | 0,6575 | não |
| Modelo 3b | X3 dominância industrial (%) | 6,3561 | 0,1573 | não |
| Modelo 3b | X4 diversificação (Shannon) | 2,7961 | 0,3576 | não |
| Modelo 3b | X5 Selic real (% a.a.) | 1,0076 | 0,9925 | não |
| Modelo 3b | X6 distância a Curitiba (km) | 6,4009 | 0,1562 | não |
| Modelo 3b | Indicadora de Curitiba | 1,5996 | 0,6252 | não |
| Modelo 3b | X3 x X6 (interação) | 8,1390 | 0,1229 | não |

## Teste F de significância conjunta sob cada matriz

| Modelo | Matriz | Hipótese | F | gl | p-valor |
|---|---|---|---|---|---|
| Modelo 2 | Clássico (MQO) | todas as inclinações = 0 | 103,4549 | 5; 284 | < 0,0001 |
| Modelo 2 | White HC1 | todas as inclinações = 0 | 86,6709 | 5; 284 | < 0,0001 |
| Modelo 2 | Newey-West | todas as inclinações = 0 | 22,4171 | 5; 284 | < 0,0001 |
| Modelo 2 | Agrupado por município | todas as inclinações = 0 | 23,6543 | 5; 284 | < 0,0001 |
| Modelo 2 | Agrupado por município e ano | todas as inclinações = 0 | 28,9623 | 5; 284 | < 0,0001 |
| Modelo 3 | Clássico (MQO) | todas as inclinações = 0 | 95,4352 | 6; 283 | < 0,0001 |
| Modelo 3 | White HC1 | inclinações = 0, exceto dummy_curitiba | 73,7754 | 5; 283 | < 0,0001 |
| Modelo 3 | Newey-West | inclinações = 0, exceto dummy_curitiba | 17,4692 | 5; 283 | < 0,0001 |
| Modelo 3 | Agrupado por município | inclinações = 0, exceto dummy_curitiba | 20,8283 | 5; 283 | < 0,0001 |
| Modelo 3 | Agrupado por município e ano | inclinações = 0, exceto dummy_curitiba | 27,1350 | 5; 283 | < 0,0001 |
| Modelo 3b | Clássico (MQO) | todas as inclinações = 0 | 82,0185 | 7; 282 | < 0,0001 |
| Modelo 3b | White HC1 | inclinações = 0, exceto dummy_curitiba | 58,2698 | 6; 282 | < 0,0001 |
| Modelo 3b | Newey-West | inclinações = 0, exceto dummy_curitiba | 19,0537 | 6; 282 | < 0,0001 |
| Modelo 3b | Agrupado por município | inclinações = 0, exceto dummy_curitiba | 19,9279 | 6; 282 | < 0,0001 |
| Modelo 3b | Agrupado por município e ano | inclinações = 0, exceto dummy_curitiba | 6,9453 | 6; 282 | < 0,0001 |

## Robustez do Modelo 2 sem as observações com X3 negativo

| Termo | Coef. amostra completa | EP agrupado | Coef. sem x3_negativo | EP agrupado | Variação do coeficiente (%) |
|---|---|---|---|---|---|
| Intercepto | 7,3341 | 0,2007 | 7,3637 | 0,1849 | 0,40 |
| X2 ensino superior (%) | 0,0159 | 0,0031 | 0,0162 | 0,0033 | 1,50 |
| X3 dominância industrial (%) | 0,0054 | 0,0011 | 0,0062 | 0,0011 | 14,09 |
| X4 diversificação (Shannon) | 0,0762 | 0,0520 | 0,0560 | 0,0447 | -26,54 |
| X5 Selic real (% a.a.) | 0,0066 | 0,0016 | 0,0067 | 0,0017 | 0,91 |
| X6 distância a Curitiba (km) | -0,0016 | 0,0016 | -0,0016 | 0,0015 | -4,62 |

## P-valor da Selic real agrupado por ano (t com 9 graus de liberdade)

Modelo 2: coeficiente 0,0066, erro-padrão 0,0019, t = 3,4786, p-valor = 0,0070.

## Memorial matricial do Modelo 2

Quadro de análise de variância (Modelo 2):

| Fonte | gl | Soma de quadrados | Quadrado médio | F | F crítico (5%) | p-valor |
|---|---|---|---|---|---|---|
| Regressão | 5 | 7,8112 | 1,5622 | 103,4549 | 2,2458 | < 0,0001 |
| Resíduo | 284 | 4,2886 | 0,0151 |  |  |  |
| Total | 289 | 12,0998 |  |  |  |  |

Coeficientes de determinação parcial (r² = t²/(t² + n - k)):

| Variável | t | r² parcial |
|---|---|---|
| X2 (ensino superior) | 11,8917 | 0,3324 |
| X3 (dominância industrial) | 11,1393 | 0,3041 |
| X4 (diversificação) | 3,5491 | 0,0425 |
| X5 (Selic real) | 3,1782 | 0,0343 |
| X6 (distância a Curitiba) | -3,1733 | 0,0342 |

Teste F de contribuição incremental:

| Bloco | m | F | F crítico (5%) | p-valor | Decisão |
|---|---|---|---|---|---|
| X2 (capital humano) | 1 | 141,4124 | 3,8744 | < 0,0001 | rejeita H0 a 5% |
| X3 e X4 (estrutura produtiva) | 2 | 96,9984 | 3,0276 | < 0,0001 | rejeita H0 a 5% |
| X5 (macroeconomia) | 1 | 10,1012 | 3,8744 | 0,0016 | rejeita H0 a 5% |
| X6 (localização) | 1 | 10,0697 | 3,8744 | 0,0017 | rejeita H0 a 5% |

Previsão de ln Y:

| Cenário | ln previsto | IC 95% da média | IC 95% individual |
|---|---|---|---|
| médias amostrais dos regressores | 7,8609 | [7,8467; 7,8751] | [7,6186; 8,1032] |
| valores de Curitiba em 2021 | 8,2381 | [8,1774; 8,2987] | [7,9887; 8,4874] |

## Simulação de cenários (Modelo 2, base 2021)

Previsão da média na escala do log, retransformada por exp() com o fator de Duan (média de exp do resíduo). Intervalo de 95% pela matriz agrupada por município, t com 28 graus de liberdade.

Cenário 1: aumento de 10 pontos percentuais em X3.

| Município | Salário previsto antes (R$) | Salário previsto depois (R$) | Variação (%) | IC 95% agrupado da variação (%) |
|---|---|---|---|---|
| Almirante Tamandaré | 2.676,49 | 2.825,32 | 5,56 | [3,17; 8,01] |
| Fazenda Rio Grande | 2.816,55 | 2.973,16 | 5,56 | [3,17; 8,01] |

Cenário 2: aumento de 5 pontos percentuais em X2 nos 29 municípios.

| Medida | Valor |
|---|---|
| Municípios | 29 |
| Variação média (%) | 8,29 |
| Variação mínima (%) | 8,29 |
| Variação máxima (%) | 8,29 |

A tabela completa está em `resultados_econometricos/simulacao_cenarios_renda.csv`.
