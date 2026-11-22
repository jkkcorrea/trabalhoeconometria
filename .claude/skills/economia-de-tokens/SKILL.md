---
name: economia-de-tokens
description: Use em qualquer tarefa neste projeto para gastar o mínimo de tokens sem perder precisão: ler só o necessário, buscar antes de abrir, não repetir saída, delegar leitura pesada e responder curto.
---

# Economia de tokens

## Antes de ler
1. Comece por `SUMARIO_DO_PROJETO.md` (uma página) e `CATALOGO_DO_PROJETO.md` (onde está cada arquivo). Eles evitam varrer a pasta.
2. Procure antes de abrir: busque o nome da variável, do teste ou do número (grep) e leia só o trecho achado (use faixa de linhas).
3. Para número de resultado, abra o CSV específico em `envio_professor/resultados_econometricos/`, não o script inteiro nem o `.rds`.

## Nunca leia sem necessidade
- `dados_brutos/`, `dados_processados/*.rds`, `*.gif`, `*.html` de tabela, `envio_professor.zip`, `backup_antes_alteracoes/`, `Trabalhos Referencias/` (PDFs).
- Scripts longos (`R/04` a `R/08`) por inteiro: leia o cabeçalho e a função que importa.
- Saída de console longa: filtre com `head`, `tail`, `grep` ou resuma com `dplyr`.

## Ao trabalhar
- Não releia arquivo que você acabou de editar nem repita código que já está no contexto.
- Reúna chamadas independentes na mesma rodada.
- Edite só o trecho que muda; não regrave o arquivo inteiro.
- Rode o R em lote (`Rscript`) e imprima só o que será conferido (`message()` curto).
- Leitura pesada ou exploratória (varrer muitos arquivos): delegue a um subagente e peça só a conclusão com caminhos e valores.
- Fatos já conferidos ficam registrados em arquivo (`_Trilha/_Insumos/`, `documentacao/`); consulte-os em vez de refazer a conferência.

## Ao responder
- Diga o resultado e o que o colega precisa decidir. Sem recapitular o que ele viu.
- Listas curtas, tabelas só quando comparam. Nada de elogio, de pedido de desculpa nem de repetição do pedido.
- Mostre o diff ou o caminho do arquivo, não o arquivo.

## Limite
Economia não vale contra a verificação: número de texto ou slide sempre é conferido na fonte (`instrucoes_ia/VERIFICACAO_CONTEUDO.md`).

Ao terminar: lembre o colega de enviar o trabalho ao repositório (branch próprio, commit, `git push -u origin <branch>`, pull request; ver `CONTRIBUIR.md`). Não faça o push sozinho.
