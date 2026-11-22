# Salário médio real formal na Região Metropolitana de Curitiba, 2012 a 2021

Trabalho de Econometria I (UFPR). Regressão linear múltipla sobre um painel de 29 municípios em 10 anos (290 observações): ln do salário médio real formal explicado por ensino superior (X2), dominância industrial (X3), diversificação setorial (X4), Selic real (X5) e distância a Curitiba (X6).

## Estado

Projeto concluído em 21/11/2026, com a pasta `envio_professor/` pronta para o professor e verificada. A redação do artigo, os sinais esperados das variáveis e a escolha final do modelo de referência cabem ao pesquisador (ver "O que cabe ao pesquisador").

## Estrutura

| Caminho | Conteúdo |
|---|---|
| `R/` | Scripts numerados (com comentários de trabalho). `00_executar_tudo.R` roda 02 a 08 em ordem. |
| `dados_brutos/`, `dados_processados/` | Dados de entrada e painel final. |
| `resultados_econometricos/`, `figuras_graficos/` | Saídas dos scripts. |
| `envio_professor/` | Pasta pronta para envio: scripts sem comentários de processo, dados, resultados, figuras, documentação e `LEIAME.md`. Gerada e verificada; não se edita à mão. |
| `_Trilha/` | Decisões (`DECISOES.md`), pendências (`BACKLOG.md`), handoffs, ferramentas e arquivos obsoletos. |
| `.claude/` | Skills `storytelling-graficos` e `professor-econometria` e o agente `professor-econometria`. |
| `CLAUDE.md` | Regras do projeto para a sessão de trabalho. |

## Scripts

| Script | Função |
|---|---|
| `01_extracao_dados.R` | Coleta (SIDRA, Banco Central, IBGE, RAIS). Download de cerca de 3,5 GB. |
| `02_tratamento_painel.R` | Painel e variáveis do modelo. |
| `03_aede_visualizacoes.R` | Gráficos, mapas numerados e animações (exige `gifski`, que exige Rust). |
| `04_modelagem_diagnosticos.R` | Modelos 1, 2, 3 e 3b, diagnósticos, erros robustos, simulação. |
| `05_robustez_mundlak.R` | Mundlak, autocorrelação em painel, Modelos 3c e 4. |
| `06_calibracao_modelo.R` | Testes de efeito de município, estimadores com efeito de município, bootstrap wild cluster. |
| `07_memorial_modelo_2.R` | Memorial matricial do Modelo 2 com quatro casas decimais. |
| `08_fragilidades_modelo.R` | Forma funcional, sensibilidade da Selic, exogeneidade, Chow, Box-Cox, decomposição da Selic real. |

## Ferramentas (`_Trilha/ferramentas/`)

| Ferramenta | Função |
|---|---|
| `limpar_comentarios.R` | Gera a versão dos scripts sem comentários de processo. |
| `gerar_documentacao.R` | Gera `envio_professor/documentacao/` a partir dos CSV de resultado. |
| `verificar_envio.R` | Verificação independente da pasta de envio (recomputa painel e resultados, reexecuta tudo em cópia limpa). |
| `reconstruir_envio.sh` | Reconstrói a pasta de envio do zero: limpeza, pipeline, documentação e verificação. |
| `gerar_catalogo.R` | Gera `CATALOGO_DO_PROJETO.md` a partir das pastas reais. |
| `conferir_numeros.R` | Confere se os números de um rascunho (artigo, slides) aparecem nos resultados e na documentação. |

Para refazer a entrega depois de qualquer mudança nos scripts: `bash _Trilha/ferramentas/reconstruir_envio.sh`.

## Instruções para IA, skills e agentes

| Arquivo | Função |
|---|---|
| `SUMARIO_DO_PROJETO.md`, `CATALOGO_DO_PROJETO.md` | Entrada rápida e catálogo gerado. |
| `instrucoes_ia/LEIA_PRIMEIRO.md` | Regras para qualquer IA e qualquer colega, com o lembrete de `git push`. |
| `instrucoes_ia/PROMPT_ARTIGO.md` | Roteiro para construir o artigo seção por seção (sem texto pronto). |
| `instrucoes_ia/PROMPT_SLIDES.md` | Roteiro, paleta e regras de leitura para os slides. |
| `instrucoes_ia/VERIFICACAO_CONTEUDO.md` | Conferência obrigatória do texto contra o código. |
| `.claude/agents/construtor-artigo.md`, `designer-storytelling-slides.md`, `professor-econometria.md` | Agentes. |
| `.claude/skills/` | `formatacao-abnt`, `estrutura-artigo-ufpr`, `economia-de-tokens`, `maximizacao-de-contexto`, `sumario-do-projeto`, `boas-praticas-programacao`, `escrita-cientifica`, `diagramacao-projeto`, `storytelling-graficos`, `professor-econometria`. |

## Ambiente

Linux, R 4.6.2, pacotes na biblioteca do usuário (versões em `envio_professor/documentacao/ambiente_r.csv`), Rust (`rustup`) em `~/.cargo` para compilar o `gifski`. O `fwildclusterboot` não existe mais no CRAN; o bootstrap wild cluster é implementação própria.

## Resultado em uma frase

O MQO empilhado (linha de base) é rejeitado por Mundlak, Hausman e pelo teste de efeitos individuais; com efeitos fixos, o efeito de X2 cai de 0,0159 para 0,0086 e o de X3 deixa de ser significativo; a Selic real fica na fronteira de 5% conforme o procedimento de inferência. Detalhes em `envio_professor/documentacao/00_resumo.md`.

## O que cabe ao pesquisador

1. Redigir o artigo (introdução, revisão, interpretação, conclusão).
2. Definir e fundamentar os sinais esperados de X2 a X6 (nenhum arquivo traz hipótese prévia de sinal; a correção do professor apontou isso).
3. Modelo principal: Mundlak; MQO empilhado como linha de base; efeitos fixos como robustez (D-2026-11-22-01).
4. Decidir sobre a discussão dos limites dL e dU do Durbin-Watson, que não foram usados (n = 290).
