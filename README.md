# Salário médio real formal na Região Metropolitana de Curitiba, 2012 a 2021

Trabalho de Econometria I (UFPR). Regressão linear múltipla sobre um painel de 29 municípios em 10 anos (290 observações): ln do salário médio real formal explicado por ensino superior (X2), dominância industrial (X3), concentração setorial pelo Gini (X4), Selic real (X5) e distância a Curitiba (X6).

## Escopo

Só métodos das fontes oficiais da disciplina (`fontes/OFICIAL_FONTES_DA_DISCIPLINA.md`). Decisão D-2026-11-22-02. Os métodos fora desse escopo foram removidos do projeto.

## Estado

Pasta `envio_professor/` regenerada e verificada (17 de 17). Antes de escrever o artigo, faltam decisões do pesquisador (ver "O que cabe ao pesquisador"). A avaliação como professor está em `_Trilha/AVALIACAO_PROFESSOR_20261122.md`.

## Estrutura

| Caminho | Conteúdo |
|---|---|
| `R/` | Scripts numerados. `00_executar_tudo.R` roda 02 a 07 em ordem. |
| `dados_brutos/`, `dados_processados/` | Dados de entrada e painel final. |
| `resultados_econometricos/`, `figuras_graficos/` | Saídas dos scripts. |
| `envio_professor/` | Pasta de envio: scripts sem comentários de processo, dados, resultados, figuras, documentação e `LEIAME.md`. Gerada e verificada; não se edita à mão. |
| `fontes/` | Fontes oficiais, IDs no Drive, referências baixadas e tabela de verificação das APIs. |
| `instrucoes_ia/` | Roteiros para o artigo e os slides, e o roteiro original do PowerPoint. |
| `_Trilha/` | Decisões, pendências, handoffs, ferramentas e a avaliação como professor. |
| `.claude/` | Skills e agentes. |
| `CLAUDE.md` | Regras do projeto para a sessão de trabalho (seção 13: escopo ensinado). |

## Scripts

| Script | Função |
|---|---|
| `01_extracao_dados.R` | Coleta (SIDRA, Banco Central, IBGE, RAIS). Download de cerca de 3,5 GB. Só roda com `INCLUIR_EXTRACAO=sim`. |
| `02_tratamento_painel.R` | Painel e variáveis, com o Gini setorial como X4. |
| `03_aede_visualizacoes.R` | Figuras, mapas numerados e animações (exige `gifski`, que exige Rust). |
| `04_modelagem_diagnosticos.R` | Modelos 2, 3 e 3b; erro clássico e de White; VIF; Breusch-Pagan-Godfrey; Goldfeld-Quandt; ANOVA. |
| `05_autocorrelacao_municipios.R` | Durbin-Watson, ρ e Breusch-Godfrey por município. |
| `06_especificacao_chow.R` | RESET, LM de tendência, Chow por período, inferência agregada de X5 e X6 e checagem do Gini. |
| `07_memorial_modelo_2.R` | Memorial matricial do Modelo 2 com quatro casas decimais. |

## Ferramentas (`_Trilha/ferramentas/`)

| Ferramenta | Função |
|---|---|
| `limpar_comentarios.R` | Gera a versão dos scripts sem comentários de processo. |
| `gerar_documentacao.R` | Gera `envio_professor/documentacao/` e o `LEIAME.md` a partir dos CSV. |
| `verificar_envio.R` | Verificação independente: recalcula por álgebra matricial e pelas fórmulas ensinadas, e confere se os métodos removidos não voltaram. |
| `reconstruir_envio.sh` | Reconstrói a pasta de envio do zero: limpeza, pipeline, documentação, verificação e zip. |
| `gerar_catalogo.R` | Gera `CATALOGO_DO_PROJETO.md`. |
| `conferir_numeros.R` | Confere se os números de um rascunho aparecem nos resultados. |

Para refazer a entrega: `bash _Trilha/ferramentas/reconstruir_envio.sh`.

## Ambiente

Linux, R 4.6.2, pacotes em `envio_professor/documentacao/ambiente_r.csv`. Rust (`rustup`) em `~/.cargo` para compilar o `gifski`.

## Resultado em uma frase

No Modelo 2, com erro de White, X2 (+0,0150), X3 (+0,0055) e X4 (−0,6548) são significativos a 5%; a Selic e a distância dependem de como se trata a estrutura de 290 observações; RESET rejeita a forma log-linear e Durbin-Watson mostra autocorrelação positiva em 14 de 29 municípios. Detalhes em `envio_professor/documentacao/00_resumo.md`.

## O que cabe ao pesquisador

1. Definir hipóteses e sinais esperados de X2 a X6 antes de escrever a metodologia.
2. Decidir a leitura da X4: diversidade setorial (sinal invertido) ou outra medida de concentração.
3. Decidir o estatuto da Selic (X5): associação não significativa fora da amostra de 290 observações, ou retirada do modelo principal.
4. Decidir como tratar a forma funcional, rejeitada pelo RESET.
5. Aceitar ou tratar a autocorrelação positiva dentro dos municípios, sem correção ensinada aplicável ao painel.
6. Redigir o artigo (introdução, revisão, interpretação, conclusão).
