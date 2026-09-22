part of 'categoria_despesa_bloc.dart';

class CategoriaDespesaState extends Equatable {
  final int? id;
  final int? empresaId;
  final String? nome;
  final bool? inativa;
  final CategoriaDespesa? categoria;
  final String? erro;
  final CategoriaDespesaStep step;

  const CategoriaDespesaState({
    this.id,
    this.empresaId,
    this.nome,
    this.inativa,
    this.categoria,
    this.erro,
    required this.step,
  });

  CategoriaDespesaState.fromModel(
    CategoriaDespesa categoria, {
    CategoriaDespesaStep? step,
  })  : id = categoria.id,
        empresaId = categoria.empresaId,
        nome = categoria.nome,
        inativa = categoria.inativa,
        categoria = categoria,
        erro = null,
        step = step ?? CategoriaDespesaStep.editando;

  CategoriaDespesaState copyWith({
    int? id,
    int? empresaId,
    String? nome,
    bool? inativa,
    CategoriaDespesa? categoria,
    String? erro,
    CategoriaDespesaStep? step,
  }) {
    return CategoriaDespesaState(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      nome: nome ?? this.nome,
      inativa: inativa ?? this.inativa,
      categoria: categoria ?? this.categoria,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props =>
      [id, empresaId, nome, inativa, categoria, erro, step];
}

enum CategoriaDespesaStep {
  inicial,
  carregando,
  editando,
  salvando,
  criado,
  salvo,
  validacaoInvalida,
  falha,
}
