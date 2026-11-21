---
name: storytelling-graficos
description: Use ao criar, revisar ou melhorar gráficos estatísticos e mapas do Trabalho de Econometria (R, ggplot2) quando o objetivo é leitura humana. Orienta a escolher o tipo de gráfico, a montar a mensagem do título, a limpar o gráfico e a escrever legendas e notas de fonte objetivas.
---

# Storytelling com gráficos estatísticos (orientado à leitura humana)

Esta skill vale para as figuras de `R/03_aede_visualizacoes.R` e para qualquer
gráfico novo do projeto. O alvo é um leitor que tem pouco tempo e não conhece o
R: ele precisa entender a mensagem em poucos segundos e conferir o dado sem
esforço.

## 1. Antes de desenhar: uma mensagem por gráfico

1. Escreva a mensagem em uma frase, como afirmação verificável. Exemplo: "Os
   municípios com maior dominância industrial têm salário médio real mais
   alto." Se não houver mensagem, o gráfico é exploração e não entra no texto.
2. Decida o que o leitor deve comparar: níveis, variações, ordem, relação entre
   duas variáveis, distribuição ou composição.
3. Escolha o tipo pelo que se compara:

| Objetivo | Tipo recomendado | Evitar |
|---|---|---|
| Comparar valores entre categorias | barras horizontais ordenadas | pizza, 3D |
| Relação entre duas contínuas | dispersão com reta e intervalo | dispersão com cor e tamanho sem necessidade |
| Correlações entre muitas variáveis | mapa de calor em triângulo, sem asteriscos | matriz de pares com diagonal densa |
| Distribuição por grupo | densidades ou boxplots lado a lado | muitas curvas sobrepostas sem rótulo |
| Padrão espacial | mapa coroplético com escala fixa e número/legenda | escala de cor que muda por quadro |
| Evolução no tempo | linha por série ou animação com ordenação estável | animação que reordena tudo sem sentido |

## 2. Título, subtítulo e nota

- **Título**: a mensagem, não o nome da variável. "Salário real sobe com ensino
  superior em toda a RMC" é melhor que "Salário x ensino superior".
- **Subtítulo**: o que está sendo medido, unidade, período e n. Exemplo: "290
  observações (29 municípios x 10 anos), 2012 a 2021; R$ de 2021."
- **Nota (caption)**: fonte completa e qualquer ressalva estatística que mude
  a leitura. Ressalva curta, em uma ou duas linhas.
- Nada de adjetivos sem medida ("enorme", "forte"). Se a palavra for usada, o
  valor deve aparecer no gráfico.

## 3. Limpeza visual (regras objetivas)

- Uma cor de destaque, o resto em cinza ou em tom único. Cor só codifica
  informação.
- Sem grade pesada: `theme_minimal()` ou `theme_bw()` com `panel.grid.minor`
  removido. Sem bordas em caixas que não informam nada.
- Rótulos diretos no lugar de legenda sempre que couber (nome dentro da barra,
  valor no fim da barra, número sobre o ponto).
- Ordene barras por valor, a não ser que a ordem natural seja o tempo.
- Eixos com formatação brasileira (`scales::label_number` com `decimal.mark = ","`).
  Unidade no título do eixo, não repetida em cada marca.
- Texto mínimo de 9 pt em figura de página inteira; títulos em negrito.
- Sem efeitos decorativos: sombra, gradiente de fundo, 3D, transição de
  animação que o leitor não precisa acompanhar.
- Tamanho e resolução: PNG a 300 dpi, fundo branco (`bg = "white"`).

## 4. Estatística honesta na figura

- Não exiba p-valor que assume independência quando as observações não são
  independentes (painel com o mesmo município em vários anos). Se for exibido,
  diga na nota por que a leitura pode ser otimista.
- Mostre o n em toda figura agregada.
- Correlação: sempre com sinal e duas casas decimais, com separador decimal
  vírgula. Mapa de calor em triângulo para não repetir pares.
- Reta de ajuste: diga que é reta de mínimos quadrados e sobre qual base.
- Outliers conhecidos: marque e explique na nota. Não remova sem dizer.
- Valores que são dado da fonte mas parecem erro (por exemplo, VAB negativo)
  devem aparecer sinalizados, com a explicação na nota.

## 5. Mapas

- Escala de cor fixa entre quadros de animação e entre painéis que se
  comparam.
- Municípios identificados por número com legenda ao lado (número e nome, em
  ordem alfabética), quando o leitor precisa referir-se a um município específico.
- Marcadores: círculo com contorno preto, fundo branco e número preto no
  centroide do polígono.
- Destaque de Curitiba com contorno preto mais grosso. Barra de escala e seta
  do norte só se o mapa for impresso ou usado isoladamente.

## 6. Animações

- Use animação só quando o movimento responde a uma pergunta que um quadro
  fixo não responde (evolução no tempo).
- Ordenação estável ou ranking com transição suave, sem ordem aleatória.
- Mostre o ano em destaque e a escala fixa. Limite a duração a 10 a 15 segundos.
- Se a leitura exigir muitos quadros, entregue também um gráfico estático com o
  último ano ou com dois anos de referência.

## 7. Checklist antes de entregar

1. A mensagem cabe em uma frase e aparece, de forma verificável, no título ou no subtítulo?
2. O tipo de gráfico corresponde ao que se compara (seção 1)?
3. Há uma única cor de destaque, e ela aponta para a mensagem?
4. Os rótulos são diretos e legíveis em tamanho de página inteira?
5. Os números têm formatação brasileira e unidade?
6. O n, o período e a fonte estão na figura?
7. A ressalva estatística que muda a leitura está na nota?
8. Os municípios estão numerados com legenda quando for preciso?
9. O arquivo foi conferido visualmente (abrir o PNG ou o GIF) antes de ser dado como pronto?

## 8. Como a sessão usa esta skill

- Ao alterar uma figura, a resposta diz qual regra da skill foi aplicada e o
  que mudou visualmente.
- Visual não conferido no R não é dado como pronto: a marca é `[a confirmar]`
  até o arquivo ser aberto e visto.
- Escolhas de apresentação sem fonte externa (ordem alfabética, cores, tamanhos)
  recebem `[presunção da modelagem]` no comentário do código.
