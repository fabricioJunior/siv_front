# Contratos de API — E-commerces (redesign SIV)

Este documento lista os campos e endpoints que o `siv_front` já está preparado
para consumir (leitura tolerante — o app não quebra e não inventa valor
enquanto o backend não devolver isso).

> **Status 2026-09-05**: itens 1 a 4 implementados no `apollo-api`
> (branch `feat/backend-redesign-siv-ecommerce`). Detalhes/regra exata abaixo.

## 1. `GET /v1/e-commerce/{id}/referencias` — campos novos por item (implementado)

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

**Regra exata de `publicavel`/`motivosBloqueio`** (calculada no backend a
cada leitura, não persistida — depende de saldo em tempo real):
- `SEM_PRECO`: referência sem preço cadastrado na tabela de preço do e-commerce.
- `SEM_MIDIA`: referência sem nenhuma mídia pública (não excluída).
- `SEM_GRADE_ATIVA`: nenhum produto (SKU) da grade está marcado `disponivel=true`
  (`produtosDisponiveis === 0`). Tem prioridade sobre `SEM_SALDO` — só é
  reportado um dos dois, nunca os dois juntos.
- `SEM_SALDO`: tem SKU disponível na grade, mas a soma do saldo real desses
  SKUs é zero.
- `publicavel = true` quando nenhum dos motivos acima se aplica.

Isso bate com a heurística local do client (`valor`, `imagemUrl`,
`saldo`/`disponivel` dos produtos) — pode substituir a heurística local com
segurança.

**Paginação implementada**: `page`/`limit` (default 50) reais, calculados em
memória após aplicar `search`/`categoriaIds`/`comProdutoDisponivel` no banco
e `rascunho`/`publicavel` (que dependem de saldo dinâmico) em memória —
catálogos muito grandes por canal (milhares de referências) não foram
otimizados nesta rodada; ok pro volume atual.

## 2. `PATCH /v1/e-commerce/{id}/referencias/lote` (implementado)

```
PATCH /v1/e-commerce/{id}/referencias/lote
body: { "ids": [12, 44, 91], "rascunho": false }
     | { "todos": true, "rascunho": false, "filtros": { "search"?: string, "categoriaIds"?: number[] } }
resposta 200: { "atualizados": 2, "falharam": [ { "id": 91, "motivos": ["SEM_MIDIA"] } ] }
```

Publicar (`rascunho: false`) só aplica nas referências `publicavel`; as
demais voltam em `falharam` com os `motivosBloqueio` reais (não motivos
vazios). Voltar pra rascunho (`rascunho: true`) nunca falha.

## 3. `PUT /v1/e-commerce/{id}/referencias/{refId}/produtos/lote` (implementado)

```
PUT /v1/e-commerce/{id}/referencias/{refId}/produtos/lote
body: { "produtoIds": [101, 102, 103], "disponivel": true }
resposta 200: { "atualizados": 3 }
```

Usado pela matriz cor × tamanho da tela de referência (toque no cabeçalho de
linha/coluna alterna o grupo inteiro).

## 4. `GET /v1/e-commerce/` e `GET /v1/e-commerce/{id}` — contadores do canal (implementado)

`referenciasPublicadas` (`int`) e `referenciasRascunho` (`int`) por
e-commerce, para os selos "412 publicadas / 18 rascunho" no card do canal em
`/ecommerces`. 1 query agrupada pro lote inteiro (sem N+1 por canal).

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
