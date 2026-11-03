# Testes manuais — leitor_camera

Marcar `[x]` e anotar data/observação. Usar um código EAN-13 impresso e um QR.

| Cenário | Chrome desktop | Safari iOS | Chrome Android | App Android | App iOS |
|---|---|---|---|---|---|
| Pede permissão da câmera ao abrir | [ ] | [ ] | [ ] | [ ] | [ ] |
| Lê EAN-13 e fecha sozinho | [ ] | [ ] | [ ] | [ ] | [ ] |
| Lê Code 128 / Code 39 | [ ] | [ ] | [ ] | [ ] | [ ] |
| Lê QR | [ ] | [ ] | [ ] | [ ] | [ ] |
| Usa câmera traseira por padrão | n/a | [ ] | [ ] | [ ] | [ ] |
| Trocar câmera funciona | [ ] | [ ] | [ ] | [ ] | [ ] |
| Lanterna aparece e liga (quando há) | n/a | [ ] | [ ] | [ ] | [ ] |
| Vibração/som ao ler | n/a | [ ] | [ ] | [ ] | [ ] |
| Mesmo código não lido 2x seguidas | [ ] | [ ] | [ ] | [ ] | [ ] |
| Permissão negada: mensagem em pt-BR e volta sem travar | [ ] | [ ] | [ ] | [ ] | [ ] |
| Cancelar (voltar) devolve ao fluxo | [ ] | [ ] | [ ] | [ ] | [ ] |
| Contagem/Venda: bipe pela câmera adiciona item | [ ] | [ ] | [ ] | [ ] | [ ] |

Web: exige HTTPS (ou localhost) e acesso a `unpkg.com`/`cdn.jsdelivr.net` (scripts do leitor carregados em runtime). Testar também com rede bloqueada: deve voltar sem travar.
