import 'package:comercial/domain/models/danfe.dart';
import 'package:comercial/domain/models/documento_fiscal.dart';
import 'package:comercial/domain/models/romaneio.dart';
import 'package:core/impressoras/printers/sefaz_nfce_portais.dart';

const _formasPagamentoWebmania = {
  '01': 'Dinheiro',
  '02': 'Cheque',
  '03': 'Cartão de Crédito',
  '04': 'Cartão de Débito',
  '05': 'Crédito Loja',
  '10': 'Vale Alimentação',
  '11': 'Vale Refeição',
  '12': 'Vale Presente',
  '13': 'Vale Combustível',
  '14': 'Duplicata Mercantil',
  '15': 'Boleto Bancário',
  '17': 'PIX',
  '18': 'Transferência bancária, Carteira Digital',
  '19': 'Programa de fidelidade, Cashback, Crédito Virtual',
  '91': 'Pagamento posterior',
  '90': 'Sem pagamento',
  '99': 'Outros',
};

/// Extrai numero e serie da chave de acesso (44 digitos, padrao SEFAZ):
/// posicoes 22-24 = serie, 25-33 = numero da nota.
({String numero, String serie})? _numeroSerie(String? chaveAcesso) {
  final chave = chaveAcesso?.replaceAll(RegExp(r'\D'), '');
  if (chave == null || chave.length != 44) return null;
  return (
    serie: chave.substring(22, 25).replaceFirst(RegExp(r'^0+(?=\d)'), ''),
    numero: chave.substring(25, 34).replaceFirst(RegExp(r'^0+(?=\d)'), ''),
  );
}

Map<String, dynamic>? _webmaniaPayload(DocumentoFiscal documento) {
  final wm = documento.payload?['webmania'];
  if (wm is! Map<String, dynamic>) return null;
  final p = wm['payload'];
  return p is Map<String, dynamic> ? p : null;
}

/// Constroi o [DanfeLayoutData] a partir do payload fiscal do documento
/// (`documento.payload.webmania.payload`, formato usado ao montar a
/// requisicao pra webMania -- ver `IntegracaoFiscalService.
/// buildWebmaniaPayloadFromRomaneio` no apollo-api) e, quando disponivel,
/// dos dados da empresa no [romaneio] (nome/CNPJ -- nao ha endereco, IE nem
/// telefone da empresa disponiveis no app hoje, ver nota em [DanfeEmpresa]).
DanfeLayoutData construirDanfeLayoutData(
  DocumentoFiscal documento, {
  Romaneio? romaneio,
}) {
  final webmaniaPayload = _webmaniaPayload(documento);
  final pedido = webmaniaPayload?['pedido'];
  final destinatario = webmaniaPayload?['destinatario'];
  final numeroSerie = _numeroSerie(documento.chaveAcesso);
  final ehNfce = documento.tipoDocumento.toLowerCase().contains('nfce');

  return DanfeLayoutData(
    empresa: DanfeEmpresa(
      razaoSocial: romaneio?.empresaNome ?? 'Empresa não identificada',
      nomeFantasia: romaneio?.empresaNomeFantasia,
      cnpj: romaneio?.empresaCnpj,
      // Inscricao estadual, endereco e telefone da empresa nao sao expostos
      // hoje em nenhum modelo/endpoint consumido pelo app (Romaneio so tem
      // nome/nomeFantasia/cnpj) -- ficam nulos ate existir essa fonte.
      inscricaoEstadual: null,
      endereco: null,
      telefone: null,
    ),
    identificacao: DanfeIdentificacao(
      tipoDocumento: ehNfce ? 'NFC-e' : 'NF-e',
      numero: numeroSerie?.numero,
      serie: numeroSerie?.serie,
      dataEmissao: documento.updatedAt,
      ehNfce: ehNfce,
    ),
    itens: _itens(webmaniaPayload),
    totais: _totais(pedido, documento),
    pagamentos: _pagamentos(pedido),
    // Troco nao vai no payload webMania (filtrado antes de montar o pedido) --
    // vem de `Romaneio.troco` (novo campo em `RomaneioImpressaoDto` no apollo-api).
    troco: romaneio?.troco,
    consumidor: DanfeConsumidor(
      nome: documento.pessoaNome,
      documento: destinatario is Map
          ? ((destinatario['cnpj'] as String?)?.isNotEmpty == true
              ? destinatario['cnpj'] as String?
              : destinatario['cpf'] as String?)
          : null,
    ),
    tributosAproximados: null, // Sem fonte de dado hoje (webMania nao devolve, payload nao guarda).
    autorizacao: DanfeAutorizacao(
      chaveAcesso: documento.chaveAcesso,
      protocolo: documento.protocolo,
      dataAutorizacao: documento.updatedAt,
    ),
    // URL de consulta do QR Code -- montada a partir do cUF (2 primeiros
    // digitos da propria chave de acesso) + portal SEFAZ da UF, sem
    // depender de campo separado no payload (ver `sefaz_nfce_portais.dart`).
    qrCodePayload: sefazNfceUrl(documento.chaveAcesso),
    mensagensRodape: [
      if (ehNfce) 'Não permite aproveitamento de crédito de ICMS',
      if (documento.erroMensagem != null) 'Obs.: ${documento.erroMensagem}',
      'Romaneio #${documento.romaneioId}',
    ],
  );
}

List<DanfeItem> _itens(Map<String, dynamic>? webmaniaPayload) {
  final produtos = webmaniaPayload?['produtos'];
  if (produtos is! List) return const [];
  return produtos.whereType<Map>().map((p) {
    final quantidade = (p['quantidade'] as num?) ?? 0;
    final subtotal = (p['subtotal'] as num?);
    final total = (p['total'] as num?) ?? subtotal ?? 0;
    final valorUnitario =
        subtotal != null && quantidade > 0 ? subtotal / quantidade : (quantidade > 0 ? total / quantidade : total);
    final desconto = subtotal != null && subtotal > total ? subtotal - total : null;
    return DanfeItem(
      codigo: p['codigo']?.toString(),
      descricao: (p['nome'] ?? p['descricao'] ?? p['produto'])?.toString() ?? '-',
      quantidade: quantidade,
      unidade: (p['unidade'] as String?) ?? 'UN',
      valorUnitario: valorUnitario,
      valorTotal: total,
      desconto: desconto,
    );
  }).toList();
}

DanfeTotais _totais(dynamic pedido, DocumentoFiscal documento) {
  final valorTotal = pedido is Map && pedido['total'] is num
      ? pedido['total'] as num
      : (documento.payload?['valorLiquido'] as num?) ?? 0;
  final desconto = pedido is Map && pedido['desconto'] is num ? pedido['desconto'] as num : 0;
  final acrescimo = pedido is Map && pedido['frete'] is num ? pedido['frete'] as num : 0;
  return DanfeTotais(
    subtotal: valorTotal - acrescimo + desconto,
    descontos: desconto,
    acrescimos: acrescimo,
    total: valorTotal,
  );
}

/// `forma_pagamento`/`valor_pagamento` podem vir como valor unico ou como
/// lista (venda com pagamento split -- ver `resolvePagamentosWebmania` no
/// apollo-api).
List<DanfePagamento> _pagamentos(dynamic pedido) {
  if (pedido is! Map) return const [];
  final formaRaw = pedido['forma_pagamento'];
  final valorRaw = pedido['valor_pagamento'];
  if (formaRaw == null) return const [];

  final formas = formaRaw is List ? formaRaw : [formaRaw];
  final valores = valorRaw is List ? valorRaw : [valorRaw];

  return List.generate(formas.length, (i) {
    final codigo = formas[i]?.toString();
    final valor = i < valores.length ? num.tryParse(valores[i]?.toString() ?? '') : null;
    return DanfePagamento(
      forma: _formasPagamentoWebmania[codigo] ?? (codigo?.isNotEmpty == true ? codigo! : '-'),
      valor: valor ?? 0,
    );
  });
}
