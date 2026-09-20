# Processa arquivo XLSX de resultados do IDEB com colunas hierárquicas

Processa arquivo XLSX de resultados do IDEB com colunas hierárquicas

## Usage

``` r
le_ideb(regiao = "municipios", nivel = "iniciais", replica = F)
```

## Arguments

- regiao:

  character , one of municipios, ufs, brasil

- nivel:

  character, one of iniciais,finais,medio

- replica:

  boolean, replicate value from year before on years if no index
  available

## Value

Tibble com dados formatados

## Examples

``` r
if (FALSE) { # \dontrun{
dados <- le_ideb(regiao = "municipios", nivel = "iniciais")
head(dados)
} # }
```
