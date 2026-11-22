# Verificação dos códigos e URLs de coleta (22/11/2026)

Conferido na fonte, por consulta direta às APIs públicas na data acima. Nenhuma credencial foi usada. O `basedosdados` não foi consultado.

| Dado | Código ou URL no projeto (`R/01_extracao_dados.R`) | Resultado da consulta | Situação |
|---|---|---|---|
| PIB municipal, SIDRA, tabela 5938 | `/t/5938/n6/<29 códigos>/v/37,543,498,513,517,6575,525` | Para Curitiba (4106902), 2019: v37 = "Produto Interno Bruto a preços correntes" (Mil Reais); v543 = "Impostos, líquidos de subsídios, sobre produtos a preços correntes"; v498 = "Valor adicionado bruto a preços correntes total"; v517 = "... da indústria"; v6575 = "... dos serviços, exclusive administração"; v525 = "... da administração, defesa, educação e saúde públicas"; v513 = "... da agropecuária". | Conferido |
| Selic, série 4390 (SGS) | `rbcb::get_series(4390)` | `api.bcb.gov.br/dados/serie/bcdata.sgs.4390`, 01/01/2019: 0,54 | Conferido |
| IPCA, série 433 (SGS) | `rbcb::get_series(433)` | `api.bcb.gov.br/dados/serie/bcdata.sgs.433`, 01/01/2019: 0,32 (variação mensal do IPCA) | Conferido |
| Composição da RMC (código 05501) | API de localidades do IBGE, `regioes-metropolitanas/05501/municipios` | 29 municípios, com os mesmos códigos da lista canônica de `CLAUDE.md` seção 6 | Conferido |
| RAIS, microdados públicos (MTE) | `ftp://ftp.mtps.gov.br/pdet/microdados/RAIS/<ano>/` | 2012: `PR2012.7z`; 2017: `PR2017.7z`; 2021: `RAIS_VINC_PUB_SUL.7z` (presente na pasta) | Conferido para 2012, 2017 e 2021. Os demais anos seguem a mesma regra, mas só foram conferidos por listagem. |
| Malha municipal (`geobr`), IBGE | `servicodados.ibge.gov.br/api/v3/malhas/estados/41?intrarregiao=municipio` | HTTP 200 | Endpoint responde. A conferência da malha dentro do script (`geobr` 2.1.0) continua no `R/01`. |

## Pendências desta conferência

- Os tamanhos aproximados da RAIS em `TAMANHO_RAIS_MB` (106 a 495 MB) não foram conferidos byte a byte.
- O `geobr` foi conferido só pelo endpoint do IBGE; a versão do pacote precisa ser registrada em `ambiente_r.csv` se mudar.
- O endpoint de metadados do SIDRA (`/desc/`) respondeu com bloqueio Cloudflare nesta sessão; a conferência foi feita pelos valores devolvidos pela API (`/values/`).
