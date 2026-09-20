# Campi de universidades e institutos federais por municipio

Tabela de campi das instituicoes publicas federais, derivada dos
microdados do Censo da Educacao Superior (INEP). Cada linha corresponde
a um par instituicao/municipio: trata-se como campus todo municipio em
que a instituicao oferta ao menos um curso presencial, mais o municipio
da sede administrativa. O conjunto de campi e o retrato de 2023; o ano
de inicio e inferido a partir do painel 2008-2023.

## Usage

``` r
campi_municipios
```

## Format

Um data frame com 6 colunas:

- nome_campus:

  Nome do campus, no formato "sigla - municipio"

- sigla_universidade:

  Sigla da instituicao (SG_IES)

- tipo:

  "universidade" (organizacao academica 1) ou "instituto federal"
  (organizacoes academicas 4 e 5, inclui os CEFETs)

- ano_criacao_campus:

  Ano de inicio inferido, nao um dado oficial do INEP: e o primeiro ano
  do painel 2008-2023 em que o par (instituicao, municipio) aparece, na
  ordem (1) com curso presencial, (2) com qualquer curso, (3)
  instituicao presente no censo. Como o identificador de IES so existe
  nos microdados a partir de 2008, o valor 2008 significa "2008 ou
  antes" (anos 1995-2007 nao trazem codigo de instituicao)

- codigo_municipio:

  Codigo IBGE do municipio

- nome_municipio:

  Nome do municipio

## Source

<https://www.gov.br/inep/pt-br/acesso-a-informacao/dados-abertos/microdados/censo-da-educacao-superior>

## See also

`data-raw/campi_municipios.R` para a geracao da tabela.
