# metaideb - basic metadata table - name , url, group/subject with auto-generated id - obtaining by applying le_ideb function

@format A list with two sublists iniciais and finais with similar
structure:

- codigo_municipio:

  codigo IBGE municipio

- nome_municipio:

  Nome do Município

- rede:

  Rede - Estadual, municipal, pública

- ano:

  Ano

- indicador:

  taxa de aprovação, Nota SAEB ,IDEB

- detalhe:

  geral/por série; ponderada/por disciplina; valor x meta

- valor:

  valor do indicador

## Usage

``` r
metaideb
```

## Format

An object of class `list` of length 2.

## Source

<https://www.gov.br/inep/pt-br/areas-de-atuacao/pesquisas-estatisticas-e-indicadores/>
