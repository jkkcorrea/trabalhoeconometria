<!-- frente=artigo-slides | estado=Pausada | data=2026-11-23 -->
# HANDOFF: artigo, slides e roteiro para apreciação dos colegas (23/11/2026)

## O que foi feito
- Escopo ajustado à orientação do professor (sem binárias de município, sem métodos de painel); modelo principal MQO empilhado com erros de White; pasta de envio verificada em 22 de 22.
- Artigo v2 (`artigo/ARTIGO_rascunho_v2.md`) e cópia no Claude Docs: metodologia detalhada (3.5, 4.1 a 4.3), estrutura da revisão da literatura (seção 2), discussão por hipótese (seção 6), contribuição candidata (6.7), 5 figuras e 6 tabelas, resumo em inglês, apêndices A e B.
- Slides (22) no artefato de Slides, com fonte em `apresentacao/deck_fonte/project/`: fundo branco, tons de cinza, Times New Roman, duas animações em GIF.
- Roteiros: `apresentacao/ROTEIRO_SLIDES.md`, `apresentacao/CONTEXTO_PARA_O_TIME.md`, guia `REVISAO_PELOS_COLEGAS.md`.
- Referências: `fontes/REFERENCIAS.md` (links, aulas de Hasegawa, fábrica de Adrianópolis); autoria do Gujarati corrigida (4ª edição, só Gujarati, 2003).
- Correção como professor (agente `professor-econometria`): nota 69/100 pela régua, 55 a 60 efetiva sem a literatura, cerca de 77 com a literatura escrita e cerca de 84 com as correções técnicas.
- Correções dessa rodada: períodos do Chow, linha do gráfico em 2017,5, descrição do Breusch-Godfrey, p = 0,0011 e W = 0,8618, robustez com porte e sem VAB industrial negativo (`R/06`, `robustez_porte_e_negativos.csv`, TABELA 6).

## Arquivos gravados (principais)
`artigo/ARTIGO_rascunho_v2.md`, `apresentacao/` (roteiros e `deck_fonte/`), `REVISAO_PELOS_COLEGAS.md`, `fontes/REFERENCIAS.md`, `_Trilha/REGISTRO_PENDENCIAS_PROFESSOR.md`, `_Trilha/AVALIACAO_COMENTARIO_PROFESSOR_20261123.md`, `R/03` e `R/06` (ranking animado, linha do Chow, robustez), `_Trilha/ferramentas/` (verificador e gerador), `envio_professor/` regenerada. Commits: `7a423ce`, `95598d5`, `2b59952`, `42bc779` e o commit deste handoff.

## Decisões tomadas
D-2026-11-23-08 (comentário do professor), -09 (aulas e referências) e -10 (preparo para os colegas), em `_Trilha/DECISOES.md`.

## Pendências
**Do professor (itens A1 a A8, em `_Trilha/REGISTRO_PENDENCIAS_PROFESSOR.md`):** normalidade rejeitada, forma funcional rejeitada, autocorrelação positiva, corte do Chow, projeção com exp(s²/2), n = 87 do Gini, modelo sem binárias e porte do município (A8: com ln dos vínculos ativos, o Gini passa a +0,2579, p = 0,1293).

**Do pesquisador:**
- Revisão da literatura (seção 2) e comparação dos resultados com ela (seção 6): bloqueia B3 e B4.
- Contribuição (6.7 e 7) e justificativas dos itens A1 a A8.
- Nome do apresentador e data na capa; tradução do resumo (marcada [revisar]).
- Decidir o tamanho: o artigo está estimado em cerca de 21 páginas (média dos exemplos 14,8; maior 22); sugestão de levar fórmulas dos testes e Figuras 2 e 3 para o apêndice.

**Referências a conferir:** editora de Hoffmann (2006); título e data do `.doc` da AEN-PR; datas de acesso dos dados; edição do Gujarati (aulas citam a 5ª, com Porter); limite FIV = 10 no slide de multicolinearidade (texto em imagem).

**Técnicas (B9):** teste de White ausente; erro de White não trata a dependência dentro do município (Selic com 10 valores anuais); F geral e intervalos da previsão clássicos; `00_executar_tudo.R` não roda `01b_extracao_pam.R` e o painel carrega colunas da PAM sem uso.

**Adrianópolis:** causa do salto de 2015 não confirmada; falta a data de início da produção da Secil e a nota metodológica do VAB municipal de 2015 (R4 e R5 do backlog).

**Outros:** `CLAUDE.md` (seções 6 e 13) ainda descreve versões anteriores e só muda por pedido do pesquisador; `RESPOSTA_AO_PROFESSOR.txt` já enviada, com W = 0,862 e p = 0,001 (arredondamentos menos precisos).

## Próximo passo
1. Compartilhar o Claude Docs e o artefato de Slides com os colegas (os dois são privados) e enviar `REVISAO_PELOS_COLEGAS.md`.
2. Receber o retorno dos colegas e decidir A8 (porte) com o professor.
3. Escrever a seção 2 e a comparação da seção 6 com obras lidas; registrar cada obra em `fontes/REFERENCIAS.md`.
4. Fazer o push por branch e pull request (`CONTRIBUIR.md`).

## Links dos artefatos (privados até o pesquisador compartilhar)
- Artigo (Claude Docs): https://claude.ai/artifact/7debwP1qtWSMGUh1UUqcjZ
- Apresentação (Slides, 22 slides): https://claude.ai/artifact/KYHrBPzxjujCVsjDHCxuUY
