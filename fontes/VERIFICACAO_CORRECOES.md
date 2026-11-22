# Verificação dos testes e das correções: existem na aula e no Gujarati?

Conferência feita em 22/11/2026 contra três fontes:

- **Slides da aula** (pasta `aulas` do Drive): `autocorrel.pdf` (lido por inteiro), `autocorrel2.pdf`, `autocorrel3.pdf`, `heterocedast.pdf`, `heterocedast2.pdf`, `especificao_diagnostico.pdf`, `multicolinear.pdf`. Os textos completos dos slides de `autocorrel2` e `autocorrel3` foram pesquisados por palavra-chave; não foram lidos página a página.
- **Gujarati**: PDF `Gujarati_Basic_Econometrics.pdf` na pasta do projeto. É a **4ª edição** (McGraw-Hill, 2004). A disciplina cita a 5ª edição (AMGH, 2011); a numeração de páginas pode diferir. As páginas abaixo são **as do PDF**.
- **Guia P2** (Google Doc do professor, `1Z8WubHPgJ3z9LmJC9CMbjqodpvmdRCEBnc1iVWEsdGs`).

## 1. Testes de autocorrelação

| Teste | Slides da aula | Gujarati (PDF) | Guia P2 | Situação no trabalho |
|---|---|---|---|---|
| Durbin-Watson | `autocorrel`, p. 94 a 95 | pp. 495 a 499; Tabela D.5A p. 995 | zonas de decisão (cinco zonas) | aplicado por município; dL = 0,243 e dU = 2,822 **conferidos** na Tabela D.5A |
| ρ por regressão auxiliar | não (método gráfico e DW) | cap. 12 (ρ ≈ 1 − d/2) | formato A (regressão de ρ) | aplicado por município |
| Breusch-Godfrey | `autocorrel`, p. 72 (lista de detecção) | pp. 499 e 500 | não | aplicado por município (ordem 1) |
| Teste das carreiras | `autocorrel`, pp. 79 a 93 | p. 493 | não | **não aplicável**: a aproximação normal exige N1 > 10 e N2 > 10; cada série tem dez anos |
| Gráfico de resíduo contra resíduo defasado | `autocorrel`, pp. 76 a 78 | cap. 12 | não | aplicado (diag3) |

## 2. Medidas corretivas da autocorrelação

| Correção | Slides da aula | Gujarati (PDF) | Guia P2 | Situação no trabalho |
|---|---|---|---|---|
| Cochrane-Orcutt | **não aparece** nos slides lidos | pp. 510 a 528 | sim (item 4.4, medida 2) | **aplicado**, ρ comum, dentro de cada município [presunção da modelagem] |
| Prais-Winsten | **não aparece** nos slides lidos | pp. 510 a 515 | sim (item 4.4, medida 2) | **aplicado**, ρ comum, dentro de cada município [presunção da modelagem] |
| Newey-West (HAC) | `autocorrel`, p. 97 (erros-padrão corrigidos, MQO) | pp. 503, 512, 518 | sim (item 4.4, medida 3) | **não aplicado**: corrige erros-padrão de uma série temporal única; o painel empilhado não atende a essa condição, e cada município tem só dez anos |
| MQG (mínimos quadrados generalizados) | `autocorrel`, p. 97 | cap. 12 | não | equivalente às transformações de Prais-Winsten e Cochrane-Orcutt |
| Reespecificação do modelo | `autocorrel`, p. 97 | cap. 12 | item 4.4, medida 1 | feita em parte: dummies de município, teste de forma funcional |

## 3. Testes de normalidade e de influência

| Teste | Slides da aula | Gujarati (PDF) | Guia P2 | Situação no trabalho |
|---|---|---|---|---|
| Jarque-Bera | **não aparece** nos slides lidos | cap. 5, seção 5.12, pp. 176 e 177 (com histograma e gráfico de probabilidade normal, p. 176) | não | **aplicado** (resíduos rejeitam a normalidade nos dois modelos) |
| Gráfico de probabilidade normal | não | cap. 5, p. 176 | não | aplicado (diag5) |
| Alavancagem, resíduo padronizado, influência | não | cap. 13, "Outliers, Leverage, and Influence", pp. 568 e 569 (conceitos; **o livro diz que não discute os testes**) | não | aplicado como **diagnóstico descritivo**, com limiares [presunção da modelagem] |
| Distância de Cook e DFBETAS | não | **não aparecem** | não | **não aplicados**: não constam do material da disciplina |

## 4. Heterocedasticidade (já usados)

| Teste ou correção | Slides da aula | Gujarati (PDF) | Guia P2 | Situação |
|---|---|---|---|---|
| Breusch-Pagan-Godfrey | `heterocedast`, `heterocedast2` | cap. 11 | sim | aplicado |
| Goldfeld-Quandt | `heterocedast` (52 menções) | pp. 432 a 441 | não | aplicado |
| White (HC1) | `heterocedast` (20 menções) | cap. 11 | sim | aplicado: erros-padrão em todas as inferências |
| MQP (ponderados) | `heterocedast` (2 menções) | cap. 11 | sim | **não aplicado**: a forma da variância não é conhecida |
| Glejser e Park | `heterocedast` | pp. 433 a 462 | não | **não aplicados**: BP e GQ bastam para o diagnóstico |

## 5. Especificação (já usados)

| Teste | Slides da aula | Gujarati (PDF) | Guia P2 | Situação |
|---|---|---|---|---|
| RESET de Ramsey | `especificao_diagnostico` | pp. 549 a 552 | não | aplicado (Modelos 2 e 4) |
| LM para acréscimo de variável | `especificao_diagnostico` | cap. 13 | não | aplicado (tendência do ano) |
| Teste F de acréscimo | `especificao_diagnostico`, `reglinmult` | cap. 8 | não | aplicado (dummies de município) |
| Chow | `teste_Chow`, `reglinmult4` | pp. 303 a 309 | não | aplicado (quebra em 2016) |
| Multicolinearidade (FIV) | `multicolinear` | cap. 10 | sim | aplicado |

## 6. Dummies de município (Modelo 4)

| Assunto | Slides da aula | Gujarati (PDF) | Trabalho de exemplo | Situação |
|---|---|---|---|---|
| Variáveis dummy | **não aparecem** | cap. 9, pp. 332 a 352 | seção 2.3 | **mantidas** (decisão registrada); confirmação pelo professor pendente |

## 7. O que mudou em relação à lista oficial anterior

- **Jarque-Bera**: a lista dizia "não encontrado nas fontes lidas". Está no Gujarati, cap. 5 (seção 5.12). Volta ao escopo.
- **Cochrane-Orcutt e Prais-Winsten**: a lista atribuía aos slides `autocorrel`. Não estão nos slides lidos. Estão no Gujarati (cap. 12) e no Guia P2.
- **Newey-West**: continua fora do painel, mas com a justificativa de série temporal única. É citado nos slides (p. 97) e no Guia P2.
- **Durbin-Watson**: os valores da Tabela D.5A (dL = 0,243; dU = 2,822) estavam corretos. A leitura por OCR coincidiu com o livro.
- **Cook e DFBETAS**: não estão no material. A análise de influência fica como diagnóstico descritivo, sem teste formal.
