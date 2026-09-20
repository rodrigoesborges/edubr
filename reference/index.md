# Package index

## Leitura de bases do INEP

Funções que baixam os arquivos públicos do INEP/MEC, interpretam os
cabeçalhos hierárquicos das planilhas e devolvem dados em formato longo
(tidy), com um ano por chamada.

- [`le_ideb()`](https://rodrigoesborges.github.io/edubr/reference/le_ideb.md)
  : Processa arquivo XLSX de resultados do IDEB com colunas hierárquicas
- [`le_afd()`](https://rodrigoesborges.github.io/edubr/reference/le_afd.md)
  : Processa arquivo XLSX de resultados da AFD com colunas hierárquicas
- [`le_idadeserie()`](https://rodrigoesborges.github.io/edubr/reference/le_idadeserie.md)
  : Processa arquivo XLS de taxas de distorção idade-série (TDI) com
  colunas hierárquicas

## Dados internos

Metadados e tabelas auxiliares incluídas no pacote.

- [`metainep`](https://rodrigoesborges.github.io/edubr/reference/metainep.md)
  : metainep - basic metadata table - name , url, group/subject with
  auto-generated id - obtaining by scraping inep site at 2025-01
- [`metaideb`](https://rodrigoesborges.github.io/edubr/reference/metaideb.md)
  : metaideb - basic metadata table - name , url, group/subject with
  auto-generated id - obtaining by applying le_ideb function
- [`campi_municipios`](https://rodrigoesborges.github.io/edubr/reference/campi_municipios.md)
  : Campi de universidades e institutos federais por municipio
