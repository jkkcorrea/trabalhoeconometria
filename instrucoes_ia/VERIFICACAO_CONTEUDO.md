# Verificação: o texto bate com o código?

Instrução permanente para qualquer IA que escreva, revise ou resuma conteúdo deste projeto (artigo, slides, resumo, legenda, e-mail). Vale mesmo que o colega não peça. Se você é uma IA: execute esta lista sempre antes de entregar e mostre o resultado.

## Princípio

O código e os arquivos gerados por ele são a fonte. O texto é uma cópia. Toda divergência se corrige no texto.

## Fontes de verdade, da mais para a menos confiável

1. `envio_professor/resultados_econometricos/*.csv` e `envio_professor/dados_processados/*.csv` (saída direta dos scripts).
2. `envio_professor/R/*.R` (o que cada script de fato calcula).
3. `envio_professor/documentacao/*.md` (gerada a partir dos CSV e verificada; `08_verificacao.md` lista as conferências).
4. `CLAUDE.md`, `_Trilha/DECISOES.md` (decisões e escopo).

Nunca use como fonte: memória do modelo, número de conversa anterior, rascunho antigo.

## Lista de conferência (marque cada item)

**A. Números**
- [ ] Cada número do texto aparece em um CSV ou em `documentacao/`. Anote ao lado o arquivo de origem.
- [ ] Arredondamento e casas decimais seguem a fonte (quatro casas para coeficientes, como no memorial).
- [ ] Unidade e escala corretas: X2 e X3 em pontos percentuais (0 a 100), X5 em % a.a., X6 em km, Y em reais de 2021; o coeficiente é de ln(Y), então não é variação em reais.
- [ ] N correto: 29 municípios, 10 anos, 290 observações (ou o N do modelo em questão, por exemplo sem as observações de `x3_negativo`).
- [ ] p-valor atribuído à matriz de variância certa (clássica ou HC1). Dizer qual.

**B. Modelo e variáveis**
- [ ] Nome e definição das variáveis iguais às de `documentacao/01_dados_e_variaveis.md` e `dicionario_variaveis.csv`.
- [ ] O modelo citado é o principal (MQO empilhado, Modelo 2, com erro de White). Não há outros modelos no trabalho.
- [ ] Equação escrita igual à de `documentacao/02_especificacao_e_metodos.md`.

**C. Afirmações**
- [ ] Toda frase com "aumenta", "reduz", "significativo", "robusto" ou "causal" tem o resultado que a sustenta ou está marcada `[PESQUISADOR: definir]`.
- [ ] Nada de causalidade sem argumento: o desenho é observacional e `documentacao/06_limitacoes.md` lista os limites.
- [ ] Os limites relevantes aparecem no texto (ver `06_limitacoes.md` e `05_fragilidades.md`).
- [ ] Resultado frágil é dito como frágil (por exemplo, p-valor que muda de lado de 5% conforme a matriz).

**D. Figuras e tabelas**
- [ ] Cada figura citada existe em `envio_professor/figuras_graficos/` com o nome exato.
- [ ] O que o texto diz da figura é o que a figura mostra (olhe a imagem; não confie só no nome do arquivo).
- [ ] Fonte da figura ou tabela indicada ("O autor" quando for elaboração própria; fonte dos dados quando for o caso).

**E. Referências e citações**
- [ ] Toda obra citada está na lista de referências e vice-versa.
- [ ] Nenhuma obra foi inventada ou completada de memória; sem confirmação, `[a confirmar]`.

**F. Reprodutibilidade**
- [ ] Se o texto diz que algo foi rodado, existe script e saída para isso.
- [ ] Se um resultado mudou, os scripts foram rodados de novo: `bash _Trilha/ferramentas/reconstruir_envio.sh` termina com "N de N verificações aprovadas".

## Conferência automática de números

```
Rscript _Trilha/ferramentas/conferir_numeros.R rascunho.md
```

O script lê o rascunho, extrai os números e procura cada um nos CSV de resultados e nos `.md` de `documentacao/`. Ele lista os que não foram achados. Número listado não é necessariamente errado (pode ser ano, contagem, número de seção), mas precisa de explicação ou correção. O script não substitui as outras conferências da lista.

## Formato do relatório que a IA entrega

```
CONFERÊNCIA DE CONTEÚDO
Arquivo conferido: <nome>
Números conferidos: <n>; sem origem: <n> (lista)
Divergências com o código: <lista: trecho do texto | valor na fonte | arquivo>
Afirmações sem sustentação: <lista>
Figuras/tabelas: <ok ou lista>
Referências: <ok ou lista>
Marcas pendentes: [a confirmar] x<n>; [PESQUISADOR: definir] x<n>
Resultado: APROVADO / REPROVADO
```

## Ao terminar

Lembre o colega de enviar ao repositório (`git push` em branch próprio e pull request, conforme `CONTRIBUIR.md`). Não faça o push sozinho.
