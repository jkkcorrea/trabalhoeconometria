# Divergências entre a resposta enviada ao professor e a fonte da verdade (24/11/2026)

A `RESPOSTA_AO_PROFESSOR.txt` já foi enviada e não é alterada. Esta lista registra o que nela diverge do código e do material de aula, para uma eventual errata. Fonte da verdade: `_Trilha/FONTE_DA_VERDADE.md`.

| Item da resposta | O que diz | O que a fonte da verdade mostra | Gravidade |
|---|---|---|---|
| 2 (autocorrelação) | chama o Prais-Winsten de "método de painel"; não informa o Breusch-Godfrey | Prais-Winsten é correção de autocorrelação de série temporal (Gujarati, cap. 12), fora do escopo ensinado; o Breusch-Godfrey por município, no procedimento do Gujarati, rejeita em 5 de 29 (3 com o primeiro defasado preenchido com zero) | média |
| 4 (normalidade) | os testes "continuam aproximadamente válidos" com 290 observações | a aproximação de amostras grandes exige observações independentes, e 72,9% da soma de quadrados dos resíduos está entre municípios | média |
| 5 (Gini) | cita as aulas "slides 21, 22 e 26" | o artigo e o código usam os slides 21 e 22 (Hasegawa, 2020) | baixa |
| 7 (influência) | diz que a análise de influência é tratada em "dados em painel" | influência é diagnóstico de regressão (Gujarati), não de painel; o item foi retirado por orientação do professor | média |
| 8 (projeção) | "VAB não disponível para 2022 e 2023" | confirmado na SIDRA em 24/11/2026 (o valor vem como "..." nesses anos) | sem erro |
| vários itens | W = 0,862 e p = 0,001 | valores exatos: W = 0,8618; p = 0,0011 (arredondamento menos preciso) | baixa |

Sugestão: se o pesquisador quiser enviar uma errata curta ao professor, os itens 2, 4 e 7 são os que mudam o sentido do que foi dito.
