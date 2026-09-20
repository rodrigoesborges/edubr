# Metodologia: `campi_ano_criacao_fonte_externa.csv`

## Objetivo

O painel derivado do Censo da Educação Superior marca 268 campi com `ano_criacao_campus == 2008`
(genérico, herdado da Lei 11.892/2008 ou de outra data-padrão). Esta tabela substitui esse valor
por anos de criação pesquisados um a um na web, com fonte URL para cada linha, e separa a escola
predecessora do campus federal quando aplicável.

**Não é dado do INEP**: foi obtido externamente por agente de pesquisa web (ver abaixo) e deve ser
tratado como tabela de referência, separada do painel derivado dos microdados.

## Método

- **Ferramenta**: agente LLM com navegação web (`agentic_fetch`), em lotes de uma instituição por
  chamada (instituições com mais de ~8 municípios foram divididas em 2 chamadas). Chamadas que
  falharam por erro de conexão foram repetidas no lote seguinte.
- **Data de consulta**: 2026-09-20 (coluna `data_consulta`).
- **Prompt usado** (adaptado por instituição):

> Pesquise na web (PT-BR). Mapeio o ano de criação de campi de instituições federais de ensino.
> Instituição atual: [X]. Para CADA município: [lista] — descubra: (1) a escola/instituição
> predecessora do campus (ex.: escola técnica, CEFET, faculdade privada/estadual, colégio agrícola,
> unidade descentralizada) com NOME e ANO de fundação/início de atividades (e ano de
> federalização/incorporação, se aplicável); (2) o ANO em que o campus passou a integrar de fato o
> [X] (se houver datas conflitantes — lei de criação vs inauguração vs primeiras aulas — informe a
> mais recente e cite as outras); (3) URL da fonte. NÃO invente: se não achar, escreva 'não
> encontrado'. Responda SOMENTE com tabela markdown, uma linha por município: Município | Escola
> predecessora (nome, ano fundação, ano federalização) | Ano de integração ao [X] | Fonte(s) URL |
> Observação.

- Fontes preferidas: páginas oficiais da instituição, Planalto/Câmara (leis e decretos), Wikipédia
  como último recurso (sempre anotada quando divergente da fonte oficial).

## Formato

Colunas: `sigla_universidade`, `nome_municipio`, `codigo_municipio` (do painel do Censo),
`entidade`, `tipo_entidade` (`escola_predecessora` ou `campus_federal`), `ano`, `fonte_url`,
`observacao`, `data_consulta`.

## Convenções adotadas

1. **Regra das duas linhas**: quando o campus vem de uma escola predecessora, cria-se uma linha
   `escola_predecessora` (nome da escola, ano de fundação) e uma `campus_federal` (instituição
   federal atual, ano em que o campus passou de fato a integrá-la). Sem predecessora, apenas a
   linha `campus_federal`.
2. **Linhagem das Escolas de Aprendizes Artífices (Decreto 7.566/1909)**: sedes de CEFET/IF dessa
   rede recebem escola 1909 (ou ano da escola local) + campus 2008 (Lei 11.892).
3. **"Faculdades fundadoras"** (sedes de universidades): ano da linha `escola_predecessora` = ano
   da escola fundadora mais antiga (ex.: UFRJ 1792, Engenharia; UFRGS 1895; UFC 1903; UFF 1912;
   UFPB 1947; UFRN 1949).
4. **Regra da data mais recente** para conflitos (lei de criação vs inauguração vs primeiras aulas
   vs federalização), sempre anotada na observação com as datas alternativas. Refinamento: uma
   data oficial bem documentada prevalece sobre data secundária sem fonte, mesmo que mais antiga
   (ex.: UFPR 1950, e não 1951 da Wikipédia; UFMS Chapadão do Sul 2006, e não 2008). Renomeações e
   inauguração de prédios novos NÃO contam como data.
5. **Escola predecessora que era unidade da própria instituição** (colégio agrícola, UNED, campus
   avançado criado pela própria rede) recebe linha `escola_predecessora`; posto avançado de OUTRA
   universidade que nunca foi incorporado fica apenas na observação (ex.: campus avançado da UFSM
   em Boa Vista 1969-85, anterior à UFRR; campi da URCAMP não incorporados pela UNIPAMPA; CEFET/
   FACJU/FUMDHAM apenas cedentes de prédio à UNIVASF).
6. **NA honesto**: quando o ano não foi localizado, o campo `ano` fica vazio e a observação
   explica a busca.

## Cobertura e validação

- 268/268 pares (sigla, município) do grupo `ano_criacao_campus == 2008` cobertos; 0 pares fora da
  lista (verificado por anti-join em ambos os sentidos).
- 421 linhas: 268 `campus_federal` + 153 `escola_predecessora` (153 dos 268 campi têm escola
  predecessora documentada).
- 10 linhas sem ano (NA honesto), todas com justificativa na observação:
  - Reitorias sem unidade de ensino datável: IF Goiano Goiânia, IFMG Belo Horizonte, IFFarroupilha
    Santa Maria.
  - Ano da escola não localizado: EMINAS Araxá (CEFET/MG), Escola Agrotécnica Municipal Dorvalino
    Minozzo (IFMT Campo Novo do Parecis), Texcel Francisco Beltrão (UTFPR), Ceprovale Santo Augusto
    (IFFarroupilha).
  - Ano do campus não localizado: IFPI Floriano, UNIR Ji-Paraná e UNIR Vilhena.

## Ressalvas

- Datas podem mudar com revisão de fontes oficiais; a coluna `observacao` preserva as datas
  alternativas encontradas para reanálise.
- Casos conhecidos de conflito não resolvido de todo: UFMA Caxias (2004 na fonte local vs 2010
  adotado), UFSC Araras (integração 1991 vs primeiro curso 1993), UNIFAP Oiapoque (campus 2007 vs
  Resolução 2013 adotada).
- A pesquisa foi feita em 2026-09-20; páginas oficiais podem ser movidas (várias fontes já
  dependem do Internet Archive, cujas URLs constam na coluna `fonte_url`).
