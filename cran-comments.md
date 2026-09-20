## Test environments

* local Debian GNU/Linux 13 (trixie), R 4.5.3 (2026-03-11), x86_64, UTF-8 locale
* R CMD check --as-cran: 0 errors | 0 warnings | 0 notes

## R CMD check results

0 errors | 0 warnings | 0 notes

This is a new submission (renamed and overhauled version of a package that was
never on CRAN; the GitHub repository is rodrigoesborges/edubr).

* Examples in the `le_*()` functions are wrapped in `\dontrun{}` because they
  download data from INEP's CDN (download.inep.gov.br), which rate-limits and
  intermittently refuses scripted connections; the functions themselves were
  tested end-to-end against the live CDN.
* All output labels and documentation are in Brazilian Portuguese; the package
  declares `Encoding: UTF-8` and data strings in code use `\uxxxx` escapes.

## Downstream dependencies

No reverse dependencies (new package).
