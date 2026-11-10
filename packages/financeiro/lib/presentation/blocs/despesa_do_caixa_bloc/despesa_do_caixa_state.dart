part of 'despesa_do_caixa_bloc.dart';

class DespesaDoCaixaState extends Equatable {
  final int? caixaId;
  final String valor;
  final String descricao;
  final int? categoriaId;
  final List<CategoriaDespesaDoCaixa> categorias;
  final String? erro;
  final DespesaDoCaixaStep step;

  const DespesaDoCaixaState({
    this.caixaId,
    this.valor = '',
    this.descricao = '',
    this.categoriaId,
    this.categorias = const [],
    this.erro,
    this.step = DespesaDoCaixaStep.inicial,
  });

  DespesaDoCaixaState copyWith({
    int? caixaId,
    String? valor,
    String? descricao,
    int? categoriaId,
    List<CategoriaDespesaDoCaixa>? categorias,
    String? erro,
    DespesaDoCaixaStep? step,
  }) {
    return DespesaDoCaixaState(
      caixaId: caixaId ?? this.caixaId,
      valor: valor ?? this.valor,
      descricao: descricao ?? this.descricao,
      categoriaId: categoriaId ?? this.categoriaId,
      categorias: categorias ?? this.categorias,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props =>
      [caixaId, valor, descricao, categoriaId, categorias, erro, step];
}

enum DespesaDoCaixaStep {
  inicial,
  editando,
  salvando,
  criado,
  validacaoInvalida,
  falha,
}
