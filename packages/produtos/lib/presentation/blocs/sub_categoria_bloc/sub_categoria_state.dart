part of 'sub_categoria_bloc.dart';

enum SubCategoriaStep {
  inicial,
  carregando,
  carregado,
  editando,
  salvo,
  criado,
  falha,
}

class SubCategoriaState extends Equatable {
  final SubCategoriaStep subCategoriaStep;
  final String? nome;
  final int? id;
  final int categoriaId;
  final bool inativa;

  const SubCategoriaState({
    required this.subCategoriaStep,
    this.categoriaId = 0,
    this.nome,
    this.id,
    this.inativa = false,
  });

  factory SubCategoriaState.fromModel(
    SubCategoria subCategoria, {
    SubCategoriaStep step = SubCategoriaStep.carregado,
  }) {
    return SubCategoriaState(
      subCategoriaStep: step,
      nome: subCategoria.nome,
      id: subCategoria.id,
      categoriaId: subCategoria.categoriaId,
      inativa: subCategoria.inativa,
    );
  }

  SubCategoriaState copyWith({
    SubCategoriaStep? subCategoriaStep,
    String? nome,
    int? id,
    int? categoriaId,
    bool? inativa,
  }) {
    return SubCategoriaState(
      subCategoriaStep: subCategoriaStep ?? this.subCategoriaStep,
      nome: nome ?? this.nome,
      id: id ?? this.id,
      categoriaId: categoriaId ?? this.categoriaId,
      inativa: inativa ?? this.inativa,
    );
  }

  @override
  List<Object?> get props => [subCategoriaStep, nome, id, categoriaId, inativa];
}
