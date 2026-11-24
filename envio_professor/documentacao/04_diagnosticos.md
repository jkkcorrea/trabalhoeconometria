# Diagnósticos do modelo principal

## Hipóteses formais e critério de decisão a 5%

Critério: rejeita-se H0 quando o p-valor é menor que 0,05.

| Teste | H0 | Ha | Estatística | p-valor | Decisão |
|---|---|---|---|---|---|
| Breusch-Pagan-Godfrey (bptest, studentized) | H0: Var(u_t) = sigma^2 para todo t (homocedasticidade) | Ha: Var(u_t) depende de algum regressor (heterocedasticidade); BP ~ qui-quadrado com k - 1 gl | 11,90 | 0,0363 | rejeita H0 |
| Goldfeld-Quandt (gqtest, ordenado por dist_curitiba_km, fração central 0,2) | H0: sigma_1^2 = sigma_2^2 (variância constante entre os dois segmentos) | Ha: sigma_2^2 > sigma_1^2 (variância maior no segmento de maior distância) | 1,06 | 0,3885 | não rejeita H0 |
| Shapiro-Wilk (normalidade dos resíduos) | H0: os resíduos têm distribuição normal | Ha: os resíduos não têm distribuição normal | 0,8618 | < 0,0001 | rejeita H0 |
| RESET de Ramsey (potências 2 e 3 dos ajustados) | H0: forma funcional correta (coeficientes de y^2 e y^3 iguais a zero) | Ha: forma funcional incorreta (algum coeficiente diferente de zero) | 14,49 | < 0,0001 | rejeita H0 |
| LM para acréscimo de tendência linear (ano) | H0: coeficiente de ano = 0 (LM = n R^2 ~ qui-quadrado com 1 gl) | Ha: coeficiente de ano diferente de zero (tendência omitida) | 0,38 | 0,5393 | não rejeita H0 |
| Chow, corte indicado pelo gráfico | H0: beta(primeiro período) = beta(segundo período) (sem quebra estrutural) | Ha: ao menos um coeficiente diferente entre os dois períodos (quebra estrutural) | 1,60 | 0,1463 | não rejeita H0 |
| Chow, corte anterior (comparação) | H0: beta(primeiro período) = beta(segundo período) (sem quebra estrutural) | Ha: ao menos um coeficiente diferente entre os dois períodos (quebra estrutural) | 1,79 | 0,1018 | não rejeita H0 |

## Multicolinearidade

| Variável | FIV | Tolerância | Decisão |
|---|---|---|---|
| prop_superior | 1,1655 | 0,8580 | sem problema (FIV <= 10) |
| dom_industrial | 1,1436 | 0,8744 | sem problema (FIV <= 10) |
| gini_setorial | 2,3265 | 0,4298 | sem problema (FIV <= 10) |
| selic_real | 1,0060 | 0,9940 | sem problema (FIV <= 10) |
| dist_curitiba_km | 2,2133 | 0,4518 | sem problema (FIV <= 10) |

Regra ensinada: FIV maior que 10 indica multicolinearidade elevada. Nenhum regressor passa do limite.

## Autocorrelação por município

Os testes são aplicados à série de dez anos de cada município, com os resíduos do modelo principal. Durbin-Watson com dL = 0,243 e dU = 2,822 (Tabela D.5A, n = 10, k = 5, 5%). Zonas de decisão: d < dL rejeita a ausência de autocorrelação positiva; dL ≤ d ≤ 4 − dL é inconclusivo; d > 4 − dL rejeita a ausência de autocorrelação negativa.

| Modelo | Municípios | DW mediano | ρ auxiliar mediano | DW rejeita ausência de autocorrelação positiva | DW inconclusivo | Breusch-Godfrey rejeita (5%) |
|---|---|---|---|---|---|---|
| Modelo 2 (principal) | 29 | 0,2504 | 0,7337 | 14 | 15 | 3 |

A autocorrelação é declarada como limitação. Não há correção de painel no modelo principal.

## Quebra estrutural (Chow)

| Corte | Papel | F | gl | p-valor | Decisão |
|---|---|---|---|---|---|
| 2012-2017 x 2018-2021 | indicado pelo gráfico | 1,60 | 6; 278 | 0,1463 | não rejeita H0 |
| 2012-2016 x 2017-2021 | comparação | 1,79 | 6; 278 | 0,1018 | não rejeita H0 |

O corte de 2017 foi escolhido a partir do gráfico das variáveis médias no tempo (figuras_graficos/diag6_variaveis_no_tempo.png). O corte de 2016 aparece para comparação; em nenhum dos dois há quebra a 5%.

LM para tendência linear do ano: estatística 0,38, gl 1, p-valor 0,5393 (não rejeita H0).

## Forma funcional (RESET)

F = 14,49 (gl 2; 282), p-valor < 0,0001: rejeita a forma funcional linear. Declarado como limitação do modelo.

## Normalidade dos resíduos

Shapiro-Wilk W = 0,8618, p-valor < 0,0001: rejeita a normalidade. O gráfico Q-Q (figuras_graficos/diag5_normalidade_qq.png) mostra desvio nas duas caudas. Com 290 observações, a inferência é aproximadamente válida; a limitação é declarada.

## Heterocedasticidade

| Teste | Estatística | gl | p-valor | Decisão |
|---|---|---|---|---|
| Breusch-Pagan-Godfrey (bptest, studentized) | 11,90 | 5 | 0,0363 | rejeita H0 |
| Goldfeld-Quandt (gqtest, ordenado por dist_curitiba_km, fração central 0,2) | 1,06 | 110; 110 | 0,3885 | não rejeita H0 |

A inferência usa erros-padrão de White (HC1), que não dependem da forma da variância.

## Heterocedasticidade: teste de White e Goldfeld-Quandt por outras variáveis

| Teste | Estatística | gl | p-valor | Decisão |
|---|---|---|---|---|
| White (regressão auxiliar com quadrados e produtos cruzados) | 94,15 | 20 | < 0,0001 | rejeita H0 |
| Goldfeld-Quandt (fração central 0,2 omitida), ordenado por prop_superior | 0,90 | 110; 110 | 0,5664 | não rejeita H0 |
| Goldfeld-Quandt (fração central 0,2 omitida), ordenado por dom_industrial | 1,53 | 110; 110 | 0,0268 | rejeita H0 |
| Goldfeld-Quandt (fração central 0,2 omitida), ordenado por gini_setorial | 0,96 | 110; 110 | 0,8404 | não rejeita H0 |
| Goldfeld-Quandt (fração central 0,2 omitida), ordenado por selic_real | 1,13 | 110; 110 | 0,5353 | não rejeita H0 |
| Goldfeld-Quandt (fração central 0,2 omitida), ordenado por dist_curitiba_km | 1,06 | 110; 110 | 0,7769 | não rejeita H0 |

O Breusch-Pagan e o White rejeitam a homocedasticidade. O Goldfeld-Quandt ordenado pela distância não rejeita, mas tem pouco poder quando a variância não cresce com essa variável; ordenado pela industrialização (X3), ele rejeita. A divergência entre os testes vem do ordenamento escolhido, não de um resultado contraditório.

## F geral com erro de White

| Matriz | F | gl | p-valor | Decisão |
|---|---|---|---|---|
| clássica | 105,26 | 5; 284 | < 0,0001 | rejeita H0 |
| White (HC1) | 92,83 | 5; 284 | < 0,0001 | rejeita H0 |

## F incremental por bloco, com erro de White

| Bloco | Restrições | F (White) | p-valor | Decisão |
|---|---|---|---|---|
| X2 (capital humano) | 1 | 105,05 | < 0,0001 | rejeita H0 |
| X3 e X4 (estrutura produtiva) | 2 | 98,34 | < 0,0001 | rejeita H0 |
| X5 (macroeconomia) | 1 | 13,38 | 0,0003 | rejeita H0 |
| X6 (localização) | 1 | 8,79 | 0,0033 | rejeita H0 |

O F geral com a matriz de White (HC1) usa F = b'V^-1 b / q para as q = 5 inclinações. A conclusão é a mesma do F clássico.

## Heterogeneidade entre municípios e o Durbin-Watson

Com os resíduos do modelo empilhado, o Durbin-Watson mediano é 0,2504 e 14 municípios ficam abaixo de dL. Com os resíduos centrados na média de cada município, a mediana passa a 1,1598 e apenas 1 município fica abaixo de dL. Em 16 dos 29 municípios os dez resíduos têm o mesmo sinal, e 72,86% da soma de quadrados dos resíduos está entre municípios. Parte do que o Durbin-Watson lê como autocorrelação é, portanto, diferença persistente entre municípios que o modelo empilhado não capta. Os valores dL e dU da Tabela D.5A são aproximados neste caso, porque X6 não varia no tempo dentro do município.

## Exame dos resíduos

As figuras figuras_graficos/diag1_residuos_vs_ajustados.png, diag2_residuos_por_municipio.png e diag7_residuos_vs_regressores.png mostram os resíduos contra os valores ajustados, por município e contra cada regressor. Os dez maiores resíduos em módulo:

| Município | Ano | Resíduo | Resíduo / erro-padrão |
|---|---|---|---|
| Adrianópolis | 2014 | 0,5858 | 4,79 |
| Araucária | 2012 | 0,5531 | 4,53 |
| Adrianópolis | 2013 | 0,5423 | 4,44 |
| Araucária | 2013 | 0,5081 | 4,16 |
| Adrianópolis | 2015 | 0,4369 | 3,58 |
| Araucária | 2014 | 0,3979 | 3,26 |
| Lapa | 2016 | -0,3924 | -3,21 |
| Adrianópolis | 2016 | 0,3683 | 3,01 |
| Adrianópolis | 2012 | 0,3206 | 2,62 |
| Quatro Barras | 2015 | 0,2798 | 2,29 |

A cauda positiva dos resíduos vem de Adrianópolis (2012 a 2016) e de Araucária (2012 a 2014), municípios com participação industrial atípica; isso ajuda a explicar a assimetria e a curtose que o Shapiro-Wilk rejeita.

## Intervalo da média da previsão de 2021 (ponto médio dos regressores)

| Cenário | Selic (% a.a.) | IC 95% clássico (ln) | IC 95% com White (ln) |
|---|---|---|---|
| Selic de 2021 | -5,11 | [7,8172; 7,8838] | [7,8250; 7,8760] |
| Selic de 2021 + 1 p.p. | -4,11 | [7,8273; 7,8867] | [7,8343; 7,8797] |
| Selic de 2021 - 1 p.p. | -6,11 | [7,8070; 7,8809] | [7,8155; 7,8724] |

## Reespecificação da forma funcional

| Especificação | R2 ajustado | AIC | RESET F | RESET p-valor | Shapiro-Wilk W | Gini: coeficiente (p) |
|---|---|---|---|---|---|---|
| Modelo principal | 0,6433 | -388,30 | 14,49 | < 0,0001 | 0,8618 | -0,6548 (0,0001) |
| Mais quadrados de X2 e X3 (centrados na média) | 0,6678 | -406,94 | 8,12 | 0,0004 | 0,9045 | -1,0152 (< 0,0001) |
| Mais ln dos vínculos ativos (porte) | 0,6744 | -413,76 | 3,98 | 0,0197 | 0,8567 | 0,2579 (0,1293) |
| Quadrados de X2 e X3 e porte | 0,7041 | -439,54 | 3,59 | 0,0288 | 0,8868 | 0,2019 (0,3246) |

Os quadrados de X2 e X3 usam as variáveis centradas na média. A inclusão do logaritmo dos vínculos ativos (porte do município) reduz bastante a estatística do RESET, o que indica que parte da não linearidade vem de uma variável omitida. O RESET ainda rejeita em todas as versões. O modelo principal permanece como o definido nas orientações; as versões ampliadas são sensibilidade.

