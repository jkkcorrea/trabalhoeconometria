# Avaliação como professor de Econometria I, versão 4 (22/11/2026)

Documento interno. Não entra no envio. Régua de 100 pontos, aplicada após: pendências conferidas (Adrianópolis na API do SIDRA; memorial matricial do Modelo 4 e de Prais-Winsten); modelo principal definido (Modelo 4 com Prais-Winsten e erro de White); referência de página pela 5ª edição do Gujarati (índice).

Nota estimada: 80 de 100 (faixa provável de 77 a 82). Antes: 77.

| Critério | Pts | v3 | v4 | Motivo da mudança |
|---|---|---|---|---|
| 1. Especificação | 10 | 6 | 7 | Modelo principal com autocorrelação corrigida e dummies; referência com o achado de fragilidade declarado. |
| 2. Dados | 10 | 7 | 8 | Adrianópolis conferido na fonte (SIDRA), com ressalva de influência. |
| 3. Estimação e memorial | 15 | 13 | 15 | Memorial do Modelo 4 (FWL) e de Prais-Winsten, conferidos contra lm() e contra a Etapa 5 (C14 e C15). |
| 4. Inferência | 10 | 7 | 7 | Sem mudança: t com 257 gl e normalidade rejeitada seguem como limitação. |
| 5. Multicolinearidade | 5 | 5 | 5 | Sem mudança. |
| 6. Heterocedasticidade | 10 | 9 | 9 | Sem mudança. |
| 7. Autocorrelação | 10 | 7 | 8 | Modelo principal corrigido; ρ dos resíduos ≈ 0,02. Newey-West não aplicado (justificado). |
| 8. Normalidade, forma funcional, influência | 10 | 7 | 7 | Normalidade rejeitada sem tratamento; sem Cook e DFBETAS (fora do programa). |
| 9. Painel e robustez | 10 | 6 | 7 | Sensibilidade, correções e robustez do Gini alinhadas ao modelo principal. |
| 10. Reprodutibilidade | 5 | 5 | 5 | 25 verificações, todas aprovadas. |
| 11. Limitações | 5 | 5 | 5 | Sem mudança. |
| **Total** | **100** | **77** | **80** | |

## O que ainda limita a nota
- Normalidade rejeitada nos dois modelos (critério 8) e sem procedimento de tratamento ensinado.
- Referências conferidas no PDF da 4ª edição (único livro de Gujarati usado).
- Confirmação do professor pendente: dummies, correção com ρ comum no painel, limiares de influência, Gini e quebra de 2016.
- O RESET do modelo principal, após a transformação de Prais-Winsten, não foi calculado. Deve entrar antes da entrega.
