# Verificação do envio

Verificação independente. Recalcula por álgebra matricial e pelas fórmulas ensinadas, sem reusar o código dos scripts.

| Id | Verificação | Situação | Detalhe |
|---|---|---|---|
| A1 | Arquivos essenciais presentes | APROVADA | 46 arquivos |
| A1b | Sem saídas de métodos removidos nem arquivos antigos | APROVADA | nenhuma saída antiga |
| A2 | Nenhum método fora do escopo ensinado nos scripts e documentos | APROVADA | 20 arquivos varridos |
| A3 | Sem identificadores internos de trabalho nem caminhos pessoais | APROVADA | limpo |
| A4 | Código dos scripts idêntico ao da versão de trabalho (só comentários diferem) | APROVADA | 8 scripts idênticos |
| A5 | Scripts usam só caminhos relativos | APROVADA | nenhum caminho absoluto |
| B1 | Painel: 290 linhas, 29 municípios, 10 anos balanceados, sem NA, NaN ou Inf | APROVADA | 290 x 22 |
| B2 | Gini setorial recomputado a partir da RAIS (fórmula do Guia P2, 87 divisões) | APROVADA | maior diferença 0.00e+00 |
| C1 | Coeficientes e erro clássico do Modelo 2 recalculados por álgebra matricial | APROVADA | max dif coef 2.9e-12; erro 3.7e-14 |
| C2 | Erro de White (HC1) do Modelo 2 recalculado | APROVADA | max dif 5.1e-13 |
| C3 | FIV do Modelo 2 recalculado por 1/(1 - R2_j) | APROVADA | max dif 2.2e-15; maior FIV 2.3265 |
| C4 | Breusch-Pagan-Godfrey do Modelo 2 recalculado (n R2) | APROVADA | calculado 11.8953; no arquivo 11.8953 |
| C5 | Durbin-Watson por município recalculado (29 séries de 10 anos) | APROVADA | max dif 3.5e-11; mediana 0.2504 |
| C6 | Teste de Chow recalculado | APROVADA | calculado 1.7863; no arquivo 1.7863 |
| D1 | Coeficiente de X2 (erro de White) escrito no resumo igual ao CSV | APROVADA | valor 0,0150 |
| D2 | Os modelos e testes do resumo batem com os arquivos de resultado | APROVADA | três modelos presentes |

16 de 16 verificações aprovadas.
