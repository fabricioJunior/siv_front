part of 'categoria_bloc.dart';

enum CategoriaStep {
  inicial,
  carregando,
  carregado,
  editando,
  salvo,
  criado,
  falha,
}

class CategoriaState extends Equatable {
  final CategoriaStep categoriaStep;
  final String? nome;
  final int? id;
  final bool inativa;

  const CategoriaState({
    required this.categoriaStep,
    this.nome,
    this.id,
    this.inativa = false,
  });

  factory CategoriaState.fromModel(
    Categoria categoria, {
    CategoriaStep step = CategoriaStep.carregado,
  }) {
    return CategoriaState(
      categoriaStep: step,
      nome: categoria.nome,
      id: categoria.id,
      inativa: categoria.inativa,
    );
  }

  CategoriaState copyWith({
    CategoriaStep? categoriaStep,
    String? nome,
    int? id,
    bool? inativa,
  }) {
    return CategoriaState(
      categoriaStep: categoriaStep ?? this.categoriaStep,
      nome: nome ?? this.nome,
      id: id ?? this.id,
      inativa: inativa ?? this.inativa,
    );
  }

  @override
  List<Object?> get props => [categoriaStep, nome, id, inativa];
}
