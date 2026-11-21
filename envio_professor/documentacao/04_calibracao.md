# Calibração do modelo (scripts 05 e 06)

O Modelo 2 (MQO empilhado) é a linha de base. Esta seção documenta os testes que verificam as hipóteses do modelo clássico sobre o Modelo 2 e as estimações que corrigem as violações encontradas. Todos os coeficientes desta seção usam erro-padrão agrupado por município (HC1) e t com 28 graus de liberdade, salvo indicação.

## 1. Sequência lógica

1. Diagnósticos do Modelo 2 (script 04): heterocedasticidade, autocorrelação, normalidade e forma funcional rejeitam H0 (ver `03_resultados_modelos_classicos.md`).
2. Verificação da origem da autocorrelação: o rho dos resíduos dentro do município é alto no MQO empilhado e só cai nos efeitos fixos, que retiram o efeito do município; no Mundlak, que o mantém no erro, o rho não cai (seção 5).
3. Testes de efeito de município (seção 4): todos rejeitam a ausência de efeito individual e a consistência do MQO empilhado.
4. Estimação com efeito de município (Mundlak, efeitos fixos) e comparação com o MQO empilhado (seções 2 e 3).
5. Inferência com poucos grupos: t com G - 1 graus de liberdade e bootstrap wild cluster (seção 8); X5 com agrupamento por ano (seção 9).

## 2. Estimadores lado a lado

| Estimador | Termo | Estimativa | EP agrupado | t | p-valor (t, 28 gl) | IC 95% |
|---|---|---|---|---|---|---|
| MQO empilhado (Modelo 2) | X2 ensino superior (%) | 0,0159 | 0,0031 | 5,1023 | < 0,0001 | [0,0095; 0,0223] |
| MQO empilhado (Modelo 2) | X3 dominância industrial (%) | 0,0054 | 0,0011 | 4,8333 | < 0,0001 | [0,0031; 0,0077] |
| MQO empilhado (Modelo 2) | X4 diversificação (Shannon) | 0,0762 | 0,0520 | 1,4647 | 0,1541 | [-0,0304; 0,1828] |
| MQO empilhado (Modelo 2) | X5 Selic real (% a.a.) | 0,0066 | 0,0016 | 4,0711 | 0,0003 | [0,0033; 0,0100] |
| MQO empilhado (Modelo 2) | X6 distância a Curitiba (km) | -0,0016 | 0,0016 | -0,9719 | 0,3394 | [-0,0049; 0,0017] |
| Prais-Winsten | X2 ensino superior (%) | 0,0038 | 0,0024 | 1,5849 | 0,1242 | [-0,0011; 0,0087] |
| Prais-Winsten | X3 dominância industrial (%) | 0,0007 | 0,0005 | 1,3183 | 0,1981 | [-0,0004; 0,0019] |
| Prais-Winsten | X4 diversificação (Shannon) | 0,0005 | 0,0523 | 0,0088 | 0,9931 | [-0,1066; 0,1076] |
| Prais-Winsten | X5 Selic real (% a.a.) | 0,0019 | 0,0007 | 2,6056 | 0,0145 | [0,0004; 0,0034] |
| Prais-Winsten | X6 distância a Curitiba (km) | -0,0044 | 0,0020 | -2,1834 | 0,0375 | [-0,0086; -0,0003] |
| Efeitos fixos (within) | X2 ensino superior (%) | 0,0086 | 0,0019 | 4,6332 | < 0,0001 | [0,0048; 0,0124] |
| Efeitos fixos (within) | X3 dominância industrial (%) | -0,0005 | 0,0007 | -0,7313 | 0,4707 | [-0,0018; 0,0009] |
| Efeitos fixos (within) | X4 diversificação (Shannon) | -0,0737 | 0,0437 | -1,6867 | 0,1028 | [-0,1632; 0,0158] |
| Efeitos fixos (within) | X5 Selic real (% a.a.) | 0,0040 | 0,0010 | 3,9375 | 0,0005 | [0,0019; 0,0061] |
| Efeitos fixos de município e ano | X2 ensino superior (%) | 0,0040 | 0,0020 | 2,0364 | 0,0513 | [-2,384e-05; 0,0081] |
| Efeitos fixos de município e ano | X3 dominância industrial (%) | -0,0004 | 0,0008 | -0,5506 | 0,5863 | [-0,0020; 0,0011] |
| Efeitos fixos de município e ano | X4 diversificação (Shannon) | -0,0899 | 0,0467 | -1,9266 | 0,0642 | [-0,1856; 0,0057] |
| Mundlak (efeitos aleatórios correlacionados) | X2 ensino superior (%) | 0,0086 | 0,0019 | 4,5925 | < 0,0001 | [0,0048; 0,0124] |
| Mundlak (efeitos aleatórios correlacionados) | X3 dominância industrial (%) | -0,0005 | 0,0007 | -0,7249 | 0,4746 | [-0,0019; 0,0009] |
| Mundlak (efeitos aleatórios correlacionados) | X4 diversificação (Shannon) | -0,0737 | 0,0441 | -1,6719 | 0,1057 | [-0,1640; 0,0166] |
| Mundlak (efeitos aleatórios correlacionados) | X5 Selic real (% a.a.) | 0,0040 | 0,0010 | 3,9029 | 0,0005 | [0,0019; 0,0061] |
| Mundlak (efeitos aleatórios correlacionados) | X6 distância a Curitiba (km) | -0,0016 | 0,0016 | -0,9903 | 0,3305 | [-0,0049; 0,0017] |
| Mundlak (efeitos aleatórios correlacionados) | Média por município de X2 | 0,0097 | 0,0042 | 2,2881 | 0,0299 | [0,0010; 0,0184] |
| Mundlak (efeitos aleatórios correlacionados) | Média por município de X3 | 0,0079 | 0,0019 | 4,2620 | 0,0002 | [0,0041; 0,0117] |
| Mundlak (efeitos aleatórios correlacionados) | Média por município de X4 | 0,1270 | 0,0723 | 1,7572 | 0,0898 | [-0,0211; 0,2751] |
| Primeiras diferenças | X2 ensino superior (%) | 0,0018 | 0,0021 | 0,8705 | 0,3915 | [-0,0025; 0,0061] |
| Primeiras diferenças | X3 dominância industrial (%) | -2,660e-05 | 0,0005 | -0,0542 | 0,9572 | [-0,0010; 0,0010] |
| Primeiras diferenças | X4 diversificação (Shannon) | -0,0778 | 0,0677 | -1,1484 | 0,2605 | [-0,2165; 0,0609] |
| Primeiras diferenças | X5 Selic real (% a.a.) | 0,0024 | 0,0007 | 3,3385 | 0,0024 | [0,0009; 0,0039] |

Prais-Winsten: rho = 0,9432; iterações = 13. Com rho próximo de 1 a transformação aproxima-se de primeiras diferenças e os coeficientes ficam muito abaixo dos do MQO empilhado; o resultado fica registrado, não é adotado como estimativa de referência. Com rho próximo de 1, a transformação deixa em X6 (constante no tempo) só a variação da primeira observação de cada município e do fator (1 - rho), então o coeficiente de X6 desse estimador é frágil. O rho é estimado em resíduos que contêm o efeito de município e reflete esse efeito, não um processo AR(1) puro.

## 3. Comparação direta dos coeficientes (MQO empilhado e efeitos fixos)

| Termo | MQO empilhado | Efeitos fixos | Variação % de Y por unidade (MQO) | Variação % de Y por unidade (efeitos fixos) |
|---|---|---|---|---|
| X2 ensino superior (%) | 0,0159 | 0,0086 | 1,61 | 0,86 |
| X3 dominância industrial (%) | 0,0054 | -0,0005 | 0,54 | -0,05 |
| X4 diversificação (Shannon) | 0,0762 | -0,0737 | 7,92 | -7,10 |
| X5 Selic real (% a.a.) | 0,0066 | 0,0040 | 0,67 | 0,40 |

Figura: `figuras_graficos/calibracao_coeficientes_estimadores.png`.

## 4. Testes de efeito de município e de autocorrelação em painel

| Teste | H0 | Ha | Estatística | gl | p-valor |
|---|---|---|---|---|---|
| Teste F de efeitos individuais (pooling contra within) | sem efeitos individuais | existem efeitos individuais | 75,8928 | 28; 257 | < 0,0001 |
| Breusch-Pagan de multiplicadores de Lagrange (efeitos individuais) | sem efeitos individuais | existem efeitos individuais | 648,1978 | 1 | < 0,0001 |
| Hausman (efeitos fixos contra efeitos aleatórios) | efeitos aleatórios consistentes | efeitos aleatórios inconsistentes | 30,9454 | 4 | < 0,0001 |
| Mundlak: médias por município = 0 (gl residuais) | efeito do município não correlacionado com X | alguma média por município com coeficiente não nulo | 14,7641 | 3; 281 | < 0,0001 |
| Mundlak: médias por município = 0 (gl do denominador = G - 1) | efeito do município não correlacionado com X | alguma média por município com coeficiente não nulo | 14,7641 | 3; 28 | < 0,0001 |
| Wooldridge de autocorrelação em painel (within) | sem autocorrelação de primeira ordem | autocorrelação de primeira ordem | 32,1183 | 1; 259 | < 0,0001 |
| Breusch-Godfrey de painel, ordem 1 (within) | sem autocorrelação de ordem 1 | autocorrelação de ordem 1 | 25,5735 | 1 | < 0,0001 |

## 5. Autocorrelação dos resíduos dentro do município

| Modelo | rho dos resíduos no mesmo município | d aproximado = 2(1 - rho) |
|---|---|---|
| MQO empilhado (Modelo 2) | 0,8279 | 0,3442 |
| Mundlak | 0,9047 | 0,1906 |
| Efeitos fixos (within) | 0,3026 | 1,3949 |

Há duas definições de rho nos arquivos, ambas sobre os resíduos do Modelo 2 e só entre linhas do mesmo município: (a) rho de regressão, soma(e_t e_t-1)/soma(e_t-1^2), usado nesta tabela (0,8279) e (b) correlação entre resíduos vizinhos, em `diagnosticos_modelo_2.csv` (0,8846). O d médio por município, média dos d de cada município, é 0,4643 e corresponde a um rho aproximado de 0,7679. As três medidas indicam autocorrelação positiva forte e diferem por construção.

## 6. Forma funcional (RESET de Ramsey, potências 2 e 3)

| Modelo | F | gl | p-valor | R² ajustado |
|---|---|---|---|---|
| MQO empilhado (Modelo 2) | 18,4638 | 10; 274 | < 0,0001 | 0,6393 |
| Mundlak | 15,7841 | 16; 265 | < 0,0001 | 0,7116 |
| Efeitos fixos (variáveis binárias de município) | 4,3018 | 8; 249 | < 0,0001 | 0,9555 |

## 7. Heterocedasticidade e tamanho do município

| Ordenado por | F | gl | p-valor (unilateral) | p-valor (bilateral) |
|---|---|---|---|---|
| vinculos_ativos | 1,4317 | 110; 110 | 0,0306 | 0,0611 |
| prop_superior | 1,0479 | 110; 110 | 0,4032 | 0,8064 |
| dom_industrial | 1,1974 | 110; 110 | 0,1732 | 0,3463 |

Regressão de ln(resíduo²) sobre ln(vínculos ativos), Modelo 2: correlação 0,1265, inclinação 0,1556, t = 2,1640, p-valor = 0,0313. Uma inclinação próxima de -1 indicaria variância proporcional a 1/n e justificaria mínimos quadrados ponderados pelo número de vínculos. A inclinação estimada é positiva e significativa a 5%: a variância dos resíduos cresce com o tamanho do município, o oposto do que essa ponderação supõe, e a correlação é baixa. O Goldfeld-Quandt unilateral (variância crescente), ordenado por vínculos, rejeita a 5% (p-valor = 0,0306); o bilateral dá p-valor = 0,0611. A ponderação não foi adotada e a inferência usa erros-padrão robustos.

## 8. Bootstrap wild cluster (H0: coeficiente igual a zero; 9.999 réplicas)

| Estimador | Termo | t | p-valor bootstrap |
|---|---|---|---|
| MQO empilhado (Modelo 2) | X2 ensino superior (%) | 5,1023 | 0,0003 |
| MQO empilhado (Modelo 2) | X3 dominância industrial (%) | 4,8333 | < 0,0001 |
| MQO empilhado (Modelo 2) | X4 diversificação (Shannon) | 1,4647 | 0,0895 |
| MQO empilhado (Modelo 2) | X5 Selic real (% a.a.) | 4,0711 | 0,0001 |
| MQO empilhado (Modelo 2) | X6 distância a Curitiba (km) | -0,9719 | 0,5003 |
| Efeitos fixos (within) | X2 ensino superior (%) | 4,6332 | < 0,0001 |
| Efeitos fixos (within) | X3 dominância industrial (%) | -0,7313 | 0,6181 |
| Efeitos fixos (within) | X4 diversificação (Shannon) | -1,6867 | 0,1124 |
| Efeitos fixos (within) | X5 Selic real (% a.a.) | 3,9375 | 0,0001 |
| Mundlak | X2 ensino superior (%) | 4,5925 | < 0,0001 |
| Mundlak | X3 dominância industrial (%) | -0,7249 | 0,6181 |
| Mundlak | X4 diversificação (Shannon) | -1,6719 | 0,1124 |
| Mundlak | X5 Selic real (% a.a.) | 3,9029 | 0,0001 |
| Mundlak | X6 distância a Curitiba (km) | -0,9903 | 0,5326 |
| Mundlak | Média por município de X2 | 2,2881 | 0,0984 |
| Mundlak | Média por município de X3 | 4,2620 | 0,0329 |
| Mundlak | Média por município de X4 | 1,7572 | 0,1159 |

## 9. Selic real com erro agrupado por ano (10 grupos, t com 9 graus de liberdade)

| Estimador | Estimativa | EP agrupado por ano | t | p-valor (t, 9 gl) |
|---|---|---|---|---|
| MQO empilhado (Modelo 2) | 0,0066 | 0,0019 | 3,4786 | 0,0070 |
| Efeitos fixos (within) | 0,0040 | 0,0011 | 3,8082 | 0,0042 |
| Mundlak | 0,0040 | 0,0011 | 3,7361 | 0,0047 |

## 10. Observações influentes (Modelo 2)

Referências: distância de Cook > 4/n = 0,0138; |DFBETAS| > 2/raiz(n) = 0,1174. Observações acima da distância de Cook de 4/n: 15 de 290.

| Município | Ano | Distância de Cook | Alavancagem | Maior |DFBETAS| |
|---|---|---|---|---|
| Araucária | 2012 | 0,1620 | 0,0430 | 0,9080 |
| Lapa | 2016 | 0,1594 | 0,0705 | 0,8501 |
| Araucária | 2013 | 0,0952 | 0,0307 | 0,6565 |
| Adrianópolis | 2014 | 0,0886 | 0,0228 | 0,5375 |
| Adrianópolis | 2013 | 0,0665 | 0,0196 | 0,3755 |
| Adrianópolis | 2016 | 0,0621 | 0,0375 | 0,3766 |
| Adrianópolis | 2015 | 0,0557 | 0,0246 | 0,3443 |
| Adrianópolis | 2012 | 0,0295 | 0,0232 | 0,1812 |

A tabela completa está em `resultados_econometricos/calibracao_influencia.csv`.

## 11. Modelos adicionais (script 05)

| Modelo | N | R² | p do RESET |
|---|---|---|---|
| Modelo 3b (referência) | 290 | 0,6706 | < 0,0001 |
| Modelo 3c (3b centrado) | 290 | 0,6706 | < 0,0001 |
| Modelo 4 (tendência) | 290 | 0,6465 | < 0,0001 |

| Modelo | Termo | Estimativa | EP agrupado | p-valor (t, 28 gl) | FIV ajustado |
|---|---|---|---|---|---|
| Modelo 3c (3b com interação centrada) | X2 ensino superior (%) | 0,0127 | 0,0032 | 0,0005 | 1,2332 |
| Modelo 3c (3b com interação centrada) | X3 centrada | 0,0054 | 0,0011 | < 0,0001 | 1,2224 |
| Modelo 3c (3b com interação centrada) | X4 diversificação (Shannon) | 0,0743 | 0,0532 | 0,1733 | 1,6722 |
| Modelo 3c (3b com interação centrada) | X5 Selic real (% a.a.) | 0,0064 | 0,0016 | 0,0003 | 1,0038 |
| Modelo 3c (3b com interação centrada) | X6 centrada | -0,0012 | 0,0016 | 0,4488 | 1,2224 |
| Modelo 3c (3b com interação centrada) | Indicadora de Curitiba | 0,2075 | 0,0910 | 0,0304 | 1,2647 |
| Modelo 3c (3b com interação centrada) | X3 x X6 centradas | 2,132e-05 | 2,946e-05 | 0,4754 |  |
| Modelo 4 (Modelo 2 com tendência) | X2 ensino superior (%) | 0,0163 | 0,0034 | < 0,0001 |  |
| Modelo 4 (Modelo 2 com tendência) | X3 dominância industrial (%) | 0,0054 | 0,0011 | < 0,0001 |  |
| Modelo 4 (Modelo 2 com tendência) | X4 diversificação (Shannon) | 0,0773 | 0,0534 | 0,1586 |  |
| Modelo 4 (Modelo 2 com tendência) | X5 Selic real (% a.a.) | 0,0054 | 0,0014 | 0,0006 |  |
| Modelo 4 (Modelo 2 com tendência) | X6 distância a Curitiba (km) | -0,0015 | 0,0017 | 0,3650 |  |
| Modelo 4 (Modelo 2 com tendência) | Tendência (ano - 2012) | -0,0027 | 0,0044 | 0,5456 |  |

Modelo 3c: ajuste idêntico ao do Modelo 3b (mesmo R², mesmo RESET); o FIV por variável explicativa cai porque a interação passa a ser calculada sobre variáveis centradas. Modelo 4: coeficiente da tendência -0,0027 (p-valor = 0,5456); o coeficiente de X5 é 0,0054 (p-valor = 0,0006).

Teste conjunto de Mundlak (script 05, matriz agrupada por município, denominador com graus de liberdade residuais): F = 14,7641 (gl 3; 281), p-valor < 0,0001.

As tabelas completas estão em `resultados_econometricos/calibracao_*.csv` e `robustez_*.csv`.
