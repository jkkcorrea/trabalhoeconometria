# Diagnósticos do modelo

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

Aplicado à série de dez anos de cada município, com os resíduos do Modelo 2 e do Modelo 4. A tabela de Durbin-Watson usada vai até k' = 20 e foi lida para n = 10 e k' = 5, com dL = 0,243 e dU = 2,822 (valores lidos do PDF por OCR, [a confirmar]). Para o Modelo 4 (k' = 32) a tabela não se aplica. Com dU maior que 4 - dU não há zona de não rejeição: a tabela só permite conclusão para d < dL.

| Modelo | Municípios | DW mediano | ρ mediano | DW positivo pela tabela | Breusch-Godfrey rejeita a 5% |
|---|---|---|---|---|---|
| Modelo 2 | 29 | 0,2504 | 0,7337 | 14 | 3 |
| Modelo 4 | 29 | 1,3330 | 0,1860 |  0 | 4 |

No Modelo 2, a autocorrelação positiva aparece em muitos municípios. No Modelo 4, a mediana do Durbin-Watson sobe para perto de 1,3 e o ρ auxiliar cai para 0,19: a maior parte da autocorrelação do Modelo 2 era heterogeneidade omitida entre municípios.

<details><summary>Série por município</summary>

| Modelo | Município | Durbin-Watson | Decisão pela tabela | ρ auxiliar | Breusch-Godfrey p |
|---|---|---|---|---|---|
| Modelo 2 | Adrianópolis | 0,0838 | autocorrelação positiva | 0,9234 | 0,0223 |
| Modelo 2 | Agudos do Sul | 0,3703 | zona de inconclusão | 0,6308 | 0,8645 |
| Modelo 2 | Almirante Tamandaré | 0,0776 | autocorrelação positiva | 0,9166 | 0,6644 |
| Modelo 2 | Araucária | 0,1142 | autocorrelação positiva | 0,7538 | 0,0238 |
| Modelo 2 | Balsa Nova | 0,7827 | zona de inconclusão | 0,6296 | 0,3380 |
| Modelo 2 | Bocaiúva do Sul | 0,6941 | zona de inconclusão | 0,6469 | 0,4167 |
| Modelo 2 | Campina Grande do Sul | 0,0909 | autocorrelação positiva | 0,9635 | 0,6055 |
| Modelo 2 | Campo do Tenente | 0,5543 | zona de inconclusão | 0,6648 | 0,0506 |
| Modelo 2 | Campo Largo | 0,0690 | autocorrelação positiva | 0,9554 | 0,4231 |
| Modelo 2 | Campo Magro | 0,5339 | zona de inconclusão | 0,7337 | 0,1150 |
| Modelo 2 | Cerro Azul | 0,2081 | autocorrelação positiva | 1,0028 | 0,0510 |
| Modelo 2 | Colombo | 0,2745 | zona de inconclusão | 0,6810 | 0,2648 |
| Modelo 2 | Contenda | 1,5334 | zona de inconclusão | 0,1792 | 0,8594 |
| Modelo 2 | Curitiba | 0,0751 | autocorrelação positiva | 0,9420 | 0,1735 |
| Modelo 2 | Fazenda Rio Grande | 0,2504 | zona de inconclusão | 0,6773 | 0,5214 |
| Modelo 2 | Itaperuçu | 0,6567 | zona de inconclusão | 0,5107 | 0,3814 |
| Modelo 2 | Lapa | 0,8421 | zona de inconclusão | 0,5635 | 0,7205 |
| Modelo 2 | Mandirituba | 0,1438 | autocorrelação positiva | 0,7556 | 0,1361 |
| Modelo 2 | Piên | 0,7010 | zona de inconclusão | 0,6372 | 0,0487 |
| Modelo 2 | Pinhais | 0,7376 | zona de inconclusão | 0,6089 | 0,1666 |
| Modelo 2 | Piraquara | 0,0850 | autocorrelação positiva | 0,8409 | 0,1142 |
| Modelo 2 | Quatro Barras | 0,2012 | autocorrelação positiva | 0,9397 | 0,6800 |
| Modelo 2 | Quitandinha | 0,1255 | autocorrelação positiva | 0,8984 | 0,5017 |
| Modelo 2 | Rio Branco do Sul | 0,0853 | autocorrelação positiva | 0,8967 | 0,9413 |
| Modelo 2 | Rio Negro | 0,0758 | autocorrelação positiva | 0,8976 | 0,3751 |
| Modelo 2 | São José dos Pinhais | 0,0477 | autocorrelação positiva | 0,9529 | 0,1623 |
| Modelo 2 | Tijucas do Sul | 1,2783 | zona de inconclusão | 0,2909 | 0,4325 |
| Modelo 2 | Tunas do Paraná | 0,7583 | zona de inconclusão | 0,5594 | 0,0543 |
| Modelo 2 | Doutor Ulysses | 0,6755 | zona de inconclusão | 0,6581 | 0,8327 |
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
