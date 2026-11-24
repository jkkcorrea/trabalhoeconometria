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

