# Registro de verificação

Verificações independentes da pasta de envio, feitas em base R sem reutilizar o código dos scripts entregues. Cada linha traz o que foi conferido e a diferença medida.

Data: 21/11/2026. Versão do R: 4.6.2.

- A: inventário, higiene dos arquivos e identidade do código (só os comentários mudaram).
- B: recomputação do painel a partir dos dados brutos.
- C: recomputação dos resultados de regressão, dos diagnósticos e dos testes do script 08.
- D: coerência da documentação com os arquivos de resultado.
- E: reexecução completa em cópia limpa da pasta.

A verificação A4 compara os scripts com a versão de trabalho, que não acompanha o envio.

| Id | Verificação | Situação | Detalhe |
|---|---|---|---|
| A1 | Arquivos essenciais presentes (scripts, dados, painel, LEIAME) | APROVADA | 21 arquivos |
| A1b | Nenhum arquivo inesperado (só R, md, csv, txt, html, png, gif e rds) | APROVADA | 101 arquivos, todos de tipo permitido |
| A2 | Arquivos de texto sem identificadores internos de trabalho nem caminhos pessoais | APROVADA | 79 arquivos varridos, 17 padrões |
| A3 | Nenhum caminho pessoal dentro dos arquivos .rds | APROVADA | 7 arquivos .rds |
| A4 | Código dos scripts idêntico ao da versão de trabalho (só os comentários foram removidos) | APROVADA | 9 scripts |
| A5 | Scripts usam só caminhos relativos à raiz da pasta | APROVADA | nenhum caminho absoluto |
| B1 | Painel: 290 linhas, 29 municípios, 10 anos, balanceado, sem NA/NaN/Inf | APROVADA | 290 x 23 |
| B2 | X2 recomputada dos microdados agregados da RAIS | APROVADA | maior diferença 0.00e+00 |
| B3 | X3 recomputada do valor adicionado setorial (soma dos quatro setores no denominador) | APROVADA | maior diferença 0.00e+00 |
| B4 | X4 (entropia de Shannon) recomputada das contagens por divisão da CNAE | APROVADA | maior diferença 0.00e+00; divisões distintas: 87 |
| B5 | X5 (Selic real, Fisher) recomputada das séries mensais 4390 e 433 | APROVADA | maior diferença 0.00e+00 |
| B6 | Y (salário médio real em R$ de 2021) e ln Y recomputados | APROVADA | maior diferença relativa 6.66e-16; ln 0.00e+00 |
| B7 | X6 igual às distâncias brutas, constante no tempo; Curitiba com distância 0 e indicadora = 1 só para ela | APROVADA | diferença 0.00e+00 |
| B8 | X5 constante entre municípios em cada ano (10 valores distintos) | APROVADA | 10 valores |
| B9 | Exatamente duas observações com X3 negativo (Araucária 2012 e 2013), marcadas em x3_negativo | APROVADA | Araucária 2012; Araucária 2013 |
| B10 | Nenhum vínculo com divisão CNAE 'ignorada' e nenhum vínculo com escolaridade ignorada | APROVADA | 0 e 0 |
| C1 | Modelo 2: coeficientes (QR) e erros-padrão clássicos iguais aos do arquivo de resultados | APROVADA | coef 0.00e+00; ep 2.01e-15 |
| C2 | Modelo 2: erro agrupado por município (laço explícito) e p-valor com t de 28 gl iguais ao arquivo de calibração | APROVADA | ep 1.89e-14; p 3.35e-13 |
| C3 | Efeitos fixos: coeficientes e erro agrupado (partialling-out por variáveis binárias) iguais ao arquivo | APROVADA | coef 1.04e-15; ep 4.23e-16 |
| C4 | Mundlak: efeitos de X2, X3 e X4 iguais aos de efeitos fixos | APROVADA | diferença 7.09e-15 |
| C5 | Teste F de efeitos individuais recomputado (28; 257 gl) | APROVADA | F = 75.8928 contra 75.8928 |
| C6 | Diagnósticos recomputados à mão: Breusch-Pagan (Koenker), Durbin-Watson, Breusch-Godfrey, RESET | APROVADA | BP 13.0536/13.0536; DW 0.4227/0.4227; BG 177.3971/177.3971; RESET 18.4638/18.4638 |
| C7 | Goldfeld-Quandt (ordenado por vínculos) recomputado, p unilateral e bilateral | APROVADA | F 1.4317/1.4317; p unilateral 0.0306/0.0306; bilateral 0.0611/0.0611 |
| C8 | P-valor da Selic agrupado por ano recomputado (t com 9 gl) | APROVADA | 0.006954 contra 0.006954 |
| C9 | FIV do Modelo 2 pelas regressões auxiliares | APROVADA | maior diferença 2.66e-15 |
| C10 | Bootstrap wild cluster: segunda implementação com outra semente concorda dentro de 0,02 (o erro de Monte Carlo combinado é de cerca de 0,004) | APROVADA | X4 0.0920/0.0895; X6 0.4962/0.5003 |
| C11 | Memorial matricial: coeficientes iguais aos recomputados por QR | APROVADA | diferença 3.27e-13 |
| C12 | Memorial: R², R² ajustado e F global iguais aos de lm() | APROVADA | R² 0.6456; F 103.4549 |
| C13 | Efeitos fixos com quadráticos: coeficientes por variáveis binárias iguais ao arquivo | APROVADA | diferença 8.68e-14 |
| C14 | RESET (regressores) dos efeitos fixos com quadráticos recomputado à mão, graus de liberdade pelo posto | APROVADA | F 1.6686/1.6686 |
| C15 | Bootstrap wild cluster por ano exato (1.024 combinações) recomputado com variáveis binárias de município (independente do script) | APROVADA | 0.054688 contra 0.054688 |
| C16 | Exogeneidade estrita: coeficientes dos valores futuros iguais aos recomputados (within) | APROVADA | diferença 6.94e-18 |
| C17 | Teste conjunto de exogeneidade estrita recomputado (Wald, F com 3 e 28 gl) | APROVADA | F 2.6191/2.6191 |
| C18 | Animações .gif presentes e válidas (cabeçalho GIF) | APROVADA | 906 KB; 3055 KB |
| C19 | Intervalos de confiança de robustez_mundlak_coeficientes.csv usam o erro agrupado e t de 28 gl (estimativa +/- t x erro) | APROVADA | diferença 0.00e+00 |
| C20 | Box-Cox com efeitos fixos: lambda estimado igual ao de MASS::boxcox | APROVADA | -0.13 contra -0.13 |
| C21 | Simulação com efeitos fixos: variação percentual de +10 pontos em X3 e +5 pontos em X2 recomputada | APROVADA | -0.4833 e 4.3984 |
| C22 | Sensibilidade a influentes: 15 observações com Cook > 4/n e coeficiente de efeitos fixos sem Adrianópolis recomputado | APROVADA | 15 observações; coef 0.007613/0.007613 |
| C23 | Teste de Chow recomputado: Modelo 2 contra indicadora de Curitiba e interações com X2 a X5 (F com 5 e 279 gl) | APROVADA | F 4.1553/4.1553 |
| C26 | Teste da restrição de Fisher recomputado (agrupado por município, t com 28 gl, e por ano, t com 9 gl) | APROVADA | p 0.6175 e 0.8154 |
| C24 | Decomposição da Selic real (Selic nominal e IPCA) por variáveis binárias recomputada | APROVADA | 0.003945 e -0.003357 |
| C25 | Bootstrap com pesos de Webb por ano: segunda implementação (variáveis binárias, outra semente) concorda dentro de 0,012 (cerca de 4 desvios de Monte Carlo) | APROVADA | 0.0426 contra 0.0462 |
| D1 | Documentação cita o coeficiente de X2 de efeitos fixos com o valor do arquivo (quatro casas) | APROVADA | 0,0086 |
| D2 | Dicionário de variáveis cobre todas as colunas do modelo no painel | APROVADA | 10 linhas |
| E1 | Reexecução em cópia limpa (a partir de dados_brutos): scripts 02 a 08 terminam sem erro | APROVADA | 02_tratamento_painel ok; 03_aede_visualizacoes ok; 04_modelagem_diagnosticos ok; 05_robustez_mundlak ok; 06_calibracao_modelo ok; 07_memorial_modelo_2 ok; 08_fragilidades_modelo ok |
| E2 | Reexecução reproduz os arquivos .csv e .txt de resultados byte a byte | APROVADA | 50 arquivos idênticos |
| E4 | Reexecução reproduz as figuras .png byte a byte | APROVADA | 13 figuras idênticas |
| E5 | Nenhuma figura .png vazia (todas com mais de 30 KB) | APROVADA | menor figura: 40 KB |
| E3 | Reexecução reproduz o painel (identical) | APROVADA | painel |

Resultado: 49 de 49 verificações aprovadas.

Limites: o script `01_extracao_dados.R` não foi reexecutado (exige o download de cerca de 3,5 GB), e a coleta fica documentada pelos arquivos de `dados_brutos/`, conferidos nas verificações B1 a B10.
