---
name: maximizacao-de-contexto
description: Use em sessões longas ou quando o contexto da IA estiver enchendo: o que carregar primeiro, o que manter fora, como resumir e passar o bastão (handoff) sem perder decisões, e como retomar uma sessão.
---

# Maximizar o contexto útil

Contexto é limitado. O objetivo é que ele contenha só o que muda a próxima resposta.

## 1. Abertura de sessão (ordem fixa)
1. `CLAUDE.md` (carregado sozinho no Claude Code) e `instrucoes_ia/LEIA_PRIMEIRO.md`.
2. `SUMARIO_DO_PROJETO.md`.
3. Handoff mais recente em `_Trilha/_Handoffs/` e `_Trilha/BACKLOG.md`.
4. Só então os arquivos da tarefa, por trecho.

## 2. Mantenha dentro
Decisões vigentes (`_Trilha/DECISOES.md`, só as linhas relevantes), a especificação do modelo, o dicionário de variáveis, a lista de pendências e o arquivo em edição.

## 3. Mantenha fora (consulte sob demanda)
Dados, GIFs, PDFs, saídas longas, scripts inteiros, logs. Guarde o caminho, não o conteúdo.

## 4. Divida o trabalho
Uma sessão por frente (artigo, slides, código, verificação). Tarefa grande vira etapas curtas, cada uma terminando com saída gravada em arquivo. Exploração ampla vai para subagente, que devolve resumo com caminhos e valores.

## 5. Resumir sem perder
Ao resumir, preserve sempre: pedido do colega (literal), decisões e quem as tomou, arquivos criados ou alterados (caminhos), números já conferidos com a fonte, erros encontrados e a correção, pendências e o próximo passo. Descarte: tentativas fracassadas já resolvidas, saídas longas, texto repetido.

## 6. Passagem de bastão
Quando o colega disser "fechar a sessão" ou "handoff", grave `_Trilha/_Handoffs/HANDOFF_<frente>_<AAAAMMDD>.md` no formato do `CLAUDE.md` (seção 10), com: o que foi feito, arquivos gravados, decisões, pendências e próximo passo. O próximo colega começa por esse arquivo.

## 7. Sinais de contexto cheio
Respostas que repetem o que já foi dito, esquecimento de decisão, números que mudam entre mensagens. Nesse caso: grave o estado em arquivo, resuma e retome a partir dos arquivos.

Ao terminar: lembre o colega de enviar o trabalho ao repositório (branch próprio, commit, `git push -u origin <branch>`, pull request; ver `CONTRIBUIR.md`). Não faça o push sozinho.
