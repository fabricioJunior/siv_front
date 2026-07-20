import 'package:comercial/models.dart';

class PedidoPagamentoDto implements PedidoPagamento {
  @override
  final int? id;
  @override
  final int? pedidoId;
  @override
  final String? tipo;
  @override
  final int? pagamentoAvulsoId;
  @override
  final String? formaPagamento;
  @override
  final double? valorEsperado;
  @override
  final double? valorConfirmado;
  @override
  final double? taxaAplicada;
  @override
  final DateTime? confirmadoEm;
  @override
  final int? confirmadoPorOperadorId;

  const PedidoPagamentoDto({
    this.id,
    this.pedidoId,
    this.tipo,
    this.pagamentoAvulsoId,
    this.formaPagamento,
    this.valorEsperado,
    this.valorConfirmado,
    this.taxaAplicada,
    this.confirmadoEm,
    this.confirmadoPorOperadorId,
  });

  factory PedidoPagamentoDto.fromJson(Map<String, dynamic> json) {
    return PedidoPagamentoDto(
      id: _toInt(json['id']),
      pedidoId: _toInt(json['pedidoId']),
      tipo: json['tipo']?.toString(),
      pagamentoAvulsoId: _toInt(json['pagamentoAvulsoId']),
      formaPagamento: json['formaPagamento']?.toString(),
      valorEsperado: _toDouble(json['valorEsperado']),
      valorConfirmado: _toDouble(json['valorConfirmado']),
      taxaAplicada: _toDouble(json['taxaAplicada']),
      confirmadoEm: _toDate(json['confirmadoEm']),
      confirmadoPorOperadorId: _toInt(json['confirmadoPorOperadorId']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        pedidoId,
        tipo,
        pagamentoAvulsoId,
        formaPagamento,
        valorEsperado,
        valorConfirmado,
        taxaAplicada,
        confirmadoEm,
        confirmadoPorOperadorId,
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
