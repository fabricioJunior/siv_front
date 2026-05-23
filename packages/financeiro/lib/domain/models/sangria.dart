import 'package:core/equals.dart';

abstract class Sangria implements Equatable {
  DateTime? get criadoEm;
  DateTime? get atualizadoEm;
  DateTime? get canceladoEm;
  int? get id;
  int get caixaId;
  double get valor;
  String get origem;
  String get descricao;
  String? get motivoCancelamento;
  bool get cancelado;

  factory Sangria.create({
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    DateTime? canceladoEm,
    int? id,
    required int caixaId,
    required double valor,
    required String origem,
    required String descricao,
    String? motivoCancelamento,
    bool cancelado = false,
  }) {
    return _SangriaImpl(
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm,
      canceladoEm: canceladoEm,
      id: id,
      caixaId: caixaId,
      valor: valor,
      origem: origem,
      descricao: descricao,
      motivoCancelamento: motivoCancelamento,
      cancelado: cancelado,
    );
  }

  @override
  List<Object?> get props => [
        criadoEm,
        atualizadoEm,
        canceladoEm,
        id,
        caixaId,
        valor,
        origem,
        descricao,
        motivoCancelamento,
        cancelado,
      ];

  @override
  bool? get stringify => true;
}

class _SangriaImpl implements Sangria {
  @override
  final DateTime? criadoEm;

  @override
  final DateTime? atualizadoEm;

  @override
  final DateTime? canceladoEm;

  @override
  final int? id;

  @override
  final int caixaId;

  @override
  final double valor;

  @override
  final String origem;

  @override
  final String descricao;

  @override
  final String? motivoCancelamento;

  @override
  final bool cancelado;

  const _SangriaImpl({
    this.criadoEm,
    this.atualizadoEm,
    this.canceladoEm,
    this.id,
    required this.caixaId,
    required this.valor,
    required this.origem,
    required this.descricao,
    this.motivoCancelamento,
    this.cancelado = false,
  });

  @override
  List<Object?> get props => [
        criadoEm,
        atualizadoEm,
        canceladoEm,
        id,
        caixaId,
        valor,
        origem,
        descricao,
        motivoCancelamento,
        cancelado,
      ];

  @override
  bool? get stringify => true;
}
