import 'package:comercial/models.dart';

class PedidoItemDto implements PedidoItem {
  @override
  final int? pedidoId;
  @override
  final int? produtoId;
  @override
  final int? sequencia;
  @override
  final double? solicitado;
  @override
  final double? atendido;
  @override
  final double? valorUnitario;
  @override
  final double? valorUnitDesconto;
  @override
  final int? referenciaId;
  @override
  final String? referenciaNome;
  @override
  final String? corNome;
  @override
  final String? tamanhoNome;

  const PedidoItemDto({
    this.pedidoId,
    this.produtoId,
    this.sequencia,
    this.solicitado,
    this.atendido,
    this.valorUnitario,
    this.valorUnitDesconto,
    this.referenciaId,
    this.referenciaNome,
    this.corNome,
    this.tamanhoNome,
  });

  factory PedidoItemDto.fromJson(Map<String, dynamic> json) {
    return PedidoItemDto(
      pedidoId: _toInt(json['pedidoId']),
      produtoId: _toInt(json['produtoId']),
      sequencia: _toInt(json['sequencia']),
      solicitado: _toDouble(json['solicitado']),
      atendido: _toDouble(json['atendido']),
      valorUnitario: _toDouble(json['valorUnitario']),
      valorUnitDesconto: _toDouble(json['valorUnitDesconto']),
      referenciaId: _toInt(json['referenciaId']),
      referenciaNome: json['referenciaNome']?.toString(),
      corNome: json['corNome']?.toString(),
      tamanhoNome: json['tamanhoNome']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
        pedidoId,
        produtoId,
        sequencia,
        solicitado,
        atendido,
        valorUnitario,
        valorUnitDesconto,
        referenciaId,
        referenciaNome,
        corNome,
        tamanhoNome,
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
