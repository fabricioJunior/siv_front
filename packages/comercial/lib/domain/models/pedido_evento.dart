import 'package:core/equals.dart';

abstract class PedidoEvento implements Equatable {
  int? get id;
  int? get pedidoId;
  String? get tipo;
  int? get operadorId;
  String? get observacao;
  DateTime? get criadoEm;

  factory PedidoEvento.create({
    int? id,
    int? pedidoId,
    String? tipo,
    int? operadorId,
    String? observacao,
    DateTime? criadoEm,
  }) = _PedidoEventoImpl;

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

class _PedidoEventoImpl implements PedidoEvento {
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

  const _PedidoEventoImpl({
    this.id,
    this.pedidoId,
    this.tipo,
    this.operadorId,
    this.observacao,
    this.criadoEm,
  });

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
