import 'package:core/equals.dart';

abstract class Ponto implements Equatable {
  int get id;
  double get valor;
  DateTime? get validade;
  String get descricao;
  DateTime? get dtCriacao;
  bool get cancelado;
  String? get motivoCancelamento;
  DateTime? get dtCancelamento;
  TipoDePonto? get tipo;
  int? get transacaoId;
  int? get resgatado;

  factory Ponto.create({
    required int id,
    required double valor,
    DateTime? validade,
    required String descricao,
    DateTime? dtCriacao,
    required bool cancelado,
    String? motivoCancelamento,
    DateTime? dtCancelamento,
    TipoDePonto? tipo,
    int? transacaoId,
    int? resgatado,
  }) = _PontoImpl;

  @override
  List<Object?> get props => [
        id,
        valor,
        validade,
        descricao,
        dtCriacao,
        dtCancelamento,
        cancelado,
        motivoCancelamento,
        dtCancelamento,
      ];

  @override
  bool? get stringify => true;
}

class _PontoImpl implements Ponto {
  @override
  final int id;
  @override
  final double valor;
  @override
  final DateTime? validade;
  @override
  final String descricao;
  @override
  final DateTime? dtCriacao;
  @override
  final bool cancelado;
  @override
  final String? motivoCancelamento;
  @override
  final DateTime? dtCancelamento;
  @override
  final TipoDePonto? tipo;
  @override
  final int? transacaoId;
  @override
  final int? resgatado;

  _PontoImpl({
    required this.id,
    required this.valor,
    this.validade,
    required this.descricao,
    this.dtCriacao,
    required this.cancelado,
    this.motivoCancelamento,
    this.dtCancelamento,
    this.tipo,
    this.transacaoId,
    this.resgatado,
  });

  _PontoImpl copyWith({
    int? id,
    double? valor,
    DateTime? validade,
    String? descricao,
    DateTime? dtCriacao,
    bool? cancelado,
    String? motivoCancelamento,
    DateTime? dtCancelamento,
    TipoDePonto? tipo,
  }) {
    return _PontoImpl(
      id: id ?? this.id,
      valor: valor ?? this.valor,
      validade: validade ?? this.validade,
      descricao: descricao ?? this.descricao,
      dtCriacao: dtCriacao ?? this.dtCriacao,
      cancelado: cancelado ?? this.cancelado,
      motivoCancelamento: motivoCancelamento ?? this.motivoCancelamento,
      dtCancelamento: dtCancelamento ?? this.dtCancelamento,
      tipo: tipo ?? this.tipo,
    );
  }

  @override
  List<Object?> get props => [
        id,
        valor,
        validade,
        descricao,
        dtCriacao,
        dtCancelamento,
        cancelado,
        motivoCancelamento,
        dtCancelamento,
      ];

  @override
  bool? get stringify => true;
}

extension PontoCopyWith on Ponto {
  Ponto copyWith({
    int? id,
    double? valor,
    DateTime? validade,
    String? descricao,
    DateTime? dtCriacao,
    bool? cancelado,
    String? motivoCancelamento,
    DateTime? dtCancelamento,
    TipoDePonto? tipo,
  }) {
    if (this is _PontoImpl) {
      return (this as _PontoImpl).copyWith(
        id: id,
        valor: valor,
        validade: validade,
        descricao: descricao,
        dtCriacao: dtCriacao,
        cancelado: cancelado,
        motivoCancelamento: motivoCancelamento,
        dtCancelamento: dtCancelamento,
        tipo: tipo,
      );
    }
    return Ponto.create(
      id: id ?? this.id,
      valor: valor ?? this.valor,
      validade: validade ?? this.validade,
      descricao: descricao ?? this.descricao,
      dtCriacao: dtCriacao ?? this.dtCriacao,
      cancelado: cancelado ?? this.cancelado,
      motivoCancelamento: motivoCancelamento ?? this.motivoCancelamento,
      dtCancelamento: dtCancelamento ?? this.dtCancelamento,
      tipo: tipo ?? this.tipo,
    );
  }
}

enum TipoDePonto {
  debito,
  credito,
}
