---
name: estrutura-artigo-ufpr
description: Use ao montar a estrutura do artigo científico do Trabalho de Econometria no padrão do Sistema de Bibliotecas da UFPR (elementos pré-textuais, textuais e pós-textuais, obrigatórios e opcionais) e ao mapear cada seção para as fontes do projeto.
---

# Estrutura de artigo de periódico no padrão UFPR

Fonte: "Modelo de artigo de periódico", Comissão de Normalização do SiBi/UFPR (março/2016; arquivo modificado em 2022), https://bibliotecas.ufpr.br/wp-content/uploads/2022/01/normas_modelo_artigo_periodico.pdf. Esse modelo foi feito sobre a NBR 6022/2003 e o manual da UFPR de 2015 e serve a estudantes cuja coordenação exige o TCC em formato de artigo. Para submissão a revista, vale a norma editorial dela. A página de normalização da UFPR (https://bibliotecas.ufpr.br/servicos/normalizacao/) oferece o template `.doc` de artigo de periódico (versão de 2026/06, posterior ao PDF) e informa que o manual está em revisão: confira o template antes da versão final.

## Ordem dos elementos (do modelo)

| Bloco | Elemento | Condição |
|---|---|---|
| Pré-textual | Capa | obrigatória em trabalho de graduação da UFPR no formato artigo |
| Pré-textual | Folha de rosto | idem |
| Pré-textual | Título e subtítulo (se houver) | obrigatório |
| Pré-textual | Autor(es) | obrigatório |
| Pré-textual | Resumo na língua do texto (100 a 250 palavras) | obrigatório |
| Pré-textual | Palavras-chave na língua do texto | obrigatório |
| Textual | Introdução, desenvolvimento, conclusão | obrigatório |
| Textual | Elementos de apoio: citações, notas explicativas, siglas, equações, ilustrações, tabelas, quadros | conforme o texto |
| Pós-textual | Título, resumo e palavras-chave em língua estrangeira | opcional em TCC de graduação |
| Pós-textual | Referências | obrigatório |
| Pós-textual | Glossário | opcional |
| Pós-textual | Apêndice | opcional |
| Pós-textual | Anexo | opcional |

Seções do modelo: 1 INTRODUÇÃO, 2 REVISÃO DE LITERATURA, 3 METODOLOGIA, 4 RESULTADOS, seguidas de conclusão e REFERÊNCIAS. O modelo não fixa as divisões do desenvolvimento: elas dependem do trabalho.

## Estrutura proposta para este trabalho

A divisão abaixo é adaptação (`[presunção da modelagem]`, a confirmar com o orientador).

| Seção | Conteúdo | Fontes no projeto |
|---|---|---|
| Resumo e palavras-chave | objetivo, método, resultados, conclusão | `documentacao/00_resumo.md` |
| 1 Introdução | problema, pergunta, objetivo, roteiro | pesquisador |
| 2 Revisão de literatura | teoria e evidências por variável | pesquisador; `Trabalhos Referencias/` só como modelo de estrutura |
| 3 Metodologia | dados, variáveis, modelo, estimadores, testes | `01_dados_e_variaveis.md`, `02_especificacao_e_metodos.md` |
| 4 Resultados | descritivas, estimativas, diagnósticos, robustez | `03_` a `05_`, CSV de `resultados_econometricos/`, figuras |
| 5 Considerações finais | síntese, limites, próximos passos | `06_limitacoes.md`; pesquisador |
| Referências | obras citadas | pesquisador; `ambiente_r.csv` para pacotes |
| Apêndices | memorial matricial, tabelas completas | `memorial_modelo_2.txt` |

Regra de coerência: a pergunta da Introdução é respondida na Conclusão; todo resultado da Conclusão aparece em Resultados; toda variável de Resultados foi definida em Metodologia.

Formatação: skill `formatacao-abnt`. Escrita: skill `escrita-cientifica`. Roteiro detalhado por seção: `instrucoes_ia/PROMPT_ARTIGO.md`.

Ao terminar: lembre o colega de enviar o trabalho ao repositório (branch, commit, `git push`, pull request; ver `CONTRIBUIR.md`).
