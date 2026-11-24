# Revisão pelos colegas: artigo, slides e roteiro

Written for: colegas que vão revisar o trabalho de Econometria I (salário médio real formal e estrutura produtiva na RMC), com ou sem experiência em R.

Versão de 23/11/2026. **Tudo aqui é rascunho para apreciação.** O pesquisador responsável decide o que entra na versão final.

## 1. O que há para revisar

| Material | Onde | Para que serve |
|---|---|---|
| Artigo (rascunho v2) | `artigo/ARTIGO_rascunho_v2.md` e a cópia no Claude Docs | Relatório final. É o material que o professor pediu para receber atenção especial |
| Slides (22, fundo branco, tons de cinza, Times New Roman, com duas animações em GIF) | Artefato de Slides, com a fonte em `apresentacao/deck_fonte/project/` | Apresentação oral. As notas do orador trazem as marcações de revisão |
| Roteiro do time | `apresentacao/CONTEXTO_PARA_O_TIME.md` | Explica os números, as variáveis e cada slide para quem vai apresentar |
| Roteiro dos slides | `apresentacao/ROTEIRO_SLIDES.md` | Texto de cada slide e as figuras usadas |
| Referências | `fontes/REFERENCIAS.md` | Lista central com links e o estado de cada fonte |
| Pendências do professor | `_Trilha/REGISTRO_PENDENCIAS_PROFESSOR.md` | Onde cada trecho aguarda orientação do professor |

Os links do Claude Docs e do artefato de Slides são privados: o pesquisador compartilha pelo menu Share de cada página. Sem isso, só o texto do repositório abre.

## 2. Como ler as marcações

| Marca | Significa | O que fazer |
|---|---|---|
| `[revisar: …]` | Texto ou interpretação que o pesquisador precisa confirmar | Dar sua opinião; não reescrever a teoria |
| `[a inserir: …]` | Falta conteúdo, em geral literatura | Sugerir obras que você leu de fato |
| `[a confirmar]` | Dado que ainda falta conferir na fonte | Conferir se puder e anotar a fonte |
| `[presunção da modelagem]` | Escolha de método sem fonte própria | Dizer se parece razoável |
| `[aguardando orientação do professor: …]` | Trecho que depende da resposta dele | Não alterar; só ler |

## 3. O que cada pessoa deve olhar

**Artigo.** O professor pediu quatro coisas: revisão da literatura, metodologia detalhada, discussão dialogando com a literatura e contribuição clara. Perguntas para guiar a leitura:
1. A introdução diz qual é a pergunta e por que ela importa para a RMC?
2. O procedimento da seção 3.5 e os testes da seção 4.2 dá para reproduzir só lendo?
3. Cada hipótese (H1 a H5) é explicada e comparada com algo? Onde falta, marcar.
4. A contribuição da seção 6.7 é honesta, sem falar em causa?
5. Tabelas e figuras estão numeradas em sequência, com título acima e fonte abaixo (UFPR/ABNT)?
6. Tamanho: está estimado em cerca de 21 páginas, acima da média dos exemplos (14,8). O que pode ir para o apêndice?

**Slides.** Cada slide tem uma mensagem? As figuras estão legíveis e inteiras? Os GIFs (slides 8 e 9) rodam no seu navegador? O texto do slide bate com o artigo? Os slides 3 (literatura) e 19 (contribuição) são placeholders até o pesquisador preencher.

**Roteiro do time.** A linguagem é clara para quem não rodou o código? Algum número está diferente do artigo ou dos slides?

## 4. Regras para quem for editar

- **Não alterar números** de tabelas, coeficientes e testes sem conferir. Eles vêm do código em `R/` e dos CSVs em `resultados_econometricos/`. Quem achar um erro deve avisar, e o pesquisador decide e roda os scripts de novo.
- **Não inserir referência que você não leu.** Toda obra entra com a página que sustenta a afirmação e passa por `fontes/REFERENCIAS.md`.
- **Linguagem de associação**, nunca de causa: "associa-se a", não "causa" nem "provoca".
- **Só métodos ensinados na disciplina.** Efeitos fixos, Mundlak, Hausman, bootstrap e correção de painel estão fora do trabalho.
- A redação do artigo e a interpretação teórica são do pesquisador. Seus comentários são sugestões.

## 5. Como enviar o retorno

- Pelo Claude Docs ou pelo Slides: comentários nos trechos, se o pesquisador compartilhar.
- Pelo repositório: abrir uma branch própria, editar os arquivos `.md` e enviar uma pull request, seguindo `CONTRIBUIR.md`. Descrever na pull request o que mudou e por quê.
- Por texto: uma lista com o trecho (seção ou slide), o problema e a sugestão.

Ao terminar sua revisão, lembre de enviar o trabalho ao repositório por branch e pull request (`CONTRIBUIR.md`).

## 6. O que ainda está em aberto

- Revisão da literatura (seção 2) e a comparação dos resultados com ela (seção 6): do pesquisador.
- Itens A1 a A7, que aguardam o professor.
- Referências a conferir: editora de Hoffmann (2006), título e data do documento da AEN-PR sobre a fábrica de Adrianópolis, datas de acesso, edição do Gujarati.
- Nome do apresentador e data na capa.
- Slides de literatura e contribuição sem conteúdo definitivo.
