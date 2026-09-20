# AGENTS.md

Guidance for AI agents working in this repository.

## What this is

`edubr` is an R package (v0.2.0; renamed from `educabR` in 2026-09 — GitHub repo rename pending) that downloads, parses, and tidies Brazilian educational statistics from INEP/MEC (IDEB, AFD, age-grade distortion rates) and ships a bundled table of federal university/institute campuses per municipality. Each `le_*` function downloads a ZIP/XLSX from a gov.br URL, parses INEP's multi-row hierarchical spreadsheet headers, and pivots the data into a long tidy tibble.

## Commands

No Makefile or CI. Standard R package tooling (roxygen2 7.3.2):

```r
devtools::document()   # regenerate NAMESPACE + man/ from roxygen comments (do NOT hand-edit those)
devtools::check()      # or R CMD check . — the only automated verification available
devtools::install()    # local install
usethis::use_data(metainep, overwrite = TRUE)  # after regenerating data in data-raw/
```

There are no tests (no testthat, no tests/ dir) and no linting config. The only realistic smoke test is calling a `le_*` function, which requires network access to INEP.

## Critical gotchas

- **Dependencies are declared in `Imports:` but never attached.** All external packages (`dplyr`, `tidyr`, `readxl`, `janitor`, `stringi`, `curl`, `data.table`, `tibble`) are called namespace-qualified (`dplyr::filter(...)`). Keep this pattern — no `library()` calls inside package code. There is no `@import`/`@importFrom` roxygen tag either; when you need a tidyselect helper inside a `pkg::` call, qualify it (e.g. `dplyr::everything()`, as an unqualified `everything()` resolves under `devtools::load_all()` but fails in the installed package). `readxl` additionally has a runtime `requireNamespace()` check with a friendly pt-BR message — keep it.
- `Depends: R (>= 4.1.0)` matches the code's use of the native pipe `|>` and lambda shorthand `\(x)`.
- **`le_censoescolar` is NOT part of the package** (v0.2.0): it was broken WIP (undefined `dados` object, nonexistent `replica` arg, IDEB-specific copy-paste over censo-escolar microdados) and was moved to `data-raw/le_censoescolar_WIP.R`, excluded from the build. Exported API is `le_ideb`, `le_afd`, `le_idadeserie` (+ bundled data `metainep`, `metaideb`, `campi_municipios`).
- README.md documents the real API (rewritten for `edubr` v0.2.0). Trust NAMESPACE over README if they ever diverge again.
- **INEP's CDN is hostile to scripted downloads**: it rate-limits sequential requests and has TLS handshake problems. `le_afd` works around this with `curl` handles that disable SSL verification (`ssl_verifypeer = 0`), force HTTP/1.1, and send a Firefox user agent; `le_idadeserie` passes `extra = '-k'` to `download.file`. Pass `cache_dir` to `le_afd` to avoid re-downloads. Preserve these workarounds.
- **Untracked files in `data/` and the repo root must not be committed**: `2025-*-backup-metainep.rda` (manual backups), `microdados_censo_da_educacao_superior_2023/` (hundreds of MB of raw microdata) and `microdados_censo_cache/` (the per-year ZIP cache written by `data-raw/campi_municipios.R`). All three are in `.gitignore`.
- **`campi_municipios` is derived, not authoritative.** The INEP Higher Education Census microdata has no campus register: the IES file is one row per institution with the sede/reitoria address only, and neither file has a campus name or creation year. The campus table approximates a campus by each municipality where the institution offers a *presencial* course. `ano_criacao_campus` is therefore an **inference**: the first year of the 2008-2023 microdata panel in which the (institution, municipality) pair appears, with three-tier precedence (presencial course > any course > institution present). Because a usable institution identifier only exists from 2008 on, the value `2008` means "2008 or earlier" (268 of 779 rows, ~34%). Microdata for 1995-2007 do download fine, but carry no institution code or name (only academic-organization categories such as `ORDEMORGACAD`/`NOMEORGACAD`/`CO_ORG`), so they cannot be joined into the panel. See `data-raw/campi_municipios.R`.

## Architecture

Control flow, shared by every `le_*` reader:

1. Filter the exported `metainep` data frame (lazy-loaded from `data/metainep.rda`, referenced as `edubr::metainep`) with `grepl()` on `assunto`/`tabela` and the year against `tab_url` to resolve the source URL. **`metainep` is the package's URL registry** — if INEP moves files, functions break until it is regenerated.
2. Download the ZIP with a local `retry()` helper (defined inline in *each* function — intentionally duplicated; based on a StackOverflow pattern) with up to 5 attempts.
3. Unzip, locate the XLSX/CSV by filename regex, read specific header rows with `readxl::read_excel(range = cell_rows(...))`, merge multi-row hierarchical headers into single names, and pivot to long format.
4. Filter to valid rows (`!is.na(codigo_municipio)`), apply filters from function arguments.

Output schema is harmonized across functions (see `le_ideb`): `codigo_municipio`, `nome_municipio`, `rede`, `ano`, `indicador`, `detalhe`, `valor`. `le_afd` differs (uf/localizacao/dependencia_administrativa/nivel/subnivel). New readers should harmonize with this schema.

Per-file parsing details are magic-tuned and will break if INEP changes spreadsheet layouts:

- Header row ranges differ per source: `le_ideb` rows 8:10, `le_afd` rows 7:10 (plus manual cell patches at columns 8 and 28), `le_idadeserie` rows 6:8 + a codes row at 9.
- `le_afd` joins header levels with the literal separator `"9"`, then `gsub(9, "-", ...)` converts it to `-` (avoids clashing with `_` already present in labels). Column-name normalization in `le_ideb` is a long heuristic `gsub` chain mapping Portuguese labels to `indicador`/`detalhe` values.

### Data regeneration (`data-raw/`, excluded from build via .Rbuildignore)

- `data-raw/metainep.R` scrapes INEP's site with `rvest::read_html_live()` (headless Chrome via chromote; sets `options(chromote.headless = "new")`), clicks JS tabs, and collects zip/xls/pdf links into `metainep`, then `usethis::use_data(metainep, overwrite = TRUE)`. Brittle against site redesigns; hard-coded row removals (`assuntos[1:23]`, indices 4/5/6/9) reflect the site as of 2025-01/2025-06.
- `data-raw/metaideb.R` derives `metaideb` (distinct dimension values of `le_ideb` output) by actually calling `le_ideb()` — requires network.
- `data-raw/campi_municipios.R` defines `cria_campi_municipios()`, which reads the bundled Censo da Educação Superior microdata (both CSVs, column-pruned via `data.table::fread(..., select=)`; the cursos file is ~374 MB), keeps public federal institutions (`TP_REDE == 1`, `TP_CATEGORIA_ADMINISTRATIVA == 1`, `TP_ORGANIZACAO_ACADEMICA %in% c(1, 4, 5)`), reduces to one row per (IES, municipality) using **presencial courses only**, writes `data-raw/campi_municipios.csv`, and calls `usethis::use_data()`. Filtering out EAD is essential: distance-learning poles would otherwise inflate institutions like UFPI from 4 to 50 "campuses".
- To date each campus, the same file walks the whole microdata panel with `baixa_microdados()` (downloads `microdados_censo_da_educacao_superior_{ano}.zip` for 2008-2023 into `cache_dir`, skipping files already present; 2009-2023 share the same `dados/MICRODADOS_CADASTRO_CURSOS_.CSV` layout with `CO_IES`, `CO_MUNICIPIO`, `NO_MUNICIPIO`, `TP_MODALIDADE_ENSINO`, so there is no 2021 gap) and `le_cursos_ano()` (unzips the CSV, reads only 4 columns, deletes the extracted ~300 MB file via `on.exit`). 2008 uses the legacy layout `DADOS/GRADUACAO_{PRESENCIAL,DISTANCIA}.CSV` (separator `|`, columns `IES`/`CODMUNIC_CURSO`/`NOME_MUNICIPIO`, modality implied by the file); `codmun_ibge()` converts the old 12-digit municipality code (UF + mesorregião + microrregião + município + ordem) to the modern 7-digit IBGE code by rebuilding the check digit (weights 1,2 alternating, digit-sum decomposition). `le_cursos_ano()` returns `NULL` for years before 2008. First appearance per (IES, municipality) is accumulated in hash environments. Do not replace the positional `match()` join of IES attributes with `merge()` — `merge()` reorders rows and would misalign the computed years.
- `data-raw/proto_generate_data_document.R` is a scratch helper that generates roxygen `\item{}` blocks for data docs.
- `data-raw/le_censoescolar_WIP.R` is the unfinished censo-escolar reader removed from the package in v0.2.0 (see gotchas above).
- `R/metainep.R` and `R/metaideb.R` are **data documentation stubs**, not code: roxygen `@format` blocks ending in the quoted data name (e.g. `"metainep"`). This is how lazy-loaded data gets man pages.
- `data-raw/campi_ano_criacao_fonte_externa.csv` (+ methodology in `data-raw/campi_ano_criacao_FONTE_EXTERNA.md`) is **web-researched provenance, NOT INEP microdata**: per-campus creation years for the 268 `ano_criacao_campus == 2008` pairs, with `escola_predecessora`/`campus_federal` rows and source URLs (LLM web agent, consulted 2026-09-20). The .md documents the conventions (two-row predecessor rule, most-recent-date rule) and the 10 documented year-NAs.

## Conventions

- Code comments, roxygen docs, and data values (`indicador`, `detalhe`) are in **Portuguese**; commit messages mix Portuguese and English.
- Base R pipe `|>` (not magrittr `%>%`) and lambda `\(x)` shorthand everywhere.
- `le_ideb(replica=TRUE)` duplicates biennial (odd-year) IDEB values into the following even year — IDEB is only published every two years.
- Function args are validated by membership checks against allowed string values (see the `if(x %in% c(...))` filter chain in `le_afd`).
