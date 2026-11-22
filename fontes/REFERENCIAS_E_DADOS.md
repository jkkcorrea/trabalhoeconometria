# Fontes do projeto: livros, artigos, dados e modelos

Situação em 22/11/2026. Cada item tem um status:
- **No Drive**: arquivo da disciplina, em `Drive > Econometria`. Pode ser citado depois de conferido.
- **A verificar**: citado no código ou na documentação, mas ainda não conferido em fonte. Não entra no artigo como referência até o verificador de fontes confirmar (DOI ou página oficial).
- **Dado público**: origem dos dados brutos. Confirmar a URL e a data de acesso antes de citar.

Nenhum livro é baixado para esta pasta pelo Claude: o conteúdo é protegido por direito autoral. Para cada item, use o link para baixar com a sua conta, ou para consultar pela biblioteca da UFPR. Os arquivos ficam em `fontes/livros_artigos/` e não vão ao professor sem verificação de licença.

## 1. Material da disciplina no Drive (fonte de conhecimento do projeto)

| Arquivo | ID no Drive | Conteúdo declarado | Status |
|---|---|---|---|
| `Gujarati_Basic_Econometrics.pdf` | `1AGHwTDPs20RjdJbAINAyUnOkUJqz__z9` | Único livro de Gujarati usado no trabalho: Gujarati, D. N.; Porter, D. C. *Basic Econometrics*. 4ª ed. McGraw-Hill, 2004 (PDF único usado no projeto: `Gujarati_Basic_Econometrics.pdf`). Páginas conferidas no próprio PDF. | Na raiz do projeto e no Drive. |
| `se614_ideias_basicas_notas.pdf` | `1Zl1QAFc53M2fIg8z6B07qbP6m8N4wfP3` | Notas de aula de Hasegawa (UFPR, 2023): regressão com duas variáveis, Gujarati (2011, cap. 2) | No Drive. Citar as notas só como material de aula, se o professor aceitar. |
| `se614_ideias_basicas.pdf` | `1qvrw9MKHYHCs73Kqr4SO-WzWId9NzQMG` | Versão das ideias básicas | No Drive |
| `se614_rls_est.pdf` | `1le4NZeK-WlTvPF-qKa6ozetjM88vW-Fi` | Estimação em regressão linear simples | No Drive |
| `se614_rls_infer.pdf` | `12-dqnWOzvUSddOa1kZVEOwQwpNd3PHuv` | Inferência | No Drive |
| `se614_rls_notas.pdf` | `1AW2OOBdXCSg58wLX0gygLHeqFJGpmUSf` | Notas da regressão linear | No Drive |
| `reglinmult3.pdf` | `1t9zHS0E1EIlAOpa-m65iSPdM7fSEEabH` | Regressão linear múltipla | No Drive |
| `multicolinear.pdf` | `1cg_s5SrrDe5xA_IyB42Ph6_7QMIEntG6` | Multicolinearidade (usada para o critério FIV) | No Drive |
| `multicolinear-UFPR-PC.pdf` | `1UUhxVo-tYzQJbJlEhQx4f1gUgYzRM6Sj` | Multicolinearidade, versão UFPR | No Drive |
| `heterocedast.pdf`, `heterocedast2.pdf`, `heterocedast3.pdf` | `1cK-6ZxNTH-leP2QjteoLzO9kGbXRRptY`, `1DRrl8FfZ7Vd9bnmyl9ypMhr77igj4QEo`, `1xtec93xUIcPINJ_Nmn9ZtHfGJBogfawW` | Heterocedasticidade | No Drive |
| `autocorrel.pdf`, `autocorrel2.pdf`, `autocorrel3.pdf` | `1WYCarnorspho-VZzBH7UncPzT4azDAgo`, `1c6OSVgOAFZ6CD6URr7yiutUh9la6O9eh`, `1R9nKPGyqAPp8glJQCZfsbpofL_4HIirp` | Autocorrelação | No Drive |
| `teste_Chow.pdf` | `1_k-SeJGSX-efcfF508KyysrSBSrIoVE2` | Teste de Chow | No Drive |
| `especificao_diagnostico.pdf` | `14esRhmU2A667g_-gevQ2AcjC2eg2N38v` | Especificação e diagnóstico | No Drive |
| `se614_rls_infer_notas.pdf` | `1F_xagxtlAhE-lRdGtJmDR-gMb8yGjwoV` | Notas de inferência | No Drive |
| `Exercício Econometria.Rmd` e `Exercício_Econometria.html` | `1-IkU0E8gYgqF-oyKZRfZz6ZYALnqkBqf`, `1gynDCkUBqhU0OOo35dkT1gkq1Vg5mcCR` | Exercício resolvido | No Drive. Não citar como referência, só como exemplo. |
| Guia P2 (Google Doc) | `1Z8WubHPgJ3z9LmJC9CMbjqodpvmdRCEBnc1iVWEsdGs` | Roteiro de resolução da P2 (regra de correção) | No Drive. Usado pelo agente professor. |

Observação: a pasta do Drive tem várias cópias dos mesmos arquivos (mesmo nome, IDs diferentes). Usar sempre a cópia da pasta `Econometria` principal e registrar o ID escolhido.

## 2. Livros e artigos citados ou usados nos testes (a verificar)

Estes são os métodos e referências que aparecem em `R/` e em `envio_professor/documentacao/`. Nenhum deles foi conferido em fonte ainda. Cada entrada traz a página para busca. O verificador de fontes confirma o DOI ou a página oficial antes de qualquer citação.

| Referência (como aparece no projeto) | Usada para | Status | Página para conferir |
|---|---|---|---|
| Gujarati e Porter (2004, 4ª ed.) | Critério FIV > 10 (`R/07`) | Na raiz do projeto (livro) | Drive, item 1 |
| Wooldridge (2002) e (2010) | Teste de autocorrelação em painel (`R/05`); exogeneidade estrita (`05_fragilidades.md`) | A verificar | busca de DOI e ISBN a fazer |
| Cameron, Gelbach e Miller (2008) | Bootstrap wild cluster com pesos de Rademacher (`R/06`, `02_especificacao_e_metodos.md`) | A verificar | busca no Google Scholar a fazer |
| Webb (pesos de seis pontos) | Pesos de Webb no bootstrap (`R/08`) | A verificar (nome e ano não confirmados no código) | busca a fazer |
| Duan (1983) | Smearing de retransformação do log (`R/04`) | A verificar | busca a fazer |
| Mundlak (1978) | Estimador de Mundlak (`R/05`, `R/06`) | A verificar | busca a fazer |
| Hausman (1978) | Teste de Hausman (`R/06`) | A verificar | busca a fazer |
| Breusch-Pagan, Jarque-Bera, RESET, Box-Cox, Goldfeld-Quandt, Chow, Newey-West, White (HC1), Prais-Winsten | Diagnósticos e correções (`R/04` a `R/08`) | A verificar cada um. Os nomes estão nas notas da disciplina em parte, mas a data e a fonte primária precisam de conferência. | busca a fazer |
| Shannon (1948) | Índice de entropia (X4) | A verificar | busca a fazer |

Pacotes de R (`plm`, `sandwich`, `lmtest`, `car`, `gifski`, `sf`, etc.): as referências são obtidas com `citation("pacote")` no R, com as versões de `envio_professor/documentacao/ambiente_r.csv`. Essa conferência é feita pelo agente de fontes.

## 3. Dados de origem (fontes para a seção de dados)

| Dado | Origem declarada no projeto | Arquivo bruto | Status |
|---|---|---|---|
| PIB municipal e valor adicionado (VAB) por setor | IBGE, SIDRA (tabelas de contas municipais). Código da tabela: a confirmar na documentação do SIDRA. | `dados_brutos/pib_sidra.rds` | Dado público. Confirmar tabela e URL. |
| Selic (série 4390) e IPCA (série 433) | Banco Central do Brasil, SGS | `dados_brutos/macro_bacen.rds` | Dado público. Confirmar código de série no SGS. |
| Salário, vínculos, escolaridade e setor (RAIS) | Ministério do Trabalho, microdados públicos da RAIS | `dados_brutos/rais.rds` (dados brutos de cerca de 3,5 GB ficam fora do projeto) | Dado público. Confirmar URL e versão. |
| Malha municipal (polígonos) | IBGE, via pacote `geobr` | `dados_brutos/malha_rmc.rds` | Dado público. Confirmar versão da malha. |
| Distâncias ao centro de Curitiba | Calculadas a partir dos centroides da malha (EPSG 31982) | `dados_brutos/distancias.rds` | Cálculo próprio (`[presunção da modelagem]`, D-2026-11-16-03). |

Regra do projeto: não usar `basedosdados` (BigQuery pode gerar cobrança). Nenhuma consulta foi feita nesse pacote.

## 4. Modelos de documento

| Arquivo | Origem | Uso |
|---|---|---|
| `modelos_ufpr/template-artigo-de-periodico-ufpr_2026-06.doc` (e `.docx` convertido) | https://bibliotecas.ufpr.br/wp-content/uploads/2026/06/template-artigo-de-periodico.doc (link na página de normalização da UFPR) | Base do artigo. Ver `formatacao-abnt` para os parâmetros lidos do próprio template. |

## 5. Como a pasta vai ao professor

- `fontes/livros_artigos/`: somente os itens com licença permitida ao compartilhamento (por exemplo, trabalhos citados e listas de referência). Os livros protegidos ficam fora do envio.
- `fontes/dados/`: os cinco `.rds` de `dados_brutos/` e o painel, em CSV e RDS, com as referências de origem deste arquivo.
- `fontes/modelos_ufpr/`: template usado.

## 6. Atualização de 22/11/2026: downloads e páginas

### 6.1 Baixados para `livros_artigos/` (versões gratuitas e legais)

| Arquivo | Referência | Página de origem | Observação |
|---|---|---|---|
| `shannon_1948_teoria_matematica_comunicacao.pdf` | Shannon, C. E. (1948). A mathematical theory of communication. *Bell System Technical Journal*, 27(3), 379–423; 27(4), 623–656. DOI 10.1002/j.1538-7305.1948.tb01338.x (parte I) e 10.1002/j.1538-7305.1948.tb00917.x (parte II) | https://people.csail.mit.edu/dmoshkov/courses/codes/shannon1948.pdf | Cópia de reimpressão (55 páginas). Conferir com a edição do BSTJ. |
| `cameron_gelbach_miller_2008_nber_t0344.pdf` | Cameron, A. C.; Gelbach, J. B.; Miller, D. L. (2008). Bootstrap-based improvements for inference with clustered errors. *Review of Economics and Statistics*, 90(3), 414–427. DOI 10.1162/rest.90.3.414 | https://www.nber.org/papers/t0344.pdf | **Atenção:** o arquivo é a versão de *working paper* (64 páginas, de 2007), não a versão publicada. Citar a versão publicada e usar este arquivo só como apoio. |
| `webb_2014_reworking_wild_bootstrap_qed1315.pdf` | Webb, M. D. (2014). Reworking wild bootstrap based inference for clustered errors. Queen's Economics Department Working Paper, n. 1315 | https://ageconsearch.umn.edu/record/274640/files/qed_wp_1315.pdf | Working paper. Versão publicada não confirmada. |
| `croissant_millo_2008_plm_jss.pdf` | Croissant, Y.; Millo, G. (2008). Panel data econometrics in R: the plm package. *Journal of Statistical Software*, 27(2). DOI 10.18637/jss.v027.i02 | https://www.jstatsoft.org/article/view/v027i02 | Versão publicada (43 páginas). |
| `zeileis_2004_sandwich_jss.pdf` | Zeileis, A. (2004). Econometric computing with HC and HAC covariance matrix estimators. *Journal of Statistical Software*, 11(10). DOI 10.18637/jss.v011.i10 | https://www.jstatsoft.org/article/view/v011i10 | Versão publicada (21 páginas). |

### 6.2 Não baixados: páginas para você encontrar (acesso pago ou restrito)

| Referência | Página | Observação |
|---|---|---|
| Gujarati, D. N.; Porter, D. C. *Basic Econometrics*. 4ª ed. McGraw-Hill, 2004 (PDF único usado no projeto: `Gujarati_Basic_Econometrics.pdf`) | Drive: `Gujarati_Basic_Econometrics.pdf` (ID `1AGHwTDPs20RjdJbAINAyUnOkUJqz__z9`) | Único livro de Gujarati usado. Outros arquivos de Gujarati (edição em espanhol e versão em português sem texto) não são citados. |
| Wooldridge, J. M. *Econometric Analysis of Cross Section and Panel Data*. 2ª ed. MIT Press, 2010. ISBN 9780262232586 | https://mitpressbookstore.mit.edu/book/9780262232586 | Pago. Você tem acesso pela biblioteca da UFPR, se houver. |
| Mundlak, Y. (1978). On the pooling of time series and cross section data. *Econometrica*, 46(1), 69–85. DOI 10.2307/1913646 | https://www.econometricsociety.org/publications/econometrica/1978/01/01/pooling-time-series-and-cross-section-data | JSTOR (acesso pela UFPR). |
| Hausman, J. A. (1978). Specification tests in econometrics. *Econometrica*, 46(6), 1251–1271. DOI 10.2307/1913827 | https://www.econometricsociety.org/publications/econometrica/1978/11/01/specification-tests-econometrics | JSTOR (acesso pela UFPR). |

### 6.3 Não verificados nesta rodada

Duan (1983), Breusch-Pagan, Jarque-Bera, RESET, Box-Cox, Goldfeld-Quandt, Chow, Newey-West, White (1980), Prais-Winsten, Shannon ainda sem DOI conferido pelo agente. Todos continuam como "a verificar" na seção 2.

## 7. Métodos e disciplina (ponto de decisão)

O `roteiro_powerpoint.md` (instrucoes_ia/) diz: "Utilizar apenas métodos ensinados na disciplina. Uma metodologia não ensinada resulta em nota zero." A busca no Drive não encontrou Hausman, Mundlak, bootstrap wild cluster, Box-Cox ou Prais-Winsten no material das notas SE614. O Gujarati cobre a maior parte dos diagnósticos clássicos. Confirmar com o professor antes de escrever a metodologia.
