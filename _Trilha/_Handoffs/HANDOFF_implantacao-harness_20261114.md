<!-- frente=implantacao-harness | estado=Concluída | data=2026-11-14 -->

# Handoff da frente de implantação do harness (14/11/2026)

## O que foi feito

A sessão implantou na pasta o harness leve próprio do projeto, conforme a decisão D-2026-11-14-01. O harness SANEPAR não foi copiado: os ganchos do perfil já rodam nesta pasta, o lembrete de estilo dispara a cada mensagem e o gancho de abertura fica mudo por estar fora da árvore do contrato.

## Arquivos gravados

- `CLAUDE.md`: núcleo do projeto, derivado de `instrucoes-claude-opus.md`, com regra de integridade factual, precedência, mapa das quatro etapas e rito de continuidade.
- `.claude/settings.json`: memória automática desligada; o estado do projeto vive na `_Trilha`.
- `.gitignore`: pronto para quando o git for instalado.
- `_Trilha/BACKLOG.md`, `_Trilha/DECISOES.md` e este handoff.

Os cinco arquivos de origem não foram editados.

## Pendências

Os sete itens do BACKLOG, dos quais os itens 1, 2 e 6 bloqueiam a Etapa 1.

## Próximo passo

O pesquisador resolve os itens 1, 2 e 6 do BACKLOG; em seguida, a sessão escreve `R/01_extracao_dados.R`.
