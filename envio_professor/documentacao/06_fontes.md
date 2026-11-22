# Fontes e referências

## Fontes oficiais da disciplina (podem ser citadas)

| Fonte | Conteúdo usado |
|---|---|
| Gujarati, D. N.; Porter, D. C. Basic Econometrics, 4ª ed. (McGraw-Hill, 2004), PDF local com texto completo; as páginas citadas são do PDF. A disciplina cita a 5ª ed. (AMGH, 2011); a paginação pode diferir. | fonte principal dos métodos (ver tabela abaixo) |
| Notas de aula de regressão linear múltipla (Hasegawa) | matriz X'X, ANOVA, t e F, R2 parcial |
| Notas de multicolinearidade, heterocedasticidade, autocorrelação, especificação e teste de Chow (SE614) | métodos de diagnóstico |
| Gujarati, Apêndice D, Tabela D.5A (PDF p. 995): n = 10, k = 5, 5%: dL = 0,243 e dU = 2,822 | Durbin-Watson por município (conferido no livro) |
| Guia da P2 (professor) | regras de decisão de FIV, BPG, DW e Gini |
| Slides da pasta `aulas` do Drive: regressão matricial, especificação e diagnóstico (cap. 13), teste de Chow, multicolinearidade, heterocedasticidade, autocorrelação (Breusch-Godfrey, teste das carreiras, Durbin-Watson, medidas corretivas MQG e Newey-West, este último não aplicado ao painel), medidas de desigualdade | confirmação dos métodos ensinados |
| Gujarati (PDF da 4ª ed., texto completo): cap. 5, seção 5.12 (Jarque-Bera, PDF pp. 176 e 177); cap. 8 (Chow, PDF pp. 303 a 309); cap. 9 (dummies, PDF pp. 332 a 352); cap. 11 (heterocedasticidade: Goldfeld-Quandt, Glejser, Park, White, MQP, PDF pp. 432 a 462); cap. 12 (autocorrelação: teste das carreiras PDF p. 493, Breusch-Godfrey PDF pp. 499 e 500, Durbin-Watson PDF pp. 495 a 499, Cochrane-Orcutt e Prais-Winsten PDF pp. 510 a 528, Newey-West, citado e não aplicado, PDF p. 503); cap. 13 (RESET PDF pp. 549 a 552, outliers, leverage e influência PDF pp. 568 e 569) | páginas citadas pelo trabalho |

## Dados

| Dado | Origem | Arquivo |
|---|---|---|
| PIB e VAB municipais | IBGE, SIDRA, tabela 5938 | dados_brutos/pib_sidra.rds |
| Selic (4390) e IPCA (433) | Banco Central, SGS | dados_brutos/macro_bacen.rds |
| Vínculos, escolaridade, salário e divisão CNAE | RAIS, microdados públicos do Ministério do Trabalho | dados_brutos/rais.rds |
| Malha municipal | IBGE, pacote geobr | dados_brutos/malha_rmc.rds |
| Distâncias a Curitiba | cálculo a partir dos centroides | dados_brutos/distancias.rds |
| Valor da produção agrícola municipal (PAM) | IBGE, SIDRA, tabela 5457, variável 215 | dados_brutos/pam_valor_producao.rds |

Os endereços e os códigos das APIs foram conferidos em 22/11/2026 (ver 08_verificacao.md).

Referências de métodos removidos do projeto não são citadas no trabalho.
