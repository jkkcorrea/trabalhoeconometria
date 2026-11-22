---
name: sumario-do-projeto
description: Use para entender o projeto em um minuto, ou para atualizar SUMARIO_DO_PROJETO.md e CATALOGO_DO_PROJETO.md depois de mudanças. Define o que o sumário contém, como regenerar o catálogo e como evitar que ele fique desatualizado.
---

# Sumário e catálogo do projeto

## Para entender o projeto
Leia `SUMARIO_DO_PROJETO.md` (uma página: pergunta, dados, modelo, resultados-chave, estrutura, como rodar, regras). Para achar um arquivo, use `CATALOGO_DO_PROJETO.md`.

## Para atualizar
1. Rode `Rscript _Trilha/ferramentas/gerar_catalogo.R` (na raiz). Ele reescreve `CATALOGO_DO_PROJETO.md` a partir das pastas reais. Não edite o catálogo à mão.
2. `SUMARIO_DO_PROJETO.md` é escrito à mão e curto. Atualize só estes pontos quando mudarem: período e N, variáveis, modelo de referência, resultados-chave (copiados de `documentacao/00_resumo.md`), lista de scripts, pendências abertas.
3. Todo número do sumário vem de `envio_professor/`; confira com `Rscript _Trilha/ferramentas/conferir_numeros.R SUMARIO_DO_PROJETO.md`.

## Regras do sumário
- Cabe em uma tela e meia. Linguagem direta. Sem interpretação teórica.
- Sempre aponta para o arquivo de detalhe; não duplica tabelas.
- Traz a data da última atualização.

## Quando atualizar
Depois de mudar resultado, script, variável, estrutura de pastas ou decisão vigente; e antes de abrir um pull request que mexa nisso.

Ao terminar: lembre o colega de enviar o trabalho ao repositório (branch próprio, commit, `git push -u origin <branch>`, pull request; ver `CONTRIBUIR.md`). Não faça o push sozinho.
