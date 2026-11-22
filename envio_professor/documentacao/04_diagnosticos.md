# Diagnósticos do modelo

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

Limite da regra ensinada: FIV > 10 indica multicolinearidade elevada.

## Heterocedasticidade, forma funcional e quebra estrutural

| Modelo | Teste | Estatística | gl | p-valor | Decisão |
|---|---|---|---|---|---|
| Modelo 2 | Breusch-Pagan-Godfrey (bptest, studentized) | 11,90 | 5 | 0,0363 | rejeita H0 |
| Modelo 3 | Breusch-Pagan-Godfrey (bptest, studentized) | 11,19 | 6 | 0,0826 | não rejeita H0 |
| Modelo 3b | Breusch-Pagan-Godfrey (bptest, studentized) | 12,61 | 7 | 0,0822 | não rejeita H0 |
| Modelo 2 | Goldfeld-Quandt (gqtest, unilateral; ordenado por dist_curitiba_km) | 1,06 | 110; 110 | 0,3885 | não rejeita H0 |

RESET de Ramsey (potências 2 e 3 dos ajustados): estatística F = 14,49, p-valor < 0,0001. A forma log-linear é rejeitada e este é o principal achado de especificação.

LM para tendência linear do ano: estatística = 0,3768, p-valor 0,5393. Não há tendência omitida.

Teste de Chow (2012 a 2016 contra 2017 a 2021): F = 1,7863, p-valor 0,1018. Não há quebra estrutural a 5%.

## Inferência com variáveis que variam pouco

A Selic tem 10 valores distintos (um por ano) e a distância tem 29 (um por município). Com 290 observações, o t do modelo trata essas linhas como independentes e superestima a precisão. A checagem usa regressões simples sobre médias, com n - 2 graus de liberdade:

| Variável | Base | gl | Estimativa | p-valor | Decisão |
|---|---|---|---|---|---|
| X5 Selic real | médias anuais (n = 10) |  8 | 0,0038 | 0,1886 | não rejeita H0 |
| X6 distância a Curitiba | médias por município (n = 29) | 27 | -0,0047 | 0,0021 | rejeita H0 |

Com a Selic, a inclinação não é significativa a 5% na base de médias anuais (p-valor 0,1886). O efeito de X5 no modelo principal não se sustenta fora da estrutura de 290 observações.

## Medida X4 (Gini setorial)

A correlação entre o Gini e o número de divisões CNAE com emprego é -0,9497. O Gini, nesta construção, mede sobretudo quantos setores têm emprego, e não a desigualdade entre setores grandes. Sinal e interpretação da X4 dependem dessa leitura.

## Autocorrelação dentro de cada município

Aplicado à série de dez anos de cada município, com os resíduos do Modelo 2. A tabela de Durbin-Watson para n = 10 e k' = 5 tem dL = 0,243 e dU = 2,822 (valores lidos do PDF por OCR, [a confirmar]). Com dU maior que 4 - dU não há zona de não rejeição: a tabela só permite conclusão para d < dL.

| Município | Durbin-Watson | Decisão pela tabela | ρ auxiliar | Breusch-Godfrey p |
|---|---|---|---|---|
| Adrianópolis | 0,0838 | autocorrelação positiva | 0,9234 | 0,0223 |
| Agudos do Sul | 0,3703 | zona de inconclusão | 0,6308 | 0,8645 |
| Almirante Tamandaré | 0,0776 | autocorrelação positiva | 0,9166 | 0,6644 |
| Araucária | 0,1142 | autocorrelação positiva | 0,7538 | 0,0238 |
| Balsa Nova | 0,7827 | zona de inconclusão | 0,6296 | 0,3380 |
| Bocaiúva do Sul | 0,6941 | zona de inconclusão | 0,6469 | 0,4167 |
| Campina Grande do Sul | 0,0909 | autocorrelação positiva | 0,9635 | 0,6055 |
| Campo do Tenente | 0,5543 | zona de inconclusão | 0,6648 | 0,0506 |
| Campo Largo | 0,0690 | autocorrelação positiva | 0,9554 | 0,4231 |
| Campo Magro | 0,5339 | zona de inconclusão | 0,7337 | 0,1150 |
| Cerro Azul | 0,2081 | autocorrelação positiva | 1,0028 | 0,0510 |
| Colombo | 0,2745 | zona de inconclusão | 0,6810 | 0,2648 |
| Contenda | 1,5334 | zona de inconclusão | 0,1792 | 0,8594 |
| Curitiba | 0,0751 | autocorrelação positiva | 0,9420 | 0,1735 |
| Fazenda Rio Grande | 0,2504 | zona de inconclusão | 0,6773 | 0,5214 |
| Itaperuçu | 0,6567 | zona de inconclusão | 0,5107 | 0,3814 |
| Lapa | 0,8421 | zona de inconclusão | 0,5635 | 0,7205 |
| Mandirituba | 0,1438 | autocorrelação positiva | 0,7556 | 0,1361 |
| Piên | 0,7010 | zona de inconclusão | 0,6372 | 0,0487 |
| Pinhais | 0,7376 | zona de inconclusão | 0,6089 | 0,1666 |
| Piraquara | 0,0850 | autocorrelação positiva | 0,8409 | 0,1142 |
| Quatro Barras | 0,2012 | autocorrelação positiva | 0,9397 | 0,6800 |
| Quitandinha | 0,1255 | autocorrelação positiva | 0,8984 | 0,5017 |
| Rio Branco do Sul | 0,0853 | autocorrelação positiva | 0,8967 | 0,9413 |
| Rio Negro | 0,0758 | autocorrelação positiva | 0,8976 | 0,3751 |
| São José dos Pinhais | 0,0477 | autocorrelação positiva | 0,9529 | 0,1623 |
| Tijucas do Sul | 1,2783 | zona de inconclusão | 0,2909 | 0,4325 |
| Tunas do Paraná | 0,7583 | zona de inconclusão | 0,5594 | 0,0543 |
| Doutor Ulysses | 0,6755 | zona de inconclusão | 0,6581 | 0,8327 |

Resumo: 14 municípios com autocorrelação positiva pela tabela; 15 na zona de inconclusão; 3 com Breusch-Godfrey significativo a 5%.

Essa autocorrelação positiva não é corrigida por nenhum método ensinado aplicável ao painel. Os erros-padrão, mesmo os de White, tendem a estar subestimados nesse caso. Isso é limitação do trabalho.
