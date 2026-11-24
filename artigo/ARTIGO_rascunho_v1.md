# Salário médio real formal e estrutura produtiva nos municípios da Região Metropolitana de Curitiba, 2012 a 2021

**Rascunho v1 (23/11/2026).** Marcações: [revisar] = interpretação teórica para o pesquisador confirmar; [a inserir] = referência ainda não conferida; números vêm de `envio_professor/documentacao/`.

## Resumo

Este trabalho estima a associação entre o salário médio real formal e a estrutura produtiva dos 29 municípios da Região Metropolitana de Curitiba entre 2012 e 2021, com 290 observações em painel empilhado. Usa-se mínimos quadrados ordinários com erros-padrão de White. A escolaridade (proporção de vínculos com ensino superior completo), a participação industrial no valor adicionado e a distância a Curitiba apresentam coeficientes positivos, positivos e negativos, respectivamente, todos significativos a 5%. A diversificação setorial do emprego, medida pelo Gini da distribuição dos vínculos entre as divisões da CNAE, associa-se a salários maiores (coeficiente de −0,655 no Gini, p < 0,001). A Selic real tem efeito positivo pequeno, de cerca de 0,66% por ponto percentual. Os diagnósticos rejeitam a forma funcional linear, a normalidade dos resíduos e a homocedasticidade; a autocorrelação positiva dentro dos municípios é declarada como limitação. Os resultados são associações, não efeitos causais.

**Palavras-chave:** salário real; RMC; estrutura produtiva; Gini setorial; mínimos quadrados ordinários.

## Abstract

[a inserir: tradução do resumo, após revisão do texto.]

## 1 Introdução

Os salários formais variam de forma acentuada entre municípios de uma mesma região metropolitana. Na Região Metropolitana de Curitiba (RMC), essa diferença coexiste com um processo de expansão de atividades industriais e de serviços ao longo da última década. A pergunta deste trabalho é se a estrutura produtiva de cada município, descrita por sua escolaridade, sua participação industrial, sua diversificação setorial e sua localização, está associada ao salário médio real dos vínculos formais.

[revisar: motivação da pergunta e relevância para a RMC, com referências a serem inseridas.]

O objetivo é estimar a associação entre o salário médio real formal dos municípios da RMC e cinco características do município: escolaridade, estrutura industrial, diversificação setorial do emprego, Selic real e distância a Curitiba, no período de 2012 a 2021. O trabalho testa a hipótese nula de que o salário não depende dessas características, controlados os efeitos comuns, contra a hipótese de que ao menos uma delas afeta o salário. Para cada variável, os sinais esperados são: positivo para escolaridade e industrialização; negativo para o Gini setorial, isto é, positivo para a diversificação; exploratório para a Selic; e negativo para a distância a Curitiba.

O trabalho usa dados oficiais de quatro fontes e um modelo de mínimos quadrados ordinários, com inferência robusta à heterocedasticidade. Os resultados são descritivos e associativos. [revisar: contribuição do trabalho em relação à literatura, a ser inserida.]

## 2 Referencial teórico

[a inserir: referencial sobre salário e escolaridade (capital humano), estrutura produtiva e diversificação, e juros reais. Nenhuma referência foi conferida ainda; manter apenas as obras efetivamente lidas.]

Os livros-base do método são Gujarati e Porter (2004), para regressão linear, testes e diagnósticos, e Hoffmann (2006), para a medida de desigualdade de Gini.

## 3 Dados

### 3.1 Unidades e período

A unidade de observação são os 29 municípios da RMC (código IBGE 05501), de 2012 a 2021. O painel é balanceado, com 290 observações. O recorte é limitado pela disponibilidade do valor adicionado setorial municipal, que não é publicado para 2022 e 2023 (SIDRA, tabela 5938).

### 3.2 Fontes e construção das variáveis

| Variável | Descrição | Fonte |
|---|---|---|
| Y: salário médio real | remuneração média dos vínculos formais, em reais de 2021 (logaritmo natural) | RAIS (Ministério do Trabalho), deflacionada pelo IPCA (série 433, Banco Central) |
| X2: escolaridade | % dos vínculos ativos com ensino superior completo | RAIS |
| X3: industrialização | VAB da indústria / VAB total, em % | IBGE, SIDRA, tabela 5938 |
| X4: diversificação (Gini) | Gini da distribuição dos vínculos entre as 87 divisões da CNAE, com zeros | RAIS |
| X5: Selic real | Selic acumulada no ano, deflacionada pelo IPCA anual, em % a.a. | Banco Central (séries 4390 e 433) |
| X6: distância | distância entre os centroides do município e de Curitiba, em km | IBGE (malha municipal) |

A variável dependente é o logaritmo natural do salário. A escolha tem duas justificativas: o salário é sempre positivo e tem distribuição assimétrica à direita, e, com o logaritmo, o coeficiente de cada regressora indica variação relativa do salário [revisar: justificativa completa, com referência ao Gujarati, 4ª ed., pp. 207-208 e 449].

### 3.3 Estatísticas descritivas

| Variável | Média | Mínimo | Máximo |
|---|---|---|---|
| Salário médio real (R$ de 2021) | 2.651,25 | 1.792,70 | 4.501,12 |
| ln do salário real | 7,8609 | 7,4915 | 8,4121 |
| X2 escolaridade (%) | 15,25 | 2,78 | 35,92 |
| X3 industrialização (%) | 25,67 | −14,07 | 67,59 |
| X4 Gini setorial | 0,8537 | 0,7328 | 0,9740 |
| X5 Selic real (% a.a.) | 2,27 | −5,11 | 7,28 |
| X6 distância (km) | 45,92 | 0,00 | 94,89 |

Dois valores merecem nota. Em Araucária, o VAB da indústria é negativo em 2012 (−R$ 560,8 milhões) e 2013 (−R$ 246,4 milhões), como publicado pelo IBGE; o valor é mantido e marcado. Em Adrianópolis, a participação industrial passa de 7% (2014) para 45% (2015). O salto foi confirmado na fonte e, segundo a pesquisa feita para o trabalho, pode estar relacionado à fábrica de cimento inaugurada no município em dezembro de 2015. Essa relação não está confirmada: o emprego formal industrial só cresce em 2017 (ver `fontes/ADRIANOPOLIS_PESQUISA.md`).

### 3.4 Construção do Gini setorial

Para cada município e ano, cada divisão da CNAE recebe a participação x_i de seus vínculos ativos no total do município; divisões sem vínculo recebem zero. As 87 participações são ordenadas em ordem crescente, e o índice é calculado pela fórmula G = (2/n) Σ i·x_i − (n+1)/n, com n = 87 (Hoffmann, 2006, cap. 17, pp. 340 e 341). O índice vai de 0 (vínculos igualmente distribuídos entre as divisões) a valores próximos de 1 (máximo de 86/87 = 0,989). A medida é uma adaptação: Hoffmann a aplica a pessoas ou empresas, e aqui as unidades são divisões setoriais. Ela depende fortemente do número de divisões com vínculo (correlação de −0,95). Como verificação, o Gini foi calculado só com as divisões que têm vínculo; o coeficiente é −0,638 (p = 0,001), com o mesmo sinal e significância.

## 4 Metodologia

### 4.1 Modelo

ln(salário real)_it = β0 + β1 X2_it + β2 X3_it + β3 X4_it + β4 X5_t + β5 X6_i + u_it

A estimação é feita por mínimos quadrados ordinários com as 290 observações empilhadas. A inferência usa erros-padrão de White (HC1), com estatística t de n − k = 284 graus de liberdade.

Não há variáveis binárias de município nem métodos de dados em painel. A orientação de Econometria I não inclui esses métodos, e o modelo não os usa.

### 4.2 Testes e diagnósticos

Em cada teste, H0 e Ha são explicitadas e a decisão é tomada a 5%:

- **Multicolinearidade:** fator de inflação da variância (FIV), com limite de 10 (Gujarati, cap. 10).
- **Heterocedasticidade:** Breusch-Pagan-Godfrey e Goldfeld-Quandt (Gujarati, cap. 11).
- **Normalidade dos resíduos:** Shapiro-Wilk, com gráfico quantil-quantil (Q-Q).
- **Forma funcional:** RESET de Ramsey, com potências 2 e 3 dos valores ajustados (Gujarati, cap. 13).
- **Estabilidade:** teste de Chow para quebra em 2017, escolhido a partir do gráfico das variáveis médias no tempo, e em 2016 para comparação; teste LM para tendência linear.
- **Autocorrelação:** Durbin-Watson, com dL = 0,243 e dU = 2,822 da tabela D.5A do Gujarati (n = 10, k = 5, 5%), e Breusch-Godfrey de ordem 1, aplicados à série de cada município.

### 4.3 Previsão

A previsão para 2021 é dentro da amostra, com a Selic observada e com a Selic ±1 ponto percentual. Como a previsão é do logaritmo, a média em reais é corrigida pelo fator exp(s²/2), que supõe erros normais; como a normalidade é rejeitada, a correção é aproximada.

## 5 Resultados

### 5.1 Coeficientes

| Variável | Coeficiente | EP (White) | t | p-valor | IC 95% |
|---|---|---|---|---|---|
| X2 escolaridade | 0,0150 | 0,0015 | 10,25 | < 0,0001 | [0,0122; 0,0179] |
| X3 industrialização | 0,0055 | 0,0007 | 8,13 | < 0,0001 | [0,0042; 0,0069] |
| X4 Gini setorial | −0,6548 | 0,1678 | −3,90 | 0,0001 | [−0,9851; −0,3244] |
| X5 Selic real | 0,0065 | 0,0018 | 3,66 | 0,0003 | [0,0030; 0,0101] |
| X6 distância | −0,0016 | 0,0005 | −2,96 | 0,0033 | [−0,0026; −0,0005] |

R² ajustado = 0,6433; F geral = 105,26 (gl 5 e 284), p < 0,0001.

Com erros clássicos, as conclusões são as mesmas: os p-valores são 0,0018 para a Selic e 0,0007 para a distância, e os demais são inferiores a 0,0001.

### 5.2 Hipóteses

- **H1 (escolaridade, positiva):** confirmada. Coeficiente de +0,0150, p < 0,0001.
- **H2 (industrialização, positiva):** confirmada. Coeficiente de +0,0055, p < 0,0001.
- **H3 (diversificação, Gini negativo):** confirmada. Coeficiente de −0,6548, p = 0,0001. Com as divisões com vínculo, −0,638, p = 0,001.
- **H4 (Selic, exploratória):** associação positiva significativa, de +0,0065 (cerca de 0,66% por ponto percentual). Ressalva: a Selic tem 10 valores distintos (um por ano), e o erro-padrão tende a ser subestimado.
- **H5 (distância, negativa):** confirmada. Coeficiente de −0,0016 por km, p = 0,0033.

[revisar: interpretação econômica de cada sinal, inclusive a leitura da H4 e a relação entre H3 e a diversificação.]

### 5.3 Diagnósticos

| Diagnóstico | Resultado | Decisão a 5% |
|---|---|---|
| FIV máximo | 2,33 | sem multicolinearidade |
| Breusch-Pagan-Godfrey | p = 0,0363 | rejeita homocedasticidade |
| Goldfeld-Quandt | p = 0,3885 | não rejeita |
| Shapiro-Wilk (resíduos) | W = 0,8618, p < 0,0001 | rejeita normalidade |
| RESET | F = 14,49 (gl 2 e 282), p < 0,0001 | rejeita forma linear |
| Chow (corte em 2017) | F = 1,60 (gl 6 e 278), p = 0,146 | não rejeita quebra |
| Chow (corte em 2016) | F = 1,79, p = 0,102 | não rejeita quebra |
| Durbin-Watson por município | mediana 0,25 | rejeita ausência de autocorrelação positiva em 14 de 29 municípios; 15 inconclusivos |
| Breusch-Godfrey por município | rejeita em 3 de 29 | — |

A rejeição da normalidade é aproximadamente tolerável com 290 observações, pela teoria de amostras grandes; a rejeição do RESET e a autocorrelação positiva são limitações do modelo. O teste das carreiras não foi usado, por ser não paramétrico e não aplicável a séries de dez anos.

### 5.4 Robustez

O coeficiente do Gini muda pouco quando se usa só as divisões com vínculo (−0,638, p = 0,001). A Selic real e a escolaridade têm sinais e significância estáveis.

### 5.5 Previsão de 2021

| Cenário | Selic (% a.a.) | Média prevista com correção (R$) |
|---|---|---|
| Selic observada | −5,11 | 2.621,97 |
| Selic +1 p.p. | −4,11 | 2.639,18 |
| Selic −1 p.p. | −6,11 | 2.604,87 |

A correção de viés exp(s²/2) = 1,0075 eleva a média em 0,75% em relação à previsão sem correção. A variação de ±1 ponto na Selic altera a previsão média em cerca de 0,66%.

## 6 Discussão

[revisar: discussão do pesquisador, com os resultados ligados às hipóteses e à literatura.]

Três pontos merecem atenção. Primeiro, a associação negativa entre o Gini setorial e o salário é robusta às duas definições da variável, mas depende da forma como ela é construída: o índice cai quando mais divisões têm vínculo, e por isso mede sobretudo a diversificação. Segundo, a escolaridade, a industrialização e a distância têm sinais estáveis, mas o modelo linear é rejeitado pelo RESET, e os coeficientes devem ser lidos como aproximações. Terceiro, o salto industrial de Adrianópolis em 2015 é um dado publicado, mas a causa não está confirmada; a fábrica de cimento inaugurada no município em dezembro de 2015 é uma hipótese plausível, que não é sustentada pelo emprego formal daquele ano.

## 7 Conclusão

Os resultados indicam associações positivas entre salário real e escolaridade e industrialização, associação negativa entre salário e concentração setorial do emprego, e associação negativa entre salário e distância a Curitiba, no período de 2012 a 2021 e nos 29 municípios da RMC. A Selic real tem associação positiva e pequena. Os resultados não são causais, e os diagnósticos apontam limitações de forma funcional, normalidade e autocorrelação que devem ser consideradas na leitura dos coeficientes. [revisar: conclusão e implicações, a cargo do pesquisador.]

## Referências

GUJARATI, D. N.; PORTER, D. C. *Basic econometrics*. 4. ed. Boston: McGraw-Hill, 2004. (PDF consultado; páginas citadas são do PDF.)

HOFFMANN, R. *Estatística para economistas*. 4. ed. rev. e ampl. São Paulo: [editora a conferir], 2006. Cap. 17, Medidas de desigualdade.

HASEGAWA, M. M. *Medidas de desigualdade*. Slides da disciplina Estatística Econômica e Introdução à Econometria. Curso de Ciências Econômicas, UFPR. Usados para a fórmula discreta do Gini (slides 21 e 22, equação 15).

[a inserir: referências de literatura sobre salário, estrutura produtiva e Selic, após conferência.]

BANCO CENTRAL DO BRASIL. Sistema Gerenciador de Séries Temporais (SGS): séries 4390 e 433.

IBGE. Produto Interno Bruto dos Municípios, SIDRA, tabela 5938. Disponível em: https://sidra.ibge.gov.br.

IBGE. Produção Agrícola Municipal, SIDRA, tabela 5457 (usada apenas na comparação da Selic).

MINISTÉRIO DO TRABALHO. Relação Anual de Informações Sociais (RAIS): microdados públicos.

AGÊNCIA ESTADUAL DE NOTÍCIAS DO PARANÁ. Inauguração da fábrica de cimento em Adrianópolis (dezembro de 2015). [a conferir o link exato.]

BRASIL DE FATO. Moradores de Adrianópolis (PR) denunciam Supremo Secil Cimentos por poluição e estragos em casas. 5 out. 2023. Disponível em: https://www.brasildefato.com.br/2023/10/05/moradores-de-adrianopolis-pr-denunciam-supremo-secil-cimentos-por-poluicao-e-estragos-em-casas.
