import 'package:core/equals.dart';

abstract class FormaDePagamento implements Equatable {
  DateTime? get criadoEm;
  DateTime? get atualizadoEm;
  int? get id;
  String get descricao;
  int get inicio;
  int get parcelas;
  String get tipo;
  bool get inativa;

  factory FormaDePagamento.create({
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    int? id,
    required String descricao,
    required int inicio,
    required int parcelas,
    required String tipo,
    required bool inativa,
  }) = _FormaDePagamentoImpl;

  @override
  List<Object?> get props => [
        criadoEm,
        atualizadoEm,
        id,
        descricao,
        inicio,
        parcelas,
        tipo,
        inativa,
      ];

  @override
  bool? get stringify => true;
}

class _FormaDePagamentoImpl implements FormaDePagamento {
  @override
  final DateTime? criadoEm;

  @override
  final DateTime? atualizadoEm;

  @override
  final int? id;

  @override
  final String descricao;

  @override
  final int inicio;

  @override
  final int parcelas;

  @override
  final String tipo;

  @override
  final bool inativa;

  const _FormaDePagamentoImpl({
    this.criadoEm,
    this.atualizadoEm,
    this.id,
    required this.descricao,
    required this.inicio,
    required this.parcelas,
    required this.tipo,
    this.inativa = false,
  });

  @override
  List<Object?> get props => [
        criadoEm,
        atualizadoEm,
        id,
        descricao,
        inicio,
        parcelas,
        tipo,
        inativa,
      ];

  @override
  bool? get stringify => true;
}
