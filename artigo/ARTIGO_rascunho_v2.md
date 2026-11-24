# Salário médio real formal e estrutura produtiva nos municípios da Região Metropolitana de Curitiba, 2012 a 2021

**Rascunho v2 (23/11/2026, ajustado ao comentário do professor).** Marcações: [revisar] = interpretação ou texto para o pesquisador confirmar; [a inserir] = referência ou seção ainda não produzida; [aguardando orientação do professor: …] = trecho que depende da resposta do professor (lista e instruções de alteração em `_Trilha/REGISTRO_PENDENCIAS_PROFESSOR.md`). Números vêm de `envio_professor/documentacao/` e `resultados_econometricos/`.

**Versão para apreciação dos colegas.** Orientações de leitura e de retorno em `REVISAO_PELOS_COLEGAS.md`. Os números vêm do código e não devem ser alterados sem conferência; as marcações indicam o que falta e quem decide. Esta nota e as marcações saem da versão final.

## Resumo

Este trabalho estima a associação entre o salário médio real formal e a estrutura produtiva dos 29 municípios da Região Metropolitana de Curitiba entre 2012 e 2021, com 290 observações em painel empilhado. Usa-se mínimos quadrados ordinários com erros-padrão de White (HC1). A escolaridade (proporção de vínculos com ensino superior completo) e a participação industrial no valor adicionado associam-se positivamente ao salário, e a distância a Curitiba, negativamente, todas significativas a 5% no modelo principal (a distância deixa de ser significativa quando se controla o porte do município). A diversificação setorial do emprego, medida pelo Gini da distribuição dos vínculos entre as divisões da CNAE, associa-se a salários maiores (coeficiente de −0,655, p < 0,001), mas esse resultado deixa de valer quando se controla o porte do município. A Selic real tem associação positiva pequena, de cerca de 0,66% por ponto percentual. Os diagnósticos rejeitam a forma funcional linear, a normalidade dos resíduos e a homocedasticidade; incluir o porte do município reduz a rejeição da forma funcional, mas não a elimina, e a autocorrelação positiva dentro dos municípios é em grande parte diferença persistente entre eles. Os resultados são associações, não efeitos causais.

**Palavras-chave:** Salário real. Região Metropolitana de Curitiba. Estrutura produtiva. Gini setorial. Mínimos quadrados ordinários.

## Abstract

This paper estimates the association between the average formal real wage and the productive structure of the 29 municipalities of the Metropolitan Region of Curitiba (Brazil) from 2012 to 2021, using 290 observations in a stacked panel. Ordinary least squares with White (HC1) standard errors is used. Educational attainment (share of formal jobs with complete higher education) and the industrial share of value added are positively associated with wages, and distance to Curitiba is negatively associated, all significant at 5% in the main model (distance is no longer significant when municipality size is controlled for). Sectoral diversification of employment, measured by the Gini coefficient of jobs across the 87 CNAE divisions, is associated with higher wages (coefficient of -0.655, p < 0.001), but this result does not hold when municipality size is controlled for. The real Selic rate has a small positive association, of about 0.66% per percentage point. The diagnostics reject linear functional form, normality of residuals and homoskedasticity; controlling for municipality size reduces the rejection of functional form without eliminating it, and the positive autocorrelation within municipalities largely reflects persistent differences between them. The results are associations, not causal effects. [revisar: tradução a conferir pelo pesquisador.]

**Keywords:** Real wage. Metropolitan Region of Curitiba. Productive structure. Sectoral Gini. Ordinary least squares.

## 1 INTRODUÇÃO

Os salários formais variam de forma acentuada entre municípios de uma mesma região metropolitana. Na Região Metropolitana de Curitiba (RMC), essa diferença coexiste com um processo de expansão de atividades industriais e de serviços ao longo da última década. A pergunta deste trabalho é se a estrutura produtiva de cada município, descrita por sua escolaridade, sua participação industrial, sua diversificação setorial e sua localização, está associada ao salário médio real dos vínculos formais.

[revisar: motivação da pergunta e relevância para a RMC, com referências a serem inseridas.]

O objetivo é estimar a associação entre o salário médio real formal dos municípios da RMC e cinco características do município: escolaridade, estrutura industrial, diversificação setorial do emprego, Selic real e distância a Curitiba, no período de 2012 a 2021. O trabalho testa a hipótese nula de que o salário não depende dessas características, contra a hipótese de que ao menos uma delas afeta o salário. Para cada variável, os sinais esperados são: positivo para escolaridade e industrialização; negativo para o Gini setorial, isto é, positivo para a diversificação; exploratório para a Selic; e negativo para a distância a Curitiba.

O trabalho usa dados oficiais de quatro fontes e um modelo de mínimos quadrados ordinários, com inferência robusta à heterocedasticidade. Os resultados são descritivos e associativos. A seção 3 descreve os dados e as variáveis, a seção 4 apresenta o modelo e os métodos, a seção 5 traz os resultados, a seção 6 os discute e a seção 7 conclui.

[revisar: contribuição do trabalho em relação à literatura, a ser inserida.]

## 2 REFERENCIAL TEÓRICO

[a inserir pelo pesquisador: o professor pediu contextualização do problema por revisão da literatura (comentário de 23/11/2026). Cada subseção abaixo precisa de obras lidas e conferidas, registradas em `fontes/REFERENCIAS.md`; nenhuma referência de periódico foi inserida ainda. A pergunta de cada subseção orienta o conteúdo.]

### 2.1 Escolaridade e salário (H1)

[a inserir: o que a teoria do capital humano prevê para a relação entre escolaridade e salário e o que os estudos para o Brasil e para regiões metropolitanas encontram. Atenção: neste trabalho a variável é a proporção de vínculos com superior no município, não a escolaridade individual.]

### 2.2 Estrutura industrial e salário (H2)

[a inserir: o que a literatura diz sobre o peso da indústria no valor adicionado e o salário médio formal local.]

### 2.3 Diversificação e especialização setorial (H3)

[a inserir: o debate sobre especialização e diversificação das atividades e o desempenho local, e o uso de medidas de concentração, como o Gini, para descrever a estrutura setorial do emprego.]

### 2.4 Juros reais e mercado de trabalho (H4)

[a inserir: o que se espera da taxa de juros real sobre salários e emprego e por que o trabalho trata a Selic como hipótese exploratória.]

### 2.5 Localização e distância ao centro (H5)

[a inserir: o que a economia regional prevê para a distância ao centro metropolitano e o salário.]

### 2.6 Materiais-base do método

Os materiais-base do método são as aulas da disciplina (HASEGAWA, 2016a; 2016b; 2017; 2020; 2022; 2024), que seguem Gujarati e Porter (2011), para regressão linear, testes e diagnósticos, e Hoffmann (2006), para a medida de desigualdade de Gini. As páginas e a tabela de Durbin-Watson usadas neste trabalho vêm da 4ª edição de Gujarati (2003), disponível localmente; a diferença de edição em relação às aulas (5ª edição, 2011) deve ser revisada [revisar].

## 3 METODOLOGIA

### 3.1 Unidades e período

A unidade de observação são os 29 municípios da RMC (código IBGE 05501), de 2012 a 2021. O painel é balanceado, com 290 observações. O recorte é limitado pela disponibilidade do valor adicionado setorial municipal, que não é publicado para 2022 e 2023 (SIDRA, tabela 5938). Os 29 municípios são listados no Apêndice B.

### 3.2 Fontes e construção das variáveis

A TABELA 1 resume as variáveis, suas fontes e sua construção.

**TABELA 1 - Variáveis do modelo, descrição e fontes**

| Variável | Descrição | Fonte |
|---|---|---|
| Y: salário médio real | remuneração média dos vínculos formais, em reais de 2021 (logaritmo natural) | RAIS (Ministério do Trabalho), deflacionada pelo IPCA (série 433, Banco Central) |
| X2: escolaridade | % dos vínculos ativos com ensino superior completo | RAIS |
| X3: industrialização | VAB da indústria / VAB total, em % | IBGE, SIDRA, tabela 5938 |
| X4: diversificação (Gini) | Gini da distribuição dos vínculos entre as 87 divisões da CNAE, com zeros | RAIS |
| X5: Selic real | Selic acumulada no ano, deflacionada pelo IPCA anual, em % a.a. | Banco Central (séries 4390 e 433) |
| X6: distância | distância entre os centroides do município e de Curitiba, em km | IBGE (malha municipal) |

FONTE: O autor (2026), a partir das fontes indicadas.

A variável dependente é o logaritmo natural do salário. A escolha tem duas justificativas: o salário é sempre positivo e tem distribuição assimétrica à direita (FIGURA 2), e, com o logaritmo, o coeficiente de cada regressora indica variação relativa do salário [revisar: justificativa completa, com referência a GUJARATI, 2003, p. 207-208 e 449].

### 3.3 Estatísticas descritivas

A TABELA 2 apresenta as estatísticas descritivas das variáveis.

**TABELA 2 - Estatísticas descritivas (290 observações)**

| Variável | Média | Mínimo | Máximo |
|---|---|---|---|
| Salário médio real (R$ de 2021) | 2.651,25 | 1.792,70 | 4.501,12 |
| ln do salário real | 7,8609 | 7,4915 | 8,4121 |
| X2 escolaridade (%) | 15,25 | 2,78 | 35,92 |
| X3 industrialização (%) | 25,67 | −14,07 | 67,59 |
| X4 Gini setorial | 0,8537 | 0,7328 | 0,9740 |
| X5 Selic real (% a.a.) | 2,27 | −5,11 | 7,28 |
| X6 distância (km) | 45,92 | 0,00 | 94,89 |

FONTE: O autor (2026), a partir dos dados do painel.

A FIGURA 1 mostra a evolução das médias anuais das variáveis, a FIGURA 2 a distribuição do salário entre os municípios em cada ano e a FIGURA 3 a correlação entre as variáveis.

**FIGURA 1 - Médias anuais das variáveis do modelo, RMC, 2012 a 2021**

[imagem: figuras_graficos/diag6_variaveis_no_tempo.png, proporção 1,14; largura 16 cm (largura da mancha de texto), altura 14 cm; centralizada; a inserir na versão final]

FONTE: O autor (2026). A linha tracejada marca a divisão do período usada no teste de Chow.

**FIGURA 2 - Distribuição do salário médio real formal entre os municípios da RMC, por ano, 2012 a 2021**

[imagem: figuras_graficos/fig2_ridgeplot_salario_anos.png, proporção 1,25; largura 16 cm, altura 12,8 cm; centralizada; a inserir na versão final]

FONTE: O autor (2026), a partir da RAIS (Ministério do Trabalho), deflacionada pelo IPCA (série 433, Banco Central), em R$ de 2021. A cor acompanha o valor do salário no eixo horizontal.

Em todos os anos, a maior parte dos municípios fica entre cerca de R$ 2.000 e R$ 3.000, com uma cauda à direita que chega perto de R$ 4.500 (FIGURA 2), o que mostra a assimetria à direita do salário.

**FIGURA 3 - Correlação de Pearson entre as variáveis do modelo, RMC, 2012 a 2021**

[imagem: figuras_graficos/fig1_matriz_correlacao.png, proporção 1,20; largura 16 cm, altura 13,3 cm; centralizada; a inserir na versão final]

FONTE: O autor (2026). Como cada município aparece dez vezes, as 290 observações não são independentes.

Dois valores merecem nota. Em Araucária, o VAB da indústria é negativo em 2012 (−R$ 560,8 milhões) e 2013 (−R$ 246,4 milhões), como publicado pelo IBGE; o valor é mantido e marcado. Em Adrianópolis, a participação industrial passa de 7,1% (2014) para 45,5% (2015). O salto foi confirmado na fonte e, segundo a pesquisa feita para o trabalho, pode estar relacionado à fábrica de cimento inaugurada no município em dezembro de 2015. Essa relação não está confirmada: o emprego formal industrial só cresce em 2017 (ver `fontes/ADRIANOPOLIS_PESQUISA.md`). A FIGURA 4 mostra Adrianópolis entre os municípios da RMC.

**FIGURA 4 - Capital humano e dominância industrial, RMC, 2012 a 2021 (painel A: escolaridade; painel B: VAB da indústria)**

[imagem: figuras_graficos/fig3_dispersao_capital_humano_industria.png, proporção 1,87; largura 16 cm, altura 8,6 cm; centralizada; a inserir na versão final]

FONTE: O autor (2026), a partir de RAIS, IBGE (SIDRA) e Banco Central. Os triângulos vermelhos são os dois valores negativos de Araucária.

### 3.4 Construção do Gini setorial

Para cada município e ano, cada divisão da CNAE recebe a participação x_i de seus vínculos ativos no total do município; divisões sem vínculo recebem zero. As 87 participações são ordenadas em ordem crescente, e o índice é calculado pela fórmula G = (2/n) Σ i·x_i − (n+1)/n, com n = 87 (HOFFMANN, 2006, p. 340-341; HASEGAWA, 2020, slides 21 e 22). O índice vai de 0 (vínculos igualmente distribuídos entre as divisões) a valores próximos de 1 (máximo de 86/87 = 0,989). A medida é uma adaptação: Hoffmann a aplica a pessoas ou empresas, e aqui as unidades são divisões setoriais. Ela depende fortemente do número de divisões com vínculo (correlação de −0,95). Como verificação, o Gini foi calculado só com as divisões que têm vínculo; o coeficiente é −0,638 (p = 0,0011), com o mesmo sinal e significância.

[aguardando orientação do professor: confirmação do n = 87 e do tratamento das divisões como indivíduos. Se o professor orientar outra definição, alterar esta subseção, a TABELA 1 e os resultados da seção 5.]

### 3.5 Procedimento de tratamento dos dados

O procedimento é executado por scripts em R, em ordem, com cache dos dados baixados. Os passos são os seguintes.

1. **Coleta.** RAIS: microdados públicos do Ministério do Trabalho, baixados e processados localmente, de 2012 a 2021. VAB e PIB: SIDRA, tabela 5938. Selic e IPCA: séries 4390 e 433 do Banco Central. Malha municipal e composição da RMC: IBGE. Cada fonte é gravada uma vez e reutilizada nas execuções seguintes.
2. **Unidades.** A RMC é a composição oficial do IBGE (código 05501), com 29 municípios. O script compara o código e o nome de cada município com a lista canônica da RMC e interrompe a execução se houver divergência.
3. **Universo da RAIS.** Vínculos ativos em 31 de dezembro de cada ano, no município do estabelecimento [presunção da modelagem]. A divisão da CNAE 2.0 é formada pelos dois primeiros dígitos da classe.
4. **Salário nominal.** Média, entre os vínculos ativos com remuneração positiva, da remuneração média nominal do vínculo [presunção da modelagem].
5. **Salário real (Y).** Salário nominal multiplicado pelo fator de deflação, igual ao índice médio do IPCA de 2021 dividido pelo índice médio do ano. O índice é a série 433 acumulada, e o valor anual é a média dos 12 índices mensais [presunção da modelagem]. O resultado, em reais de 2021, entra em logaritmo natural.
6. **Escolaridade (X2).** X2 = 100 × (vínculos com superior completo, mestrado ou doutorado) / (vínculos ativos − vínculos com escolaridade ignorada) [presunção da modelagem].
7. **Industrialização (X3).** X3 = 100 × VAB da indústria / VAB total, com o VAB total igual à soma dos quatro setores publicados (agropecuária, indústria, serviços e administração pública). O script confere que essa soma coincide com o VAB total divulgado.
8. **Gini setorial (X4).** Cálculo descrito na seção 3.4. Vínculos sem divisão da CNAE válida ("ignorada") ficam fora do cálculo, e o número de divisões é fixo em 87.
9. **Selic real (X5).** A Selic do ano é a composição dos 12 valores mensais da série 4390, e o IPCA do ano, a composição dos 12 valores da série 433. A Selic real, em % ao ano, é X5 = [(1 + Selic/100) / (1 + IPCA/100) − 1] × 100 (equação de Fisher).
10. **Distância (X6).** Distância, em quilômetros, entre os centroides do município e de Curitiba, calculada após projetar a malha em SIRGAS 2000 / UTM zona 22S (EPSG 31982). Curitiba recebe o valor zero [presunção da modelagem: a coordenada do marco zero não foi localizada].
11. **Painel e validações.** O painel tem 29 municípios × 10 anos = 290 linhas. O script confere o número de linhas, relata valores ausentes, NaN e infinitos, converte as variáveis econômicas em numéricas e confere que o Gini está entre 0 e 1. Os valores negativos do VAB da indústria de Araucária são mantidos e marcados.

## 4 MODELO E MÉTODOS

### 4.1 Modelo

ln(salário real)_it = β0 + β1 X2_it + β2 X3_it + β3 X4_it + β4 X5_t + β5 X6_i + u_it    (1)

Em que ln(salário real)_it é o logaritmo natural do salário médio real do município i no ano t; X2 é a escolaridade; X3, a industrialização; X4, o Gini setorial; X5, a Selic real anual; X6, a distância a Curitiba; e u_it, o erro. A estimação é feita por mínimos quadrados ordinários com as 290 observações empilhadas, isto é, sem distinguir os municípios: o estimador é β̂ = (X'X)⁻¹ X'y, com k = 6 parâmetros (o intercepto e cinco coeficientes). A variância de β̂ usa a correção de White (HC1), V̂ = [n/(n − k)] (X'X)⁻¹ (Σ û_i² x_i x_i') (X'X)⁻¹, em que x_i é o vetor das variáveis do município e ano i e û_i, o resíduo. A estatística t de cada coeficiente é β̂_j dividido pelo seu erro-padrão de White, comparada à distribuição t com n − k = 284 graus de liberdade; o intervalo de confiança de 95% é β̂_j ± t(0,975; 284) × EP.

O modelo não inclui variáveis binárias de município nem métodos de dados em painel, por estarem fora do escopo da disciplina. [aguardando orientação do professor: confirmação de que o modelo principal não usa binárias de município.]

### 4.2 Testes e diagnósticos

Em cada teste, H0 e Ha são explicitadas e a decisão é tomada a 5%:

- **Multicolinearidade:** fator de inflação da variância (FIV), com limite de 10 (GUJARATI, 2003, cap. 10, p. 390 do PDF; HASEGAWA, 2016a). Objetivo: verificar se as regressoras são tão correlacionadas que inflacionam os erros-padrão.
- **Heterocedasticidade:** Breusch-Pagan-Godfrey (HASEGAWA, 2016b; GUJARATI, 2003, cap. 11), com H0 de variância constante e Ha de variância que depende das regressoras, o teste geral de White (regressão auxiliar com os regressores, seus quadrados e produtos cruzados) e Goldfeld-Quandt, com a amostra ordenada pela distância e, como verificação, por cada regressor, e fração central de 0,2 omitida [presunção da modelagem] (HASEGAWA, 2016b).
- **Normalidade dos resíduos:** Shapiro-Wilk, com H0 de normalidade e Ha de não normalidade, complementado pelo gráfico quantil-quantil (Q-Q). [aguardando orientação do professor: procedimento a adotar quando a normalidade é rejeitada.]
- **Forma funcional:** RESET de Ramsey (HASEGAWA, 2022; GUJARATI, 2003, cap. 13), com potências 2 e 3 dos valores ajustados, com H0 de forma linear correta. Como o RESET rejeita, o modelo é reestimado com os quadrados de X2 e X3 (centrados na média) e com o logaritmo dos vínculos ativos como controle de porte, e o RESET é repetido (TABELA 7); os resíduos são examinados contra cada regressor (FIGURA 6). [aguardando orientação do professor: tratamento da forma funcional rejeitada.]
- **Estabilidade:** teste de Chow para quebra estrutural (HASEGAWA, 2024), com o corte em 2017 escolhido a partir do gráfico das médias anuais (FIGURA 1), e em 2016 para comparação; teste LM para tendência linear. [aguardando orientação do professor: escolha do corte e comparação em 2016.]
- **Autocorrelação:** Durbin-Watson (HASEGAWA, 2017), com dL = 0,243 e dU = 2,822 da tabela D.5A de Gujarati (2003) (n = 10, k = 5, 5%), e Breusch-Godfrey de ordem 1 (HASEGAWA, 2017), aplicados à série de cada município (APÊNDICE A). Como verificação, o Durbin-Watson também é calculado com os resíduos centrados na média de cada município, para separar a dependência de um ano para o seguinte da diferença persistente entre municípios.

As estatísticas e as regras de decisão de cada teste são as seguintes (n = 290, k = 6, salvo indicação):

- **FIV:** FIV_j = 1 / (1 − R²_j), em que R²_j vem da regressão da variável j sobre as demais. Decisão: FIV acima de 10 indica multicolinearidade.
- **Breusch-Pagan-Godfrey:** LM = n·R² da regressão auxiliar do quadrado dos resíduos sobre as regressoras (versão estudentizada), com distribuição qui-quadrado de 5 graus de liberdade. Rejeita H0 se o p-valor for menor que 5%.
- **Goldfeld-Quandt:** F = SQR₂ / SQR₁ entre as duas pontas da amostra ordenada por uma variável, omitida a fração central de 0,2; para a distância, Ha é que a variância cresce com ela; para as demais ordenações, o teste é bilateral.
- **Shapiro-Wilk:** estatística W calculada sobre os resíduos; rejeita a normalidade se o p-valor for menor que 5%. O gráfico Q-Q compara os quantis dos resíduos com os da normal.
- **RESET:** F do acréscimo das potências 2 e 3 dos valores ajustados ao modelo, com 2 e 282 graus de liberdade. Rejeita H0 (forma linear correta) se o p-valor for menor que 5%.
- **Chow:** F = [(SQR_R − SQR₁ − SQR₂) / k] / [(SQR₁ + SQR₂) / (n − 2k)], com SQR_R do modelo para todo o período e SQR₁ e SQR₂ dos modelos de 2012 a 2017 e de 2018 a 2021 (corte em 2017; o corte de 2016 compara 2012 a 2016 com 2017 a 2021); graus de liberdade 6 e 278. H0: os coeficientes são iguais nos dois períodos.
- **Durbin-Watson:** d = Σ_{t=2}^{10} (û_t − û_{t−1})² / Σ_{t=1}^{10} û_t², calculado com os resíduos de cada município. Decisão: d < dL, autocorrelação positiva; dL ≤ d ≤ dU, inconclusivo; d > dU, não se rejeita a ausência de autocorrelação positiva.
- **Breusch-Godfrey de ordem 1:** LM da regressão auxiliar do resíduo de cada município sobre uma constante e o resíduo defasado, com distribuição qui-quadrado de 1 grau de liberdade. É uma versão reduzida do teste, sem os regressores, porque a série de cada município tem dez anos; o primeiro resíduo defasado é preenchido com zero (padrão do `lmtest`), e, se for descartado, rejeitam 5 municípios em vez de 3, o que mostra a sensibilidade do teste com dez observações.
- **White:** LM = n·R² da regressão auxiliar de û² sobre os regressores, seus quadrados e produtos cruzados (20 termos), com distribuição qui-quadrado de 20 graus de liberdade.
- **F geral com erro de White:** F = b'V⁻¹b / q, com b as q = 5 inclinações e V o bloco correspondente da matriz HC1.

### 4.3 Previsão

A previsão para 2021 é dentro da amostra, com a Selic observada e com a Selic ±1 ponto percentual. Como a previsão é do logaritmo, a média em reais é ŷ = exp(ln ŷ + s²/2), com s² a variância residual do modelo (0,0149), de modo que o fator de correção é exp(s²/2) = 1,0075. A correção supõe erros normais; como a normalidade é rejeitada, ela é aproximada. [aguardando orientação do professor: uso da correção aproximada e da previsão dentro da amostra.]

## 5 RESULTADOS

### 5.1 Coeficientes

A TABELA 3 apresenta as estimativas do modelo principal, com erros-padrão de White.

**TABELA 3 - Estimativas do modelo (1), erros-padrão de White (HC1), 290 observações**

| Variável | Coeficiente | EP (White) | t | p-valor | IC 95% |
|---|---|---|---|---|---|
| X2 escolaridade | 0,0150 | 0,0015 | 10,25 | < 0,0001 | [0,0122; 0,0179] |
| X3 industrialização | 0,0055 | 0,0007 | 8,13 | < 0,0001 | [0,0042; 0,0069] |
| X4 Gini setorial | −0,6548 | 0,1678 | −3,90 | 0,0001 | [−0,9851; −0,3244] |
| X5 Selic real | 0,0065 | 0,0018 | 3,66 | 0,0003 | [0,0030; 0,0101] |
| X6 distância | −0,0016 | 0,0005 | −2,96 | 0,0033 | [−0,0026; −0,0005] |

FONTE: O autor (2026). R² ajustado = 0,6433; F geral = 105,26 (gl 5 e 284), p < 0,0001.

O F geral com a matriz de White (HC1) é 92,83 (gl 5 e 284; p < 0,0001), próximo do F clássico (105,26), e a conclusão é a mesma. Com erros clássicos, as conclusões dos coeficientes também são as mesmas: os p-valores são 0,0018 para a Selic e 0,0007 para a distância, e os demais são inferiores a 0,0001.

### 5.2 Hipóteses

- **H1 (escolaridade, positiva):** confirmada. Coeficiente de +0,0150, p < 0,0001.
- **H2 (industrialização, positiva):** confirmada. Coeficiente de +0,0055, p < 0,0001.
- **H3 (diversificação, Gini negativo):** confirmada no modelo principal. Coeficiente de −0,6548, p = 0,0001. Com as divisões com vínculo, −0,638, p = 0,0011. Ressalva: com o logaritmo dos vínculos ativos como controle de porte, o coeficiente deixa de ser significativo e muda de sinal (seção 5.4).
- **H4 (Selic, exploratória):** associação positiva significativa, de +0,0065 (cerca de 0,66% por ponto percentual). Ressalva: a Selic tem 10 valores distintos (um por ano), o que limita a precisão do coeficiente.
- **H5 (distância, negativa):** confirmada no modelo principal. Coeficiente de −0,0016 por km, p = 0,0033. Ressalva: com o controle de porte, o coeficiente cai para −0,0007 (p = 0,1748) e deixa de ser significativo (seção 5.4).

[revisar: interpretação econômica de cada sinal, inclusive a leitura da H4 e a relação entre H3 e a diversificação.]

### 5.3 Diagnósticos

A TABELA 4 resume os diagnósticos do modelo principal.

**TABELA 4 - Diagnósticos do modelo principal, a 5%**

| Diagnóstico | Resultado | Decisão |
|---|---|---|
| FIV máximo | 2,33 | sem multicolinearidade |
| Breusch-Pagan-Godfrey | p = 0,0363 | rejeita homocedasticidade |
| White (20 termos) | 94,15 (gl 20), p < 0,0001 | rejeita homocedasticidade |
| Goldfeld-Quandt (ordenado pela distância, unilateral) | p = 0,3885 | não rejeita |
| Goldfeld-Quandt (ordenado por X3) | F = 1,53 (gl 110 e 110), p = 0,0268 | rejeita |
| Shapiro-Wilk (resíduos) | W = 0,8618, p < 0,0001 | rejeita normalidade |
| RESET | F = 14,49 (gl 2 e 282), p < 0,0001 | rejeita forma linear |
| Chow (corte em 2017) | F = 1,60 (gl 6 e 278), p = 0,146 | não rejeita quebra |
| Chow (corte em 2016) | F = 1,79, p = 0,102 | não rejeita quebra |
| Durbin-Watson por município | mediana 0,25 | positiva em 14 de 29 municípios; 15 inconclusivos |
| Durbin-Watson com resíduos centrados por município | mediana 1,16 | 1 município abaixo de dL |
| Breusch-Godfrey por município | rejeita em 3 de 29 | APÊNDICE A |

FONTE: O autor (2026). Detalhes por município no APÊNDICE A.

A FIGURA 5 mostra o gráfico Q-Q dos resíduos.

**FIGURA 5 - Gráfico quantil-quantil dos resíduos do modelo principal**

[imagem: figuras_graficos/diag5_normalidade_qq.png, proporção 1,40; largura 16 cm, altura 11,4 cm; centralizada; a inserir na versão final]

FONTE: O autor (2026).

**Leitura dos diagnósticos.** Cada resultado muda a leitura dos coeficientes de uma forma específica:

- **Heterocedasticidade (rejeitada):** os estimadores de mínimos quadrados continuam não tendenciosos, mas perdem eficiência e os testes t e F usuais podem deixar de valer (HASEGAWA, 2016b; 2017). Por isso a inferência usa erros-padrão de White. O Breusch-Pagan e o White rejeitam a homocedasticidade; o Goldfeld-Quandt ordenado pela distância não rejeita, mas tem pouco poder quando a variância não cresce com essa variável, e ordenado pela industrialização (X3) ele rejeita (p = 0,0268), o que indica que a variância dos resíduos está ligada à industrialização.
- **Forma funcional (RESET rejeita):** a relação linear em logaritmo pode omitir termos ou variáveis (HASEGAWA, 2022). Os coeficientes são lidos como aproximações lineares. O porte do município explica parte da não linearidade: ao incluir o logaritmo dos vínculos ativos, o F do RESET cai de 14,49 para 3,98 e o R² ajustado sobe de 0,6433 para 0,6744, mas o RESET ainda rejeita (TABELA 7).
- **Autocorrelação positiva (14 de 29 municípios; 15 inconclusivos):** os estimadores seguem não tendenciosos e consistentes, mas deixam de ser eficientes, a variância residual tende a ser subestimada e os testes t e F perdem validade (HASEGAWA, 2017). Com apenas dez anos por município, o teste de Durbin-Watson tem poder limitado, o que explica o grande número de resultados inconclusivos. Parte da autocorrelação aparente vem de o modelo empilhado não captar diferenças persistentes entre municípios: em 16 dos 29 municípios os dez resíduos têm o mesmo sinal, o que ajuda a explicar por que o Durbin-Watson aponta 14 municípios e o Breusch-Godfrey apenas 3. Com os resíduos centrados na média de cada município, o Durbin-Watson mediano passa de 0,25 para 1,16 e só 1 município fica abaixo de dL; 72,9% da soma de quadrados dos resíduos está entre municípios. Os valores dL e dU da tabela D.5A são aproximados neste caso, porque X6 não varia no tempo dentro do município.
- **Estabilidade (Chow não rejeita em 2016 nem em 2017):** não há evidência de que os coeficientes mudem entre os dois subperíodos, o que sustenta o uso de um único modelo para todo o período.

A cauda positiva dos resíduos vem de poucas observações: os cinco maiores resíduos são de Adrianópolis (2013 a 2015) e de Araucária (2012 e 2013), municípios com participação industrial atípica, e o maior em módulo é de 4,79 erros-padrão (Adrianópolis, 2014). A FIGURA 6 mostra os resíduos contra cada regressor.

**FIGURA 6 - Resíduos contra cada regressor, modelo principal**

[imagem: figuras_graficos/diag7_residuos_vs_regressores.png, proporção 1,50; largura 16 cm, altura 10,7 cm; centralizada; a inserir na versão final]

FONTE: O autor (2026). A linha escura é uma suavização.

A rejeição da normalidade, mostrada na FIGURA 5, é tratada como limitação: com 290 observações, a inferência por erros de White não depende da normalidade [revisar: a relação entre o tamanho da amostra e a validade dos testes, com referência]. A rejeição do RESET e a autocorrelação positiva são limitações do modelo. [aguardando orientação do professor: tratamento da normalidade e da forma funcional rejeitadas, que pode alterar esta subseção.]

### 5.4 Robustez

Foram feitas três verificações, resumidas na TABELA 6. Primeira, o Gini calculado só com as divisões que têm vínculo mantém o sinal (−0,638; p = 0,0011). Segunda, sem as duas observações de Araucária com VAB da indústria negativo (N = 288), o coeficiente do Gini passa de −0,6548 para −0,4992 e segue significativo (p = 0,0001), e os demais coeficientes mantêm sinal e significância. Terceira, o Gini setorial tem correlação de −0,88 com o logaritmo dos vínculos ativos do município, isto é, acompanha o porte; ao incluir esse logaritmo como controle, o coeficiente do Gini passa a +0,2579 (p = 0,1293) e o da distância deixa de ser significativo (p = 0,1748), enquanto escolaridade, industrialização e Selic mantêm sinal e significância.

**TABELA 6 - Robustez do Gini e da distância: controle de porte e exclusão de observações**

| Especificação | Gini setorial: coeficiente (p-valor) | Distância: coeficiente (p-valor) | N | R² ajustado |
|---|---|---|---|---|
| Modelo principal | −0,6548 (0,0001) | −0,0016 (0,0033) | 290 | 0,6433 |
| Mais o logaritmo dos vínculos ativos (porte) | +0,2579 (0,1293) | −0,0007 (0,1748) | 290 | 0,6744 |
| Sem as 2 observações com VAB da indústria negativo | −0,4992 (0,0001) | −0,0016 (0,0019) | 288 | 0,6831 |

FONTE: O autor (2026). Erros-padrão de White (HC1).

Assim, H3 se sustenta no modelo principal, mas não resiste ao controle do porte: a medida pode estar captando o tamanho do município e não apenas a diversificação. [aguardando orientação do professor: decidir se o porte entra no modelo principal.]

A TABELA 7 repete os diagnósticos com termos adicionais, em resposta à rejeição do RESET.

**TABELA 7 - Reespecificação da forma funcional e do porte: ajuste e diagnósticos**

| Especificação | R² ajustado | AIC | RESET: F (p-valor) | Shapiro-Wilk: W | Gini: coeficiente (p-valor) |
|---|---|---|---|---|---|
| Modelo principal | 0,6433 | −388,30 | 14,49 (< 0,0001) | 0,8618 | −0,6548 (0,0001) |
| Mais quadrados de X2 e X3 (centrados) | 0,6678 | −406,94 | 8,12 (0,0004) | 0,9045 | −1,0152 (< 0,0001) |
| Mais ln dos vínculos ativos (porte) | 0,6744 | −413,76 | 3,98 (0,0197) | 0,8567 | +0,2579 (0,1293) |
| Quadrados de X2 e X3 e porte | 0,7041 | −439,54 | 3,59 (0,0288) | 0,8868 | +0,2019 (0,3246) |

FONTE: O autor (2026). O RESET rejeita a forma linear em todas as versões; a inclusão do porte é a que mais reduz a estatística, e o Shapiro-Wilk rejeita a normalidade em todas.

O modelo principal permanece como o definido pelas hipóteses do trabalho; as versões ampliadas servem de sensibilidade. O porte melhora o ajuste e reduz a estatística do RESET, mas muda o resultado de H3.

### 5.5 Previsão de 2021

A TABELA 5 apresenta a previsão de 2021 para três cenários da Selic.

**TABELA 5 - Previsão da média do salário real em 2021, com correção de viés**

| Cenário | Selic (% a.a.) | Média prevista com correção (R$) |
|---|---|---|
| Selic observada | −5,11 | 2.621,97 |
| Selic +1 p.p. | −4,11 | 2.639,18 |
| Selic −1 p.p. | −6,11 | 2.604,87 |

FONTE: O autor (2026). Previsão dentro da amostra; correção de viés exp(s²/2) = 1,0075.

No ponto médio dos regressores de 2021 e no cenário base, o intervalo de 95% da média de ln(salário) vai de 7,8250 a 7,8760 com a matriz de White e de 7,8172 a 7,8838 com a matriz clássica. Em municípios isolados a diferença pode ser maior: em Adrianópolis, o intervalo com White é de 7,7923 a 7,9346, contra 7,8072 a 7,9197 com a matriz clássica, e em 9 dos 29 municípios o intervalo com White é o mais largo. A correção de viés eleva a média em 0,75% em relação à previsão sem correção. A variação de ±1 ponto na Selic altera a previsão média em cerca de 0,66%. [aguardando orientação do professor: uso de exp(s²/2) como correção aproximada.]

## 6 DISCUSSÃO

[revisar: o professor pediu que a discussão dialogue com a literatura vigente e deixe clara a contribuição do trabalho (comentário de 23/11/2026). Cada subseção abaixo traz o resultado deste trabalho, com a magnitude, e deixa a comparação com a literatura para o pesquisador. Os percentuais abaixo vêm de exp(coeficiente × variação) − 1.]

### 6.1 Escolaridade (H1)

Mais um ponto percentual de vínculos com ensino superior associa-se a salário médio cerca de 1,5% maior (coeficiente de 0,0150; p < 0,0001). [a inserir: comparação com o que a teoria do capital humano prevê e com estudos para o Brasil, lembrando que a variável é coletiva e não individual.]

### 6.2 Industrialização (H2)

Mais um ponto percentual da indústria no valor adicionado associa-se a salário cerca de 0,55% maior (coeficiente de 0,0055; p < 0,0001). Duas observações exigem cuidado: o VAB da indústria é negativo em Araucária em 2012 e 2013, e Adrianópolis tem salto de 7,1% para 45,5% em 2015. [a inserir: comparação com a literatura sobre indústria e salário.]

### 6.3 Diversificação setorial (H3)

Um aumento de 0,10 no Gini setorial (emprego mais concentrado em poucas divisões) associa-se a salário cerca de 6,3% menor (coeficiente de −0,6548; p = 0,0001). O sinal se mantém quando o Gini é calculado só com as divisões que têm vínculo (−0,638; p = 0,0011). Como o índice cai quando mais divisões têm vínculo (correlação de −0,95 com essa contagem), ele acompanha o porte do município. Ao controlar o porte, o coeficiente deixa de ser significativo (seção 5.4), de modo que o resultado não permite afirmar que a diversificação, separada do tamanho do município, se associa ao salário. [a inserir: comparação com o debate sobre especialização e diversificação.]

### 6.4 Selic real (H4)

Mais um ponto percentual da Selic real associa-se a salário cerca de 0,66% maior (intervalo de 95%: 0,30% a 1,01%). A Selic tem um valor por ano, ou seja, 10 valores distintos para 290 observações, o que limita a precisão do coeficiente. A hipótese é exploratória, e o sinal positivo não tem fundamento teórico apresentado neste trabalho. [a inserir: leitura do sinal à luz da literatura sobre juros e mercado de trabalho.]

### 6.5 Distância a Curitiba (H5)

Mais dez quilômetros de distância associam-se a salário cerca de 1,6% menor (coeficiente de −0,0016 por km; p = 0,0033). Com o logaritmo dos vínculos ativos como controle, o coeficiente cai para −0,0007 e deixa de ser significativo (p = 0,1748), de modo que a associação com a distância não se separa do porte do município. [a inserir: comparação com a economia regional.]

### 6.6 Limitações e pontos de atenção

Três pontos merecem atenção. Primeiro, a associação negativa entre o Gini setorial e o salário mantém o sinal nas duas definições da variável, mas depende da forma como ela é construída e não resiste ao controle do porte do município. Segundo, a escolaridade, a industrialização e a distância têm sinais estáveis nas estimativas (a significância da distância, porém, não resiste ao controle de porte), mas o modelo linear é rejeitado pelo RESET, e os coeficientes devem ser lidos como aproximações. Terceiro, o salto industrial de Adrianópolis em 2015 é um dado publicado, mas a causa não está confirmada; a fábrica de cimento inaugurada no município em dezembro de 2015 é uma hipótese plausível, que não é sustentada pelo emprego formal daquele ano. Além disso, os resultados são associações, não efeitos causais.

**Endogeneidade e variável omitida.** Há três razões para não ler os coeficientes como efeitos. Primeira, simultaneidade: salário e escolaridade se determinam juntos, porque municípios que pagam mais tendem a atrair trabalhadores mais escolarizados, e o VAB da indústria inclui a massa salarial do setor, o que liga X3 ao salário pela própria definição. Segunda, variável omitida: o porte do município tem correlação de −0,88 com o Gini e se associa ao salário, e sua inclusão muda o resultado de H3 (TABELA 6); outros fatores locais, como a composição por ocupação, não estão no modelo. Terceira, medição: a Selic real tem um só valor por ano e a distância é medida entre centroides. Sem instrumentos nem diferenças entre municípios no modelo, que ficam fora do escopo da disciplina, os resultados são associações. [revisar: interpretação a cargo do pesquisador.]

### 6.7 Contribuição do trabalho

[revisar: a contribuição precisa ser confirmada pelo pesquisador e depende da revisão da literatura. Candidatas, só o que o trabalho de fato faz:]

1. Uso do Gini discreto da aula (HOFFMANN, 2006; HASEGAWA, 2020) sobre as 87 divisões da CNAE como medida de diversificação setorial do emprego municipal, com a verificação de que o índice é dominado pelo número de divisões com vínculo.
2. Painel balanceado dos 29 municípios da RMC, de 2012 a 2021, que combina RAIS, SIDRA, Banco Central e IBGE, com validações automáticas.
3. Evidência descritiva de que escolaridade, industrialização e proximidade de Curitiba se associam a salário médio maior na RMC; a diversificação se associa no modelo principal, mas não com o controle de porte.
4. Registro dos limites do modelo (forma funcional, normalidade e autocorrelação) e do caso de Adrianópolis.

## 7 CONCLUSÃO

Os resultados indicam associações positivas entre salário real e escolaridade e industrialização, associação negativa entre salário e concentração setorial do emprego, que deixa de ser significativa quando se controla o porte do município, e associação negativa entre salário e distância a Curitiba, que também deixa de ser significativa com esse controle, no período de 2012 a 2021 e nos 29 municípios da RMC. A Selic real tem associação positiva e pequena. Os resultados não são causais, e os diagnósticos apontam limitações de forma funcional, normalidade e autocorrelação que devem ser consideradas na leitura dos coeficientes. A contribuição do trabalho, na seção 6.7, é descritiva: [revisar: uma frase com a contribuição, a cargo do pesquisador, e os próximos passos possíveis]. [revisar: conclusão e implicações, a cargo do pesquisador.]

## REFERÊNCIAS

AGÊNCIA ESTADUAL DE NOTÍCIAS DO PARANÁ (AEN). Inauguração da fábrica de cimento em Adrianópolis. Curitiba, 17 dez. 2015. [título e data a conferir no documento]. Disponível em: https://arquivo2011.aen.pr.gov.br/sites/default/arquivos_restritos/files/documento/migrados/1712_adrianopolis_pos_e.doc. Acesso em: [data de acesso a confirmar].

BANCO CENTRAL DO BRASIL. *Sistema Gerenciador de Séries Temporais (SGS)*: séries 4390 (Selic acumulada no mês) e 433 (variação mensal do IPCA). Brasília: BCB, [ano a confirmar]. Disponível em: https://api.bcb.gov.br/dados/serie/bcdata.sgs.4390 e https://api.bcb.gov.br/dados/serie/bcdata.sgs.433. Acesso em: [data de acesso a confirmar].

BRASIL DE FATO. Moradores de Adrianópolis (PR) denunciam Supremo Secil Cimentos por poluição e estragos em casas. Brasil de Fato, 5 out. 2023. Disponível em: https://www.brasildefato.com.br/2023/10/05/moradores-de-adrianopolis-pr-denunciam-supremo-secil-cimentos-por-poluicao-e-estragos-em-casas. Acesso em: [data de acesso a confirmar].

GUJARATI, Damodar N. *Basic econometrics*. 4. ed. Boston: McGraw-Hill/Irwin, 2003. [PDF local consultado; a 4ª edição tem Gujarati como único autor; páginas citadas são do PDF.]

HASEGAWA, Marcos Minoru. 2016a. *Multicolinearidade*. Slides de aula, Curso de Ciências Econômicas, Universidade Federal do Paraná, 10 nov. 2016. Baseado em Gujarati e Porter (2011, cap. 10).

HASEGAWA, Marcos Minoru. 2016b. *Heterocedasticidade*. Slides de aula, Curso de Ciências Econômicas, Universidade Federal do Paraná, 17 nov. 2016. Baseado em Gujarati e Porter (2011, cap. 11).

HASEGAWA, Marcos Minoru. 2017. *Autocorrelação*. Slides de aula, Curso de Ciências Econômicas, Universidade Federal do Paraná, 9 out. 2017. Baseado em Gujarati e Porter (2011, cap. 11).

HASEGAWA, Marcos Minoru. 2020. *Medidas de desigualdade*: Hoffmann (2006, cap. 17). Slides de aula, disciplina Estatística Econômica e Introdução à Econometria, Curso de Ciências Econômicas, Universidade Federal do Paraná, 6 nov. 2020. 61 slides.

HASEGAWA, Marcos Minoru. 2022. *Modelagem: especificação e diagnóstico*. Slides de aula, Curso de Ciências Econômicas, Universidade Federal do Paraná, 8 maio 2022. Baseado em Gujarati e Porter (2011, cap. 13).

HASEGAWA, Marcos Minoru. 2024. *Teste de Chow*. Slides de aula, Curso de Ciências Econômicas, Universidade Federal do Paraná, 30 out. 2024. Baseado em Gujarati e Porter (2011, cap. 8).

GUJARATI, Damodar N.; PORTER, Dawn C. *Econometria básica*. 5. ed. Porto Alegre: AMGH, 2011. [citado nas aulas; a edição usada nas aulas não foi consultada neste trabalho; revisar a referência.]

HOFFMANN, Rodolfo. *Estatística para economistas*. 4. ed. rev. e ampl. São Paulo: Pioneira Thomson Learning, 2006. Cap. 17, Medidas de desigualdade. [editora a confirmar: catálogos indicam Cengage Learning para a mesma edição, ISBN 9788522104949.]

IBGE. *Produto Interno Bruto dos Municípios*: tabela 5938. Sistema IBGE de Recuperação Automática (SIDRA). Rio de Janeiro: IBGE, [ano da última revisão a confirmar]. Disponível em: https://sidra.ibge.gov.br/tabela/5938. Acesso em: [data de acesso a confirmar].

IBGE. *Localidades*: composição da Região Metropolitana de Curitiba (código 05501). API de localidades. Rio de Janeiro: IBGE, [ano a confirmar]. Disponível em: https://servicodados.ibge.gov.br/api/v1/localidades/. [endereço exato a confirmar]. Acesso em: [data de acesso a confirmar].

IBGE. *Malhas municipais*. API de malhas. Rio de Janeiro: IBGE, [ano a confirmar]. Disponível em: https://servicodados.ibge.gov.br/api/v3/malhas/estados/41?intrarregiao=municipio. Acesso em: [data de acesso a confirmar].

MINISTÉRIO DO TRABALHO. *Relação Anual de Informações Sociais (RAIS)*: microdados públicos, 2012 a 2021. Brasília: MTE, [ano a confirmar]. Disponível em: ftp://ftp.mtps.gov.br/pdet/microdados/RAIS/. Acesso em: [data de acesso a confirmar].

[a inserir: referências de literatura sobre salário, estrutura produtiva e Selic. Nenhuma foi conferida ainda; a seção 2 depende delas.]

## APÊNDICE A - Autocorrelação por município (Durbin-Watson e Breusch-Godfrey)

Objetivo: verificar a autocorrelação dos resíduos dentro de cada município, na série de 10 anos. Durbin-Watson com H0 de ausência de autocorrelação positiva, com dL = 0,243 e dU = 2,822 (n = 10, k = 5, 5%); Breusch-Godfrey de ordem 1, com H0 de ausência de autocorrelação de ordem 1, a 5%.

**QUADRO A.1 - Durbin-Watson e Breusch-Godfrey por município**

| Município | DW | Decisão (DW) | Breusch-Godfrey p | Decisão (BG) |
|---|---|---|---|---|
| Adrianópolis | 0,08 | positiva | 0,022 | rejeita H0 |
| Agudos do Sul | 0,37 | inconclusiva | 0,864 | não rejeita H0 |
| Almirante Tamandaré | 0,08 | positiva | 0,664 | não rejeita H0 |
| Araucária | 0,11 | positiva | 0,024 | rejeita H0 |
| Balsa Nova | 0,78 | inconclusiva | 0,338 | não rejeita H0 |
| Bocaiúva do Sul | 0,69 | inconclusiva | 0,417 | não rejeita H0 |
| Campina Grande do Sul | 0,09 | positiva | 0,606 | não rejeita H0 |
| Campo do Tenente | 0,55 | inconclusiva | 0,051 | não rejeita H0 |
| Campo Largo | 0,07 | positiva | 0,423 | não rejeita H0 |
| Campo Magro | 0,53 | inconclusiva | 0,115 | não rejeita H0 |
| Cerro Azul | 0,21 | positiva | 0,051 | não rejeita H0 |
| Colombo | 0,27 | inconclusiva | 0,265 | não rejeita H0 |
| Contenda | 1,53 | inconclusiva | 0,859 | não rejeita H0 |
| Curitiba | 0,08 | positiva | 0,173 | não rejeita H0 |
| Fazenda Rio Grande | 0,25 | inconclusiva | 0,521 | não rejeita H0 |
| Itaperuçu | 0,66 | inconclusiva | 0,381 | não rejeita H0 |
| Lapa | 0,84 | inconclusiva | 0,720 | não rejeita H0 |
| Mandirituba | 0,14 | positiva | 0,136 | não rejeita H0 |
| Piên | 0,70 | inconclusiva | 0,049 | rejeita H0 |
| Pinhais | 0,74 | inconclusiva | 0,167 | não rejeita H0 |
| Piraquara | 0,09 | positiva | 0,114 | não rejeita H0 |
| Quatro Barras | 0,20 | positiva | 0,680 | não rejeita H0 |
| Quitandinha | 0,13 | positiva | 0,502 | não rejeita H0 |
| Rio Branco do Sul | 0,09 | positiva | 0,941 | não rejeita H0 |
| Rio Negro | 0,08 | positiva | 0,375 | não rejeita H0 |
| São José dos Pinhais | 0,05 | positiva | 0,162 | não rejeita H0 |
| Tijucas do Sul | 1,28 | inconclusiva | 0,432 | não rejeita H0 |
| Tunas do Paraná | 0,76 | inconclusiva | 0,054 | não rejeita H0 |
| Doutor Ulysses | 0,68 | inconclusiva | 0,833 | não rejeita H0 |

FONTE: O autor (2026), a partir de `resultados_econometricos/autocorrelacao_por_municipio.csv`.

[aguardando orientação do professor: tratamento da autocorrelação positiva dentro dos municípios. Por ora, é declarada como limitação.]

## APÊNDICE B - Municípios da RMC (código IBGE)

Adrianópolis (4100202); Agudos do Sul (4100301); Almirante Tamandaré (4100400); Araucária (4101804); Balsa Nova (4102307); Bocaiúva do Sul (4103107); Campina Grande do Sul (4104006); Campo do Tenente (4104105); Campo Largo (4104204); Campo Magro (4104253); Cerro Azul (4105201); Colombo (4105805); Contenda (4106209); Curitiba (4106902); Fazenda Rio Grande (4107652); Itaperuçu (4111258); Lapa (4113205); Mandirituba (4114302); Piên (4119103); Pinhais (4119152); Piraquara (4119509); Quatro Barras (4120804); Quitandinha (4121208); Rio Branco do Sul (4122206); Rio Negro (4122305); São José dos Pinhais (4125506); Tijucas do Sul (4127601); Tunas do Paraná (4127882); Doutor Ulysses (4128633).

FONTE: O autor (2026), a partir da API de localidades do IBGE (composição oficial da RMC, código 05501).

## APÊNDICE C - Memorial do modelo principal

Resumo do memorial matricial (arquivo completo em `resultados_econometricos/memorial_modelo_2.txt`). O estimador é b = (X'X)⁻¹X'y; a variância residual é s² = SQR/(n − k) = 4,2408/284 = 0,0149; R² = 0,6495 e R² ajustado = 0,6433.

**QUADRO C.1 - Análise de variância do modelo principal**

| Fonte | gl | Soma de quadrados | Quadrado médio | F | F crítico (5%) |
|---|---|---|---|---|---|
| Regressão | 5 | 7,8590 | 1,5718 | 105,2606 | 2,2458 |
| Resíduo | 284 | 4,2408 | 0,0149 | | |
| Total | 289 | 12,0998 | | | |

**QUADRO C.2 - Determinação parcial e multicolinearidade**

| Variável | t (erro clássico) | R² parcial | Tolerância | FIV |
|---|---|---|---|---|
| X2 escolaridade | 11,2380 | 0,3078 | 0,8580 | 1,1655 |
| X3 industrialização | 11,8368 | 0,3304 | 0,8744 | 1,1436 |
| X4 Gini setorial | −3,9922 | 0,0531 | 0,4298 | 2,3265 |
| X5 Selic real | 3,1535 | 0,0338 | 0,9940 | 1,0060 |
| X6 distância | −3,4168 | 0,0395 | 0,4518 | 2,2133 |

**QUADRO C.3 - F incremental por bloco de variáveis, com erro clássico e com erro de White**

| Bloco excluído | Restrições | SQR restrita | SQR irrestrita | F (clássico) | F crítico (5%) | p-valor | F (White) | p-valor (White) |
|---|---|---|---|---|---|---|---|---|
| X2 | 1 | 6,1267 | 4,2408 | 126,2934 | 3,8744 | < 0,0001 | 105,0537 | < 0,0001 |
| X3 e X4 | 2 | 7,2181 | 4,2408 | 99,6913 | 3,0276 | < 0,0001 | 98,3401 | < 0,0001 |
| X5 | 1 | 4,3893 | 4,2408 | 9,9445 | 3,8744 | 0,0018 | 13,3844 | 0,0003 |
| X6 | 1 | 4,4151 | 4,2408 | 11,6742 | 3,8744 | 0,0007 | 8,7878 | 0,0033 |

O F de White é o de Wald, F = (Rb)'(RVR')⁻¹(Rb)/q, com V a matriz HC1.

**QUADRO C.4 - Erro-padrão clássico e de White (HC1)**

A matriz de White é V = [n/(n − k)] (X'X)⁻¹ (Σ û_i² x_i x_i') (X'X)⁻¹, com n/(n − k) = 290/284 = 1,0211. O erro-padrão de cada coeficiente é a raiz do elemento correspondente da diagonal.

| Termo | EP clássico | EP de White | Razão (White/clássico) |
|---|---|---|---|
| Intercepto | 0,13557 | 0,15333 | 1,1310 |
| X2 escolaridade | 0,00134 | 0,00147 | 1,0964 |
| X3 industrialização | 0,00047 | 0,00068 | 1,4554 |
| X4 Gini setorial | 0,16402 | 0,16783 | 1,0233 |
| X5 Selic real | 0,00207 | 0,00179 | 0,8620 |
| X6 distância | 0,00046 | 0,00053 | 1,1526 |

FONTE: O autor (2026), a partir de `resultados_econometricos/memorial_modelo_2_*.csv`. Erros clássicos.
