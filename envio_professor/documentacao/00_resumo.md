# Resumo

Modelo principal: MQO com as observações empilhadas (29 municípios da RMC x 10 anos = 290), sem controles fixos por município e sem métodos de dados em painel. Erros-padrão de White (HC1).

Variável dependente: logaritmo natural do salário médio formal real (reais de 2021).

## Coeficientes (erro de White)

| Variável | Coeficiente | EP (White) | t | p-valor | IC 95% inferior | IC 95% superior |
|---|---|---|---|---|---|---|
| X2 escolaridade (proporção com superior completo, %) | 0,0150 | 0,0015 | 10,25 | < 0,0001 | 0,0122 | 0,0179 |
| X3 industrialização (VAB da indústria / VAB total, %) | 0,0055 | 0,0007 | 8,13 | < 0,0001 | 0,0042 | 0,0069 |
| X4 Gini setorial (vínculos entre 87 divisões CNAE) | -0,6548 | 0,1678 | -3,90 | 0,0001 | -0,9851 | -0,3244 |
| X5 Selic real (% a.a.) | 0,0065 | 0,0018 | 3,66 | 0,0003 | 0,0030 | 0,0101 |
| X6 distância a Curitiba (km) | -0,0016 | 0,0005 | -2,96 | 0,0033 | -0,0026 | -0,0005 |
| Intercepto | 8,1064 | 0,1533 | 52,87 | < 0,0001 | 7,8046 | 8,4082 |

R² ajustado = 0,6433; F geral = 105,26 (gl 5 e 284), p-valor < 0,0001.

## Diagnósticos

- Multicolinearidade: FIV máximo = 2,33 (limite 10).
- Heterocedasticidade: Breusch-Pagan-Godfrey p = 0,0363 (rejeita); Goldfeld-Quandt ordenado pela distância p = 0,3885 (unilateral, não rejeita; ordenado pela industrialização, rejeita). O teste de White rejeita (ver 04_diagnosticos). Inferência com erros de White.
- Normalidade dos resíduos: Shapiro-Wilk W = 0,8618, p-valor < 0,0001 (rejeita).
- Forma funcional: RESET F = 14,49 (gl 2; 282), p-valor < 0,0001 (rejeita).
- Autocorrelação por município: mediana do Durbin-Watson = 0,2504; o teste rejeita a ausência de autocorrelação positiva em 14 de 29 municípios.
- Quebra estrutural (Chow, corte em 2017, indicado pelo gráfico): F = 1,60, p-valor 0,1463 (não rejeita).

## Projeção de 2021 (previsão dentro da amostra)

| Cenário | Selic (% a.a.) | Média prevista sem correção (R$) | Média prevista com correção (R$) |
|---|---|---|---|
| Selic de 2021 | -5,11 | 2602,47 | 2621,97 |
| Selic de 2021 + 1 p.p. | -4,11 | 2619,55 | 2639,18 |
| Selic de 2021 - 1 p.p. | -6,11 | 2585,50 | 2604,87 |

## Escolhas de construção

- Gini (X4): fórmula da aula sobre medidas de desigualdade (Hasegawa, 2020) e de Hoffmann (2006, cap. 17), com as 87 divisões da CNAE e zeros incluídos. Verificação complementar só com as divisões que têm vínculo.
- Recorte temporal: 2012 a 2021. O VAB setorial municipal está publicado até 2021 e aparece como não disponível para 2022 e 2023; mudar o recorte exige reexecutar o pipeline e atualizar a documentação.

