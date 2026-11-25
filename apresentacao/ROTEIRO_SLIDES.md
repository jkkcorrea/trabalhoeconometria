# Roteiro da apresentação (rascunho v2, 23/11/2026)

Duração estimada: 12 a 15 minutos, 22 slides (o cabeçalho anterior dizia 14; corrigido em 23/11/2026, [revisar]). Uma mensagem por slide. Números do envio (`envio_professor/`). Figuras em `figuras_graficos/`. A versão em PowerPoint ainda não foi gerada; a versão atual é o artefato de Slides (fundo branco, tons de cinza, Times New Roman), com a fonte em `apresentacao/deck_fonte/project/`.

## Slide 1: título
Salário médio real formal e estrutura produtiva na RMC, 2012 a 2021. Nome, disciplina (Econometria I, UFPR), data.

## Slide 2: pergunta
A estrutura produtiva de um município (escolaridade, indústria, diversificação, Selic e localização) se associa ao salário médio real dos vínculos formais?

## Slide 3: revisão da literatura (em construção)
Tabela com cinco blocos (escolaridade, estrutura industrial, diversificação setorial, juros reais e trabalho, distância ao centro), a hipótese de cada um (H1 a H5) e a pergunta que a literatura precisa responder. Estado de todos: a inserir.
[revisar: o pesquisador escolhe e lê as obras; ver `_Trilha/AVALIACAO_COMENTARIO_PROFESSOR_20261123.md`.]

## Slide 4: dados
- 29 municípios da RMC x 10 anos = 290 observações (painel balanceado).
- Fontes: RAIS (salário, escolaridade, CNAE), SIDRA 5938 (VAB), Banco Central (Selic e IPCA), IBGE (distâncias).
- Variável dependente: ln do salário médio real (R$ de 2021).

## Slide 5: mapa dos 29 municípios (figura em tela cheia)
- Só a figura, com uma frase de legenda. Falar do que a figura mostra, sem repetir o slide anterior.

## Slide 6: hipóteses
- H0 geral: o salário não depende da escolaridade, da industrialização, da diversificação setorial, da Selic nem da distância a Curitiba.
- H1 escolaridade +; H2 industrialização +; H3 diversificação (Gini −); H4 Selic exploratória; H5 distância −.
- Decisão a 5%, com erros de White.

## Slide 7: variáveis e o Gini
- X4 = Gini da distribuição dos vínculos entre 87 divisões da CNAE, zeros incluídos.
- Fórmula da aula e de Hoffmann (2006, cap. 17): G = (2/n) Σ i·x_i − (n+1)/n.
- Vai de 0,73 a 0,97; quanto mais divisões com emprego, menor o Gini (correlação −0,95).
- Figura: `fig1_matriz_correlacao.png`.

## Slide 8: matriz de correlação (figura em tela cheia)
- Só a figura, com uma frase de legenda. Falar do que a figura mostra, sem repetir o slide anterior.

## Slide 9: descrição dos dados
- Salário médio: R$ 2.651 (média). Escolaridade: 15,3%. Industrialização: 25,7%. Selic real: 2,3% a.a. Distância média: 46 km.
- Figura: `fig2_ridgeplot_salario_anos.png` (distribuição do salário por ano).

## Slide 10: distribuição do salário por ano (figura em tela cheia)
- Só a figura, com uma frase de legenda. Falar do que a figura mostra, sem repetir o slide anterior.

## Slide 11: renda no mapa, ano a ano (animação)
Animação de 15 segundos (figura `animacao1_mapa_renda_rmc.gif`): salário médio real por município, 2012 a 2021, com a mesma escala de cor em todos os anos e Curitiba com contorno preto. Em PowerPoint ou PDF o GIF perde o movimento; usar o mapa estático `mapa1_painel_espacial_rmc.png`.

## Slide 12: animação do mapa (figura em tela cheia)
- Só a figura, com uma frase de legenda. Falar do que a figura mostra, sem repetir o slide anterior.

## Slide 13: ranking dos salários por município (animação)
Animação de 15 segundos (figura `animacao2_ranking_salario_municipios.gif`): municípios ordenados do maior ao menor salário em cada ano. Cada ano fica parado cerca de um segundo e a troca de posições dura cerca de meio segundo, sem sobreposição de rótulos; se necessário, congelar um ano em PNG. As barras são cinza, no padrão sem azul dos slides.

## Slide 14: animação do ranking (figura em tela cheia)
- Só a figura, com uma frase de legenda. Falar do que a figura mostra, sem repetir o slide anterior.

## Slide 15: o que o gráfico no tempo mostra
- Médias dos 29 municípios: salário pico em 2017; Selic pico em 2016 e 2017, depois queda; escolaridade desacelera após 2017.
- Justifica o corte de Chow em 2017.
- Figura: `diag6_variaveis_no_tempo.png`.

## Slide 16: gráfico no tempo (figura em tela cheia)
- Só a figura, com uma frase de legenda. Falar do que a figura mostra, sem repetir o slide anterior.

## Slide 17: modelo
- ln(salário real) = β0 + β1 X2 + β2 X3 + β3 X4 + β4 X5 + β5 X6 + u.
- MQO com erros de White (HC1), gl = 284.
- Sem variáveis binárias de município e sem métodos de painel (escopo da disciplina).

## Slide 18: resultados principais
| Variável | Coeficiente | p-valor |
|---|---|---|
| Escolaridade | +0,0150 | < 0,0001 |
| Industrialização | +0,0055 | < 0,0001 |
| Gini | −0,6548 | 0,0001 |
| Selic real | +0,0065 | 0,0003 |
| Distância | −0,0016 | 0,0033 |

R² ajustado = 0,643.

## Slide 19: leitura dos coeficientes
- Escolaridade: +1 p.p. de vínculos com superior está associado a salário 1,5% maior.
- Gini: diversificação maior (Gini menor) está associada a salário maior no modelo principal, mas não com o controle do porte do município.
- Selic: +1 p.p. está associado a salário 0,66% maior (IC 95%: 0,30% a 1,01%).
- Distância: +10 km está associado a salário 1,6% menor.
- Associações, não efeitos causais.
- [revisar: leitura econômica com o pesquisador.]

## Slide 20: hipóteses e resultado
| Hipótese | Resultado |
|---|---|
| H1 escolaridade + | rejeita H0; sinal esperado |
| H2 industrialização + | rejeita H0; sinal esperado |
| H3 diversificação (Gini −) | rejeita H0 no modelo principal; não resiste ao controle de porte |
| H4 Selic (exploratória) | rejeita-se H0 (p = 0,0003), sinal positivo; ressalva de 10 valores anuais |
| H5 distância − | rejeita H0 no modelo principal; perde significância com o controle de porte |

## Slide 21: diagnósticos
- FIV máximo 2,33: sem multicolinearidade.
- Breusch-Pagan (p = 0,036) e White (p < 0,0001) rejeitam a homocedasticidade: inferência com erros de White.
- Shapiro-Wilk rejeita normalidade (W = 0,8618): figura Q-Q, limitação declarada.
- RESET rejeita forma linear (p < 0,0001); com o porte do município o F cai de 14,5 para 4,0, sem eliminar a rejeição.
- Figura: `diag5_normalidade_qq.png`.

## Slide 22: autocorrelação e quebra estrutural
- Breusch-Godfrey (n − p observações): rejeita em 5 de 29 municípios (3 com o primeiro defasado preenchido por zero); no Durbin-Watson, 14 em autocorrelação positiva e 15 inconclusivos, porque dU > 2 e a zona de não rejeição é vazia.
- Durbin-Watson por município: mediana 0,25; autocorrelação positiva em 14 de 29 municípios. Com os resíduos centrados por município, mediana 1,16 e só 1 município abaixo de dL. Limitação declarada.
- Chow em 2017: F = 1,60, p = 0,146 (sem quebra). Em 2016: p = 0,102.

## Slide 23: robustez e previsão
- Com o porte do município (ln dos vínculos) no modelo, o Gini passa a +0,258 (p = 0,13) e a distância perde a significância: H3 não resiste a esse controle.
- Sem Araucária em 2012 e 2013: Gini −0,499 (p = 0,0001). Gini só com divisões com vínculo: −0,638 (p = 0,0011).
- Previsão de 2021: média de R$ 2.622 com a Selic observada; R$ 2.639 com +1 p.p.; R$ 2.605 com −1 p.p. Correção de viés exp(s²/2) = 1,0075.

## Slide 24: caso de Adrianópolis
- Participação industrial: 7,1% (2014) para 45,5% (2015), com dado oficial do IBGE.
- Fábrica de cimento inaugurada no município em dezembro de 2015: hipótese plausível, não confirmada (o emprego formal da indústria extrativa sobe de 66 vínculos (2012) para 260 (2015) e cai para 64 (2017), quando a divisão 23 (minerais não metálicos) salta de 14 para 186: compatível com a hipótese, sem confirmá-la).
- Figura sugerida: `fig3_dispersao_capital_humano_industria.png` (destaque de Adrianópolis, se a figura marcar o município).
- [revisar: decidir se o caso entra na apresentação ou só no texto.]

## Slide 25: dispersão capital humano e indústria (figura em tela cheia)
- Só a figura, com uma frase de legenda. Falar do que a figura mostra, sem repetir o slide anterior.

## Slide 26: contribuição do trabalho (candidatas)
- Gini discreto da aula sobre as 87 divisões da CNAE como medida de diversificação setorial do emprego municipal.
- Painel balanceado dos 29 municípios da RMC, 2012 a 2021, que combina RAIS, SIDRA, Banco Central e IBGE.
- Evidência descritiva: escolaridade, industrialização e proximidade de Curitiba se associam a salário maior; a diversificação, só sem o controle de porte.
- Registro dos limites do modelo e do caso de Adrianópolis.
- [revisar: contribuição a confirmar pelo pesquisador, depois da revisão da literatura.]

## Slide 27: limitações
- Associações, não causalidade.
- O Gini acompanha o porte do município; com esse controle, H3 não se mantém.
- Forma funcional (RESET) e normalidade rejeitadas.
- Autocorrelação positiva dentro dos municípios.
- Gini depende do número de divisões com vínculo.
- Recorte limitado a 2012 a 2021 pela disponibilidade do VAB setorial.

## Slide 28: conclusão
Escolaridade e industrialização associam-se a salários maiores, e a distância a Curitiba, a salários menores. A diversificação setorial (Gini) se associa a salários maiores no modelo principal, mas não quando se controla o porte do município; a distância também perde significância com esse controle. A Selic real tem associação positiva pequena. [revisar: fechamento a cargo do pesquisador.]

## Slide 29: referências
Gujarati (2003); Gujarati e Porter (2011, citado nas aulas; não consultado); Hoffmann (2006, cap. 17); Hasegawa (slides de aula, 2016a, 2016b, 2017, 2020, 2022 e 2024, UFPR); IBGE/SIDRA; Banco Central (SGS); RAIS/MTE; fontes do caso de Adrianópolis (conferir links).

## Pendências desta apresentação
- Gerar o arquivo PowerPoint a partir deste roteiro, após revisão do texto.
- Conferir se a figura do slide 25 marca Adrianópolis (hoje só o rótulo de 2021).
- Confirmar as referências do slide 22.
