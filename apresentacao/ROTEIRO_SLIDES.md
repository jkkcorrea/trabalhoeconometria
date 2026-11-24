# Roteiro da apresentação (rascunho v1, 23/11/2026)

Duração estimada: 12 a 15 minutos, 14 slides. Uma mensagem por slide. Números do envio (`envio_professor/`). Figuras em `figuras_graficos/`. A versão em PowerPoint ainda não foi gerada.

## Slide 1: título
Salário médio real formal e estrutura produtiva na RMC, 2012 a 2021. Nome, disciplina (Econometria I, UFPR), data.

## Slide 2: pergunta
A estrutura produtiva de um município (escolaridade, indústria, diversificação, Selic e localização) se associa ao salário médio real dos vínculos formais?

## Slide 3: dados
- 29 municípios da RMC x 10 anos = 290 observações (painel balanceado).
- Fontes: RAIS (salário, escolaridade, CNAE), SIDRA 5938 (VAB), Banco Central (Selic e IPCA), IBGE (distâncias).
- Variável dependente: ln do salário médio real (R$ de 2021).

## Slide 4: hipóteses
- H0 geral: o salário não depende da escolaridade, da estrutura de emprego e da localização.
- H1 escolaridade +; H2 industrialização +; H3 diversificação (Gini −); H4 Selic exploratória; H5 distância −.
- Decisão a 5%, com erros de White.

## Slide 5: variáveis e o Gini
- X4 = Gini da distribuição dos vínculos entre 87 divisões da CNAE, zeros incluídos.
- Fórmula da aula e de Hoffmann (2006, cap. 17): G = (2/n) Σ i·x_i − (n+1)/n.
- Vai de 0,73 a 0,97; quanto mais divisões com emprego, menor o Gini (correlação −0,95).
- Figura: `fig1_matriz_correlacao.png`.

## Slide 6: descrição dos dados
- Salário médio: R$ 2.651 (média). Escolaridade: 15,3%. Industrialização: 25,7%. Selic real: 2,3% a.a. Distância média: 46 km.
- Figura: `fig2_ridgeplot_salario_anos.png` (distribuição do salário por ano).

## Slide 7: o que o gráfico no tempo mostra
- Médias dos 29 municípios: salário pico em 2017; Selic pico em 2016 e 2017, depois queda; escolaridade desacelera após 2017.
- Justifica o corte de Chow em 2017.
- Figura: `diag6_variaveis_no_tempo.png`.

## Slide 8: modelo
- ln(salário real) = β0 + β1 X2 + β2 X3 + β3 X4 + β4 X5 + β5 X6 + u.
- MQO com erros de White (HC1), gl = 284.
- Sem variáveis binárias de município e sem métodos de painel (escopo da disciplina).

## Slide 9: resultados principais
| Variável | Coeficiente | p-valor |
|---|---|---|
| Escolaridade | +0,0150 | < 0,0001 |
| Industrialização | +0,0055 | < 0,0001 |
| Gini | −0,6548 | 0,0001 |
| Selic real | +0,0065 | 0,0003 |
| Distância | −0,0016 | 0,0033 |

R² ajustado = 0,643.

## Slide 10: leitura dos coeficientes
- Escolaridade: +1 p.p. de vínculos com superior está associado a salário 1,5% maior.
- Gini: diversificação maior (Gini menor) está associada a salário maior.
- Selic: +1 p.p. está associado a salário 0,66% maior (IC 95%: 0,30% a 1,01%).
- Distância: +10 km está associado a salário 1,6% menor.
- Associações, não efeitos causais.
- [revisar: leitura econômica com o pesquisador.]

## Slide 11: hipóteses e resultado
| Hipótese | Resultado |
|---|---|
| H1 escolaridade + | confirmada |
| H2 industrialização + | confirmada |
| H3 diversificação (Gini −) | confirmada |
| H4 Selic (exploratória) | associação positiva; ressalva de 10 valores anuais |
| H5 distância − | confirmada |

## Slide 12: diagnósticos
- FIV máximo 2,33: sem multicolinearidade.
- Breusch-Pagan rejeita homocedasticidade (p = 0,036): inferência com erros de White.
- Shapiro-Wilk rejeita normalidade (W = 0,862): figura Q-Q, limitação declarada.
- RESET rejeita forma linear (p < 0,0001): limitação declarada.
- Figura: `diag5_normalidade_qq.png`.

## Slide 13: autocorrelação e quebra estrutural
- Durbin-Watson por município: mediana 0,25; autocorrelação positiva em 14 de 29 municípios. Limitação declarada.
- Chow em 2017: F = 1,60, p = 0,146 (sem quebra). Em 2016: p = 0,102.

## Slide 14: robustez e previsão
- Gini só com divisões com vínculo: −0,638 (p = 0,001), mesmo sinal.
- Previsão de 2021: média de R$ 2.622 com a Selic observada; R$ 2.639 com +1 p.p.; R$ 2.605 com −1 p.p. Correção de viés exp(s²/2) = 1,0075.

## Slide 15: caso de Adrianópolis
- Participação industrial: 7% (2014) para 45% (2015), com dado oficial do IBGE.
- Fábrica de cimento inaugurada no município em dezembro de 2015: hipótese plausível, não confirmada (emprego industrial só cresce em 2017).
- Figura sugerida: `fig3_dispersao_capital_humano_industria.png` (destaque de Adrianópolis, se a figura marcar o município).
- [revisar: decidir se o caso entra na apresentação ou só no texto.]

## Slide 16: limitações
- Associações, não causalidade.
- Forma funcional (RESET) e normalidade rejeitadas.
- Autocorrelação positiva dentro dos municípios.
- Gini depende do número de divisões com vínculo.
- Recorte limitado a 2012 a 2021 pela disponibilidade do VAB setorial.

## Slide 17: conclusão
Escolaridade, industrialização e diversificação setorial associam-se a salários maiores; distância a Curitiba, a salários menores. A Selic real tem associação positiva pequena. [revisar: fechamento a cargo do pesquisador.]

## Slide 18: referências
Gujarati e Porter (2004); Hoffmann (2006, cap. 17); Hasegawa (slides de medidas de desigualdade, UFPR); IBGE/SIDRA; Banco Central (SGS); RAIS/MTE; fontes do caso de Adrianópolis (conferir links).

## Pendências desta apresentação
- Gerar o arquivo PowerPoint a partir deste roteiro, após revisão do texto.
- Escolher a figura do slide 5 e do slide 15.
- Confirmar as referências dos slides 16 e 18.
