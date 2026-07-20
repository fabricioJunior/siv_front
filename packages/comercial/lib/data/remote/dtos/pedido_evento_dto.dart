import 'package:comercial/models.dart';

class PedidoEventoDto implements PedidoEvento {
  @override
  final int? id;
  @override
  final int? pedidoId;
  @override
  final String? tipo;
  @override
  final int? operadorId;
  @override
  final String? observacao;
  @override
  final DateTime? criadoEm;

  const PedidoEventoDto({
    this.id,
    this.pedidoId,
    this.tipo,
    this.operadorId,
    this.observacao,
    this.criadoEm,
  });

  factory PedidoEventoDto.fromJson(Map<String, dynamic> json) {
    return PedidoEventoDto(
      id: _toInt(json['id']),
      pedidoId: _toInt(json['pedidoId']),
      tipo: json['tipo']?.toString(),
      operadorId: _toInt(json['operadorId']),
      observacao: json['observacao']?.toString(),
      criadoEm: _toDate(json['criadoEm']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        pedidoId,
        tipo,
        operadorId,
        observacao,
        criadoEm,
      ];

  @override
  bool? get stringify => true;
}

int? _toInt(dynamic value) => int.tryParse(value?.toString() ?? '');

DateTime? _toDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}
