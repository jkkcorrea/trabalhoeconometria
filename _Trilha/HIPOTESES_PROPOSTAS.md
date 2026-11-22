# Hipóteses e sinais esperados: proposta para aprovação (22/11/2026)

Status: PROPOSTA. Hipóteses e sinais esperados são decisão do pesquisador (CLAUDE.md, seções 1 e 3). Nada aqui entra no envio até aprovação, registro em `_Trilha/DECISOES.md` e texto literal do pesquisador.

Regra de leitura: cada hipótese é testada pelo coeficiente do modelo indicado, com o teste t de White (H0: coeficiente igual a zero; decisão a 5%), e a interpretação diz se o resultado é entre municípios (Modelo 2) ou dentro deles (Modelo 4).

## Hipótese principal

**H0 geral:** o salário médio real formal de um município não depende da sua estrutura de emprego, da sua escolaridade e da sua localização, controlados os efeitos comuns a todos os municípios.

## Hipóteses por variável

| Hipótese | Sinal esperado (proposta) | Modelo que testa | Resultado observado | Conclusão |
|---|---|---|---|---|
| H1: escolaridade (X2) | positivo | Modelo 4 (dentro) e Modelo 2 (entre) | +0,0150 (Modelo 2) e +0,0084 (Modelo 4), p < 0,0001 nos dois | confirmada nos dois sentidos |
| H2: estrutura industrial (X3) | positivo | Modelo 2 (entre) e Modelo 4 (dentro) | +0,0055 entre (p < 0,0001); -0,0006 dentro (p = 0,41) | confirmada só entre municípios |
| H3: diversificação setorial (X4, Gini invertido) | positivo para a diversificação, ou seja, negativo para o Gini | Modelo 2 (entre) e Modelo 4 (dentro) | Gini -0,6548 entre (p = 0,0001); +0,8653 dentro (p = 0,050) | confirmada entre municípios; dentro, sinal oposto e fronteira de 5% |
| H4: juros reais (X5) | sem sinal teórico único; proposta: exploratória | Modelo 4 | +0,0039 dentro (p < 0,0001 pelo t de 257 gl) | não testável com inferência válida: 10 valores de Selic |
| H5: distância a Curitiba (X6) | negativo (acesso e aglomeração no centro) | Modelo 2 (X6 não identificada no Modelo 4) | -0,0016 por km (p = 0,0033) | confirmada entre municípios, confundida com diferenças não observadas |

## O que precisa ser decidido pelo pesquisador

1. Aprovar ou alterar cada sinal esperado acima, com base na teoria que ele quer usar (Gujarati e as notas de aula dão o método, não a teoria econômica de cada relação).
2. Decidir se H4 entra como hipótese testável. Com 10 anos, não há inferência válida para a Selic; a alternativa é declarar a hipótese como exploratória.
3. Decidir se H5 é testada só no Modelo 2, como acima.
4. Aprovar que o Modelo 4 é o principal e que as hipóteses sobre o que varia dentro do município são testadas nele.

## Registro

Quando aprovadas, as hipóteses e os sinais vão para `_Trilha/DECISOES.md` com o texto literal do pesquisador e o identificador D-AAAA-MM-DD-NN. Sem esse registro, elas não valem.
