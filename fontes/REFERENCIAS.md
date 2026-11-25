# Referências do trabalho

Atualizado em 23/11/2026. É a lista central de referências e links do artigo, dos slides e da documentação. A lista formatada do artigo está em `artigo/ARTIGO_rascunho_v2.md` (seção REFERÊNCIAS). Marcas: **[a confirmar]** = dado que falta conferir; **[revisar]** = decisão do pesquisador.

## 1. Livros

| Referência (ABNT) | Onde está no projeto | Usado em | Estado |
|---|---|---|---|
| GUJARATI, Damodar N. *Basic econometrics*. 4. ed. Boston: McGraw-Hill/Irwin, 2003. | `Gujarati_Basic_Econometrics.pdf` (raiz, não versionado; 1.027 páginas; capa com Gujarati como único autor, copyright 2003) | tabela D.5A (dL e dU), cap. 10, 11 e 13, p. 207-208 e 449 | Conferido no PDF. Correção em 23/11/2026: o projeto citava "Gujarati e Porter (2004)", mas a 4ª edição do PDF tem um autor. |
| GUJARATI, Damodar N.; PORTER, Dawn C. *Econometria básica*. 5. ed. Porto Alegre: AMGH, 2011. | não está na pasta | citado nas aulas de Hasegawa (rodapé "Bibliografia básica") | **[revisar]** edição das aulas (5ª) difere da usada nos cálculos (4ª). |
| HOFFMANN, Rodolfo. *Estatística para economistas*. 4. ed. rev. e ampl. São Paulo: Pioneira Thomson Learning, 2006. Cap. 17. | `hoffmann2006_cap17_desiguald.pdf` (raiz; 33 páginas, capítulo 17) | fórmula do Gini (p. 340-341) | Editora **[a confirmar]**: catálogos online listam Thomson Pioneira e Cengage Learning para a mesma edição (ISBN 9788522104949); não consultei a página da editora. |
| HOFFMANN, Rodolfo. *Análise de regressão*: uma introdução à econometria. Portal de Livros Abertos da USP, 2016. | `fontes/livros_artigos/hoffmann_2016_usp_livro_aberto.pdf` | apoio; não citado no artigo | Livro aberto. Cap. 5 trata de binárias (fora do escopo). |

## 2. Aulas do professor (Hasegawa, UFPR)

Todas são slides de aula, citados no artigo como HASEGAWA com o ano. Os PDFs estão no Drive da disciplina (pasta `Econometria`); somente o de desigualdade está na pasta do projeto.

| Citação no artigo | Título e data | Base citada na aula | Arquivo (Drive) | O que sustenta no artigo |
|---|---|---|---|---|
| HASEGAWA, 2016a | *Multicolinearidade*, 10 nov. 2016 | Gujarati e Porter (2011, cap. 10) | `multicolinear.pdf` (`1cg_s5SrrDe5xA_IyB42Ph6_7QMIEntG6`) | FIV. O texto extraído não traz o limite 10 (está em imagem): **[a confirmar]**. |
| HASEGAWA, 2016b | *Heterocedasticidade*, 17 nov. 2016 | Gujarati e Porter (2011, cap. 11) | `heterocedast.pdf` (`1cK-6ZxNTH-leP2QjteoLzO9kGbXRRptY`) | Breusch-Pagan-Godfrey e Goldfeld-Quandt (lista de métodos formais, p. 47-48 da aula). |
| HASEGAWA, 2017 | *Autocorrelação*, 9 out. 2017 | Gujarati e Porter (2011, cap. 12; o título do slide diz cap. 11, mas as figuras são do cap. 12) | `autocorrel.pdf` (`1WYCarnorspho-VZzBH7UncPzT4azDAgo`) | Durbin-Watson, Breusch-Godfrey (Gujarati, PDF p. 501: regressão com n − p observações e estatística (n − p) R²); consequências para t e F (p. 55-65 da aula); medidas corretivas (p. 97-100). |
| HASEGAWA, 2020 | *Medidas de desigualdade*: Hoffmann (2006, cap. 17), 6 nov. 2020 | Hoffmann (2006, cap. 17) | `se305_medidasdesigualdade_.pdf` (raiz; 61 slides) | Gini discreto (slides 21 e 22). O slide escreve "Hoffman". |
| HASEGAWA, 2022 | *Modelagem: especificação e diagnóstico*, 8 maio 2022 | Gujarati e Porter (2011, cap. 13) | `especificao_diagnostico.pdf` (`14esRhmU2A667g_-gevQ2AcjC2eg2N38v`) | RESET, exame de resíduos, Durbin-Watson como sinal de erro de especificação (valores de dL e dU para n = 10, k = 1 a 3). |
| HASEGAWA, 2024 | *Teste de Chow*, 30 out. 2024 | Gujarati e Porter (2011, cap. 8); Hoffmann e Vieira (1987) | `teste_Chow.pdf` (`1_k-SeJGSX-efcfF508KyysrSBSrIoVE2`) | Mecânica do teste e graus de liberdade (k e n1 + n2 − 2k; aqui, 6 e 278). |

Observações:
- As aulas foram lidas em texto extraído pelo Drive; figuras e fórmulas em imagem não foram vistas. O limite FIV = 10 e as fórmulas gráficas dependem de conferência visual **[a confirmar]**.
- Os slides citam também Hoffmann e Vieira (1987), *Análise de regressão*, 2. ed., Hucitec. Não foi consultado e não entra no artigo.
- A aula de autocorrelação inclui o teste das carreiras; o professor orientou retirá-lo do trabalho (D-2026-11-23-01).

## 3. Dados públicos

| Dado | Endereço | Observação |
|---|---|---|
| Selic (série 4390) | https://api.bcb.gov.br/dados/serie/bcdata.sgs.4390 | Conferido em 22/11/2026 (`fontes/VERIFICACAO_APIS.md`). |
| IPCA, variação mensal (série 433) | https://api.bcb.gov.br/dados/serie/bcdata.sgs.433 | Idem. |
| PIB dos Municípios e VAB (SIDRA, tabela 5938) | https://sidra.ibge.gov.br/tabela/5938 | Variáveis 498 e 517 usadas; ver `VERIFICACAO_APIS.md`. Ano da publicação **[a confirmar]**. |
| RAIS, microdados públicos (Ministério do Trabalho) | ftp://ftp.mtps.gov.br/pdet/microdados/RAIS/ | Arquivos `PR<ano>.7z` (2012, 2017) e `RAIS_VINC_PUB_SUL.7z` (2018 a 2021). |
| Malha municipal (IBGE) | https://servicodados.ibge.gov.br/api/v3/malhas/estados/41?intrarregiao=municipio | Usada nos centroides (distância). |
| Localidades (RMC, código 05501) | https://servicodados.ibge.gov.br/api/v1/localidades/ | Endereço exato do endpoint **[a confirmar]** no `R/01_extracao_dados.R`. |

Datas de acesso dos dados (necessárias para a NBR 6023): **[a confirmar]**; a extração está em cache em `dados_brutos/`. Conferir as datas de gravação dos `.rds`.

## 4. Caso de Adrianópolis: fábrica de cimento (Secil Supremo)

Usado em: `fontes/ADRIANOPOLIS_PESQUISA.md`, artigo (§3.3 e §6) e slides 24 e 25. A hipótese de que a fábrica explique o salto da participação industrial em 2015 é **plausível e não confirmada**.

| Fonte | Link | O que traz | Estado |
|---|---|---|---|
| Agência Estadual de Notícias do Paraná (AEN), inauguração | https://arquivo2011.aen.pr.gov.br/sites/default/arquivos_restritos/files/documento/migrados/1712_adrianopolis_pos_e.doc | Governador na inauguração em 17/12/2015; capacidade de 1,7 milhão de t/ano; investimento de R$ 200 milhões. | Data e valores segundo a busca; o `.doc` não foi lido por inteiro. **[a confirmar título e data no documento]** |
| AEN, documentos relacionados | https://arquivo2011.aen.pr.gov.br/sites/default/arquivos_restritos/files/documento/migrados/1611_cimento_e.doc ; https://arquivo2011.aen.pr.gov.br/sites/default/arquivos_restritos/files/documento/migrados/2010_cimenteira_e.doc ; https://arquivo2011.aen.pr.gov.br/sites/default/arquivos_restritos/files/documento/migrados/0412_supreme_cimentos_e.doc | Anúncios e etapas do projeto (nomes de arquivo indicam 16/11, 20/10 e 04/12; anos **[a confirmar]**). | Não lidos. |
| Brasil Engenharia, 18/12/2015 | https://brasilengenharia.com/portal/noticias/noticias-da-engenharia/15035-secil-inaugura-fabrica-de-cimento-mais-moderna-do-brasil?format=pdf | Inauguração no dia 18/12; capacidade de cerca de 1,8 milhão de t/ano; investimento de R$ 800 milhões; 1.500 trabalhadores na obra. | Segundo a busca. |
| Brasil Engenharia, obra | https://brasilengenharia.com/portal/noticias/destaque/9376-nova-fabrica-de-cimentos-em-adrianopolis-pr-vai-produzir-1-milhao-de-toneladas-ao-ano?format=pdf | Anúncio da fábrica. | Citado em `ADRIANOPOLIS_PESQUISA.md`. |
| AECweb | https://www.aecweb.com.br/revista/noticias/nova-fabrica-de-cimentos-em-adrianopolis-pr-deve-gerar-mais-de-mil-empregos/8429 | Previsão de mais de mil empregos. | Não lido. |
| Cemnet | https://cemnet.com/home/tags/Supremo Cimentos | Data de 23/12/2015 para a abertura. | Diverge da AEN (17/12) e da Brasil Engenharia (18/12). |
| Global Energy Monitor | https://www.gem.wiki/SECIL_Companhia_Geral_de_Cal_e_Cimento_Adrianópolis_Cement_Plant | Ficha da unidade. | Fonte secundária. |
| Brasil de Fato, 05/10/2023 | https://www.brasildefato.com.br/2023/10/05/moradores-de-adrianopolis-pr-denunciam-supremo-secil-cimentos-por-poluicao-e-estragos-em-casas | Denúncia de moradores sobre poluição e danos em casas. | Citado no artigo (§3.3 e referências). |
| Gazeta do Povo, 2017 | https://www.gazetadopovo.com.br/economia/cimenteira-anuncia-nova-fabrica-no-parana-com-investimento-de-r-915-milhoes-ed15u7ai6prbamer3htk31o3y | Anúncio de nova fábrica no Paraná (R$ 915 milhões); não confirmado que seja a mesma. | Apoio. |

Divergências encontradas entre as fontes: data da inauguração (17, 18 ou 23/12/2015), capacidade (1,7 ou 1,8 milhão de t/ano) e investimento (R$ 200 milhões ou R$ 800 milhões). O artigo usa apenas "dezembro de 2015".

## 5. Pacotes de R

As referências dos pacotes saem de `citation("pacote")` com as versões de `envio_professor/documentacao/ambiente_r.csv`. **[a inserir]** se o professor pedir.

## 6. O que ainda falta

- Literatura sobre salário, estrutura produtiva, capital humano e Selic: nenhuma referência de periódico foi conferida (seção 2 do artigo). Cabe ao pesquisador escolher.
- Editora de Hoffmann (2006), datas de acesso dos dados e títulos dos documentos da AEN.
- Edição de Gujarati: decidir entre citar a 4ª edição (PDF local) ou a 5ª, usada nas aulas.
