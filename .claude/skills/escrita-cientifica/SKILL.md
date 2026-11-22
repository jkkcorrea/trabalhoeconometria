---
name: escrita-cientifica
description: Use ao redigir ou revisar texto científico do artigo de Econometria: estrutura do parágrafo, clareza, voz, precisão numérica, linguagem de resultado (associação versus causa), apresentação de tabelas e limitações, e checagem de coerência entre seções.
---

# Boas práticas de escrita científica (artigo de Econometria)

## Clareza
- Frases de até 25 palavras, em ordem direta (sujeito, verbo, complemento). Voz ativa quando possível.
- Um parágrafo, uma ideia: abre com a afirmação, desenvolve com evidência, fecha ligando à próxima.
- Defina cada termo técnico e cada sigla na primeira vez. Use o mesmo nome para a mesma variável em todo o texto (o do `dicionario_variaveis.csv`).
- Corte advérbios de ênfase ("claramente", "evidentemente") e adjetivos sem medida.

## Precisão
- Todo número com unidade, N e origem. Coeficiente de modelo log-nível: variação aproximada de 100 × β por cento a cada unidade da explicativa; confirme a escala de cada variável antes de escrever a interpretação.
- Diga qual matriz de variância sustenta cada p-valor.
- Intervalo de confiança ao lado da estimativa pontual quando existir.
- Separador decimal: vírgula. Mesmo número de casas da fonte.

## Linguagem de resultado
- Desenho observacional: escreva "associa-se", "está associado", "é maior em". Evite "causa", "provoca", "determina", a menos que o desenho sustente.
- Significância estatística não é importância econômica: dê a magnitude.
- Resultado frágil (muda com a matriz, o estimador ou a amostra) é dito frágil e vai para a discussão.
- Não explique o que o dado não mostra. Hipótese entra como hipótese, com marca `[PESQUISADOR: definir]` se não for do pesquisador.

## Estrutura
- Introdução: problema, pergunta, contribuição, roteiro. Conclusão responde à pergunta, nada novo.
- Resultados descrevem; discussão interpreta; limitações vêm explícitas (`documentacao/06_limitacoes.md`).
- Cada tabela e figura é citada no texto antes de aparecer e vem com uma frase do que ver.

## Ética e fontes
- Cite quem fez; paráfrase não é cópia. Não copie texto de trabalhos de referência.
- Não invente obra, dado ou página. Sem conferência: `[a confirmar]`.
- Se usar IA para redigir, o autor responde pelo conteúdo e confere cada afirmação (`instrucoes_ia/VERIFICACAO_CONTEUDO.md`); declare o uso se a instituição ou o orientador exigir.

## Revisão em três passes
1. Conteúdo: pergunta respondida? cada afirmação tem sustentação?
2. Coerência: variáveis, N e notação iguais em todas as seções; resumo bate com resultados e conclusão.
3. Forma: cortar, simplificar, ABNT (skill `formatacao-abnt`), ortografia.

Ao terminar: lembre o colega de enviar o trabalho ao repositório (branch próprio, commit, `git push -u origin <branch>`, pull request; ver `CONTRIBUIR.md`). Não faça o push sozinho.
