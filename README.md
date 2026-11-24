# Salário médio real formal na Região Metropolitana de Curitiba, 2012 a 2021

Trabalho de Econometria I (UFPR). Regressão linear múltipla sobre um painel de 29 municípios em 10 anos (290 observações): ln do salário médio real formal explicado por ensino superior (X2), dominância industrial (X3), concentração setorial pelo Gini (X4), Selic real (X5) e distância a Curitiba (X6).

## Escopo

Só métodos ensinados em Econometria I. Dummies de município, painel (efeitos fixos, Hausman, Mundlak), Prais-Winsten e Newey-West no painel, análise de influência e teste das carreiras estão fora do escopo, por orientação do professor. Shapiro-Wilk e gráfico Q-Q para normalidade. Gini (X4) pela fórmula de Hoffmann (2006, cap. 17), em revisão até as aulas sobre o índice.

## Estado

Pasta `envio_professor/` regenerada e verificada (29 de 29). Modelo principal: MQO empilhado com erros de White. Pendências em `_Trilha/BACKLOG.md`.

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
| `01b_extracao_pam.R` | Produção agrícola (PAM). Não é mais usada no painel; fica no projeto como registro e não vai à pasta de envio. |
| `02_tratamento_painel.R` | Painel e variáveis, com o Gini setorial como X4. |
| `03_aede_visualizacoes.R` | Figuras, mapas numerados e animações (exige `gifski`, que exige Rust). |
| `04_modelagem_diagnosticos.R` | Modelo principal (MQO empilhado); erro clássico e de White; FIV; Breusch-Pagan-Godfrey; Goldfeld-Quandt; Shapiro-Wilk e Q-Q. |
| `05_autocorrelacao_municipios.R` | Durbin-Watson e Breusch-Godfrey por município (testes paramétricos). |
| `06_especificacao_chow.R` | Gráfico das variáveis no tempo; RESET; LM de tendência; Chow (corte de 2017 pelo gráfico, e 2016 para comparação); robustez do Gini; projeção de 2021 com correção de viés exp(s²/2); efeito da Selic. |
| `07_memorial_modelo_2.R` | Memorial matricial do modelo principal com quatro casas decimais. |

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

No modelo principal (MQO empilhado, erro de White), escolaridade (+0,0150), industrialização (+0,0055), Gini (−0,6548) e Selic (+0,0065) rejeitam H0 a 5% com os sinais esperados; a distância (−0,0016) também. Ressalvas: o Gini e a distância perdem a significância quando se controla o porte do município (ln dos vínculos ativos), e as observações de um município não são independentes (73% da soma de quadrados dos resíduos está entre municípios). RESET rejeita a forma linear, Shapiro-Wilk rejeita a normalidade, e Durbin-Watson indica autocorrelação positiva em 14 de 29 municípios. Detalhes em `envio_professor/documentacao/00_resumo.md`.

## O que cabe ao pesquisador

1. Responder ao professor (ver `RESPOSTA_AO_PROFESSOR.txt`) e aguardar as aulas sobre o Gini.
2. Decidir o recorte temporal (2012 a 2021, ou outro, com as implicações em `_Trilha/DECISOES.md`).
3. Decidir o tratamento da forma funcional (RESET) e da normalidade, se o professor indicar.
4. Redigir o artigo (introdução, revisão, interpretação, conclusão).
