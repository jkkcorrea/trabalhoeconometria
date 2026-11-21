# Tratamento das três fragilidades (script 08)

Erros-padrão agrupados por município (HC1) e t com 28 graus de liberdade, salvo indicação.

## 1. Forma funcional

Ponto de partida: o RESET rejeita a forma linear no Modelo 2 e no modelo de efeitos fixos. Estimaram-se especificações alternativas dentro do modelo de efeitos fixos. O RESET aparece em duas versões: com potências 2 e 3 de cada regressor e com potências 2 e 3 dos valores ajustados. Os graus de liberdade usam o posto da matriz: com termos quadráticos, o quadrado de X2 é exatamente colinear com o regressor X2 ao quadrado e não acrescenta parâmetro (por isso 11 e não 14 graus de liberdade no numerador).

| Especificação | R² ajustado | AIC | BIC | RESET regressores: F | gl | p-valor | RESET ajustados: F | gl  | p-valor  |
|---|---|---|---|---|---|---|---|---|---|
| Efeitos fixos linear | 0,9555 | -966,6690 | -841,8930 | 4,3018 | 8; 249 | < 0,0001 | 0,4778 | 2; 255 | 0,6207 |
| Efeitos fixos linear com ln dos vínculos | 0,9555 | -965,9548 | -837,5090 | 3,4881 | 10; 246 | 0,0003 | 0,6932 | 2; 254 | 0,5009 |
| Efeitos fixos com quadráticos de X2, X3 e X4 | 0,9584 | -984,0519 | -848,2663 | 1,6686 | 11; 243 | 0,0811 | 3,0022 | 2; 252 | 0,0515 |
| Efeitos fixos de município e ano com quadráticos | 0,9646 | -1.023,5348 | -858,3902 | 2,9601 | 9; 237 | 0,0024 | 2,4058 | 2; 244 | 0,0923 |

Leitura numérica: o RESET de regressores passa de < 0,0001 (linear) para 0,0811 com termos quadráticos de X2, X3 e X4 (valores ajustados: 0,0515), ambos próximos do limite de 5%, e o AIC cai de -966,67 para -984,05. O ln dos vínculos como controle não melhora o ajuste. Com efeitos fixos de município e de ano e quadráticos o RESET de regressores rejeita (0,0024).

Coeficientes do modelo de efeitos fixos com quadráticos:

| Termo | Estimativa | EP agrupado | t | p-valor (t, 28 gl) |
|---|---|---|---|---|
| X2 ensino superior (%) | 0,0221 | 0,0058 | 3,8413 | 0,0006 |
| X3 dominância industrial (%) | 0,0001 | 0,0011 | 0,0929 | 0,9266 |
| X4 diversificação (Shannon) | -0,0772 | 0,1537 | -0,5023 | 0,6194 |
| X5 Selic real (% a.a.) | 0,0040 | 0,0008 | 4,7075 | < 0,0001 |
| X2 ao quadrado | -0,0004 | 0,0001 | -2,6393 | 0,0134 |
| X3 ao quadrado | -6,919e-06 | 1,664e-05 | -0,4158 | 0,6808 |
| X4 ao quadrado | -0,0041 | 0,0333 | -0,1234 | 0,9027 |

Efeitos marginais médios (derivada em relação a cada variável, avaliada na média amostral; variância pelo método delta):

| Termo | Média do regressor | Efeito marginal médio | EP agrupado | t | p-valor (t, 28 gl) | Vértice da parábola | Mínimo observado | Máximo observado | Vértice no suporte |
|---|---|---|---|---|---|---|---|---|---|
| X2 ensino superior | 15,2523 | 0,0102 | 0,0017 | 5,8860 | < 0,0001 | 28,3263 | 2,7798 | 35,9181 | sim |
| X3 dominância industrial | 25,6705 | -0,0003 | 0,0007 | -0,3631 | 0,7192 | 7,4478 | -14,0686 | 67,5915 | sim |
| X4 diversificação | 2,6513 | -0,0990 | 0,0460 | -2,1528 | 0,0401 | -9,3923 | 0,9874 | 3,4156 | não |

Teste conjunto dos três termos quadráticos: F = 2,4802 (gl 3; 28), p-valor = 0,0817. O quadrático de X2 é significativo isoladamente (p-valor = 0,0134), os de X3 e X4 não.

Figura: `figuras_graficos/fragilidades_efeito_marginal_superior.png` (efeito marginal de X2 por nível de X2).

Observação sobre o vértice: -b/(2c) é o ponto de máximo ou de mínimo da parábola, não ponto de inflexão. O vértice de X4 (-9,3923) fica fora do intervalo observado (0,9874 a 3,4156), de modo que a curvatura de X4 não tem interpretação dentro dos dados.

Escolha da forma de Y (Box-Cox, razão de verossimilhança; lambda = 0 é o logaritmo e lambda = 1 o nível):

| Modelo | Lambda estimado | IC 95% | LR contra logaritmo | p-valor | LR contra nível | p-valor  |
|---|---|---|---|---|---|---|
| MQO empilhado | -1,6531 | [-2,0700; -1,2400] | 60,8434 | < 0,0001 | 153,0166 | < 0,0001 |
| Efeitos fixos (variáveis binárias de município) | -0,1349 | [-0,4900; 0,2100] | 0,5483 | 0,4590 | 40,4880 | < 0,0001 |

Com efeitos fixos, o logaritmo não é rejeitado (p-valor = 0,4590) e o nível é rejeitado (p-valor < 0,0001); no MQO empilhado ambos são rejeitados, e o lambda estimado fica longe de 0 e de 1.

## 2. Sensibilidade da Selic real (10 valores distintos)

| Cenário | N | Estimativa | EP agrupado | t | gl | p-valor |
|---|---|---|---|---|---|---|
| Efeitos fixos, todos os anos (erro agrupado por município) | 290 | 0,0040 | 0,0010 | 3,9375 | 28 | 0,0005 |
| Sem o ano 2012 | 261 | 0,0033 | 0,0008 | 3,9663 | 28 | 0,0005 |
| Sem o ano 2013 | 261 | 0,0040 | 0,0011 | 3,7455 | 28 | 0,0008 |
| Sem o ano 2014 | 261 | 0,0039 | 0,0010 | 3,9529 | 28 | 0,0005 |
| Sem o ano 2015 | 261 | 0,0041 | 0,0011 | 3,8366 | 28 | 0,0007 |
| Sem o ano 2016 | 261 | 0,0054 | 0,0010 | 5,4277 | 28 | < 0,0001 |
| Sem o ano 2017 | 261 | 0,0037 | 0,0013 | 2,7988 | 28 | 0,0092 |
| Sem o ano 2018 | 261 | 0,0040 | 0,0011 | 3,7895 | 28 | 0,0007 |
| Sem o ano 2019 | 261 | 0,0042 | 0,0010 | 4,1218 | 28 | 0,0003 |
| Sem o ano 2020 | 261 | 0,0039 | 0,0010 | 3,8781 | 28 | 0,0006 |
| Sem o ano 2021 | 261 | 0,0037 | 0,0010 | 3,6363 | 28 | 0,0011 |
| Sem 2020 e 2021 | 232 | 0,0027 | 0,0012 | 2,3617 | 28 | 0,0254 |
| Com tendência linear no ano | 290 | 0,0060 | 0,0010 | 5,9776 | 28 | < 0,0001 |
| Erro agrupado por ano (10 grupos, t com 9 gl) | 290 | 0,0040 | 0,0011 | 3,8082 | 9 | 0,0042 |
| Com termos quadráticos de X2, X3 e X4 | 290 | 0,0040 | 0,0008 | 4,7075 | 28 | < 0,0001 |

Bootstrap wild cluster por ano, restrito, com todas as 2^10 = 1.024 combinações de sinais (resultado exato, sem aleatoriedade):

| Modelo | t (agrupado por ano) | p-valor do bootstrap exato | Combinações de sinais |
|---|---|---|---|
| Efeitos fixos linear | 3,8082 | 0,0547 | 1.024 |
| Efeitos fixos com quadráticos | 4,2990 | 0,0547 | 1.024 |

Bootstrap exato por ano: p-valor = 0,0547 no modelo linear e 0,0547 com quadráticos; esse procedimento não rejeita a 5%, ao contrário do erro agrupado por município e do erro agrupado por ano com t de 9 graus de liberdade (0,0042). O bootstrap exato refaz a transformação within em cada réplica.

Leitura numérica: o coeficiente de X5 varia de 0,0033 a 0,0054 quando se retira cada ano (todos positivos, p-valores abaixo de 0,05), vale 0,0027 sem 2020 e 2021 (p-valor = 0,0254) e 0,0060 com tendência linear.

## 3. Exogeneidade estrita e regressores defasados

Com regressores estritamente exógenos, valores futuros de X2, X3 e X4 não devem afetar o salário corrente depois de controlar os valores correntes e o efeito de município (Wooldridge, 2010).

| Modelo | Termo | Estimativa | EP agrupado | t | p-valor (t, 28 gl) | N |
|---|---|---|---|---|---|---|
| Efeitos fixos com valores futuros dos regressores (2012 a 2020) | X2 ensino superior (%) | 0,0071 | 0,0020 | 3,6443 | 0,0011 | 261 |
| Efeitos fixos com valores futuros dos regressores (2012 a 2020) | X3 dominância industrial (%) | -0,0008 | 0,0006 | -1,2312 | 0,2285 | 261 |
| Efeitos fixos com valores futuros dos regressores (2012 a 2020) | X4 diversificação (Shannon) | -0,0446 | 0,0638 | -0,6983 | 0,4907 | 261 |
| Efeitos fixos com valores futuros dos regressores (2012 a 2020) | X5 Selic real (% a.a.) | 0,0037 | 0,0013 | 2,8677 | 0,0078 | 261 |
| Efeitos fixos com valores futuros dos regressores (2012 a 2020) | X2 do ano seguinte | 0,0036 | 0,0014 | 2,5769 | 0,0155 | 261 |
| Efeitos fixos com valores futuros dos regressores (2012 a 2020) | X3 do ano seguinte | 0,0009 | 0,0011 | 0,7946 | 0,4335 | 261 |
| Efeitos fixos com valores futuros dos regressores (2012 a 2020) | X4 do ano seguinte | -0,0471 | 0,0566 | -0,8321 | 0,4124 | 261 |
| Efeitos fixos com X2, X3 e X4 defasados em um ano (2013 a 2021) | X2 defasada | 0,0050 | 0,0011 | 4,3917 | 0,0001 | 261 |
| Efeitos fixos com X2, X3 e X4 defasados em um ano (2013 a 2021) | X3 defasada | -0,0014 | 0,0002 | -5,7049 | < 0,0001 | 261 |
| Efeitos fixos com X2, X3 e X4 defasados em um ano (2013 a 2021) | X4 defasada | -0,1037 | 0,0402 | -2,5800 | 0,0154 | 261 |
| Efeitos fixos com X2, X3 e X4 defasados em um ano (2013 a 2021) | X5 Selic real (% a.a.) | 0,0044 | 0,0009 | 5,1044 | < 0,0001 | 261 |

Teste conjunto dos valores futuros: F = 2,6191 (gl 3; 28), p-valor = 0,0705. O coeficiente de X2 do ano seguinte é 0,0036 (p-valor = 0,0155).

O teste conjunto não rejeita a exogeneidade estrita a 5%, mas o valor futuro de X2 é significativo isoladamente, o que é compatível com antecipação ou retroalimentação entre escolaridade e salário.

Com regressores defasados em um ano, X2 e X4 mantêm o sinal dos valores contemporâneos; X3 defasada tem coeficiente -0,0014 (p-valor < 0,0001), diferente do coeficiente contemporâneo de efeitos fixos, que não difere de zero.

## 4. Simulação de cenários com efeitos fixos

Variação percentual de Y, 100 x (exp(delta x b) - 1), com os coeficientes de cada modelo. O intervalo usa o erro agrupado por município e t com 28 graus de liberdade.

| Cenário | Modelo | Variação de Y (%) | IC 95% (%) |
|---|---|---|---|
| Cenário 1: +10 pontos em X3 | MQO empilhado (Modelo 2) | 5,5604 |  |
| Cenário 1: +10 pontos em X3 | Efeitos fixos linear | -0,4833 | [-1,8247; 0,8764] |
| Cenário 1: +10 pontos em X3 | Efeitos fixos com quadráticos (média dos dois municípios, base 2021) | -0,3815 |  |
| Cenário 2: +5 pontos em X2 | MQO empilhado (Modelo 2) | 8,2905 |  |
| Cenário 2: +5 pontos em X2 | Efeitos fixos linear | 4,3984 | [2,4304; 6,4042] |
| Cenário 2: +5 pontos em X2 | Efeitos fixos com quadráticos (média dos 29 municípios, base 2021) | 3,7479 |  |

Com quadráticos, a variação de +5 pontos em X2 vai de -3,7793% (Curitiba) a 7,6468% (Bocaiúva do Sul) entre os 29 municípios; os municípios com X2 acima do vértice da parábola têm efeito negativo.

## 5. Sensibilidade a observações influentes

Reestimação do MQO empilhado e do modelo de efeitos fixos sem observações específicas: Araucária 2012 e 2013, as 15 observações com distância de Cook acima de 4/n, Lapa 2016 e o município de Adrianópolis (5 anos marcados).

| Cenário | Excluídas | Modelo | Termo | Estimativa | p-valor (t, G - 1 gl) |
|---|---|---|---|---|---|
| Amostra completa | 0 | MQO empilhado | X2 ensino superior (%) | 0,0159 | < 0,0001 |
| Amostra completa | 0 | MQO empilhado | X3 dominância industrial (%) | 0,0054 | < 0,0001 |
| Amostra completa | 0 | Efeitos fixos | X2 ensino superior (%) | 0,0086 | < 0,0001 |
| Amostra completa | 0 | Efeitos fixos | X3 dominância industrial (%) | -0,0005 | 0,4707 |
| Sem Araucária 2012 e 2013 | 2 | MQO empilhado | X2 ensino superior (%) | 0,0162 | < 0,0001 |
| Sem Araucária 2012 e 2013 | 2 | MQO empilhado | X3 dominância industrial (%) | 0,0062 | < 0,0001 |
| Sem Araucária 2012 e 2013 | 2 | Efeitos fixos | X2 ensino superior (%) | 0,0088 | 0,0002 |
| Sem Araucária 2012 e 2013 | 2 | Efeitos fixos | X3 dominância industrial (%) | -0,0002 | 0,8413 |
| Sem as observações com Cook > 4/n | 15 | MQO empilhado | X2 ensino superior (%) | 0,0172 | < 0,0001 |
| Sem as observações com Cook > 4/n | 15 | MQO empilhado | X3 dominância industrial (%) | 0,0058 | < 0,0001 |
| Sem as observações com Cook > 4/n | 15 | Efeitos fixos | X2 ensino superior (%) | 0,0099 | < 0,0001 |
| Sem as observações com Cook > 4/n | 15 | Efeitos fixos | X3 dominância industrial (%) | -0,0004 | 0,6149 |
| Sem Lapa 2016 | 1 | MQO empilhado | X2 ensino superior (%) | 0,0170 | < 0,0001 |
| Sem Lapa 2016 | 1 | MQO empilhado | X3 dominância industrial (%) | 0,0055 | < 0,0001 |
| Sem Lapa 2016 | 1 | Efeitos fixos | X2 ensino superior (%) | 0,0105 | < 0,0001 |
| Sem Lapa 2016 | 1 | Efeitos fixos | X3 dominância industrial (%) | -0,0004 | 0,5873 |
| Sem Adrianópolis (município inteiro) | 10 | MQO empilhado | X2 ensino superior (%) | 0,0161 | < 0,0001 |
| Sem Adrianópolis (município inteiro) | 10 | MQO empilhado | X3 dominância industrial (%) | 0,0047 | 0,0002 |
| Sem Adrianópolis (município inteiro) | 10 | Efeitos fixos | X2 ensino superior (%) | 0,0076 | < 0,0001 |
| Sem Adrianópolis (município inteiro) | 10 | Efeitos fixos | X3 dominância industrial (%) | -0,0012 | < 0,0001 |

Tabela completa: `resultados_econometricos/fragilidades_influencia_sensibilidade.csv`.

## 6. Selic real e deflator

X5 = ((1 + Selic)/(1 + IPCA) - 1) x 100, e Y é deflacionado pelo mesmo IPCA. Separando X5 em Selic nominal e IPCA do ano, em efeitos fixos:

| Termo | Estimativa | EP agrupado | t | p-valor (t, 28 gl) | EP agrupado por ano | p-valor (por ano, t com 9 gl) |
|---|---|---|---|---|---|---|
| X2 | 0,0088 | 0,0020 | 4,3622 | 0,0002 | 0,0034 | 0,0282 |
| X3 | -0,0005 | 0,0007 | -0,7398 | 0,4656 | 0,0005 | 0,3876 |
| X4 | -0,0736 | 0,0441 | -1,6685 | 0,1064 | 0,0701 | 0,3207 |
| Selic nominal do ano | 0,0039 | 0,0012 | 3,2102 | 0,0033 | 0,0015 | 0,0248 |
| IPCA do ano | -0,0034 | 0,0007 | -4,7493 | < 0,0001 | 0,0017 | 0,0768 |

Se X5 tivesse um efeito próprio, a equação de Fisher imporia coeficientes de sinais opostos e mesma magnitude na Selic nominal e no IPCA. O teste da restrição (soma dos dois coeficientes igual a zero) não rejeita: p-valor = 0,6175 com agrupamento por município e p-valor = 0,8154 com agrupamento por ano. Os dados não distinguem um efeito próprio de X5 de um canal de deflação. Com agrupamento por ano, o exigido para variáveis que só variam no tempo, o IPCA perde significância a 5% (p-valor = 0,0768).

Bootstrap wild cluster por ano com pesos de Webb:

| Modelo | t (agrupado por ano) | p-valor (Webb) | Réplicas |
|---|---|---|---|
| Efeitos fixos linear | 3,8082 | 0,0462 | 9.999 |
| Efeitos fixos com quadráticos | 4,2990 | 0,0492 | 9.999 |

## 7. Quebra estrutural em Curitiba

Teste de Chow: Modelo 2 contra o modelo com a indicadora de Curitiba e suas interações com X2 a X5 (X6 não interage, por ser constante em Curitiba): F = 4,1553 (gl 5; 279), p-valor = 0,0012. Teste clássico, sem erro agrupado; Curitiba tem 10 observações.

## 8. RESET dos Modelos 3 e 3b

| Modelo | RESET regressores: F | gl | p-valor | RESET ajustados: F | gl  | p-valor  |
|---|---|---|---|---|---|---|
| Modelo 3 | 20,0044 | 10; 273 | < 0,0001 | 8,0656 | 2; 281 | 0,0004 |
| Modelo 3b | 18,9711 | 12; 270 | < 0,0001 | 18,9939 | 2; 280 | < 0,0001 |

