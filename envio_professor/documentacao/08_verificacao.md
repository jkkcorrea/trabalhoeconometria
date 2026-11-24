# Verificação do envio

Verificação independente. Recalcula por álgebra matricial e pelas fórmulas ensinadas, sem reusar o código dos scripts.

| Id | Verificação | Situação | Detalhe |
|---|---|---|---|
| A1 | Arquivos essenciais presentes | APROVADA | 71 arquivos esperados presentes; 71 arquivos na pasta |
| A1b | Sem arquivos de versões anteriores nos resultados, figuras e dados brutos | APROVADA | nenhum arquivo antigo |
| A2 | Nenhum método fora do escopo ensinado nos scripts e documentos | APROVADA | 20 arquivos varridos |
| A3 | Sem identificadores internos de trabalho nem caminhos pessoais | APROVADA | limpo |
| A4 | Código dos scripts idêntico ao da versão de trabalho (só comentários diferem) | APROVADA | 8 scripts idênticos |
| A5 | Scripts usam só caminhos relativos | APROVADA | nenhum caminho absoluto |
| B1 | Painel: 290 linhas, 29 municípios, 10 anos balanceados, sem NA, NaN ou Inf | APROVADA | 290 x 21 |
| B2 | Gini setorial recomputado a partir da RAIS (fórmula da aula de desigualdade, Hasegawa 2020, 87 divisões) | APROVADA | maior diferença 0.00e+00 |
| C1 | Coeficientes e erro clássico do modelo principal recalculados por álgebra matricial | APROVADA | maior diferença 2.86e-12 |
| C2 | Erro de White (HC1) recalculado | APROVADA | maior diferença 5.12e-13 |
| C3 | FIV do modelo principal recalculado por 1/(1 - R2_j) | APROVADA | maior FIV 2.3265; maior diferença 2.22e-15 |
| C4 | Breusch-Pagan-Godfrey recalculado (n R2 da regressão auxiliar) | APROVADA | calculado 11.8953; no arquivo 11.8953 |
| C5 | RESET de Ramsey recalculado (F com ajustados ao quadrado e ao cubo) | APROVADA | calculado 14.4857; no arquivo 14.4857 |
| C6 | Durbin-Watson por município recalculado (29 séries de 10 anos) | APROVADA | maior diferença 3.52e-11 |
| C7 | Decisões de Durbin-Watson por município conferidas com dL = 0,243 e dU = 2,822 (Gujarati, Tabela D.5A) | APROVADA | 29 de 29 municípios com decisão igual à regra |
| C8 | Teste de Chow (corte de 2017) recalculado | APROVADA | calculado 1.6026; no arquivo 1.6026 |
| C9 | Shapiro-Wilk dos resíduos recalculado | APROVADA | W = 0.8618; p = 1.97e-15 |
| C10 | Projeção de 2021 (cenário base) igual ao ajuste do modelo e correção de viés exp(s2/2) aplicada | APROVADA | desvio do ajuste 1.14e-12; fator exp(s2/2) = 1.00749 |
| C11 | Intervalo de confiança da Selic (erro de White, gl = n - k) recalculado | APROVADA | IC [0.003022; 0.010062] |
| C19 | Breusch-Godfrey por município recalculado (n - p observações, primeiro defasado descartado) | APROVADA | maior diferença 7.20e-12; rejeitam 5 de 29 |
| C12 | Memorial matricial do modelo principal bate com a álgebra independente | APROVADA | maior diferença nos coeficientes 1.66e-12 |
| C13 | Teste de White recalculado (n R2 da regressão auxiliar com quadrados e produtos cruzados) | APROVADA | calculado 94.1532 (gl 20); no arquivo 94.1532 (gl 20) |
| C20 | Goldfeld-Quandt unilateral ordenado por X3 recalculado (fração central 0,2 omitida) | APROVADA | calculado F = 1.5295, p = 0.0134; no arquivo F = 1.5295, p = 0.0134 |
| C14 | F geral com erro de White (HC1) recalculado | APROVADA | calculado 92.8340; no arquivo 92.8340 |
| C15 | Durbin-Watson com resíduos centrados por município e municípios de mesmo sinal recalculados | APROVADA | mesmo sinal 16; abaixo de dL com resíduos centrados 1 |
| C16 | Reespecificação com o porte do município: RESET e coeficiente do Gini recalculados | APROVADA | RESET calculado 3.9843, no arquivo 3.9843; Gini 0.2579 |
| C17 | F incremental com erro de White (bloco X3 e X4) recalculado | APROVADA | calculado 98.3401; no arquivo 98.3401 |
| C18 | Intervalo da média da previsão (matriz de White, regressores médios de 2021) recalculado | APROVADA | limite inferior calculado 7.8250; no arquivo 7.8250 |
| D1 | Coeficiente de X2 (erro de White) escrito na documentação igual ao CSV | APROVADA | valor esperado 0,0150 |
| D2 | Estatística de Shapiro-Wilk escrita na documentação igual ao CSV | APROVADA | valor esperado 0,8618 |

30 de 30 verificações aprovadas.
