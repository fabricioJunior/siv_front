import 'package:core/equals.dart';

abstract class DespesaDoCaixa implements Equatable {
  int get id;
  double get valor;
  String get descricao;
  int get categoriaId;
  String? get categoriaNome;
  DateTime? get dataHora;
  String? get operadorNome;
  bool get cancelado;
  String? get motivoCancelamento;

  @override
  List<Object?> get props => [
        id,
        valor,
        descricao,
        categoriaId,
        categoriaNome,
        dataHora,
        operadorNome,
        cancelado,
        motivoCancelamento,
      ];

  @override
  bool? get stringify => true;
}

abstract class CategoriaDespesaDoCaixa implements Equatable {
  int get id;
  String get nome;

  @override
  List<Object?> get props => [id, nome];

  @override
  bool? get stringify => true;
}
