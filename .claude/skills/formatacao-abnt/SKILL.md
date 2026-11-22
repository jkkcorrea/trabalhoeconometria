---
name: formatacao-abnt
description: Use ao formatar artigo, tabelas, figuras, citações e referências do Trabalho de Econometria em ABNT (NBR 6022, 6023, 10520, 14724, 6024, 6028). Traz as regras conferidas no modelo da UFPR e marca o que precisa de conferência na norma vigente.
---

# Formatação ABNT para o artigo

Origem das regras: (A) template e modelo de artigo de periódico do SiBi/UFPR (`normas_modelo_artigo_periodico.pdf`, março/2016, revisado 2022; lido na sessão de 21/11/2026) e (B) guias de bibliotecas universitárias sobre as NBR, que são fonte secundária. Itens de (B) levam `[a confirmar na norma]`. O texto das normas ABNT é pago; o SiBi/UFPR oferece acesso pelo Target (https://target.ufpr.br/register.php). O modelo (A) cita a NBR 6022/2003 e o manual da UFPR de 2015; a NBR 6022 tem edição de 2018, então confirme com o orientador qual versão vale. Se o artigo for para uma revista, valem as normas editoriais dela.

## 1. Parâmetros do modelo UFPR (A)

| Elemento | Regra |
|---|---|
| Título do artigo | 12 pt, MAIÚSCULAS, negrito, centralizado, entrelinha 1,5 (capa e folha de rosto); na primeira página do texto: maiúsculas e minúsculas, negrito, centralizado |
| Autor(es) | 12 pt; capa e folha de rosto em maiúsculas, negrito, centralizado; na primeira página do texto: maiúsculas e minúsculas, sem negrito, alinhado à esquerda |
| Nota da natureza do trabalho e orientador | 10 pt, sem negrito, entrelinha simples |
| Local e ano | 12 pt, MAIÚSCULAS, negrito, centralizado |
| RESUMO | título em 12 pt, maiúsculas, negrito; texto de 100 a 250 palavras, 12 pt, entrelinha simples, justificado, parágrafo único |
| Palavras-chave | 12 pt, entrelinha simples, depois do resumo, separadas por ponto, com inicial maiúscula (ex.: "Palavras-chave: Acessibilidade. Inclusão social.") |
| Seção primária | número, um espaço, título em 12 pt, MAIÚSCULAS, negrito (ex.: "1 INTRODUÇÃO") |
| Seção secundária | em artigo não começa página nova |
| Texto | 12 pt, entrelinha 1,5; uma linha em branco (1,5) entre título de seção e texto |
| Paginação | canto superior direito, 10 pt; páginas contadas desde a folha de rosto, numeração visível a partir da primeira página da Introdução |
| Siglas | por extenso na primeira vez, sigla entre parênteses; depois só a sigla |
| Citação curta (até 3 linhas) | no texto, entre aspas; página obrigatória: Pupo (2008, p. 18) |
| Citação longa (mais de 3 linhas) | recuo de 4 cm da margem esquerda, 10 pt, entrelinha simples, sem aspas; página obrigatória |
| Citação de lei, indireta | (BRASIL, 1996) |
| Quadro, gráfico, figura | título **acima**, 10 pt, MAIÚSCULAS, entrelinha simples, centralizado ("QUADRO 1 - TÍTULO"); fonte e notas abaixo, 10 pt, centralizadas; elaboração própria: "FONTE: O autor (ano)." |
| Tabela | título acima, 10 pt, maiúsculas; sem traços nas laterais; título, fonte e notas alinhados à esquerda (norma de apresentação tabular do IBGE); fonte e notas abaixo |
| Chamada no texto | em maiúsculas no modelo: (TABELA 1), (FIGURA 1), (GRÁFICO 1), (QUADRO 1) |
| REFERÊNCIAS | título em 12 pt, maiúsculas, negrito, centralizado; lista alinhada à esquerda, 12 pt, entrelinha simples, uma linha simples em branco entre referências; só obras citadas |
| APÊNDICE | opcional, texto elaborado pelo autor (ex.: questionário); título "APÊNDICE 1" |
| ANEXO | opcional, documento não elaborado pelo autor (mapa, lei); título "ANEXO 1" |

Margens, fonte e papel: confirmados no template oficial da UFPR (`fontes/modelos_ufpr/template-artigo-de-periodico-ufpr_2026-06.doc`, lido em 22/11/2026): papel A4 (11906 x 16838 twips); margem superior 3 cm e esquerda 3 cm; inferior 2 cm e direita 2 cm; fonte Arial 12 pt no texto (estilo Normal); entrelinha 1,5 no corpo; recuo de primeira linha de 1,5 cm no estilo "Texto" (851 twips), justificado; resumo e referências em entrelinha simples; citação longa com recuo de 4 cm (2268 twips), 10 pt, entrelinha simples, justificada; legendas em 10 pt. Essas medidas coincidem com as margens e a fonte que a NBR 14724 prevê na prática; a conferência com o texto da norma (paga) fica com o orientador `[a confirmar na norma]`. Fonte de conhecimento sobre a ABNT aplicada a documentos LaTeX: abnTeX2 (https://ctan.org/pkg/abntex2), que documenta as regras de NBR 14724, 6022, 6023, 6028 e 10520.

## 2. Citações no texto (NBR 10520) (B)

- Sistema autor-data. Autor entre parênteses em MAIÚSCULAS; no corpo do texto, só a inicial maiúscula: "Segundo Silva (2020, p. 5)" e "(SILVA, 2020, p. 5)".
- Dois autores: (SILVA; SOUZA, 2020). Três ou mais: (SILVA et al., 2020).
- Mesmo autor, mesmo ano: 2020a, 2020b.
- Citação indireta: página é opcional; citação direta: página obrigatória.
- Vários autores na mesma chamada: ordem alfabética, separados por ponto e vírgula.
- Citação de citação: "apud" (evite).
- A edição de 2023 da NBR 10520 existe `[a confirmar na norma]`.

## 3. Referências (NBR 6023) (B)

Modelos `[a confirmar na norma]` (edição de 2018; há menção a edição mais recente):

- Livro: SOBRENOME, Nome. **Título**: subtítulo. Edição. Local: Editora, ano.
- Artigo: SOBRENOME, Nome. Título do artigo. **Título do periódico**, local, v. 10, n. 2, p. 15-30, mês abreviado ano.
- Dados públicos: INSTITUIÇÃO. **Nome da base ou tabela**. Local: instituição, ano. Disponível em: URL. Acesso em: dia mês ano.
- Pacote de R: AUTOR. **Nome do pacote**: descrição. Versão x.y.z. Ano. Disponível em: URL. Use `citation("pacote")` e as versões de `envio_professor/documentacao/ambiente_r.csv`.
- Ordem alfabética por sobrenome; título em destaque (negrito) de forma uniforme em toda a lista; todas as obras citadas, e só elas.

## 4. Equações e tabelas de regressão

- Equações centralizadas, numeradas à direita entre parênteses: (1), (2). Chamada no texto: "equação (1)" `[a confirmar na norma]`.
- Símbolos explicados logo após a equação, com a unidade.
- Tabela de regressão: coeficiente, erro-padrão entre parênteses, N, R² e a matriz de variância usada, dita na nota. Casas decimais iguais às da fonte (`resultados_econometricos/`).
- Separador decimal: vírgula, em todo o texto, tabelas e figuras.

## 5. Conferência final

- [ ] Todo "TABELA n", "FIGURA n" citado no texto existe e está numerado em sequência.
- [ ] Toda figura e tabela tem título acima e fonte abaixo.
- [ ] Toda citação está nas Referências e vice-versa.
- [ ] Vírgula decimal e mesmos nomes de variável do dicionário.
- [ ] Itens `[a confirmar na norma]` resolvidos com o orientador ou com o template atual da UFPR.

Ao terminar: lembre o colega de enviar o trabalho ao repositório (branch, commit, `git push`, pull request; ver `CONTRIBUIR.md`).
