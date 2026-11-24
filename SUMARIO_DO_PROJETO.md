# Sumário do projeto

Atualizado em 23/11/2026 (noite). Números vindos de `envio_professor/documentacao/00_resumo.md`.

## Pergunta e dados
Salário médio real formal (ln) de 29 municípios da RMC, 2012 a 2021: 290 observações (painel balanceado, empilhado).
Regressores: X2 escolaridade (superior completo, %), X3 industrialização (VAB da indústria / VAB total, %), X4 Gini setorial (vínculos entre 87 divisões CNAE, zeros incluídos), X5 Selic real (% a.a.), X6 distância a Curitiba (km).
Recorte temporal: 2012 a 2021, mantido. Registro de mudanças possíveis: `_Trilha/REGISTRO_RECORTE_TEMPORAL.md`.

## Modelo principal
MQO com as observações empilhadas, erros-padrão de White (HC1). Sem variáveis binárias de município e sem métodos de painel (orientação do professor, D-2026-11-23-01).

## Resultados-chave (erro de White)
- X2: +0,0150 (p < 0,0001). X3: +0,0055 (p < 0,0001). X4: −0,6548 (p = 0,0001). X5: +0,0065 (p = 0,0003). X6: −0,0016 (p = 0,0033).
- R² ajustado 0,6433; F geral 105,26 (gl 5 e 284).
- Diagnósticos: FIV máximo 2,33; Breusch-Pagan rejeita a homocedasticidade (p = 0,0363); RESET rejeita a forma linear (p < 0,0001); Shapiro-Wilk rejeita a normalidade (p < 0,0001); Durbin-Watson rejeita a ausência de autocorrelação positiva em 14 de 29 municípios; Chow não mostra quebra (corte em 2017, p = 0,146).
- Projeção de 2021 (previsão dentro da amostra), com correção de viés exp(s²/2) = 1,0075.

## Estrutura do projeto
| O que | Onde |
|---|---|
| Resumo para o professor (envio) | `envio_professor/documentacao/00_resumo.md` |
| Resposta ao professor (rascunho para envio) | `RESPOSTA_AO_PROFESSOR.txt` |
| Pasta de envio (gerada, não editar à mão) | `envio_professor/` (zip: `envio_professor.zip`) |
| Scripts de análise (fonte) | `R/00_executar_tudo.R` a `R/07_memorial_modelo_2.R` |
| Dados brutos (cache das APIs e da RAIS) | `dados_brutos/` |
| Painel e estatísticas | `dados_processados/` |
| Resultados (CSV) | `resultados_econometricos/` |
| Figuras | `figuras_graficos/` |
| Documentação gerada e verificação | `envio_professor/documentacao/` (gerador: `_Trilha/ferramentas/gerar_documentacao.R`) |
| Verificação independente | `_Trilha/ferramentas/verificar_envio.R` (resultado em `envio_professor/documentacao/08_verificacao.md`) |
| Decisões do pesquisador | `_Trilha/DECISOES.md` |
| Pendências | `_Trilha/BACKLOG.md` |
| Registro de mudanças do recorte | `_Trilha/REGISTRO_RECORTE_TEMPORAL.md` |
| Fontes, referências e páginas | `fontes/` (`PAGINAS_DE_REFERENCIA.md`, `VERIFICACAO_CORRECOES.md`, `VERIFICACAO_EDICOES.md`, `OFICIAL_FONTES_DA_DISCIPLINA.md`) |
| Guia para os colegas que vão revisar | `REVISAO_PELOS_COLEGAS.md` |
| Referências e links (lista central) | `fontes/REFERENCIAS.md` |
| Artigo (rascunho v2, ajustado ao comentário do professor) | `artigo/ARTIGO_rascunho_v2.md` (v1 fica como registro); versão publicada no Claude Docs |
| Apresentação (roteiro, fonte dos slides e contexto para o time) | `apresentacao/ROTEIRO_SLIDES.md`, `apresentacao/deck_fonte/project/`, `apresentacao/CONTEXTO_PARA_O_TIME.md` |
| Pendências que dependem do professor e comentário dele | `_Trilha/REGISTRO_PENDENCIAS_PROFESSOR.md`, `_Trilha/AVALIACAO_COMENTARIO_PROFESSOR_20261123.md` |
| Avaliações internas como professor | `_Trilha/AVALIACAO_PROFESSOR_*.md` (histórico) |
| Regras do projeto para sessões de IA | `CLAUDE.md` |
| Catálogo de arquivos (gerado) | `CATALOGO_DO_PROJETO.md` (gerador: `_Trilha/ferramentas/gerar_catalogo.R`) |
| Roteiros para o artigo e os slides | `instrucoes_ia/` |
| Arquivos de instruções originais (não editar sem pedido) | `prompt-*.md`, `instrucoes-claude-opus.md`, `roteiro_powerpoint.docx` |

## Como reproduzir
1. `Rscript R/00_executar_tudo.R` (a partir da raiz) roda os scripts 02 a 07.
2. Entrega completa: `bash _Trilha/ferramentas/reconstruir_envio.sh` (limpa, roda, gera documentação, verifica e gera o zip). A verificação atual passa em 22 de 22.

## Pendências (ver `_Trilha/BACKLOG.md`)
- Recorte temporal: mantido em 2012 a 2021; mudanças registradas no arquivo de registro.
- Tratamento da forma funcional (RESET) e da normalidade (Shapiro-Wilk), se o professor orientar.
- Causa do salto industrial de Adrianópolis em 2015 (não documentada na fonte).
- `CLAUDE.md` seções 6 e 13 ainda descrevem a versão anterior; atualizar só com pedido do pesquisador.

## Regras
- Dados brutos e cache não são apagados. Resultados obsoletos vão para `backup_antes_alteracoes/`.
- Livros e PDFs de terceiros não entram no repositório.
- Decisões ficam em `_Trilha/DECISOES.md` com identificador `D-AAAA-MM-DD-NN`.
