# metainep - basic metadata table - name , url, group/subject with auto-generated id - obtaining by scraping inep site at 2025-01

@format A data frame with 636 rows and 5 variables:

- grupo_id:

  id do grupo/página superior principal

- grupo:

  Nome do Grupo de assuntos/página superior principal

- grupo_url:

  url do Grupo/Página superior

- assunto_id:

  id do assunto

- assunto:

  Assunto - subgrupo de indicadores

- assunto_url:

  url do assunto

- id:

  id da tabela

- tabela:

  Nome da tabela

- periodo:

  Periodo de referencia da tabela

- tab_url:

  URL da tabela

## Usage

``` r
metainep
```

## Format

An object of class `data.frame` with 806 rows and 10 columns.

## Source

<https://www.gov.br/inep/pt-br/areas-de-atuacao/pesquisas-estatisticas-e-indicadores/>
