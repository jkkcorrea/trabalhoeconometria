# Leia primeiro: regras para usar IA neste projeto

Este arquivo vale para qualquer IA (Claude Code, ChatGPT, Gemini, Copilot) e para qualquer colega. Se você é uma IA, leia este arquivo inteiro antes de responder e siga as regras abaixo. Se você é uma pessoa, cole o conteúdo deste arquivo no começo da conversa com a IA, ou peça a ela que o leia.

## 1. O projeto em quatro linhas

Salário médio real formal nos 29 municípios da Região Metropolitana de Curitiba, de 2012 a 2021 (290 observações). Regressão linear múltipla por mínimos quadrados empilhados, com ln(salário real) como variável dependente e cinco explicativas: proporção com ensino superior (X2), dominância industrial (X3), diversificação setorial (X4), Selic real (X5) e distância a Curitiba (X6). Trabalho de Econometria I, UFPR. Resumo de uma página: `SUMARIO_DO_PROJETO.md`.

## 2. Regras que não têm exceção

1. **Número só entra se estiver nos arquivos.** Todo número, p-valor, coeficiente, tamanho de amostra ou nome de variável usado em texto ou slide vem de `envio_professor/documentacao/` ou de `envio_professor/resultados_econometricos/`. Se não estiver lá, escreva `[a confirmar]` e não invente.
2. **O código manda.** Se o texto disser uma coisa e o código ou o CSV de resultado disser outra, o texto está errado. Corrija o texto, nunca o resultado.
3. **Não invente interpretação.** Sinal esperado, hipótese, teoria e conclusão são do pesquisador. Onde faltar, escreva `[PESQUISADOR: definir]`.
4. **Não invente referência.** Cite apenas obras que o pesquisador forneceu ou que você conferiu na fonte. Referência não conferida leva `[a confirmar]`.
5. **Não altere resultado para o texto ficar melhor.** Se um resultado é fraco (por exemplo, p-valor perto de 5%), o texto diz que é fraco.
6. **Não edite `envio_professor/` à mão.** Ela é gerada por `bash _Trilha/ferramentas/reconstruir_envio.sh`.
7. **Não coloque senha, token ou chave de API em arquivo, chat ou commit.**
8. **Não rode `R/01_extracao_dados.R`** (baixa cerca de 3,5 GB) nem consulte o `basedosdados` sem autorização do responsável.

## 3. Como pedir cada tarefa

| Quero | Arquivo que a IA deve ler | Quem faz |
|---|---|---|
| Montar o artigo seção por seção | `instrucoes_ia/PROMPT_ARTIGO.md` | agente `construtor-artigo` |
| Montar os slides | `instrucoes_ia/PROMPT_SLIDES.md` | agente `designer-storytelling-slides` |
| Conferir se um texto bate com o código | `instrucoes_ia/VERIFICACAO_CONTEUDO.md` | qualquer IA |
| Formatar em ABNT | skill `formatacao-abnt` | qualquer IA |
| Seguir a estrutura de artigo da UFPR | skill `estrutura-artigo-ufpr` | qualquer IA |
| Entender o projeto rápido | `SUMARIO_DO_PROJETO.md` e `CATALOGO_DO_PROJETO.md` | qualquer IA |

No Claude Code, as skills e os agentes ficam em `.claude/skills/` e `.claude/agents/` e são carregados sozinhos quando a sessão abre nesta pasta (agentes novos só aparecem depois de recarregar a sessão). Em outra IA, peça: "Leia o arquivo `.claude/skills/<nome>/SKILL.md` e siga as instruções dele".

## 4. Antes de entregar qualquer texto ou slide

Rode a conferência de `instrucoes_ia/VERIFICACAO_CONTEUDO.md` e mostre o resultado ao colega. Texto sem conferência não é entregue.

Conferência automática de números (R, na raiz do projeto):

```
Rscript _Trilha/ferramentas/conferir_numeros.R caminho/do/rascunho.md
```

## 5. Ao terminar: atualize o repositório (git push)

Todo trabalho só conta quando está no repositório https://github.com/jkkcorrea/trabalhoeconometria. **A IA deve lembrar o colega disso ao fim de cada tarefa.** O fluxo completo está em `CONTRIBUIR.md`. Em resumo:

```bash
git checkout main && git pull origin main         # antes de começar
git checkout -b ajuste/nome-curto                  # um branch por tarefa
# ... trabalho e conferência ...
git status                                         # só os arquivos esperados
git add arquivo1 arquivo2                          # por nome, nunca "git add ."
git commit -m "Descreve o que mudou"
git push -u origin ajuste/nome-curto               # envia o branch
```

Depois abra o pull request no GitHub e peça revisão. Não faça push direto na `main` e nunca use `git push --force`. A IA não faz commit nem push sozinha: ela lembra, e o colega executa ou autoriza.

## 6. Onde registrar o que foi decidido

Decisão do pesquisador vai literalmente em `_Trilha/DECISOES.md` (formato `D-AAAA-MM-DD-NN`). Pendência vai em `_Trilha/BACKLOG.md`. Decisão que ficou só no chat não vale.
