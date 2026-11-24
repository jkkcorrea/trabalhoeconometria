# BACKLOG do Trabalho de Econometria

Pendências abertas do projeto. Item resolvido é marcado com `- [x]`, a data e a decisão que o resolveu em `_Trilha/DECISOES.md`. Os itens 1 a 5 vieram da leitura dos cinco arquivos de origem na implantação do harness, em 14/11/2026, e precisam ser resolvidos antes da etapa indicada em cada um.

## Antes da Etapa 1

- [x] **1. Lista dos 29 municípios da RMC.** Baixado em 15/11/2026 pela decisão D-2026-11-15-01: a conferência na API de localidades do IBGE achou 12 códigos que não correspondem ao nome escrito ao lado, além de Jaguariaíva fora da região; vale a lista oficial do IBGE, transcrita na seção 6 do `CLAUDE.md`. Texto original do item: A lista dos arquivos de origem inclui Jaguariaíva (4112108), que pela referência do Claude não integra a RMC, e não inclui Tunas do Paraná, que integra `[a confirmar contra a lista oficial da RMC]`. Há também suspeita de códigos IBGE trocados: os arquivos atribuem 4104204 a Campo do Tenente, 4104253 a Campo Largo e 4104303 a Campo Magro, enquanto pela referência do Claude 4104204 é Campo Largo, 4104253 é Campo Magro e 4104303 é Campo Mourão `[a confirmar na tabela de códigos do IBGE]`. Recomendação: fixar a lista canônica por decisão e fazer o script da Etapa 1 conferir código e nome pela malha do `geobr`, interrompendo se houver divergência.
- [x] **2. Códigos das séries do SGS do Banco Central.** Baixado em 15/11/2026 pela decisão D-2026-11-15-02: confirmado que a série 432 é a meta Selic do Copom e que a 433 é a variação mensal do IPCA; a série 189 devolve variações mensais diferentes das do IPCA, logo não é o número-índice do IPCA (o nome dela segue `[a confirmar]`, sem efeito, porque não será usada). Valem as séries 4390 e 433 compostas no ano, com deflator pela média anual. Texto original do item: Pela referência do Claude, a série 432 é a meta Selic definida pelo Copom (% a.a.), e não a Selic acumulada no ano; a série 433 é a variação mensal do IPCA (% a.m.), e não a acumulada no ano; a série 189 é o IGP-M mensal, e não o número-índice do IPCA `[a confirmar no SGS]`. Se os códigos dos prompts forem seguidos sem conferência, o deflacionamento do salário e a Selic real (X5) sairão errados.
- [x] **6. Custo do `basedosdados`.** Baixado em 15/11/2026 pela decisão D-2026-11-15-03: a RAIS vem dos microdados públicos do Ministério do Trabalho, sem conta Google; o endereço de download e o tamanho dos arquivos seguem `[a confirmar]` na escrita do script da Etapa 1. Texto original do item: A opção primária da RAIS consulta o BigQuery do Google Cloud, que exige `billing_id` e pode gerar cobrança. Decidir se a coleta usa essa opção (com o projeto de faturamento do pesquisador) ou parte direto para a alternativa via `ipeadatar` ou tabelas agregadas.

## Antes da Etapa 2

- [x] **3. Nome do painel mestre.** Baixado em 16/11/2026 pela decisão D-2026-11-16-01: `dados_painel_rmc.rds`, com cópia `dados_painel_rmc.csv`. Texto original do item: `instrucoes-claude-opus.md` chama o painel de `dados_rmc.rds`; os prompts 2, 3 e 4 usam `./dados_processados/dados_painel_rmc.rds`. Recomendação: `dados_painel_rmc.rds`, já usado por três dos quatro arquivos.
- [x] **4. Dicionário de variáveis.** Baixado em 16/11/2026 pela decisão D-2026-11-16-02: valem os nomes do prompt 3, mais `salario_medio_nominal`, `salario_medio_real` e `dummy_curitiba`, com X2 em percentual de 0 a 100; o dicionário completo está na decisão e na seção 6 do `CLAUDE.md`. Texto original do item: As Etapas 3 e 4 usam nomes diferentes para as mesmas variáveis: `ln_salario_real` e `salario_real`; `prop_superior` e `escolaridade_sup`; `dom_industrial` e `dom_industria`; `shannon_diversificacao` e `shannon_div`; `dist_curitiba_km` e `dist_curitiba`. Sem um dicionário único gravado pela Etapa 2, os scripts 3 e 4 falham na leitura do painel. Recomendação: fixar os nomes por decisão antes de escrever o script da Etapa 2.

## Antes da Etapa 4

- [x] 16/11/2026 **5. Pontos metodológicos para o pesquisador decidir.** Resolvido pelas decisões D-2026-11-16-08 (testes do prompt mais erros agrupados por município), 09 (Modelo 3 e Modelo 3b com interação), 10 (sem efeitos fixos), 11 (multicolinearidade decidida pelo fator de inflação da variância) e 12 (cenários da simulação). Registro original: (a) O painel empilhado tem 29 municípios em T anos; Durbin-Watson e Newey-West pressupõem uma única ordenação temporal, e no painel empilhado a passagem de um município para o seguinte entra no cálculo como se fosse defasagem. Alternativa a considerar: erros padrão agrupados por município (`sandwich::vcovCL`) ao lado dos exigidos pela disciplina. (b) O Modelo 3 é descrito no prompt 4 como "com interação espacial", mas a equação dele não tem termo de interação; decidir se o termo entra e qual é. (c) X5 varia só no tempo e X6 só entre municípios; ambos entram no modelo empilhado sem efeito fixo, o que é coerente com a especificação, mas impede incluir efeitos fixos de ano ou de município sem retirar X5 ou X6. (d) Fato apurado na Etapa 2, em 16/11/2026: a correlação de Pearson entre a diversificação setorial (X4) e a distância a Curitiba (X6) é de -0,74 no painel, a maior entre as explicativas; o fator de inflação da variância na Etapa 4 dirá se o par compromete a estimação.

## Abertos na escrita da Etapa 1 (15/11/2026)

- [x] **8. Teste do script `R/01_extracao_dados.R`.** Baixado em 15/11/2026: a RAIS de 2012 a 2021 foi extraída e consolidada em `dados_brutos/rais.rds`, com 290 linhas município-ano (29 municípios em 10 anos), nenhum valor ausente e 13.882 linhas por divisão de atividade econômica. Os vínculos ativos na RMC variam entre 1,21 e 1,32 milhão por ano e a proporção com ensino superior sobe de 24,9% (2012) para 30,4% (2021). Na primeira rodada, a leitura de 2021 falhou porque o R não conseguiu mapear na memória o arquivo extraído de 6 GB; o script ganhou a leitura em blocos como alternativa automática, o teste em 2012 mostrou que ela devolve exatamente as mesmas 2.131.904 linhas da leitura direta, e 2021 rodou depois pela leitura direta em processo novo do R. Os arquivos compactados da RAIS (cerca de 3,5 GB) ficam em `%LOCALAPPDATA%/trabalho_econometria_rais`, fora do OneDrive. Texto anterior do item: O script foi escrito e o R o lê sem erro de sintaxe, mas ainda não rodou. A execução instala pacotes do CRAN (sidrar, rbcb, geobr, sf, fs, archive, data.table, tibble) na biblioteca do usuário e baixa os dados; só a RAIS soma cerca de 3,5 GB, guardados fora do OneDrive. As chamadas de pacote marcadas `[a confirmar]` no script só se confirmam nessa execução. Andamento em 15/11/2026: com autorização do pesquisador, os pacotes foram instalados na biblioteca do usuário e o teste parcial rodou PIB (290 linhas), Selic e IPCA (120 meses; IPCA anual de 2012 a 2021 coerente com os números oficiais conhecidos) e malha (29 municípios). O geobr 2.1.0 falhou com "arquivo corrompido no download", e o script passou a usar, nesse caso, a malha oficial da API de malhas do IBGE. Falta rodar a RAIS (cerca de 3,5 GB de download).
- [x] **12. VAB da indústria negativo em Araucária.** Baixado em 16/11/2026 pela decisão D-2026-11-16-06: o painel mantém o valor do SIDRA, marca as duas observações na coluna `x3_negativo`, e a Etapa 4 estima o modelo principal também sem elas. Na conferência de 16/11/2026, X3 de Araucária ficou em -14,1% (2012), -5,2% (2013) e 19,1% (2014), contra 50% a 65% de 2015 a 2021; nenhuma outra das 290 observações saiu da faixa de 0 a 100. Texto original do item: O SIDRA traz VAB da indústria negativo para Araucária (4101804) em 2012 (-560.800 mil reais) e 2013 (-246.380 mil reais). O dado é da fonte, não erro de extração, mas faz X3 (dominância industrial) sair negativo nesses dois anos. Decidir na Etapa 2 se mantém o valor, trata como observação atípica ou usa outra definição.
- [x] **9. Ponto de referência da distância (X6).** Baixado em 16/11/2026 pela decisão D-2026-11-16-03, que mandou usar o marco zero só com coordenada de fonte oficial e, sem ela, o centroide. Verificação da condição em 16/11/2026: o serviço de marcos geodésicos do IPPUC (geoapp.ippuc.org.br/marcosgeodesicos) carrega a página, mas a camada de dados (geo.ippuc.org.br, serviço MapaMarcosGeodesicos) respondeu com erro 500 a toda consulta, e a pasta pública de monografias dos marcos não lista arquivos; as coordenadas achadas estão só em fontes não oficiais (Wikipédia e Wikimapia). Coordenada oficial não localizada nessas fontes, nessa data; vale o centroide, e as distâncias gravadas em 15/11/2026 permanecem. Texto original do item: O script mede a distância até o centroide do polígono de Curitiba. O prompt 1 fala em "marco zero de Curitiba (Praça Tiradentes)"; trocar exige a coordenada do marco zero, que não foi conferida. Decidir antes da Etapa 2.
- [x] **10. Denominador da proporção de superior (X2).** Baixado em 16/11/2026 pela decisão D-2026-11-16-04: X2 divide os vínculos com superior pelos vínculos ativos com escolaridade informada. Texto original do item: A RAIS gravada traz o total de vínculos ativos e também os vínculos com escolaridade ignorada. Decidir se X2 divide os vínculos com superior pelo total de ativos ou só pelos ativos com escolaridade informada. Decidir antes da Etapa 2. Fato apurado na extração de 15/11/2026: nenhum vínculo ativo dos 29 municípios tem escolaridade ignorada em nenhum ano de 2012 a 2021, então os dois denominadores dão o mesmo número nesse período; a decisão só tem efeito se 2022 entrar.
- [x] **11. Ano de 2022.** Baixado em 16/11/2026 pela decisão D-2026-11-16-07, que superou a D-2026-11-16-05: o período volta a 2012 a 2021, com 290 observações, porque o IBGE não publicou o valor adicionado municipal de 2022. Os arquivos consolidados de 2012 a 2021 voltaram a `dados_brutos/`; os de 2012 a 2022 ficaram guardados em `dados_brutos/_periodo_2012_2022`, e a RAIS de 2022 continua em `dados_brutos/rais_2022.rds`, para o caso de o IBGE publicar o dado que falta. Histórico: decidido em 16/11/2026 pela decisão D-2026-11-16-05 (incluir 2022), mas a execução esbarrou em lacuna da fonte. A extração de 16/11/2026 gravou 2012 a 2022: a RAIS de 2022 saiu completa (29 municípios, 1.354.954 vínculos ativos, nenhum com escolaridade ignorada), a Selic e o IPCA de 2022 também (12,38% e 5,78% no ano), e os anos de 2012 a 2021 saíram idênticos aos da extração anterior, guardada em `dados_brutos/_periodo_2012_2021`. O SIDRA, porém, devolve o PIB de 2022 e 2023 e marca com "..." (dado não disponível) os impostos e todos os valores adicionados desses dois anos, consultados para Curitiba e para os 29 municípios; a tabela 5938 é a única de PIB municipal por setor no catálogo de tabelas do IBGE. Sem o valor adicionado de 2022, X3 (dominância industrial) não existe para esse ano. Fonte alternativa conferida em 16/11/2026, com autorização do pesquisador: o arquivo `base_de_dados_2010_2023_txt.zip` (7,4 MB), publicado pelo IBGE em 23/12/2025 em ftp.ibge.gov.br/Pib_Municipios/2022_2023/base/. Para 2010 a 2021 ele traz os oito valores (quatro VAB setoriais, VAB total, impostos, PIB e PIB per capita), e os de Curitiba em 2021 batem com o SIDRA; para 2022 e 2023, as 399 linhas do Paraná trazem só o PIB e o PIB per capita. O valor adicionado municipal de 2022 não está publicado em nenhuma das duas fontes do IBGE nessa data. Nova decisão do pesquisador pendente: manter 2022 sem X3 ou voltar a 2012 a 2021. Texto original do item: O SIDRA tem PIB municipal até 2023 e o FTP tem a RAIS de 2022; os dois estão consolidados. O script usa 2012 a 2021 por padrão e aceita 2022 mudando um parâmetro. Decidir o período antes de rodar a extração completa.

## Abertos na Etapa 2 (16/11/2026)

- [x] 21/11/2026 **13. Confirmar o total de divisões da CNAE 2.0.** Baixado em 21/11/2026: o handoff de 21/11/2026 registra a confirmação do total oficial (21 seções e 87 divisões, IBGE), e a RAIS gravada tem 87 divisões distintas, nenhuma com rótulo "ignorada" (verificações B4 e B10 do registro de verificação). Texto original: O `shannon_normalizado` divide pelo logaritmo de 87, o número de divisões distintas achadas na RAIS da região de 2012 a 2021. Que 87 é também o total oficial de divisões da CNAE 2.0 está `[a confirmar]` na documentação da Comissão Nacional de Classificação (CONCLA) do IBGE. Se o total oficial for outro, decidir qual número usar; o índice principal (X4) não muda.

## Abertos na Etapa 3 (16/11/2026)

- [x] 21/11/2026 **14. Acabamento das figuras.** Baixado em 21/11/2026 pela decisão D-2026-11-21-18: legendas e acabamento de todas as figuras refeitos e conferidos visualmente; a matriz de correlação já tinha sido refeita (D-2026-11-21-02) e a animação 2 trocada (D-2026-11-21-03).
- [x] 16/11/2026 **15. Inferência da Selic real e da indicadora de Curitiba na Etapa 4.** Apurado em 16/11/2026 e conferido por contraprova independente em R básico. (a) A Selic real (X5) muda só entre anos, com 10 valores distintos; o erro-padrão agrupado por município (0,00163) sai menor que o clássico (0,00209), porque esse agrupamento não capta a correlação entre municípios no mesmo ano. Para X5, o p-valor agrupado (6,1e-05) não é a medida adequada; o de Newey-West (0,0059) e o clássico (0,0016) também não tratam a dependência entre municípios. Alternativas a decidir: agrupar por ano (só 10 grupos, pouco confiável), agrupar nas duas dimensões, ou erros de Driscoll e Kraay `[a confirmar]` a disponibilidade em `sandwich::vcovPL`. (b) `dummy_curitiba` isola um município, os resíduos de Curitiba somam zero e as matrizes robustas ficam pouco confiáveis nessa direção; o teste F robusto dos Modelos 3 e 3b sai inflado (por exemplo, 281,0 agrupado contra 95,4 clássico no Modelo 3). Decidir se o texto apresenta o F clássico para esses modelos ou só registra a ressalva.

## Abertos em 21/11/2026

- [x] 21/11/2026 **16. Renderizar as animações (gifski).** Baixado em 21/11/2026 pela decisão D-2026-11-21-14: Rust instalado com autorização do pesquisador, `gifski` 1.32.0.2 compilado, as duas animações renderizadas e conferidas quadro a quadro; os `.gif` entram em `envio_professor/figuras_graficos/`. O `animacao2_dispersao_animada_industria_renda.gif` antigo continua em `figuras_graficos/` do projeto, obsoleto.
- [x] 21/11/2026 **17. Pasta `dados_brutos/_periodo_2012_2021` vazia.** Baixado em 21/11/2026: a pasta continua vazia e sem função; os arquivos ativos de `dados_brutos/` foram recomputados contra o painel (verificações B2 a B10) e nada em uso se perdeu. Não foi apagada.
- [x] 21/11/2026 **18. `CLAUDE.md` desatualizado.** Baixado em 21/11/2026 pela decisão D-2026-11-21-17: etapas 5 a 8, ambiente de 21/11/2026 e seção 11 acrescentados.
- [x] 21/11/2026 **19. Modelo de referência do artigo.** Delimitado em 21/11/2026 pela decisão D-2026-11-21-20 (`[presunção da modelagem]`): efeitos fixos para X2, X3 e X4, MQO empilhado como linha de base. O pesquisador pode reverter.
- [x] 21/11/2026 **20. Itens de calibração.** Baixado em 21/11/2026 pela decisão D-2026-11-21-19: (a) teste de Chow de Curitiba feito (F = 5,17; p = 0,0001); (b) RESET nos Modelos 3 e 3b feito (rejeita nas duas versões); (c) quadráticos, Box-Cox e ln dos vínculos feitos; (d) mínimos quadrados ponderados descartados, porque a variância cresce com o tamanho do município, o oposto do que o peso supõe; (e) `R/00_executar_tudo.R` criado e `LEIAME.md` na pasta de envio.
- [x] 21/11/2026 **21. Ferramentas de apoio.** Reunidas em `_Trilha/ferramentas/` (`limpar_comentarios.R`, `gerar_documentacao.R`, `verificar_envio.R`, `reconstruir_envio.sh`) e documentadas no `README.md`.

- [x] 21/11/2026 **22. Registro do agente `professor-econometria`.** O agente foi reconhecido e rodou na segunda e na terceira correção.
- [x] 21/11/2026 **23. Arquivos obsoletos do projeto.** Movidos (não apagados) para `_Trilha/_obsoletos/`: o `animacao2_dispersao_animada_industria_renda.gif` e os `*quatro_matrizes*`. `backup_antes_alteracoes/` e `dados_brutos/_periodo_2012_2022/` ficam como cache e backup.

- [ ] **24. Sinais esperados das variáveis (cabe ao pesquisador).** Aberto por natureza: é fundamentação teórica do artigo. A correção do professor apontou, nas duas rodadas, que nenhum arquivo traz o sinal esperado de X2 a X6; o sinal positivo da Selic real (0,0066 no MQO e 0,0040 com efeitos fixos) não é confrontado com hipótese prévia. A sessão não escreveu isso.
- [x] 21/11/2026 **25. Durbin-Watson com dL e dU.** Tratado como limitação documentada (limitação 12): n = 290 não consta nas linhas usuais das tabelas, a decisão usa o p-valor de `dwtest` (bilateral) e o memorial traz o passo a passo da estatística. Não foram inventados limites tabelados.

## Ferramentaria

- [x] 21/11/2026 **7. Git.** Baixado em 21/11/2026: git 2.43.0 instalado na máquina Linux; repositório local iniciado com o `.gitignore` do projeto (acrescido de `Trabalhos Referencias/`, `backup_antes_alteracoes/` e `envio_professor.zip`); remoto só por decisão do pesquisador. Texto anterior: Em 14/11/2026 o git não foi localizado no PATH nem nas pastas do Windows.

## Abertos em 21/11/2026 (instruções para colegas)

- [ ] **26. Conferir com o orientador** a edição da NBR 6022/14724/6023 e o template atual da UFPR (modelo lido é de 2016/2022; template de artigo de 2026/06 só listado); margens e fonte do artigo vêm da prática geral da ABNT `[a confirmar]`. Itens marcados `[a confirmar na norma]` em `.claude/skills/formatacao-abnt/SKILL.md`.
- [ ] **27. Testar os agentes novos** (`construtor-artigo`, `designer-storytelling-slides`) após recarregar a sessão; criar `artigo/` e `apresentacao/` quando os colegas começarem.

## Concluídos em 22/11/2026 (coerência do modelo e fontes)

- [x] 22/11/2026 **28. Coerência do modelo.** Mundlak confirmado como modelo principal (D-2026-11-22-01). Corrigido o denominador do F agrupado por município: era o gl residual (281 e 284) e passa a G - 1 = 28, como no t. Afetados: `teste_mundlak.csv` e `teste_f_global_robusto.csv`.
- [x] 22/11/2026 **29. Conferência das APIs.** SIDRA tabela 5938 (variáveis 37, 543, 498, 513, 517, 6575 e 525 conferidas na API); SGS 4390 e 433 (valor de jan/2019 conferido); localidades IBGE 05501 (29 municípios conferidos); endereço da RAIS no FTP do MTE (`PR<ano>.7z` em 2012 e 2017; `RAIS_VINC_PUB_SUL.7z` em 2018 a 2021). Registro em `fontes/VERIFICACAO_APIS.md`.
- [x] 22/11/2026 **30. Referências baixadas.** Shannon (1948), Cameron, Gelbach e Miller (2008, versão de working paper), Webb (2014, Queen's WP 1315) e Croissant e Millo (2008) em `fontes/livros_artigos/`. Os livros protegidos ficam para download do pesquisador.

## Pendências com ação humana (atualizado em 22/11/2026)

Concluídos pela sessão: hipóteses aprovadas (D-2026-11-22-03), autocorrelação aceita como limitação (D-2026-11-22-04), teste da Selic e da produção agrícola (`resultados_econometricos/comparacao_*.csv`), correção da entropia de Shannon (D-2026-11-22-05), leitura dos slides de `aulas`, produção agrícola coletada com cache (R/01b).

- [x] 22/11/2026 **C. Manter a Selic ou retirá-la.** Decidido: manter (D-2026-11-22-06). Projeção e efeito documentados. Retirar piora o ajuste (F = 26,7 no Modelo 4). Trocar pela produção agrícola não melhora (AIC −943,7 contra −969,1 com a Selic; coeficiente da produção negativo e não significativo). Recomendação: manter a Selic e declarar a inferência como limitação. Decisão do pesquisador.
- [ ] **D. Dummies de município no Modelo 4.** Os slides de `aulas` não trazem dummies, mas o trabalho de exemplo (seção 2.3), o Hoffmann (capítulo 5) e o Gujarati (capítulo 9) trazem (D-2026-11-22-07, mantidas). Falta a confirmação do professor. Se ele não aceitar, o modelo principal volta a ser o Modelo 2.
- [x] 22/11/2026 **F. Conferir dL = 0,243 e dU = 2,822.** Conferidos na Tabela D.5A do Gujarati (PDF p. 995), que coincide com a leitura por OCR. A tabela do Hoffmann começa em n = 15 e não serve.
- [ ] **G. Confirmar com o professor o n = 87 do Gini** e o tratamento das divisões como indivíduos (fórmula do Guia P2). Robustez calculada (`robustez_x4_definicao_gini.csv`): com as divisões ativas, o efeito dentro dos municípios deixa de ser significativo (p = 0,44); entre municípios o sinal se mantém. Decisão do pesquisador sobre qual definição usar.
- [ ] **H. Presunções a confirmar** (ver seção "Presunções" abaixo).
- [x] 22/11/2026 **I. Referências.** Gujarati (PDF da 4ª edição) conferido e registrado em `fontes/PAGINAS_DE_REFERENCIA.md` e em `fontes/VERIFICACAO_CORRECOES.md`. Único livro de Gujarati usado: 4ª edição (2004). Hoffmann (1987) não localizado.
- [ ] **J. Destino da pasta `backup_antes_alteracoes/`** (2,7 MB, fora do git) e de `Trabalhos Referencias/`. Mantidos (D-2026-11-22-08). Apagar exige pedido expresso.
- [ ] **K. Artigo**: só depois de C, D e H e da aprovação do pesquisador.

## Presunções (o que confirmar)

1. Ordenação do Goldfeld-Quandt pela distância e fração 0,2 central omitida.
2. Divisão do teste de Chow em 2012–2016 e 2017–2021 (o ano de corte é uma escolha).
3. Tratamento das 87 divisões CNAE como indivíduos no Gini.
4. Uso de dummies de município (item D).

## Pendências abertas (22/11/2026, rodada de testes e correções)

- [x] 22/11/2026 **L. Conferir Adrianópolis 2012 e a industrialização de 2015.** Conferido na API do SIDRA: iguais ao cache e ao publicado. Dado mantido com ressalva (D-2026-11-22-12). Causa econômica não documentada na fonte. Salto de 7% para 45% só nesse município; resíduo padronizado de −6,88. Conferir em `SIDRA 5938` (cache de `dados_brutos/pib_sidra.rds`) e corrigir se for erro de construção.
- [x] 22/11/2026 **M. Memorial matricial do Modelo 4 e de Prais-Winsten.** Feito em `R/07` (C14 e C15).
- [ ] **N. Confirmação do professor** (texto em `SOLICITACAO_AO_PROFESSOR.txt`): dummies de município; correção com ρ comum no painel; procedimento para normalidade rejeitada; limiares de influência; teste das carreiras com dez observações; Gini de 87 divisões; quebra de 2016; projeção com exp() sem correção.
- [x] 22/11/2026 **O. Edição do Gujarati.** Decidido usar só a 4ª edição (2004), PDF local com texto completo (D-2026-11-22-13). Outras edições não são usadas no trabalho.
- [x] 22/11/2026 **P. Modelo de referência.** Decidido: principal Modelo 4 com Prais-Winsten; referência Modelo 2 com Prais-Winsten (D-2026-11-22-12). Com Prais-Winsten, o Modelo 2 perde significância em X3 e X4. Decidir se o texto apresenta o Modelo 2 apenas como referência ou se X6 passa a ser estimada de outra forma.

## Pendências (23/11/2026)

Concluídos pela sessão: escopo ajustado à orientação do professor (D-2026-11-23-01); painel sem dummies; modelo principal MQO empilhado; Durbin-Watson e Breusch-Godfrey por município; Shapiro-Wilk e Q-Q; Chow pelo gráfico; projeção com correção de viés; documentação, README e verificação (22 de 22); Hoffmann cap. 17 conferido (D-2026-11-23-03); testes t e F recalculados.

- [x] 23/11/2026 **P1. Recorte temporal** (D-2026-11-23-02): mantido em 2012 a 2021; pontos de mudança em `REGISTRO_RECORTE_TEMPORAL.md`. Escolher entre 2012 a 2021 (atual), 2016 a 2025 com X3 trocada por emprego industrial, ou 2016 a 2021. A escolha afeta modelo, texto e números.
- [x] 23/11/2026 **P2. Gini (X4)** (D-2026-11-23-04): fechado conforme a aula e Hoffmann (2006, cap. 17). Definição: 87 divisões CNAE, zeros incluídos. Verificação complementar: só divisões com vínculo.
- [ ] **P3. Resposta do professor** sobre o tratamento da forma funcional (RESET rejeita) e da normalidade (Shapiro-Wilk rejeita), se ele orientar.
- [ ] **P4. CLAUDE.md** (seções 6 e 13 mencionam Mundlak, Prais-Winsten e Etapas 05 e 06 antigas). Atualizar só com pedido do pesquisador, por ser arquivo de instruções.
- [ ] **P5. Causa do salto industrial em Adrianópolis (2015).** Não é bloqueante: o valor é o publicado pelo IBGE; a causa não está documentada.
- [ ] **P6. Edição do Gujarati.** Usamos só a 4ª edição (2004). Páginas da 5ª edição ficam como referência não conferida.
- [ ] **Q. Conferência manual de números da resposta.** A conferência automática (`conferir_numeros.R`) não encontra em CSV: mediana de 47,5 divisões com vínculo (calculada da RAIS), R$ 67,8 milhões (painel, `vab_industria` = 67.762 mil reais) e R$ -560,8 e -246,4 milhões (painel, em mil reais convertido para milhões). Conferidos manualmente nesta data.

## Atualização de 23/11/2026 (tarde)

Concluídos: Adrianópolis registrado com pesquisa na internet e conferência na RAIS (D-2026-11-23-06); rascunho do artigo e roteiro da apresentação (D-2026-11-23-07); Gini fechado conforme a aula e Hoffmann (D-2026-11-23-04); recorte mantido e registrado (D-2026-11-23-02); números do rascunho conferidos (6 sem origem em CSV, todos verificados à mão: páginas, conversão para milhões e 86/87).

Pendentes:
- [ ] **R1. Revisão do artigo pelo pesquisador**: interpretação teórica, conclusões, referências marcadas [a inserir] e resumo em inglês.
- [ ] **R2. Gerar o PowerPoint** a partir de `apresentacao/ROTEIRO_SLIDES.md`, depois de revisar o texto. Escolher as figuras dos slides 6 e 18 (numeração de 22 slides).
- [ ] **R3. Referências do artigo**: conferir a editora de Hoffmann (2006) e incluir a literatura sobre salário, estrutura produtiva e Selic (nenhuma foi conferida).
- [ ] **R4. Links das fontes do caso Adrianópolis**: confirmar o link exato da notícia da Agência Estadual de Notícias do Paraná (inauguração em 17/12/2015) e a data de início de produção da Secil.
- [ ] **R5. Causa do salto de Adrianópolis (2015)**: consultar a nota metodológica do IBGE para o VAB municipal de 2015 e verificar o VAB de construção. Não bloqueante.
- [x] 23/11/2026 **R6. Resposta ao professor**: enviada (o comentário do professor responde a ela). Arredondamentos menos precisos (W = 0,862; p = 0,001) ficam como estão.
- [ ] **R7. CLAUDE.md** (seções 6 e 13) e prompts originais: atualizar só com pedido do pesquisador (P4 acima).

## Atualização de 23/11/2026 (noite): comentário do professor e referências

Concluídos pela sessão: referências conferidas e arquivo `fontes/REFERENCIAS.md` criado, com os links da fábrica de Adrianópolis (R4, parcial: o `.doc` da AEN não foi lido por inteiro); aulas de Hasegawa citadas (D-2026-11-23-09); autoria do Gujarati corrigida (4ª edição, só Gujarati, 2003); editora de Hoffmann (2006) levantada em catálogos (R3, parcial); resumo em inglês incluído (revisar); metodologia detalhada, estrutura da revisão e da discussão e contribuição candidata no artigo v2 (D-2026-11-23-08); artigo v2 e roteiro para o time (`apresentacao/CONTEXTO_PARA_O_TIME.md`); registro das pendências do professor (`_Trilha/REGISTRO_PENDENCIAS_PROFESSOR.md`).

Abertos:
- [ ] **B1. Revisão da literatura (seção 2)**: o pesquisador escolhe, lê e registra as obras (candidatas em `_Trilha/AVALIACAO_COMENTARIO_PROFESSOR_20261123.md`). Bloqueia B3 e B4.
- [ ] **B3. Discussão dialogando com a literatura (seção 6)**: depende de B1.
- [ ] **B4. Contribuição (seções 6.7 e 7)**: o pesquisador confirma as candidatas.
- [ ] **B5. Pontos da resposta ao professor** explicados no texto: metodologia redigida; faltam as justificativas que cabem ao pesquisador (itens A1 a A7).
- [x] 23/11/2026 **B6. Slides**: slides de literatura (3) e de contribuição (19) acrescentados com marcações; preencher depois de B1 e B4.
- [ ] **B7. Conferências menores**: limite FIV = 10 no slide de multicolinearidade (texto em imagem); editora de Hoffmann (2006); título e data do `.doc` da AEN; datas de acesso dos dados; edição de Gujarati (aulas citam a 5ª).
- [ ] **R6 (atualizado)**: o comentário do professor indica que a resposta foi enviada; o pesquisador confirma.
- [ ] **B8. Porte do município e H3 (23/11/2026, noite).** A correção como professor apontou, e eu conferi no painel: correlação do Gini com ln(vínculos ativos) = −0,88; com esse controle, Gini = +0,2579 (p = 0,1293) e distância = −0,0007 (p = 0,1748); sem Araucária 2012 e 2013, Gini = −0,4992 (p = 0,0001). Verificações incluídas em `R/06` (`robustez_porte_e_negativos.csv`) e no artigo (TABELA 6). Decisão do pesquisador e do professor: manter o modelo principal como está ou incluir o porte (item A8 de `_Trilha/REGISTRO_PENDENCIAS_PROFESSOR.md`).
- [ ] **B9. Conferências abertas da correção como professor.** Teste de White ausente (só Breusch-Pagan e Goldfeld-Quandt); erro de White não trata a dependência dentro do município (a Selic tem 10 valores anuais e a distância 29); F geral e intervalos da previsão são clássicos; ANOVA e F incremental só no envio, não no artigo; `00_executar_tudo.R` não roda `01b_extracao_pam.R` e o painel carrega colunas da PAM sem uso.
- [x] 23/11/2026 **Correções de texto da correção como professor**: períodos do Chow (corte em 2017 = 2012 a 2017 contra 2018 a 2021; linha do gráfico corrigida para 2017,5), descrição do Breusch-Godfrey (constante e resíduo defasado), p = 0,0011 e W = 0,8618, referências internas retiradas do corpo do artigo, H0 do documento de métodos sem "controlados os efeitos comuns".


## Pendências consolidadas no fechamento de 23/11/2026

Lista completa e ordem de ataque em `_Trilha/_Handoffs/HANDOFF_artigo-slides_20261123.md`. Em aberto: A1 a A8 (professor); B1, B3, B4 e B5 (pesquisador: literatura, discussão, contribuição e justificativas); B7 (referências a conferir); B8 e B9 (porte do município e conferências técnicas); R1 a R5 e R7 (artigo, PowerPoint, literatura, links e causa de Adrianópolis, `CLAUDE.md`).

## Plano para a nota 100 (registrado em 23/11/2026)

Detalhe por critério, ganhos e ordem em `_Trilha/PLANO_PARA_NOTA_100.md`. Base: 69/100 pela régua; 55 a 60 efetiva sem literatura e discussão. Teto realista dentro do escopo: cerca de 92 a 95 (estimativa).

- [ ] **N1. Decidir A8 (porte do município) com o professor.** Define H3, o modelo principal e tudo que depende dele.
- [ ] **N2. Revisão da literatura e fundamentação dos sinais H1 a H5** (critério 1 e peso real do professor). Pesquisador.
- [ ] **N3. Decidir o papel da Selic (H4):** fundamentar ou tratar como controle macro. Pesquisador e professor.
- [ ] **N4. Reespecificação para o RESET** (termos quadráticos de X2 e X3, por exemplo) e novo RESET. Código; professor aprova (A2).
- [ ] **N5. Teste de White** e Goldfeld-Quandt ordenado por outras variáveis; discutir a divergência com o Breusch-Pagan (critério 6).
- [ ] **N6. F geral robusto e intervalos da previsão com a matriz de White** (critério 4); reescrever H4 com a ressalva da Selic (10 valores).
- [ ] **N7. Durbin-Watson com resíduos centrados por município**, limite do dL e dU com k = 5, e a explicação 14 × 3 (critério 7). Conferir a afirmação do agente (mediana 1,16; 1 município abaixo de dL), que não foi verificada.
- [ ] **N8. Exame de resíduos** (por município e por variável) para localizar as caudas (assimetria 1,74; curtose 8,52) (critério 8).
- [ ] **N9. Parágrafo de endogeneidade** (simultaneidade, variável omitida, medição) na discussão (critério 9).
- [ ] **N10. Apêndice do artigo com ANOVA, F incremental, determinação parcial e resumo de (X'X)⁻¹**; quatro casas em todo o texto (critério 3).
- [ ] **N11. PAM:** tirar as colunas do painel final ou incluir `01b_extracao_pam.R` no `00_executar_tudo.R` (critérios 2 e 10).
- [ ] **N12. Verificador:** incluir os novos arquivos de saída e reconstruir o envio (22 de 22 ou mais).
- [ ] **N13. Discussão com a literatura, contribuição e considerações finais.** Pesquisador.
- [ ] **N14. Slides finais, formatação no template UFPR/ABNT e limpeza das marcações.**
- [ ] **N15. Nova correção com o agente `professor-econometria`** depois de cada bloco; registrar a nova nota aqui.

## Execução do plano para a nota 100: pacote técnico (24/11/2026)

- [x] 24/11/2026 **N4. Reespecificação para o RESET** (`R/06`, `reespecificacao_forma_funcional.csv`, TABELA 7). Resultado: o RESET ainda rejeita em todas as versões; o porte do município reduz o F de 14,49 para 3,98; o Gini perde a significância e muda de sinal. A decisão de qual versão é a principal continua aberta (A8).
- [x] 24/11/2026 **N5. Teste de White e Goldfeld-Quandt por outras variáveis** (`R/04`, `testes_heterocedasticidade_complementares.csv`). White rejeita (p < 0,0001); Goldfeld-Quandt rejeita ordenado por X3 (p = 0,0134, após trocar o bilateral pelo unilateral do livro) e não rejeita pelas demais; a divergência com o Breusch-Pagan foi explicada.
- [x] 24/11/2026 **N6. F geral com erro de White e intervalos da previsão com a matriz HC1** (`f_geral_robusto.csv`, colunas `*_white` em `projecao_selic_m2.csv`). O H4 do artigo já traz a ressalva da Selic.
- [x] 24/11/2026 **N7. Durbin-Watson com resíduos centrados por município** (`R/05`). Confirmado: mediana 0,25 para 1,16; de 14 para 1 município abaixo de dL; 16 de 29 com resíduos de mesmo sinal; 72,9% da soma de quadrados entre municípios.
- [x] 24/11/2026 **N8. Exame de resíduos** (`diag7_residuos_vs_regressores.png`, `maiores_residuos.csv`). As maiores caudas são de Adrianópolis (2013 a 2015) e Araucária (2012 e 2013).
- [x] 24/11/2026 **N9. Parágrafo de endogeneidade** na seção 6.6 do artigo (revisar pelo pesquisador).
- [x] 24/11/2026 **N10. Apêndice C do artigo** com ANOVA, determinação parcial, FIV e F incremental.
- [x] 24/11/2026 **N11. PAM fora do painel e do envio** (`R/02`; `R/01b` fica só no projeto).
- [x] 24/11/2026 **N12. Verificador com 26 checagens** (novas C13 a C16: White, F robusto, DW centrado, reespecificação com porte); envio reconstruído e aprovado em 26 de 26.
- [x] 24/11/2026 **N15. Nova correção com o agente `professor-econometria`**: 85/100 (auditoria completa, números recalculados todos conferem). Corrigidos: referências de arquivo nos slides, ROTEIRO (H0 geral, H4, BG, Gujarati e Porter), página do BG (p. 501 do PDF), contagem de checagens (29).
- [ ] **N16. Abertos após a nota 85:** (a) previsão da Tabela 7 (média em reais) e IC do ponto médio (ln) são objetos diferentes: unificar ou explicar; (b) [feito 24/11/2026: citado como apud Hasegawa e fora da lista de referências] (c) [feito 24/11/2026: Bonferroni retirado e Goldfeld-Quandt unilateral como no livro; X3 p = 0,0134] ; (d) limpar marcadores internos ([revisar], caminhos _Trilha, nome e data do slide 1, editora) na versão final; (e) [feito 24/11/2026: ordem das figuras] (f) A8 (porte no modelo principal); literatura e discussão (pesquisador).
