import 'package:core/equals.dart';

mixin Ponto implements Equatable {
  int get id;
  int get valor;
  DateTime get validade;
  String get descricao;
  DateTime? get dtCriacao;
  bool get cancelado;
  String? get motivoCancelamento;
  DateTime? get dtCancelamento;
  TipoDePonto? get tipo;

  static Ponto instance({
    required int id,
    required int valor,
    required DateTime validade,
    required String descricao,
    required TipoDePonto tipo,
    DateTime? dtCriacao,
    bool? cancelado,
    String? motivoCancelamento,
    DateTime? dtCancelamento,
  }) =>
      _Ponto(
        id: id,
        valor: valor,
        validade: validade,
        descricao: descricao,
        tipo: tipo,
      );

  Ponto copyWith({
    int? valor,
    DateTime? validade,
    String? descricao,
    DateTime? dtCriacao,
    bool? cancelado,
    String? motivoCancelamento,
    DateTime? dtCancelamento,
    TipoDePonto? tipo,
  }) {
    return _Ponto(
        id: id,
        valor: valor ?? this.valor,
        validade: validade ?? this.validade,
        descricao: descricao ?? this.descricao,
        dtCriacao: dtCriacao ?? this.dtCriacao,
        cancelado: cancelado ?? this.cancelado,
        motivoCancelamento: motivoCancelamento ?? this.motivoCancelamento,
        dtCancelamento: dtCancelamento ?? this.dtCancelamento,
        tipo: tipo ?? this.tipo);
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

class _Ponto with Ponto {
  @override
  final int valor;

  @override
  final DateTime validade;

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

  const _Ponto({
    required this.id,
    required this.valor,
    required this.validade,
    required this.descricao,
    required this.tipo,
    this.dtCriacao,
    this.cancelado = false,
    this.motivoCancelamento,
    this.dtCancelamento,
  });

  @override
  final int id;
}

enum TipoDePonto {
  debito,
  credito,
}
