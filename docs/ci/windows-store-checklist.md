# Checklist para CI/CD Windows Store (Azure DevOps)

## 1) Identidade do pacote (ja informado)
- Identity Name: ValedoCear.SivFront
- Publisher: CN=B25EE2CC-9891-4248-BD5B-370EA12848D0
- Publisher Display Name: Vale do Ceara
- Store ID: 9NVMVB4DZFR2
- PFN: ValedoCear.SivFront_nstam08y50m7a
- SID: S-1-15-2-2096131051-655928859-3374687196-2091115240-3713590405-3290016653-845330940

## 2) Certificado de assinatura (obrigatorio)
- Arquivo PFX com o mesmo Publisher acima
- Senha do PFX
- Nome do arquivo PFX cadastrado em Azure DevOps Secure Files

## 3) Azure DevOps (obrigatorio)
- Nome da Service Connection para Microsoft Store (Partner Center)
- Nome do Flight (se usar flight; deixar vazio para publicar no publico)
- Variavel SubmitToStore: true ou false

## 4) Microsoft Partner Center (obrigatorio)
- App registrado no Partner Center com o mesmo Store ID
- API access ativo para a conta que sera usada pela Service Connection
- Permissoes para criar submissao e enviar pacote

## 5) Pipeline variables para preencher
- WindowsStoreServiceConnection
- StoreFlightName
- PfxSecureFileName
- PfxPassword (secret)
- SubmitToStore

## 6) Primeiro ciclo recomendado
1. Rodar pipeline com SubmitToStore=false para validar build e assinatura.
2. Conferir artefato gerado (.msixupload).
3. Rodar com SubmitToStore=true para envio automatico.

## 7) Comandos locais para troubleshoot
- fvm flutter pub get
- fvm flutter build windows --release
- fvm dart run msix:create --certificate-path <caminho.pfx> --certificate-password <senha>
