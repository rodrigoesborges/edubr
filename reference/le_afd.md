# Processa arquivo XLSX de resultados da AFD com colunas hierárquicas

Processa arquivo XLSX de resultados da AFD com colunas hierárquicas

## Usage

``` r
le_afd(
  ano = 2024,
  regiao = "municipios",
  localizacoes = "total",
  dependencias = "total",
  niveis = "ensino_medio",
  subniveis = "total",
  cache_dir = NULL
)
```

## Arguments

- ano:

  number , year

- regiao:

  character , one of escolas,municipios, ufs

- localizacoes:

  character, one of "total","urbana","rural"

- dependencias:

  character, one of "total","publica","privada","estadual","municipal"

- niveis:

  character, one of
  infantil,ensino_fundamental,ensino_medio,eja_fundamental,eja_medio

- subniveis:

  character, one of total,anos_iniciais,anos_finais

- cache_dir:

  character, optional directory to cache downloads (avoids
  re-downloading from INEP CDN which rate-limits sequential calls)

## Value

Tibble com dados formatados

## Examples

``` r
if (FALSE) { # \dontrun{
dados <- le_afd(ano = 2024, regiao = "municipios", niveis = "ensino_medio")
head(dados)
} # }
```
