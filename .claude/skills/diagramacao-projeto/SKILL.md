---
name: diagramacao-projeto
description: Use para diagramar o projeto e seus materiais: diagrama do fluxo de dados e scripts, layout de página do artigo e de painéis de slides (grade, hierarquia, espaço em branco), e organização das pastas. Interpretação adotada nesta skill declarada no texto.
---

# Diagramação do projeto

Interpretação adotada (`[presunção da modelagem]`, a pedido "diagramação do projeto"): três usos, (1) diagramas do fluxo do projeto, (2) layout de páginas e slides e (3) organização de pastas. Se o colega quis outro sentido, ajuste.

## 1. Diagrama do fluxo
Fluxo real (confira em `R/00_executar_tudo.R` e no catálogo):

```
APIs públicas (SIDRA, Banco Central, IBGE) + RAIS
        │  R/01_extracao_dados.R  (opcional; RAIS ≈ 3,5 GB)
        ▼
dados_brutos/*.rds
        │  R/02_tratamento_painel.R
        ▼
dados_processados/dados_painel_rmc.(rds|csv)   ← 29 municípios × 10 anos = 290 obs
        ├─ R/03  → figuras_graficos/ (mapas, GIFs, correlação)
        ├─ R/04  → resultados_econometricos/ + diag1..4
        ├─ R/05  → robustez (Mundlak, Modelos 3c e 4)
        ├─ R/06  → calibração (efeito de município, bootstrap)
        ├─ R/07  → memorial matricial do Modelo 2
        └─ R/08  → fragilidades (forma funcional, Selic, exogeneidade)
        ▼
_Trilha/ferramentas/reconstruir_envio.sh → envio_professor/ + documentação + verificação
```

Regras de diagrama: um sentido de leitura (cima para baixo ou esquerda para direita); no máximo sete caixas por nível; rótulo curto no verbo ou no arquivo; mesma cor para mesmo tipo (dados, código, resultado); legenda se houver mais de duas cores. Formatos aceitos: bloco de texto como acima, Mermaid em Markdown (`flowchart TD`), ou figura em ggplot/SVG.

## 2. Layout de página e de slide
- **Grade**: margens constantes, uma coluna de texto, figura alinhada à grade, largura da figura igual à da coluna ou da mancha de texto.
- **Hierarquia**: título, subtítulo, corpo, fonte/nota, em tamanhos distintos e consistentes; no máximo duas famílias de fonte.
- **Espaço em branco**: separa ideias; não preencha tudo. Um slide tem um ponto focal.
- **Alinhamento**: elementos relacionados alinham pelo mesmo eixo; tabela de números alinhada à direita ou ao separador decimal.
- **Cor**: poucas, com função; paleta calma de `instrucoes_ia/PROMPT_SLIDES.md`; contraste do texto pelo menos 4,5.
- **Figura**: título como mensagem, legenda perto do dado, fonte na base (ver skill `storytelling-graficos`).
- **Artigo**: regras de página em `formatacao-abnt` têm prioridade sobre gosto.

## 3. Organização de pastas
- `R/`: scripts numerados. `envio_professor/`: gerada, não editar. `instrucoes_ia/`: prompts e regras. `.claude/`: skills e agentes. `_Trilha/`: decisões, pendências, handoffs, ferramentas. `artigo/` e `apresentacao/`: produção dos colegas.
- Nome de arquivo em snake_case sem acento, com prefixo numérico quando a ordem importa.
- Depois de criar ou mover arquivos: `Rscript _Trilha/ferramentas/gerar_catalogo.R`.

Ao terminar: lembre o colega de enviar o trabalho ao repositório (branch próprio, commit, `git push -u origin <branch>`, pull request; ver `CONTRIBUIR.md`). Não faça o push sozinho.
