## Gera o objeto interno `campi_municipios`, que vira tabela de dados do pacote.
##
## Fonte: microdados do Censo da Educacao Superior (INEP), painel 2008-2023.
##
## Por que a tabela precisa ser derivada:
##   * O arquivo de IES tem uma linha por instituicao e traz apenas o endereco
##     da sede administrativa/reitoria; nao existe campo de campus.
##   * O arquivo de cursos tambem nao tem codigo nem nome de campus.
##   * Nenhum dos dois arquivos tem ano de criacao de campus.
##
## Tratamento adotado (campi por municipio):
##   Cada municipio em que a instituicao oferta ao menos um curso PRESENCIAL e
##   tratado como um campus. Cursos a distancia sao descartados porque
##   representam polos de EAD espalhados pelo pais, e nao campi. O municipio da
##   sede e incluido mesmo que so apareca em cursos EAD.
##
## Ano de inicio do campus (inferido):
##   O INEP nao publica o ano de criacao de campi. Como o censo e anual e
##   identifica IES e municipio, adota-se a PRIMEIRA aparicao do par
##   (IES, municipio) no painel como ano de inicio do campus, na ordem:
##     1) primeiro ano com curso presencial no municipio;
##     2) primeiro ano com qualquer curso no municipio;
##     3) primeiro ano em que a IES aparece no painel.
##   Limitacao: o identificador de IES so existe nos microdados a partir de
##   2008 (campo IES, mesmo espaco de codigos do CO_IES moderno); portanto
##   todo valor igual a 2008 significa "2008 ou antes". Os arquivos de
##   1995-2007 nao trazem codigo nem nome de instituicao, apenas categorias
##   de organizacao academica (ORDEMORGACAD/NOMEORGACAD, CO_ORG/NOMEORG),
##   o que impede estender o painel para tras de 2008.
##
## O download dos ZIPs por ano e cacheado em `cache_dir`; reaproveite o mesmo
## diretorio nas reexecucoes.

URL_MICRODADOS <- "https://download.inep.gov.br/microdados/microdados_censo_da_educacao_superior_%d.zip"

baixa_microdados <- function(ano, cache_dir) {
  if (!dir.exists(cache_dir)) dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
  dest <- file.path(cache_dir, sprintf("microdados_censo_da_educacao_superior_%d.zip", ano))
  if (file.exists(dest) && file.size(dest) > 1e6) return(dest)

  ## O CDN do INEP tem problemas de TLS e limita requisicoes sequenciais;
  ## o mesmo contorno usado em le_afd se aplica aqui.
  h <- curl::new_handle()
  curl::handle_setopt(
    h, ssl_verifypeer = 0, ssl_verifyhost = 0, http_version = 2,
    useragent = "Mozilla/5.0 (X11; Linux x86_64; rv:130.0) Gecko/20100101 Firefox/130.0",
    followlocation = TRUE, timeout = 600
  )
  for (tentativa in 1:5) {
    r <- tryCatch(curl::curl_download(sprintf(URL_MICRODADOS, ano), dest, handle = h, quiet = TRUE),
                  error = function(e) e)
    if (!inherits(r, "error") && file.exists(dest) && file.size(dest) > 1e6) return(dest)
    Sys.sleep(2)
  }
  stop(sprintf("Falha ao baixar os microdados de %d", ano))
}

## Le apenas as colunas necessarias do arquivo de cursos de um ano. O CSV
## completo passa de 300 MB, por isso o `select` e obrigatorio e o arquivo
## extraido e removido logo apos a leitura.
##
## Layouts:
##   * 2009+: um arquivo MICRODADOS_CADASTRO_CURSOS_*.CSV (separador ";"),
##     colunas CO_IES/CO_MUNICIPIO/NO_MUNICIPIO/TP_MODALIDADE_ENSINO.
##   * 2008: dois arquivos, GRADUACAO_PRESENCIAL e GRADUACAO_DISTANCIA
##     (separador "|"), colunas IES/CODMUNIC_CURSO/NOME_MUNICIPIO; a
##     modalidade vem do arquivo e o codigo de municipio e o formato antigo
##     de 12 digitos, convertido por `codmun_ibge()`.
##   * 1995-2007: sem codigo de IES utilizavel, retorna NULL.
codmun_ibge <- function(x) {
  ## Ate 2008 o codigo do municipio tem 12 digitos: UF(2) + mesorregiao(2)
  ## + microrregiao(3) + municipio(4) + ordem(1). O codigo IBGE moderno de
  ## 7 digitos e UF(2) + municipio(4) + digito verificador (pesos 1 e 2
  ## alternados da esquerda para a direita, decompondo cada produto em
  ## algarismos). Reconferido contra todos os municipios do Censo 2023.
  base <- as.integer(paste0(substr(x, 1, 2), substr(x, 8, 11)))
  dv <- vapply(sprintf("%06d", base), function(s) {
    p <- as.integer(strsplit(s, "")[[1]]) * c(1L, 2L, 1L, 2L, 1L, 2L)
    soma <- sum(vapply(as.character(p), function(k) {
      sum(as.integer(strsplit(k, "")[[1]]))
    }, numeric(1)))
    (10 - soma %% 10) %% 10
  }, numeric(1), USE.NAMES = FALSE)
  as.integer(paste0(sprintf("%06d", base), dv))
}

le_cursos_ano <- function(ano, cache_dir) {
  if (ano < 2008) return(NULL)

  zip <- baixa_microdados(ano, cache_dir)
  nm <- utils::unzip(zip, list = TRUE)$Name
  tmp <- file.path(cache_dir, "_extracao")
  if (!dir.exists(tmp)) dir.create(tmp, recursive = TRUE, showWarnings = FALSE)

  if (ano >= 2009) {
    alvo <- nm[grepl("CURSOS", nm, useBytes = TRUE) & grepl("[.]CSV$", nm, useBytes = TRUE)][1]
    if (is.na(alvo)) return(NULL)
    utils::unzip(zip, files = alvo, exdir = tmp, junkpaths = TRUE)
    arquivo <- file.path(tmp, basename(alvo))
    on.exit(unlink(arquivo), add = TRUE)

    return(as.data.frame(data.table::fread(
      arquivo, sep = ";", encoding = "Latin-1",
      select = c("CO_IES", "CO_MUNICIPIO", "NO_MUNICIPIO", "TP_MODALIDADE_ENSINO")
    )))
  }

  alvos <- nm[grepl("GRADUACAO_(PRESENCIAL|DISTANCIA)", nm, useBytes = TRUE) &
                grepl("[.]CSV$", nm, useBytes = TRUE)]
  if (length(alvos) == 0) return(NULL)
  utils::unzip(zip, files = alvos, exdir = tmp, junkpaths = TRUE)
  arquivos <- file.path(tmp, basename(alvos))
  on.exit(unlink(arquivos), add = TRUE)

  partes <- lapply(arquivos, function(arquivo) {
    d <- data.table::fread(
      arquivo, sep = "|", encoding = "Latin-1",
      select = c("IES", "CODMUNIC_CURSO", "NOME_MUNICIPIO"),
      colClasses = c(CODMUNIC_CURSO = "character")
    )
    data.frame(
      CO_IES = d$IES,
      CO_MUNICIPIO = codmun_ibge(d$CODMUNIC_CURSO),
      NO_MUNICIPIO = d$NOME_MUNICIPIO,
      TP_MODALIDADE_ENSINO = if (grepl("DISTANCIA", arquivo)) 2L else 1L,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, partes)
}

cria_campi_municipios <- function(
    dir_microdados = "microdados_censo_da_educacao_superior_2023/dados",
    ano = 2023,
    anos_painel = 2008:2023,
    cache_dir = "microdados_censo_cache") {

  arquivo_ies <- file.path(dir_microdados, sprintf("MICRODADOS_ED_SUP_IES_%d.CSV", ano))
  arquivo_cursos <- file.path(dir_microdados, sprintf("MICRODADOS_CADASTRO_CURSOS_%d.CSV", ano))
  stopifnot(file.exists(arquivo_ies), file.exists(arquivo_cursos))

  ies <- as.data.frame(data.table::fread(
    arquivo_ies, sep = ";", encoding = "Latin-1",
    select = c("CO_IES", "SG_IES", "TP_ORGANIZACAO_ACADEMICA", "TP_REDE",
               "TP_CATEGORIA_ADMINISTRATIVA", "CO_MUNICIPIO_IES", "NO_MUNICIPIO_IES")
  ))

  ## Rede publica federal. Organizacao academica:
  ##   1 = Universidade
  ##   4 = Instituto Federal de Educacao, Ciencia e Tecnologia
  ##   5 = Centro Federal de Educacao Tecnologica (CEFET)
  federais <- ies[
    ies$TP_REDE == 1 &
      ies$TP_CATEGORIA_ADMINISTRATIVA == 1 &
      ies$TP_ORGANIZACAO_ACADEMICA %in% c(1, 4, 5), ,
    drop = FALSE
  ]

  cursos <- as.data.frame(data.table::fread(
    arquivo_cursos, sep = ";", encoding = "Latin-1",
    select = c("CO_IES", "CO_MUNICIPIO", "NO_MUNICIPIO", "TP_MODALIDADE_ENSINO")
  ))

  ## TP_MODALIDADE_ENSINO: 1 = presencial, 2 = a distancia.
  cursos_federais <- function(x) {
    x[x$CO_IES %in% federais$CO_IES & !is.na(x$CO_MUNICIPIO), , drop = FALSE]
  }

  cursos <- cursos_federais(cursos)
  presencial <- cursos[cursos$TP_MODALIDADE_ENSINO == 1, , drop = FALSE]

  campi <- unique(presencial[, c("CO_IES", "CO_MUNICIPIO", "NO_MUNICIPIO")])

  sede <- unique(data.frame(
    CO_IES = federais$CO_IES,
    CO_MUNICIPIO = federais$CO_MUNICIPIO_IES,
    NO_MUNICIPIO = federais$NO_MUNICIPIO_IES
  ))

  campi <- unique(rbind(campi, sede))

  ## Painel 2008-2023: primeira aparicao de cada par (IES, municipio).
  primeira_presencial <- new.env(parent = emptyenv())
  primeira_qualquer <- new.env(parent = emptyenv())
  primeira_ies <- new.env(parent = emptyenv())

  for (a in anos_painel) {
    d <- if (a == ano) cursos else tryCatch(cursos_federais(le_cursos_ano(a, cache_dir)),
                                            error = function(e) NULL)
    if (is.null(d) || nrow(d) == 0) next

    pres <- d[d$TP_MODALIDADE_ENSINO == 1, , drop = FALSE]
    pares_pres <- unique(paste(pres$CO_IES, pres$CO_MUNICIPIO))
    pares_todos <- unique(paste(d$CO_IES, d$CO_MUNICIPIO))
    ies_ano <- unique(as.character(d$CO_IES))

    for (p in pares_pres) if (is.null(primeira_presencial[[p]])) assign(p, a, envir = primeira_presencial)
    for (p in pares_todos) if (is.null(primeira_qualquer[[p]])) assign(p, a, envir = primeira_qualquer)
    for (i in ies_ano) if (is.null(primeira_ies[[i]])) assign(i, a, envir = primeira_ies)
  }

  ## Atributos da IES por correspondencia direta de posicao. Nao usar merge()
  ## aqui: ele reordena as linhas e desaliniza o vetor `anos` calculado abaixo.
  i <- match(campi$CO_IES, federais$CO_IES)
  campi$SG_IES <- federais$SG_IES[i]
  campi$TP_ORGANIZACAO_ACADEMICA <- federais$TP_ORGANIZACAO_ACADEMICA[i]

  chave <- paste(campi$CO_IES, campi$CO_MUNICIPIO)
  ano_por_par <- function(p, env) vapply(p, function(k) if (is.null(env[[k]])) NA_integer_ else env[[k]],
                                         integer(1), USE.NAMES = FALSE)
  anos <- ano_por_par(chave, primeira_presencial)
  anos <- ifelse(is.na(anos), ano_por_par(chave, primeira_qualquer), anos)
  anos <- ifelse(is.na(anos), ano_por_par(as.character(campi$CO_IES), primeira_ies), anos)

  campi <- data.frame(
    nome_campus = paste0(campi$SG_IES, " - ", campi$NO_MUNICIPIO),
    sigla_universidade = campi$SG_IES,
    tipo = ifelse(campi$TP_ORGANIZACAO_ACADEMICA == 1, "universidade", "instituto federal"),
    ano_criacao_campus = as.integer(anos),
    codigo_municipio = as.integer(campi$CO_MUNICIPIO),
    nome_municipio = campi$NO_MUNICIPIO,
    stringsAsFactors = FALSE
  )

  campi <- campi[order(campi$sigla_universidade, campi$nome_municipio, method = "radix"), ]
  rownames(campi) <- NULL
  campi
}

campi_municipios <- cria_campi_municipios()

data.table::fwrite(
  campi_municipios, "data-raw/campi_municipios.csv",
  sep = ";", encoding = "UTF-8"
)

usethis::use_data(campi_municipios, overwrite = TRUE)
