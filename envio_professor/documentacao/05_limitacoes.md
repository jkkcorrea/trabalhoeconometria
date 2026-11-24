# Limitações

- Desenho observacional: os coeficientes indicam associações, não efeitos causais.
- A forma funcional linear é rejeitada pelo RESET; os coeficientes devem ser lidos com essa ressalva.
- A normalidade dos resíduos é rejeitada pelo Shapiro-Wilk. A inferência usa a aproximação de amostras grandes.
- O porte do município é uma variável omitida relevante: o Gini setorial tem correlação de -0,88 com o logaritmo dos vínculos ativos e, com esse controle, perde a significância e muda de sinal (robustez_porte_e_negativos.csv). Salário e escolaridade podem se determinar juntos, e o VAB da indústria contém a massa salarial; os resultados são associações.
- O Breusch-Godfrey é aplicado à série de resíduos de cada município (constante e resíduo defasado), versão reduzida, porque a série tem dez anos. Sem preencher com zero o primeiro resíduo defasado, o número de municípios que rejeitam sobe de 3 para 5 (valor em autocorrelacao_heterogeneidade_resumo.csv), o que mostra que o resultado é sensível a esse tratamento com apenas dez observações.
- Autocorrelação dentro dos municípios: o Durbin-Watson e o Breusch-Godfrey indicam autocorrelação em parte dos municípios. Não há correção no modelo principal; a limitação é declarada.
- O Gini (X4) usa as 87 divisões da CNAE como unidades, com zeros incluídos. A aula e Hoffmann aplicam a medida a indivíduos; a adaptação é nossa. O índice depende do número de divisões com vínculo (correlação de −0,95).
- A Selic (X5) tem 10 valores distintos, um por ano. Seu coeficiente trata 290 observações como independentes e tende a superestimar a precisão.
- A distância a Curitiba (X6) é constante no tempo para cada município (29 valores distintos).
- Adrianópolis (2014 e 2015) tem salto da participação industrial confirmado na fonte; a causa não está documentada.
- Araucária tem VAB industrial negativo em 2012 e 2013, como publicado pelo IBGE.
- A quebra estrutural foi testada com um corte escolhido pelo gráfico; outro corte pode dar resultado diferente.
- Recorte temporal de 2012 a 2021, limitado pela disponibilidade do VAB setorial municipal (não publicado para 2022 e 2023).
