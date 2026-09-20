# edubr 0.2.0

-   O pacote `educabR` foi renomeado para `edubr`; as funções `le_ideb()`,
    `le_afd()` e `le_idadeserie()` mantêm as mesmas assinaturas e saídas.
-   Dependências declaradas formalmente no `DESCRIPTION`
    (`Imports`: curl, dplyr, janitor, readxl, stringi, tibble, tidyr) e piso
    de versão do R corrigido para 4.1.0 (o código usa o pipe nativo `|>`).
-   `le_censoescolar()` foi removida do pacote por estar incompleta; a versão
    em desenvolvimento segue preservada em `data-raw/le_censoescolar_WIP.R`.
-   Novo conjunto de dados `campi_municipios`, com os municípios brasileiros
    que possuem campi de instituições de educação superior.
-   `metainep` (catálogo de URLs do INEP) atualizado com as divulgações de
    2025.
-   Literais acentuados no código convertidos para escapes `\uXXXX`, com os
    mesmos valores (robustez de encoding em qualquer locale).
-   Site de documentação (pkgdown) e integração contínua com R-CMD-check em
    Windows, macOS e Ubuntu (R devel, release e oldrel) no GitHub.
