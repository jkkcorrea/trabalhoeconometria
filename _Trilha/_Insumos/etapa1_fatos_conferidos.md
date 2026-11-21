# Fatos conferidos para o script da Etapa 1 (extração)

Conferidos pela sessão em 14 e 15/11/2026, por consulta direta às fontes. Cada fato traz a origem. O que não foi conferido está marcado `[a confirmar]`; escolha metodológica da sessão está marcada `[presunção da modelagem]`.

## Municípios

A lista canônica dos 29 municípios, com código IBGE de 7 dígitos, está na seção 6 do `CLAUDE.md` do projeto (decisão D-2026-11-15-01, origem: API de localidades do IBGE, região metropolitana 05501).

## PIB municipal (SIDRA, tabela 5938)

Origem: `https://servicodados.ibge.gov.br/api/v3/agregados/5938/metadados`, consultado em 15/11/2026. Periodicidade anual, de 2002 a 2023. Nível territorial de município: N6. Variáveis, todas em mil reais:

| Código | Variável |
|---|---|
| 37 | Produto Interno Bruto a preços correntes |
| 543 | Impostos, líquidos de subsídios, sobre produtos a preços correntes |
| 498 | Valor adicionado bruto a preços correntes total |
| 513 | Valor adicionado bruto a preços correntes da agropecuária |
| 517 | Valor adicionado bruto a preços correntes da indústria |
| 6575 | Valor adicionado bruto a preços correntes dos serviços, exclusive administração, defesa, educação e saúde públicas e seguridade social |
| 525 | Valor adicionado bruto a preços correntes da administração, defesa, educação e saúde públicas e seguridade social |

## Banco Central (SGS)

Decisão D-2026-11-15-02. Origem: API `https://api.bcb.gov.br/dados/serie/bcdata.sgs.<codigo>/dados?formato=json` e portal de dados abertos do Banco Central, consultados em 14/11/2026.

- Série 4390: Selic acumulada no mês, em % ao mês (nome conferido no portal). Valores recentes entre 0,46 e 1,08.
- Série 433: variação mensal do IPCA, em % ao mês (nome conferido na documentação da biblioteca python-bcb). Valores recentes entre -0,32 e 0,82.
- Selic do ano = produto de (1 + valor mensal / 100) nos 12 meses, menos 1, vezes 100. IPCA do ano: mesma fórmula sobre a série 433.
- Índice de preços mensal: acumulação da série 433 a partir de base 100 no primeiro mês da amostra. Índice anual: média dos 12 meses `[presunção da modelagem]`.

## RAIS (microdados do Ministério do Trabalho)

Decisão D-2026-11-15-03. Origem: listagem do FTP público `ftp://ftp.mtps.gov.br/pdet/microdados/RAIS/`, feita em 15/11/2026.

- De 2012 a 2017 há um arquivo por unidade da federação: `<ano>/PR<ano>.7z`. Tamanhos: 2012 com 106 MB, 2013 com 108 MB, 2014 com 109 MB, 2015 com 176 MB, 2016 com 182 MB, 2017 com 177 MB.
- De 2018 a 2022 há um arquivo por região: `<ano>/RAIS_VINC_PUB_SUL.7z`, que inclui Paraná, Santa Catarina e Rio Grande do Sul. Tamanhos entre 495 MB e 599 MB. Em 2019 o arquivo da raiz da pasta é a versão atualizada (a subpasta `Legado` guarda a anterior, conforme o `Leia-me.txt` do ano).
- Também há 2023 a 2025 no FTP, fora do período do trabalho.
- Download total estimado para 2012 a 2021: cerca de 3,5 GB compactados. Os arquivos descompactados são várias vezes maiores `[a confirmar]`. O disco C: tinha 45 GB livres em 15/11/2026.

Campos do layout oficial (`Layouts/vínculos/RAIS_vinculos_layout2015.xls`, `...2017.xls`, `...2018e2019.xls` e `...2020.xls`, todos iguais nestes campos):

- MUNICIPIO: município de localização do estabelecimento, código de **6 dígitos** (o código IBGE sem o dígito verificador). Existe também MUN TRAB, o município onde o empregado trabalha.
- EMP EM 31/12: indicador de vínculo ativo em 31/12.
- REM MED (R$): remuneração média do trabalhador no ano, valor nominal.
- GR INSTRUCAO OU ESCOLARIDADE APÓS 2005: 1 analfabeto; 2 até o 5º ano incompleto; 3 5º ano completo; 4 do 6º ao 9º ano; 5 fundamental completo; 6 médio incompleto; 7 médio completo; 8 superior incompleto; 9 superior completo; 10 mestrado; 11 doutorado; -1 ignorado.
- CLAS CNAE 20: classe CNAE 2.0, 5 dígitos. SB CLAS 20: subclasse, 7 dígitos.

O layout traz o nome lógico do campo, não o texto exato do cabeçalho do arquivo. O cabeçalho real (separador, codificação, grafia das colunas e formato decimal) está `[a confirmar]` na primeira leitura de cada formato (até 2017 e a partir de 2018).

Escolhas de agregação `[presunção da modelagem]`:
- Município de referência: o do estabelecimento (MUNICIPIO).
- Universo: vínculos ativos em 31/12.
- Remuneração média nominal do município: média de REM MED entre os vínculos ativos com remuneração maior que zero.
- Vínculos com superior: escolaridade 9, 10 ou 11.
- Setor para o índice de Shannon: divisão CNAE 2.0, os dois primeiros dígitos da classe.

## Ambiente R da máquina

Conferido em 15/11/2026: R 4.5.1 em `C:/Program Files/R/R-4.5.1/bin/Rscript.exe`. Biblioteca única em `C:/Program Files/R/R-4.5.1/library`, que exige permissão de administrador para gravar. Instalados: dplyr 1.1.4, tidyr 1.3.1, readr 2.1.5, purrr 1.1.0, stringr 1.5.2, lubridate 1.9.4, jsonlite 2.0.0, curl 7.0.0, vroom 1.6.5, readxl. Ausentes: tidyverse, sidrar, rbcb, geobr, sf, fs, archive, data.table, httr, skimr, corrplot.

A pasta do projeto fica dentro do OneDrive. Arquivos grandes gravados nela são enviados à nuvem pela sincronização.
