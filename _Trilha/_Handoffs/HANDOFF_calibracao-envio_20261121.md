<!-- frente=calibracao-envio | estado=Concluída | data=2026-11-21 -->
# HANDOFF: calibração do modelo, fragilidades e pasta de envio (21/11/2026)

Leia com `CLAUDE.md` (seção 11), `_Trilha/DECISOES.md` (D-2026-11-21-01 a 17) e `_Trilha/BACKLOG.md` (itens 14 a 23).

## O que foi feito

- Gráficos: municípios numerados com legenda (círculo de contorno preto, fundo branco, número preto); matriz de correlação refeita em triângulo; animação 2 trocada por ranking; `gifski` instalado com Rust e as duas animações renderizadas.
- Regressão: Etapa 5 (Mundlak, Modelos 3c e 4), Etapa 6 (testes de efeito de município, estimadores com efeito de município, bootstrap wild cluster), Etapa 7 (memorial matricial do Modelo 2) e Etapa 8 (forma funcional, sensibilidade da Selic, exogeneidade).
- Skill `storytelling-graficos`, skill `professor-econometria` e agente `professor-econometria`.
- Pasta `envio_professor/` regerada com o pipeline inteiro (scripts 02 a 08 rodados dentro dela, a partir de `dados_brutos/`), documentação gerada a partir dos CSV e verificação independente.

## Arquivos gravados

- `R/05` a `R/08`; alterações em `R/03`, `R/04`.
- `envio_professor/` (scripts sem comentários de processo, dados, resultados, figuras, `documentacao/`, `LEIAME.md`).
- `_Trilha/ferramentas/gerar_documentacao.R` e `verificar_envio.R`.
- `.claude/skills/storytelling-graficos`, `.claude/skills/professor-econometria`, `.claude/agents/professor-econometria.md`.

## Decisões tomadas

D-2026-11-21-01 a 17 em `_Trilha/DECISOES.md`. Pontos que dependem do pesquisador: modelo de referência do artigo (backlog 19) e a calibração registrada como `[presunção da modelagem]` (D-2026-11-21-05 e 15).

## Pendências

Só o item 24 do backlog (sinais esperados, cabe ao pesquisador) segue aberto. O item 19 foi delimitado por presunção (D-2026-11-21-20) e pode ser revertido.

## Fatos a lembrar

- O RESET com termos quadráticos precisa de graus de liberdade pelo posto: `lmtest::resettest` conta 14 parâmetros quando só 11 são independentes e dava p = 0,21; o valor correto é 0,081.
- O bootstrap exato por ano precisa de tolerância numérica na comparação (`>= |t| - 1e-9`), porque a combinação de sinais todos positivos reproduz a amostra observada.
- O `gganimate` interpola texto como cor: rótulos de animação devem ser fatores.
- Bootstrap wild cluster por ano em modelo within: os sinais variam por ano dentro do município, então y* precisa ser recentrado por município em cada réplica. O primeiro cálculo (p = 0,018) estava errado; o correto é 0,0547. A verificação C15 passou a usar variáveis binárias de município, independente do script.
- `confint.default(modelo, vcov. = V)` ignora `vcov.`; os intervalos do `05` agora saem de estimativa +/- t(28) x erro agrupado.
- Dentro de `tibble()`, um nome de coluna criado antes mascara objetos de mesmo nome (`modelo = nome_modelo` mascarou o `lm`).
- Existem dois rho para os mesmos resíduos (correlação entre vizinhos 0,8846; regressão 0,8279); a documentação explica as duas definições.
- Selic real: p-valor de 0,0005 (agrupado por município) a 0,0547 (bootstrap exato por ano); 0,046 com pesos de Webb. Fica na fronteira de 5%. X5 também carrega o canal da deflação (Selic nominal +0,0039, IPCA -0,0034 com efeitos fixos).
- Curitiba difere dos demais (Chow F = 5,17, p = 0,0001). A matriz de dois eixos do Modelo 3b não é semidefinida positiva.
- Três correções do professor (agente `professor-econometria`): 75, 80 e 82. Erros da terceira, já corrigidos: Chow sem X6 (agora Modelo 2 contra indicadora e interações, F = 4,16), RESET dos Modelos 3 e 3b sem posto, Goldfeld-Quandt só bilateral (agora unilateral, p = 0,031, com o bilateral em coluna própria), decomposição da Selic lida além do que os dados sustentam (a restrição de Fisher não é rejeitada), legenda da figura de calibração e verificação C25 frouxa. Faltas que ficam: sinais esperados (pesquisador) e zonas numéricas do DW.
- Reconstrução completa da pasta de envio: `bash _Trilha/ferramentas/reconstruir_envio.sh` (limpeza, pipeline, documentação e verificação).
- Os scripts do projeto mantêm comentários; a versão de `envio_professor/R/` sai do filtro `limpar_comentarios.R` (`_Trilha/ferramentas/limpar_comentarios.R`: `Rscript _Trilha/ferramentas/limpar_comentarios.R R <destino> <relatório>`).

## Próximo passo

1. Redigir o artigo e fundamentar os sinais esperados (backlog 24).
2. Confirmar ou reverter o modelo de referência (D-2026-11-21-20).
3. Se algum resultado mudar: rodar os scripts dentro de `envio_professor/`, regenerar a documentação e rodar o verificador.
