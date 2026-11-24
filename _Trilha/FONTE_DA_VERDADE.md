# Fonte da verdade do trabalho (eleita em 24/11/2026)

Regra: tudo que se afirma no artigo, nos slides, nos roteiros, na documentação e na resposta ao professor deve poder ser rastreado até uma das fontes abaixo, na ordem. Quando duas fontes divergem, vale a de nível mais alto, e o texto de nível mais baixo é que se corrige. Se o erro estiver no código, corrige-se o código, reconstrói-se a pasta de envio e regeneram-se todos os derivados.

## Níveis

| Nível | Fonte | Vale para | Onde está |
|---|---|---|---|
| 1 | **Código executado e seus resultados** | todo número, tabela, figura, decisão de teste, contagem | `R/` (scripts 02 a 07); saídas em `resultados_econometricos/`, `figuras_graficos/`, `dados_processados/`; cópia verificada em `envio_professor/` |
| 2 | **Material de aula do professor** | definição de cada método, H0 e Ha, regra de decisão, limite de bolso (FIV, zonas do Durbin-Watson), o que é ensinado (escopo) | slides de Hasegawa: multicolinearidade (2016a), heterocedasticidade (2016b), autocorrelação (2017), medidas de desigualdade (2020), especificação e diagnóstico (2022), Chow (2024); registro em `fontes/REFERENCIAS.md` e `fontes/OFICIAL_FONTES_DA_DISCIPLINA.md` |
| 3 | **Livros-base consultados** | páginas, tabelas (Durbin-Watson D.5A), fórmulas de apoio | Gujarati, *Basic econometrics*, 4. ed. (2003), PDF local, páginas do PDF; Hoffmann (2006), cap. 17 |
| 4 | **Dados públicos conferidos na origem** | origem e definição das séries | `fontes/VERIFICACAO_APIS.md` (BCB SGS 4390 e 433; SIDRA 5938; RAIS; IBGE) |
| 5 | **Decisões do pesquisador** | escolhas de modelagem e de escopo | `_Trilha/DECISOES.md` (em conflito com os níveis 1 a 4 sobre fato, vale o fato; sobre escolha, vale a decisão) |

Subordinados (nunca são fonte): `artigo/ARTIGO_rascunho_v2.md` e sua cópia no Claude Docs, slides (`apresentacao/deck_fonte/` e o artefato publicado), `apresentacao/*.md`, `envio_professor/documentacao/` (gerada por `_Trilha/ferramentas/gerar_documentacao.R`), `RESPOSTA_AO_PROFESSOR.txt`, `README.md`, `SUMARIO_DO_PROJETO.md`.

## Tipo de afirmação e fonte

| O texto afirma | Conferir em |
|---|---|
| coeficiente, erro-padrão, t, p-valor, IC, R² | `resultados_econometricos/coeficientes_modelos.csv` |
| teste de diagnóstico (BP, White, GQ, SW, RESET, Chow, DW, BG) | `testes_*.csv`, `normalidade_residuos.csv`, `especificacao_*.csv`, `chow_quebra_periodo.csv`, `autocorrelacao_*.csv` |
| memorial (ANOVA, F incremental, FIV, R² parcial) | `memorial_modelo_2_*.csv`, `f_incremental_robusto.csv`, `f_geral_robusto.csv` |
| robustez, porte, reespecificação | `robustez_*.csv`, `reespecificacao_forma_funcional.csv` |
| previsão de 2021 | `projecao_selic_m2.csv`, `previsao_media_2021.csv`, `efeito_selic_m2.csv` |
| estatística descritiva, N, correlação | `dados_processados/estatisticas_descritivas.csv`, painel |
| como o método funciona, H0, regra de decisão | aulas (nível 2); página do Gujarati (nível 3) |
| construção de cada variável | `R/02_tratamento_painel.R` (fórmula no código) |
| o que "pode ser usado" | escopo: só o que as aulas ensinam (`fontes/OFICIAL_FONTES_DA_DISCIPLINA.md`) |

## Como se confere

1. `Rscript _Trilha/ferramentas/verificar_envio.R`: recalcula em R base, sem usar os scripts entregues, os resultados do nível 1 e confere a documentação (28 checagens).
2. `bash _Trilha/ferramentas/conferir_derivados.sh`: extrai os números do artigo, dos slides e dos roteiros e procura cada um nas saídas do nível 1; o que não aparece precisa de explicação.
3. Leitura do agente `professor-econometria` (somente leitura) contra esta hierarquia.
4. Sincronia: o artigo no Claude Docs e o deck publicado devem ser iguais a `artigo/ARTIGO_rascunho_v2.md` e a `apresentacao/deck_fonte/`; o arquivo do repositório é a referência.

## Lacunas conhecidas da fonte da verdade

- Os slides de aula foram lidos em texto extraído; figuras e fórmulas em imagem não foram vistas.
- O Gujarati consultado é a 4ª edição (só Gujarati, 2003); as aulas citam a 5ª (com Porter, 2011). Páginas citadas são do PDF da 4ª.
- A `RESPOSTA_AO_PROFESSOR.txt` já foi enviada e não pode ser corrigida; divergências dela são registradas, não editadas.
