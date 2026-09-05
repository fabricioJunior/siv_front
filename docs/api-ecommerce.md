# Contratos de API — E-commerces (redesign SIV)

Este documento lista os campos e endpoints que o `siv_front` já está preparado
para consumir (leitura tolerante — o app não quebra e não inventa valor
enquanto o backend não devolver isso), e os três endpoints de lote que ainda
não existem.

## 1. `GET /v1/e-commerce/{id}/referencias` — campos novos por item

| Campo | Tipo | Para quê |
| --- | --- | --- |
| `categoriaNome` | `String?` | coluna CATEGORIA da tela "Produtos no site" |
| `produtosTotal` | `int?` | denominador de GRADE ATIVA (`9 / 15`) |
| `produtosDisponiveis` | `int?` | numerador de GRADE ATIVA |
| `publicavel` | `bool?` | o backend decide; o app só exibe o selo |
| `motivosBloqueio` | `List<String>?` | códigos: `SEM_PRECO`, `SEM_MIDIA`, `SEM_SALDO`, `SEM_GRADE_ATIVA` |
| `tabelaDePrecoNome` | `String?` | frase "Falta preço na tabela X" |

**Envelope**, ao lado de `items`: `total`, `totalPublicados`, `totalRascunho`,
`totalNaoPublicaveis` (todos `int`). Sem eles, os segmentos da tela aparecem
sem número (nunca contamos a página carregada como se fosse o total).

**Paginação:** o client já manda `page` (a partir de 1) e `limit=50` em vez do
`limit=200` fixo de antes, com carregamento incremental ao rolar a tabela até
o fim. Mantém `search`, `categoriaIds`, `rascunho`. Novo filtro opcional:
`publicavel` (bool) — usado pelo segmento "Não publicáveis".

Enquanto os campos acima não existirem: os selos de grade/categoria/motivo
não aparecem, os segmentos mostram só o rótulo (sem número), e o filtro
"Não publicáveis" fica sem resultado quando `publicavel` não é reconhecido
pelo backend antigo (não trata como erro).

## 2. `PATCH /v1/e-commerce/{id}/referencias/lote` — ainda não existe

```
PATCH /v1/e-commerce/{id}/referencias/lote
body: { "ids": [12, 44, 91], "rascunho": false }
resposta 200: { "atualizados": 2, "falharam": [ { "id": 91, "motivos": ["SEM_MIDIA"] } ] }
```

O client (`EcommerceRepository.publicarReferenciasEmLote`) já tenta esse
endpoint primeiro. Se a resposta for 404 ou 405, cai automaticamente no laço
de hoje (`PATCH` individual em série, um por vez) e devolve o mesmo formato
de resultado (`atualizados` + `falharam` com motivos vazios, já que o laço
individual não sabe o motivo específico de cada falha — só que falhou).

## 3. `PUT /v1/e-commerce/{id}/referencias/{refId}/produtos/lote` — ainda não existe

```
PUT /v1/e-commerce/{id}/referencias/{refId}/produtos/lote
body: { "produtoIds": [101, 102, 103], "disponivel": true }
```

Mesmo esquema de fallback: usado pela matriz cor × tamanho da tela de
referência (toque no cabeçalho de linha/coluna alterna o grupo inteiro). Sem
o endpoint, o client faz um `PUT` por produto em série.

## 4. `GET /v1/e-commerce/` e `GET /v1/e-commerce/{id}` — contadores do canal

`referenciasPublicadas` (`int?`) e `referenciasRascunho` (`int?`) por
e-commerce, para os selos "412 publicadas / 18 rascunho" no card do canal em
`/ecommerces`. Sem eles, o card não mostra selo nenhum — o client **não**
faz uma chamada de referências por canal só pra contar.

## 5. Banners do carrossel — já implementado, sem pendência

```
POST   /v1/e-commerce/{id}/banners       multipart, campo "file" (imagem/gif/vídeo, máx 20MB)
                                          -> { id, ecommerceId, type: "Imagem"|"Video", url, ordem, ativo }
GET    /v1/e-commerce/{id}/banners       público, lista só ativos, já ordenados
PUT    /v1/e-commerce/{id}/banners/{id}  body: { ordem?, ativo? }
DELETE /v1/e-commerce/{id}/banners/{id}  204, apaga arquivo físico também
```

Permissão `ECOFM003`. Já integrado (aba dentro do painel de configuração do
canal em `/ecommerces`), sem mock nem fallback — contrato estável.

## 6. Nada muda em

`POST`/`PUT`/`DELETE /v1/e-commerce/{id}`, `/restaurar`,
`POST .../referencias`, `PATCH .../referencias/{id}`,
`GET .../referencias/{refId}/produtos`, `PUT .../produtos/{produtoId}`.

## Códigos de `motivosBloqueio` adotados no client

Como o backend ainda não envia `motivosBloqueio`, o client define o mapa de
textos em `ecommerce_referencias_page.dart` (`_textoMotivoBloqueio`) e no
checklist de `ecommerce_referencia_detalhe_page.dart`:

| Código | Texto exibido |
| --- | --- |
| `SEM_PRECO` | Falta preço na tabela do canal |
| `SEM_MIDIA` | Falta mídia — sem imagem cadastrada |
| `SEM_SALDO` | Sem saldo em estoque |
| `SEM_GRADE_ATIVA` | Nenhum item da grade disponível |

Se o backend enviar um código fora dessa lista, o client mostra o próprio
código (não quebra, não esconde a informação).

Enquanto isso, o checklist de publicação usa heurística local com os campos
que já existem hoje (`valor`, `imagemUrl`, `saldo`/`disponivel` dos
produtos) — não depende de `motivosBloqueio` pra funcionar.
