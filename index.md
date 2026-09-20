# edubr

[![R-CMD-check](https://github.com/rodrigoesborges/edubr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/rodrigoesborges/edubr/actions/workflows/R-CMD-check.yaml)
[![Documentação](https://img.shields.io/badge/docs-pkgdown-blue.svg)](https://rodrigoesborges.github.io/edubr/)

Acesso facilitado aos dados educacionais do Brasil (MEC/INEP).

## Descrição

O pacote **edubr** fornece uma interface simplificada para baixar, ler e
arrumar dados educacionais publicados pelo Instituto Nacional de Estudos
e Pesquisas Educacionais Anísio Teixeira (INEP), incluindo o IDEB
(Índice de Desenvolvimento da Educação Básica), a AFD (Adequação da
Formação Docente) e as taxas de distorção idade-série (TDI), além de uma
tabela de campi de universidades e institutos federais por município
derivada do Censo da Educação Superior. As funções baixam as planilhas
originais do INEP, interpretam seus cabeçalhos hierárquicos de múltiplas
linhas e devolvem tibbles no formato longo, com esquema harmonizado
entre indicadores.

## Instalação

O pacote ainda não está disponível no CRAN (submissão em andamento).
Para instalá-lo a partir do GitHub, utilize:

``` r

# Instalar o pacote devtools, caso ainda não tenha
install.packages("devtools")

# Instalar o edubr
devtools::install_github("rodrigoesborges/edubr")
```

## Uso

``` r

library(edubr)

# IDEB por município (anos/séries iniciais do ensino fundamental)
ideb <- le_ideb(regiao = "municipios", nivel = "iniciais")
head(ideb)

# AFD por município (ensino médio)
afd <- le_afd(ano = 2024, regiao = "municipios", niveis = "ensino_medio")
head(afd)

# Taxa de distorção idade-série por município
tdi <- le_idadeserie(ano = 2023)
head(tdi)

# Campi de universidades e institutos federais por município
# (dados embutidos, não requer download)
head(campi_municipios)

# Registro de URLs dos dados do INEP usado pelas funções le_*
head(metainep)
```

Nota: as funções `le_*` baixam arquivos diretamente do CDN do INEP, que
por vezes limita requisições em sequência. O argumento `cache_dir` de
`le_afd` evita repetir downloads.

## Funcionalidades

- `le_ideb(regiao, nivel, replica)`: IDEB por município, UF ou Brasil
  (`municipios`, `ufs`, `brasil` × `iniciais`, `finais`, `medio`). Com
  `replica = TRUE`, replica o valor bienal no ano seguinte.
- `le_afd(ano, regiao, localizacoes, dependencias, niveis, subniveis, cache_dir)`:
  Adequação da Formação Docente com filtros por localização, dependência
  administrativa e nível de ensino.
- `le_idadeserie(ano)`: Taxa de Distorção Idade-Série por município.
- `campi_municipios`: tabela embutida de campi das instituições públicas
  federais de educação superior por município (retrato de 2023, painel
  2008-2023).
- `metainep`: registro das URLs de download dos dados do INEP usado
  internamente pelas funções `le_*`.

## Contribuição

Contribuições são bem-vindas. Caso encontre problemas ou tenha
sugestões, abra uma issue no repositório do GitHub.

## Licença

Este projeto é licenciado sob a licença GPL-3.
