/// Modelo de dados do DANFE (NFC-e/NF-e) independente de formato de saida --
/// nao depende de `pdf` nem de `printing_ffi`. Populado a partir do payload
/// fiscal (ver `danfe_mapper.dart`) e consumido pelos renderers (PDF e
/// ESC/POS) em `presentation/relatorios/danfe/`.
class DanfeLayoutData {
  final DanfeEmpresa empresa;
  final DanfeIdentificacao identificacao;
  final List<DanfeItem> itens;
  final DanfeTotais totais;
  final List<DanfePagamento> pagamentos;
  final num? troco;
  final DanfeConsumidor consumidor;
  final num? tributosAproximados;
  final DanfeAutorizacao autorizacao;
  final String? qrCodePayload;
  final List<String> mensagensRodape;

  const DanfeLayoutData({
    required this.empresa,
    required this.identificacao,
    required this.itens,
    required this.totais,
    required this.pagamentos,
    this.troco,
    required this.consumidor,
    this.tributosAproximados,
    required this.autorizacao,
    this.qrCodePayload,
    this.mensagensRodape = const [],
  });
}

class DanfeEmpresa {
  final String razaoSocial;
  final String? nomeFantasia;
  final String? cnpj;
  final String? inscricaoEstadual;
  final String? endereco;
  final String? telefone;

  const DanfeEmpresa({
    required this.razaoSocial,
    this.nomeFantasia,
    this.cnpj,
    this.inscricaoEstadual,
    this.endereco,
    this.telefone,
  });
}

class DanfeIdentificacao {
  /// "NFC-e" ou "NF-e".
  final String tipoDocumento;
  final String? numero;
  final String? serie;
  final DateTime? dataEmissao;
  /// Data/hora em que a venda (romaneio) foi realizada -- pode divergir da
  /// [dataEmissao] quando o documento fiscal e reprocessado depois da venda.
  final DateTime? dataVenda;
  final bool ehNfce;

  const DanfeIdentificacao({
    required this.tipoDocumento,
    this.numero,
    this.serie,
    this.dataEmissao,
    this.dataVenda,
    this.ehNfce = true,
  });
}

class DanfeItem {
  final String? codigo;
  final String descricao;
  final num quantidade;
  final String unidade;
  final num valorUnitario;
  final num valorTotal;
  final num? desconto;

  const DanfeItem({
    this.codigo,
    required this.descricao,
    required this.quantidade,
    required this.unidade,
    required this.valorUnitario,
    required this.valorTotal,
    this.desconto,
  });
}

class DanfeTotais {
  final num subtotal;
  final num descontos;
  final num acrescimos;
  final num total;

  const DanfeTotais({
    required this.subtotal,
    this.descontos = 0,
    this.acrescimos = 0,
    required this.total,
  });
}

class DanfePagamento {
  final String forma;
  final num valor;

  const DanfePagamento({required this.forma, required this.valor});
}

class DanfeConsumidor {
  final String? documento;
  final String? nome;

  const DanfeConsumidor({this.documento, this.nome});

  bool get identificado =>
      (documento?.trim().isNotEmpty ?? false) || (nome?.trim().isNotEmpty ?? false);
}

class DanfeAutorizacao {
  final String? chaveAcesso;
  final String? protocolo;
  final DateTime? dataAutorizacao;

  const DanfeAutorizacao({this.chaveAcesso, this.protocolo, this.dataAutorizacao});
}
