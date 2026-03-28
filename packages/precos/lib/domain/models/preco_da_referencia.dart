import 'package:core/equals.dart';

abstract class PrecoDaReferencia implements Equatable {
  DateTime? get atualizadoEm;
  int get tabelaDePrecoId;
  int get referenciaId;
  String get referenciaIdExterno;
  String get referenciaNome;
  double get valor;
  int get operadorId;

  factory PrecoDaReferencia.create({
    required DateTime? atualizadoEm,
    required int tabelaDePrecoId,
    required int referenciaId,
    required String referenciaIdExterno,
    required String referenciaNome,
    required double valor,
    required int operadorId,
  }) = _PrecoDaReferenciaImpl;

  @override
  List<Object?> get props => [
    atualizadoEm,
    tabelaDePrecoId,
    referenciaId,
    referenciaIdExterno,
    referenciaNome,
    valor,
    operadorId,
  ];

  @override
  bool? get stringify => true;
}

class _PrecoDaReferenciaImpl implements PrecoDaReferencia {
  @override
  final DateTime? atualizadoEm;
  @override
  final int tabelaDePrecoId;
  @override
  final int referenciaId;
  @override
  final String referenciaIdExterno;
  @override
  final String referenciaNome;
  @override
  final double valor;
  @override
  final int operadorId;

  _PrecoDaReferenciaImpl({
    required this.atualizadoEm,
    required this.tabelaDePrecoId,
    required this.referenciaId,
    required this.referenciaIdExterno,
    required this.referenciaNome,
    required this.valor,
    required this.operadorId,
  });

  _PrecoDaReferenciaImpl copyWith({
    DateTime? atualizadoEm,
    int? tabelaDePrecoId,
    int? referenciaId,
    String? referenciaIdExterno,
    String? referenciaNome,
    double? valor,
    int? operadorId,
  }) {
    return _PrecoDaReferenciaImpl(
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      tabelaDePrecoId: tabelaDePrecoId ?? this.tabelaDePrecoId,
      referenciaId: referenciaId ?? this.referenciaId,
      referenciaIdExterno: referenciaIdExterno ?? this.referenciaIdExterno,
      referenciaNome: referenciaNome ?? this.referenciaNome,
      valor: valor ?? this.valor,
      operadorId: operadorId ?? this.operadorId,
    );
  }

  @override
  List<Object?> get props => [
    atualizadoEm,
    tabelaDePrecoId,
    referenciaId,
    referenciaIdExterno,
    referenciaNome,
    valor,
    operadorId,
  ];

  @override
  bool? get stringify => true;
}

extension PrecoDaReferenciaCopyWith on PrecoDaReferencia {
  PrecoDaReferencia copyWith({
    DateTime? atualizadoEm,
    int? tabelaDePrecoId,
    int? referenciaId,
    String? referenciaIdExterno,
    String? referenciaNome,
    double? valor,
    int? operadorId,
  }) {
    if (this is _PrecoDaReferenciaImpl) {
      return (this as _PrecoDaReferenciaImpl).copyWith(
        atualizadoEm: atualizadoEm,
        tabelaDePrecoId: tabelaDePrecoId,
        referenciaId: referenciaId,
        referenciaIdExterno: referenciaIdExterno,
        referenciaNome: referenciaNome,
        valor: valor,
        operadorId: operadorId,
      );
    }

    return PrecoDaReferencia.create(
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      tabelaDePrecoId: tabelaDePrecoId ?? this.tabelaDePrecoId,
      referenciaId: referenciaId ?? this.referenciaId,
      referenciaIdExterno: referenciaIdExterno ?? this.referenciaIdExterno,
      referenciaNome: referenciaNome ?? this.referenciaNome,
      valor: valor ?? this.valor,
      operadorId: operadorId ?? this.operadorId,
    );
  }
}
