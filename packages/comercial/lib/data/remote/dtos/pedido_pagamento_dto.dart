import 'package:comercial/models.dart';

class PedidoPagamentoCobrancaDto implements PedidoPagamentoCobranca {
  @override
  final String? qrCodePix;
  @override
  final String? chavePixCopiaECola;
  @override
  final String? urlDePagamento;

  const PedidoPagamentoCobrancaDto({
    this.qrCodePix,
    this.chavePixCopiaECola,
    this.urlDePagamento,
  });

  factory PedidoPagamentoCobrancaDto.fromJson(Map<String, dynamic> json) {
    return PedidoPagamentoCobrancaDto(
      qrCodePix: json['qrCodePix']?.toString(),
      chavePixCopiaECola: json['chavePixCopiaECola']?.toString(),
      urlDePagamento: json['urlDePagamento']?.toString(),
    );
  }

  @override
  List<Object?> get props => [qrCodePix, chavePixCopiaECola, urlDePagamento];

  @override
  bool? get stringify => true;
}

class PedidoPagamentoDto implements PedidoPagamento {
  @override
  final int? id;
  @override
  final int? pedidoId;
  @override
  final int? formaDePagamentoId;
  @override
  final String? tipo;
  @override
  final double? valorEsperado;
  @override
  final double? valorConfirmado;
  @override
  final double? valorParaTroco;
  @override
  final double? taxaAplicada;
  @override
  final DateTime? confirmadoEm;
  @override
  final int? confirmadoPorOperadorId;
  @override
  final PedidoPagamentoCobranca? cobranca;
  @override
  final bool? estoqueDisponivel;

  const PedidoPagamentoDto({
    this.id,
    this.pedidoId,
    this.formaDePagamentoId,
    this.tipo,
    this.valorEsperado,
    this.valorConfirmado,
    this.valorParaTroco,
    this.taxaAplicada,
    this.confirmadoEm,
    this.confirmadoPorOperadorId,
    this.cobranca,
    this.estoqueDisponivel,
  });

  factory PedidoPagamentoDto.fromJson(Map<String, dynamic> json) {
    final cobrancaJson = json['cobranca'];
    return PedidoPagamentoDto(
      id: _toInt(json['id']),
      pedidoId: _toInt(json['pedidoId']),
      formaDePagamentoId: _toInt(json['formaDePagamentoId']),
      tipo: json['tipo']?.toString(),
      valorEsperado: _toDouble(json['valorEsperado']),
      valorConfirmado: _toDouble(json['valorConfirmado']),
      valorParaTroco: _toDouble(json['valorParaTroco']),
      taxaAplicada: _toDouble(json['taxaAplicada']),
      confirmadoEm: _toDate(json['confirmadoEm']),
      confirmadoPorOperadorId: _toInt(json['confirmadoPorOperadorId']),
      cobranca: cobrancaJson is Map<String, dynamic>
          ? PedidoPagamentoCobrancaDto.fromJson(cobrancaJson)
          : null,
      estoqueDisponivel: json['estoqueDisponivel'] as bool?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        pedidoId,
        formaDePagamentoId,
        tipo,
        valorEsperado,
        valorConfirmado,
        valorParaTroco,
        taxaAplicada,
        confirmadoEm,
        confirmadoPorOperadorId,
        cobranca,
        estoqueDisponivel,
      ];

  @override
  bool? get stringify => true;
}

int? _toInt(dynamic value) => int.tryParse(value?.toString() ?? '');

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

DateTime? _toDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}
