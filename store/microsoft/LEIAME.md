# Microsoft Store: o que corrigir na reprovação

O revisor apontou 3 itens. Os dois primeiros e o terceiro estão **na listagem do Partner Center** (e na imagem do tile),
não no código. Tudo que dá para gerar já está nesta pasta.

| Política | Problema | Onde corrigir | Material pronto |
|---|---|---|---|
| 10.1.1.11 Tiles | "tile icons include a default image" | Partner Center → *Store listing* → **Store logos** (e conferir o ícone dentro do `.msix`) | `imagens/` |
| 10.1.1.3 Screenshots | só abertura/login | Partner Center → *Store listing* → **Screenshots** | roteiro abaixo |
| 10.1.4.3 Descrição | descrição curta/insuficiente | Partner Center → *Store listing* → **Description** (en-US **e** pt-BR) | `descricao-pt-br.md`, `descricao-en-us.md` |

O revisor cita "English (United States), Portuguese (Brazil)": **os dois idiomas precisam ser corrigidos** (descrição e screenshots).

## 1. Tiles / logos (10.1.1.11)

1. No Partner Center, em *Store listing → Store logos*, envie (apague qualquer imagem padrão/automática):
   - **1:1 (300×300):** `imagens/logo-1x1-300.png` (obrigatório)
   - **9:16/2:3 poster (720×1080):** `imagens/poster-2x3-720x1080.png`
   - **16:9 box art (1920×1080):** `imagens/boxart-16x9-1920x1080.png`
   Faça isso nos **dois idiomas** (en-US e pt-BR) se a Store mostrar os campos por idioma.
2. Confirme que o **pacote** enviado é o novo (o ícone do tile vem de `msix_config.logo_path`, já apontando para
   `assets/brand/siv_icone.png`, e `msix_version` 1.0.1.0 ou maior). Se o `.msix` enviado foi gerado antes do commit
   `5bdabc69` (01/10), gere de novo e **aumente a versão** (a Store exige versão maior a cada envio):
   ```
   # pubspec.yaml -> msix_config.msix_version: 1.0.2.0
   flutter build windows --release
   dart run msix:create --store
   ```
   Para conferir: renomeie o `.msix` para `.zip`, abra `Assets/` e veja `Square44x44Logo*`, `Square150x150Logo*`,
   `Wide310x150Logo*`, `StoreLogo*` e `SplashScreen*`: todos devem mostrar o **SIV** (branco sobre azul-marinho), nunca o
   logo azul do Flutter.

## 2. Screenshots (10.1.1.3)

Requisitos da Store: PNG/JPG, **mínimo 1366×768** (recomendado 1920×1080), de 1 a 10 imagens, mostrando o produto em uso.
Capture o app **logado com dados de demonstração** (nunca dados reais de clientes: nomes, CPF, valores). Roteiro sugerido
(use o mesmo nome em pt-BR e en-US, trocando só a legenda):

| # | Tela | Legenda pt-BR | Legenda en-US |
|---|---|---|---|
| 1 | Início (home) com indicadores | Visão geral da loja em tempo real | Real-time store overview |
| 2 | Venda (PDV) com itens e leitor de código de barras | Venda rápida no balcão, com leitor de código de barras | Fast point-of-sale with barcode scanning |
| 3 | Fechamento da venda (formas de pagamento) | Pix, cartão, dinheiro e mais, no mesmo recebimento | Pix, card, cash and more in one checkout |
| 4 | Caixa (abertura/movimentos) | Controle de caixa: abertura, sangria, suprimento e fechamento | Cash register control |
| 5 | Referência com grade (cor × tamanho) | Produtos com cores, tamanhos e código de barras | Products with colors, sizes and barcodes |
| 6 | Estoque / saldo ou balanço | Estoque e balanço sempre atualizados | Always up-to-date inventory |
| 7 | Pedidos / romaneios | Pedidos, romaneios e consignação | Orders, packing lists and consignment |
| 8 | Relatórios (faturamento / curva ABC) | Relatórios para decidir com dados | Reports to decide with data |
| 9 | Importação guiada | Importação guiada de clientes, produtos e estoque | Guided import of customers, products and stock |

Evite: tela de login, abertura/splash, telas vazias e janelas com erro. Se possível, deixe a janela maximizada.

## 3. Descrição (10.1.4.3)

Cole `descricao-pt-br.md` na listagem pt-BR e `descricao-en-us.md` na en-US (campos *Description*, *Short description*,
*Features* e *Search terms*).

## 4. Notas para a certificação (muito importante)

O app exige **login** (licenciado + usuário + senha). Sem credencial, o revisor só vê a tela de login e reprova de novo
por 10.1.1.3. Em *Submission options → Notes for certification*, informe:
```
O SIV exige conta. Para testar: abra o app, escolha o licenciado "<LICENCIADO DE DEMONSTRAÇÃO>",
usuário "<USUARIO>", senha "<SENHA>". A conta é de demonstração, com dados fictícios.
Fluxo sugerido: Início > Venda (PDV) > adicionar produto > finalizar com Pix > Caixa > Relatórios.
```
Crie um **licenciado/usuário só de demonstração** (ambiente separado, dados fictícios, permissões de leitura e venda
simples). Não use a conta administrativa nem credenciais de produção.
