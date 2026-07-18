/// Portal de consulta de NFC-e por UF, indexado pelo `cUF` (codigo IBGE da
/// UF que autorizou a nota -- tabela oficial SEFAZ). Usado pra montar a URL
/// do QR Code de consulta sem depender de nenhum campo extra vindo do
/// gateway fiscal: o `cUF` ja esta embutido nos 2 primeiros digitos da
/// propria chave de acesso (`chNFe`, 44 digitos).
const Map<int, String> sefazNfcePortal = {
  11: 'https://www.nfce.sefin.ro.gov.br',
  12: 'https://www.sefaznet.ac.gov.br/nfce',
  13: 'https://nfce.sefaz.am.gov.br',
  14: 'https://www.sefaz.rr.gov.br/nfce',
  15: 'https://www.sefa.pa.gov.br/nfce',
  16: 'https://www.sefaz.ap.gov.br/nfce',
  17: 'https://www.sefaz.to.gov.br/nfce',
  21: 'https://www.sefaz.ma.gov.br/nfce',
  22: 'https://webas.sefaz.pi.gov.br/nfce',
  23: 'https://nfce.sefaz.ce.gov.br',
  24: 'https://nfce.set.rn.gov.br',
  25: 'https://www.sefaz.pb.gov.br/nfce',
  26: 'https://nfce.sefaz.pe.gov.br',
  27: 'https://nfce.sefaz.al.gov.br',
  28: 'https://www.sefaz.se.gov.br/nfce',
  29: 'https://nfe.sefaz.ba.gov.br',
  31: 'https://www.fazenda.mg.gov.br/portalnfce',
  32: 'https://app.sefaz.es.gov.br/ConsultaNFCe',
  33: 'https://www4.fazenda.rj.gov.br/consultaNFCe',
  35: 'https://www.nfce.fazenda.sp.gov.br',
  41: 'https://www.fazenda.pr.gov.br/nfce',
  42: 'https://sat.sef.sc.gov.br/nfce',
  43: 'https://www.sefaz.rs.gov.br/NFCE',
  50: 'https://www.dfe.ms.gov.br/nfce',
  51: 'https://www.sefaz.mt.gov.br/nfce',
  52: 'https://nfce.sefaz.go.gov.br',
  53: 'https://www.fazenda.df.gov.br/nfce',
};

/// Monta a URL de consulta do QR Code da NFC-e a partir da chave de acesso
/// (44 digitos): `cUF` = 2 primeiros digitos, portal resolvido via
/// [sefazNfcePortal]. Retorna `null` quando a chave e invalida (nao tem 44
/// digitos) ou o `cUF` nao esta mapeado -- nesses casos o node de QR Code
/// simplesmente nao e renderizado (sem inventar URL generica que poderia
/// levar a pagina errada).
String? sefazNfceUrl(String? chNFe) {
  final chave = chNFe?.replaceAll(RegExp(r'\D'), '');
  if (chave == null || chave.length != 44) return null;

  final cUF = int.tryParse(chave.substring(0, 2));
  final portal = sefazNfcePortal[cUF];
  if (portal == null) return null;

  return '$portal/$chave';
}
