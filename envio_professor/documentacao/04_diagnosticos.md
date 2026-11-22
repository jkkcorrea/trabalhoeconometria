# Diagnósticos do modelo

## Hipóteses formais (H0 e Ha) e critério de decisão a 5%

Critério em todos os testes: rejeita-se H0 quando o p-valor é menor que 0,05 (ou quando a estatística passa do valor crítico).

| Teste | Modelo | H0 | Ha | Estatística | p-valor | Decisão |
|---|---|---|---|---|---|---|
| Breusch-Pagan-Godfrey (bptest, studentized) | Modelo 2 | H0: Var(u_t) = sigma^2 para todo t (erros homocedásticos; inclinações da regressão auxiliar dos resíduos ao quadrado iguais a zero) | Ha: Var(u_t) depende de ao menos um regressor (heterocedasticidade); critério BP ~ qui-quadrado com k - 1 gl | 11,90 | 0,0363 | rejeita H0 |
| Breusch-Pagan-Godfrey (bptest, studentized) | Modelo 3 | H0: Var(u_t) = sigma^2 para todo t (erros homocedásticos; inclinações da regressão auxiliar dos resíduos ao quadrado iguais a zero) | Ha: Var(u_t) depende de ao menos um regressor (heterocedasticidade); critério BP ~ qui-quadrado com k - 1 gl | 11,19 | 0,0826 | não rejeita H0 |
| Breusch-Pagan-Godfrey (bptest, studentized) | Modelo 3b | H0: Var(u_t) = sigma^2 para todo t (erros homocedásticos; inclinações da regressão auxiliar dos resíduos ao quadrado iguais a zero) | Ha: Var(u_t) depende de ao menos um regressor (heterocedasticidade); critério BP ~ qui-quadrado com k - 1 gl | 12,61 | 0,0822 | não rejeita H0 |
| Breusch-Pagan-Godfrey (bptest, studentized) | Modelo 4 | H0: Var(u_t) = sigma^2 para todo t (erros homocedásticos; inclinações da regressão auxiliar dos resíduos ao quadrado iguais a zero) | Ha: Var(u_t) depende de ao menos um regressor (heterocedasticidade); critério BP ~ qui-quadrado com k - 1 gl | 68,98 | 0,0002 | rejeita H0 |
| Goldfeld-Quandt (gqtest, unilateral; ordenado por dist_curitiba_km) | Modelo 2 | H0: sigma_1^2 = sigma_2^2 (variância constante entre os dois segmentos) | Ha: sigma_2^2 > sigma_1^2 (variância cresce com a distância); estatística F = SQR2/SQR1 com gl (n - omitidas)/2 - k | 1,06 | 0,3885 | não rejeita H0 |
| RESET de Ramsey (potências 2 e 3 dos ajustados) | Modelo 2 | H0: forma funcional correta (coeficientes de y^2 e y^3 na regressão auxiliar iguais a zero) | Ha: forma funcional incorreta (ao menos um dos coeficientes de y^2 e y^3 diferente de zero) | 14,49 | < 0,0001 | rejeita H0 |
| RESET de Ramsey (potências 2 e 3 dos ajustados) | Modelo 4 | H0: forma funcional correta (coeficientes de y^2 e y^3 na regressão auxiliar iguais a zero) | Ha: forma funcional incorreta (ao menos um dos coeficientes de y^2 e y^3 diferente de zero) | 0,28 | 0,7527 | não rejeita H0 |
| F de acréscimo das dummies de município (X2 a X5, sem e com as dummies) | Modelo 4 | H0: beta(dummies de município) = 0 conjuntamente (modelo restrito, sem dummies) | Ha: ao menos uma dummy de município diferente de zero (modelo irrestrito, com dummies) | 76,13 | < 0,0001 | rejeita H0 |
| LM para acréscimo de tendência linear (ano) | Modelo 2 | H0: coeficiente de ano = 0 (sem tendência linear omitida); LM = n R^2 ~ qui-quadrado com 1 gl | Ha: coeficiente de ano diferente de zero (tendência linear omitida) | 0,38 | 0,5393 | não rejeita H0 |
| Chow: quebra estrutural entre 2012-2016 e 2017-2021 | Modelo 2 | H0: beta(2012-2016) = beta(2017-2021) (sem quebra estrutural) | Ha: ao menos um coeficiente diferente entre os dois períodos (quebra estrutural) | 1,79 | 0,1018 | não rejeita H0 |
| Jarque-Bera (Gujarati, cap. 5, seção 5.12) | Modelo 2 | H0: os resíduos têm distribuição normal (S = 0 e K = 3) | Ha: os resíduos não têm distribuição normal (S diferente de 0 ou K diferente de 3) | 514,42 | < 0,0001 | rejeita H0 |
| Jarque-Bera (Gujarati, cap. 5, seção 5.12) | Modelo 4 | H0: os resíduos têm distribuição normal (S = 0 e K = 3) | Ha: os resíduos não têm distribuição normal (S diferente de 0 ou K diferente de 3) | 615,88 | < 0,0001 | rejeita H0 |

## Normalidade dos resíduos (Jarque-Bera)

| Modelo | Estatística | gl | p-valor | Decisão | Assimetria S | Curtose K |
|---|---|---|---|---|---|---|
| Modelo 2 | 514,42 | 2 | < 0,0001 | rejeita H0 | 1,7377 | 8,5221 |
| Modelo 4 | 615,88 | 2 | < 0,0001 | rejeita H0 | -0,9392 | 9,8877 |

A normalidade dos resíduos é rejeitada nos dois modelos (p-valor < 0,0001 no Modelo 2 e < 0,0001 no Modelo 4). A distribuição tem caudas pesadas, sobretudo no Modelo 2 (S = 1,7377, K = 8,5221). Com 290 observações, os testes t e F são aproximadamente válidos pela teoria de amostras grandes; essa é uma limitação a declarar [a confirmar no Gujarati, cap. 5].

## Influência e observações atípicas

Conceitos do Gujarati (cap. 13): outlier (resíduo grande), ponto de alavancagem (valor extremo de um regressor) e ponto influente (sua retirada muda a inclinação). O livro não apresenta teste formal para esses pontos; distância de Cook e DFBETAS não fazem parte do material da disciplina. Usamos a alavancagem (diagonal da matriz chapéu), o resíduo padronizado e a variação de cada coeficiente ao retirar a observação, em erros-padrão. Limiares: alavancagem acima de 2k/n, resíduo padronizado maior que 2 em módulo, e variação maior que 1 erro-padrão [presunção da modelagem].

| Modelo | Alavancagem acima de 2k/n | Outliers (resíduo padronizado acima de 2 em módulo) | Influentes |
|---|---|---|---|
| Modelo 2 | 23 | 12 | 0 |
| Modelo 4 |  3 | 13 | 2 |

Pontos influentes no Modelo 4: Adrianópolis 2012; Lapa 2016. Retirados esses pontos, o coeficiente de X4 (Gini) passa de 0,8653 para 1,1516, e o de X5 (Selic) varia 0,67%. A observação de Adrianópolis em 2012 tem o maior resíduo padronizado do painel; a participação industrial do município salta de 7,14% em 2014 para 45,47% em 2015, enquanto a mediana do RMC em 2015 é 22,39%. O dado deve ser conferido na fonte (SIDRA, tabela 5938) antes de qualquer conclusão [a confirmar].

## Heterogeneidade entre municípios

| Teste | Estatística F | gl | p-valor | Decisão |
|---|---|---|---|---|
| F de acréscimo das dummies de município (X2 a X5, sem e com as dummies) | 76,13 | 28; 257 | < 0,0001 | rejeita H0 |

As dummies de município são conjuntamente significativas. O RESET do Modelo 2 rejeita (p-valor < 0,0001) e o RESET do Modelo 4 não rejeita (p-valor 0,7527). A rejeição da forma funcional vem, portanto, da variável omitida entre municípios.

## Multicolinearidade (FIV e tolerância)

| Modelo | Variável | FIV | Tolerância | Decisão |
|---|---|---|---|---|
| Modelo 2 | prop_superior | 1,1655 | 0,8580 | sem problema (FIV <= 10) |
| Modelo 2 | dom_industrial | 1,1436 | 0,8744 | sem problema (FIV <= 10) |
| Modelo 2 | gini_setorial | 2,3265 | 0,4298 | sem problema (FIV <= 10) |
| Modelo 2 | selic_real | 1,0060 | 0,9940 | sem problema (FIV <= 10) |
| Modelo 2 | dist_curitiba_km | 2,2133 | 0,4518 | sem problema (FIV <= 10) |
| Modelo 3 | prop_superior | 1,5297 | 0,6537 | sem problema (FIV <= 10) |
| Modelo 3 | dom_industrial | 1,1465 | 0,8722 | sem problema (FIV <= 10) |
| Modelo 3 | gini_setorial | 2,3283 | 0,4295 | sem problema (FIV <= 10) |
| Modelo 3 | selic_real | 1,0068 | 0,9933 | sem problema (FIV <= 10) |
| Modelo 3 | dist_curitiba_km | 2,2770 | 0,4392 | sem problema (FIV <= 10) |
| Modelo 3 | dummy_curitiba | 1,5617 | 0,6403 | sem problema (FIV <= 10) |

FIV calculado no Modelo 2 e no Modelo 3, pela regra ensinada (FIV > 10 indica multicolinearidade elevada). O Modelo 4 não entra nessa tabela.

## Heterocedasticidade e testes de especificação

| Modelo | Teste | Estatística | gl | p-valor | Decisão |
|---|---|---|---|---|---|
| Modelo 2 | Breusch-Pagan-Godfrey (bptest, studentized) | 11,90 | 5 | 0,0363 | rejeita H0 |
| Modelo 3 | Breusch-Pagan-Godfrey (bptest, studentized) | 11,19 | 6 | 0,0826 | não rejeita H0 |
| Modelo 3b | Breusch-Pagan-Godfrey (bptest, studentized) | 12,61 | 7 | 0,0822 | não rejeita H0 |
| Modelo 4 | Breusch-Pagan-Godfrey (bptest, studentized) | 68,98 | 32 | 0,0002 | rejeita H0 |
| Modelo 2 | Goldfeld-Quandt (gqtest, unilateral; ordenado por dist_curitiba_km) | 1,06 | 110; 110 | 0,3885 | não rejeita H0 |

Como o Breusch-Pagan-Godfrey rejeita no Modelo 2 e no Modelo 4, a inferência usa erros de White (HC1).

RESET de Ramsey: Modelo 2, p-valor < 0,0001 (rejeita); Modelo 4, p-valor 0,7527 (não rejeita).

LM para tendência linear do ano (Modelo 2): estatística = 0,3768, p-valor 0,5393. Não há tendência omitida.

Teste de Chow (2012 a 2016 contra 2017 a 2021, Modelo 2): F = 1,7863, p-valor 0,1018. Não há quebra estrutural a 5%.

## Inferência com variáveis que variam pouco

A Selic tem 10 valores distintos (um por ano) e a distância tem 29 (um por município). Com 290 observações, o t do modelo trata essas linhas como independentes e superestima a precisão. A checagem usa regressões simples sobre médias, com n - 2 graus de liberdade:

| Variável | Base | gl | Estimativa | p-valor | Decisão |
|---|---|---|---|---|---|
| X5 Selic real | médias anuais (n = 10) |  8 | 0,0038 | 0,1886 | não rejeita H0 |
| X6 distância a Curitiba | médias por município (n = 29) | 27 | -0,0047 | 0,0021 | rejeita H0 |

Com a Selic, a inclinação não é significativa a 5% na base de médias anuais (p-valor 0,1886). Esse resultado não se sustenta com a inferência do Modelo 4.

## Projeção pela previsão matricial (Modelo 4)

Previsão do ln do salário para 2021 em cada município, com intervalos da previsão média e individual (fórmulas de previsão matricial das notas de regressão múltipla). A variável de cenário é a Selic.

| Cenário | Selic (% a.a.) | Salário médio previsto (R$, média dos 29 municípios) |
|---|---|---|
| Selic de 2021 | -5,11 | 2582,82 |
| Selic de 2021 + 1 p.p. | -4,11 | 2592,95 |
| Selic de 2021 - 1 p.p. | -6,11 | 2572,72 |

| Modelo | Efeito de +1 p.p. (ln) | Efeito (%) | IC 95% (ln) | gl | p-valor |
|---|---|---|---|---|---|
| M4 (dummies de município), erro de White | 0,0039 | 0,39 | [0,0023; 0,0055] | 257 | < 0,0001 |
| Checagem agregada (médias anuais, n = 10) | 0,0038 | 0,38 | [-0,0023; 0,0099] |   8 | 0,1886 |

Leitura: pelo Modelo 4, cada ponto percentual a mais de Selic está associado a um salário cerca de 0,4% maior. A inferência do Modelo 4 é otimista (290 observações para 10 valores de Selic); a checagem agregada tem intervalo que inclui zero. A projeção mostra o efeito, mas o intervalo para a Selic deve ser lido com essa ressalva.

## Robustez da X4: definição do Gini

| Modelo | Definição da X4 | coef | p-valor | R2 aj. | AIC | RESET p |
|---|---|---|---|---|---|---|
| Modelo 4 | 87 divisões (zeros incluídos) | 0,8653 | 0,0496 | 0,9558 | -969,14 | 0,7527 |
| Modelo 2 | 87 divisões (zeros incluídos) | -0,6548 | 0,0001 | 0,6433 | -388,30 | < 0,0001 |
| Modelo 4 | somente divisões com vínculo | 0,1776 | 0,4420 | 0,9549 | -963,11 | 0,5671 |
| Modelo 2 | somente divisões com vínculo | -0,6378 | 0,0011 | 0,6356 | -382,07 | < 0,0001 |

O Gini sobre as 87 divisões (com zeros) depende de quantos setores têm emprego (correlação -0,95). O Gini só sobre as divisões com vínculo tem correlação -0,41 com esse número. Com a segunda definição, o efeito dentro dos municípios (Modelo 4) não é significativo. O efeito entre municípios (Modelo 2) se mantém nas duas definições.

## Medida X4 (Gini setorial)

A correlação entre o Gini e o número de divisões CNAE com emprego é -0,9497. O Gini, nesta construção, mede sobretudo quantos setores têm emprego, e não a desigualdade entre setores grandes.

## Teste da Selic e da produção agrícola

A produção agrícola vem da PAM (IBGE/SIDRA, tabela 5457, variável 215, valor da produção em mil reais), deflacionada pelo IPCA. Testou-se se retirar a Selic melhora o modelo e se a produção a substitui. Critérios: AIC e BIC (menores são melhores), R2 ajustado e diagnósticos. O t usa erro de White.

| Especificação | R2 aj. | AIC | BIC | RESET p | BP p | p Selic (White) | Coef. produção | p produção |
|---|---|---|---|---|---|---|---|---|
| M4 com Selic | 0,9558 | -969,14 | -844,36 | 0,7527 | 0,0002 | < 0,0001 | - | - |
| M4 sem Selic | 0,9515 | -942,47 | -821,36 | 0,1407 | 0,0001 | - | - | - |
| M4 sem Selic + ln produção agrícola | 0,9518 | -943,67 | -818,89 | 0,5655 | < 0,0001 | - | -0,0185 | 0,0886 |
| M2 com Selic | 0,6433 | -388,30 | -362,61 | < 0,0001 | 0,0363 | 0,0003 | - | - |
| M2 sem Selic | 0,6321 | -380,32 | -358,30 | < 0,0001 | 0,0443 | - | - | - |
| M2 sem Selic + ln produção agrícola | 0,6383 | -384,22 | -358,53 | < 0,0001 | 0,0818 | - | -0,0112 | 0,0499 |

Retirar a Selic piora o ajuste: F = 26,70 no Modelo 4 (p-valor < 0,0001) e F = 9,94 no Modelo 2 (p-valor 0,0018). A produção agrícola substitui a Selic sem ganho relevante (AIC -943,67 contra -969,14 no Modelo 4) e com coeficiente negativo e não significativo; não é adotada no modelo principal.

## Autocorrelação dentro de cada município

Os testes são aplicados à série de dez anos de cada um dos 29 municípios, com os resíduos do Modelo 2 e do Modelo 4 (Gujarati, cap. 12; Guia P2).

H0 do Durbin-Watson: ρ = 0 (ausência de autocorrelação de primeira ordem). Ha: ρ > 0 (positiva) ou ρ < 0 (negativa). Valores de dL = 0,243 e dU = 2,822 para n = 10 e k = 5, a 5%, da Tabela D.5A do Gujarati (PDF p. 995), conferidos no livro. Zonas do Guia P2: d < dL rejeita H0 (positiva); dL ≤ d ≤ dU inconclusiva; dU < d < 4 − dU não rejeita; 4 − dU ≤ d ≤ 4 − dL inconclusiva; d > 4 − dL rejeita H0 (negativa). Com dU maior que 2, a zona de não rejeição fica vazia: o teste só rejeita H0 com d < 0,243 ou d > 3,757.

H0 do Breusch-Godfrey (ordem 1): ausência de autocorrelação de primeira ordem. Estatística qui-quadrado com 1 gl; rejeita H0 se p < 0,05.

H0 do teste das carreiras: os resíduos são aleatórios. Ha: não são aleatórios. A aproximação normal do Gujarati (cap. 12) exige N1 > 10 e N2 > 10; com dez anos por município isso não ocorre, e o teste é declarado não aplicável em cada série.

| Modelo | Municípios | DW mediano | ρ mediano | DW positivo | DW inconclusivo | DW não aplicável | Breusch-Godfrey rejeita (5%) | Carreiras não aplicáveis |
|---|---|---|---|---|---|---|---|---|
| Modelo 2 | 29 | 0,2504 | 0,7337 | 14 | 15 |  0 | 3 | 29 |
| Modelo 4 | 29 | 1,3330 | 0,1860 |  0 |  0 | 29 | 4 | 29 |

No Modelo 2, o Durbin-Watson mediano é 0,2504 e o ρ auxiliar mediano é 0,7337: a autocorrelação positiva é forte. No Modelo 4, a mediana do Durbin-Watson é 1,3330, e o ρ auxiliar cai para 0,1860. A autocorrelação do Modelo 2 em boa parte reflete diferenças persistentes entre municípios.

## Correção da autocorrelação: Prais-Winsten e Cochrane-Orcutt

Métodos do Gujarati (cap. 12) e do Guia P2. O ρ é comum a todos os municípios e a transformação é feita dentro de cada município (a primeira observação de cada um é tratada por Prais-Winsten e descartada por Cochrane-Orcutt) [presunção da modelagem]. Newey-West não é aplicado: ver a nota de métodos não aplicados em 02_especificacao_e_metodos.md.

| Modelo | Método | ρ estimado | Variável | Coef. antes (White) | Coef. corrigido | EP HC1 | p-valor HC1 | Obs. |
|---|---|---|---|---|---|---|---|---|
| Modelo 2 | Prais-Winsten | 0,9440 | X2 escolaridade | 0,0150 | 0,0038 | 0,0019 | 0,0514 | 290 |
| Modelo 2 | Prais-Winsten | 0,9440 | X3 industrialização | 0,0055 | 0,0007 | 0,0006 | 0,2242 | 290 |
| Modelo 2 | Prais-Winsten | 0,9440 | X4 Gini | -0,6548 | 0,0578 | 0,3869 | 0,8814 | 290 |
| Modelo 2 | Prais-Winsten | 0,9440 | X5 Selic real | 0,0065 | 0,0019 | 0,0007 | 0,0123 | 290 |
| Modelo 2 | Prais-Winsten | 0,9440 | X6 distância | -0,0016 | -0,0046 | 0,0015 | 0,0020 | 290 |
| Modelo 2 | Cochrane-Orcutt | 0,9519 | X2 escolaridade | 0,0150 | 0,0016 | 0,0016 | 0,3245 | 261 |
| Modelo 2 | Cochrane-Orcutt | 0,9519 | X3 industrialização | 0,0055 | 0,0003 | 0,0005 | 0,5727 | 261 |
| Modelo 2 | Cochrane-Orcutt | 0,9519 | X4 Gini | -0,6548 | 1,0092 | 0,5143 | 0,0508 | 261 |
| Modelo 2 | Cochrane-Orcutt | 0,9519 | X5 Selic real | 0,0065 | 0,0024 | 0,0008 | 0,0038 | 261 |
| Modelo 2 | Cochrane-Orcutt | 0,9519 | X6 distância | -0,0016 | -0,0030 | 0,0031 | 0,3360 | 261 |
| Modelo 4 | Prais-Winsten | 0,3677 | X2 escolaridade | 0,0084 | 0,0067 | 0,0022 | 0,0029 | 290 |
| Modelo 4 | Prais-Winsten | 0,3677 | X3 industrialização | -0,0006 | -0,0004 | 0,0009 | 0,6678 | 290 |
| Modelo 4 | Prais-Winsten | 0,3677 | X4 Gini | 0,8653 | 0,8409 | 0,5059 | 0,0977 | 290 |
| Modelo 4 | Prais-Winsten | 0,3677 | X5 Selic real | 0,0039 | 0,0030 | 0,0009 | 0,0005 | 290 |
| Modelo 4 | Cochrane-Orcutt | 0,3950 | X2 escolaridade | 0,0084 | 0,0006 | 0,0011 | 0,5824 | 261 |
| Modelo 4 | Cochrane-Orcutt | 0,3950 | X3 industrialização | -0,0006 | -0,0015 | 0,0006 | 0,0132 | 261 |
| Modelo 4 | Cochrane-Orcutt | 0,3950 | X4 Gini | 0,8653 | 1,5861 | 0,4140 | 0,0002 | 261 |
| Modelo 4 | Cochrane-Orcutt | 0,3950 | X5 Selic real | 0,0039 | 0,0025 | 0,0007 | 0,0002 | 261 |

Depois da correção, o ρ auxiliar dos resíduos transformados cai para -0,0148 no Modelo 2 e 0,0167 no Modelo 4 (Prais-Winsten). O ρ estimado é 0,9440 no Modelo 2 e 0,3677 no Modelo 4.

Efeito sobre o Modelo 2: o coeficiente de X2 (escolaridade) passa de 0,0150, com erro de White, para 0,0038, com Prais-Winsten e erro de White (p-valor 0,0514). Leitura: a associação entre municípios no Modelo 2 depende da persistência dos dados, e não só da correção dos erros-padrão.

No Modelo 4 corrigido, o coeficiente de X4 (Gini) é 0,8409, com p-valor 0,0977 pelo erro de White. Com a correção, o efeito do Gini dentro dos municípios não é significativo a 5%.

<details><summary>Série por município</summary>

| Modelo | Município | Durbin-Watson | Decisão pela tabela | ρ auxiliar | Breusch-Godfrey p |
|---|---|---|---|---|---|
| Modelo 2 | Adrianópolis | 0,0838 | positiva (d < dL): rejeita H0 | 0,9234 | 0,0223 |
| Modelo 2 | Agudos do Sul | 0,3703 | inconclusiva | 0,6308 | 0,8645 |
| Modelo 2 | Almirante Tamandaré | 0,0776 | positiva (d < dL): rejeita H0 | 0,9166 | 0,6644 |
| Modelo 2 | Araucária | 0,1142 | positiva (d < dL): rejeita H0 | 0,7538 | 0,0238 |
| Modelo 2 | Balsa Nova | 0,7827 | inconclusiva | 0,6296 | 0,3380 |
| Modelo 2 | Bocaiúva do Sul | 0,6941 | inconclusiva | 0,6469 | 0,4167 |
| Modelo 2 | Campina Grande do Sul | 0,0909 | positiva (d < dL): rejeita H0 | 0,9635 | 0,6055 |
| Modelo 2 | Campo do Tenente | 0,5543 | inconclusiva | 0,6648 | 0,0506 |
| Modelo 2 | Campo Largo | 0,0690 | positiva (d < dL): rejeita H0 | 0,9554 | 0,4231 |
| Modelo 2 | Campo Magro | 0,5339 | inconclusiva | 0,7337 | 0,1150 |
| Modelo 2 | Cerro Azul | 0,2081 | positiva (d < dL): rejeita H0 | 1,0028 | 0,0510 |
| Modelo 2 | Colombo | 0,2745 | inconclusiva | 0,6810 | 0,2648 |
| Modelo 2 | Contenda | 1,5334 | inconclusiva | 0,1792 | 0,8594 |
| Modelo 2 | Curitiba | 0,0751 | positiva (d < dL): rejeita H0 | 0,9420 | 0,1735 |
| Modelo 2 | Fazenda Rio Grande | 0,2504 | inconclusiva | 0,6773 | 0,5214 |
| Modelo 2 | Itaperuçu | 0,6567 | inconclusiva | 0,5107 | 0,3814 |
| Modelo 2 | Lapa | 0,8421 | inconclusiva | 0,5635 | 0,7205 |
| Modelo 2 | Mandirituba | 0,1438 | positiva (d < dL): rejeita H0 | 0,7556 | 0,1361 |
| Modelo 2 | Piên | 0,7010 | inconclusiva | 0,6372 | 0,0487 |
| Modelo 2 | Pinhais | 0,7376 | inconclusiva | 0,6089 | 0,1666 |
| Modelo 2 | Piraquara | 0,0850 | positiva (d < dL): rejeita H0 | 0,8409 | 0,1142 |
| Modelo 2 | Quatro Barras | 0,2012 | positiva (d < dL): rejeita H0 | 0,9397 | 0,6800 |
| Modelo 2 | Quitandinha | 0,1255 | positiva (d < dL): rejeita H0 | 0,8984 | 0,5017 |
| Modelo 2 | Rio Branco do Sul | 0,0853 | positiva (d < dL): rejeita H0 | 0,8967 | 0,9413 |
| Modelo 2 | Rio Negro | 0,0758 | positiva (d < dL): rejeita H0 | 0,8976 | 0,3751 |
| Modelo 2 | São José dos Pinhais | 0,0477 | positiva (d < dL): rejeita H0 | 0,9529 | 0,1623 |
| Modelo 2 | Tijucas do Sul | 1,2783 | inconclusiva | 0,2909 | 0,4325 |
| Modelo 2 | Tunas do Paraná | 0,7583 | inconclusiva | 0,5594 | 0,0543 |
| Modelo 2 | Doutor Ulysses | 0,6755 | inconclusiva | 0,6581 | 0,8327 |
| Modelo 4 | Adrianópolis | 0,9123 | tabela não cobre k' = 32 | 0,2190 | 0,4921 |
| Modelo 4 | Agudos do Sul | 1,3328 | tabela não cobre k' = 32 | 0,0635 | 0,8535 |
| Modelo 4 | Almirante Tamandaré | 1,6800 | tabela não cobre k' = 32 | -0,1358 | 0,6758 |
| Modelo 4 | Araucária | 0,3952 | tabela não cobre k' = 32 | 1,0943 | 0,0103 |
| Modelo 4 | Balsa Nova | 1,4473 | tabela não cobre k' = 32 | 0,2379 | 0,4702 |
| Modelo 4 | Bocaiúva do Sul | 0,5490 | tabela não cobre k' = 32 | 0,6328 | 0,0459 |
| Modelo 4 | Campina Grande do Sul | 0,7002 | tabela não cobre k' = 32 | 0,6195 | 0,0583 |
| Modelo 4 | Campo do Tenente | 0,4897 | tabela não cobre k' = 32 | 0,6610 | 0,0413 |
| Modelo 4 | Campo Largo | 1,5796 | tabela não cobre k' = 32 | 0,1860 | 0,5637 |
| Modelo 4 | Campo Magro | 1,0805 | tabela não cobre k' = 32 | 0,4578 | 0,1485 |
| Modelo 4 | Cerro Azul | 0,5421 | tabela não cobre k' = 32 | 0,5805 | 0,0818 |
| Modelo 4 | Colombo | 1,3896 | tabela não cobre k' = 32 | 0,0544 | 0,8636 |
| Modelo 4 | Contenda | 1,6334 | tabela não cobre k' = 32 | 0,1345 | 0,6715 |
| Modelo 4 | Curitiba | 0,8563 | tabela não cobre k' = 32 | 0,5500 | 0,1557 |
| Modelo 4 | Fazenda Rio Grande | 0,5587 | tabela não cobre k' = 32 | 0,4100 | 0,2032 |
| Modelo 4 | Itaperuçu | 1,9229 | tabela não cobre k' = 32 | -0,0549 | 0,8702 |
| Modelo 4 | Lapa | 2,2948 | tabela não cobre k' = 32 | -0,2612 | 0,4225 |
| Modelo 4 | Mandirituba | 1,5690 | tabela não cobre k' = 32 | 0,0447 | 0,8882 |
| Modelo 4 | Piên | 0,3536 | tabela não cobre k' = 32 | 0,7633 | 0,0176 |
| Modelo 4 | Pinhais | 1,1347 | tabela não cobre k' = 32 | 0,4263 | 0,1948 |
| Modelo 4 | Piraquara | 1,3444 | tabela não cobre k' = 32 | -0,0615 | 0,8504 |
| Modelo 4 | Quatro Barras | 2,2686 | tabela não cobre k' = 32 | -0,1602 | 0,6125 |
| Modelo 4 | Quitandinha | 1,2034 | tabela não cobre k' = 32 | 0,0499 | 0,8757 |
| Modelo 4 | Rio Branco do Sul | 1,2263 | tabela não cobre k' = 32 | 0,3212 | 0,3100 |
| Modelo 4 | Rio Negro | 0,4923 | tabela não cobre k' = 32 | 0,5626 | 0,0759 |
| Modelo 4 | São José dos Pinhais | 1,6100 | tabela não cobre k' = 32 | 0,0724 | 0,8403 |
| Modelo 4 | Tijucas do Sul | 1,7721 | tabela não cobre k' = 32 | 0,0381 | 0,9041 |
| Modelo 4 | Tunas do Paraná | 1,8828 | tabela não cobre k' = 32 | -0,1097 | 0,7344 |
| Modelo 4 | Doutor Ulysses | 1,9415 | tabela não cobre k' = 32 | -0,0279 | 0,9332 |

</details>
