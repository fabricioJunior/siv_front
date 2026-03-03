part of 'categoria_sub_categoria_selecao_bloc.dart';

abstract class CategoriaSubCategoriaSelecaoEvent extends Equatable {
  const CategoriaSubCategoriaSelecaoEvent();

  @override
  List<Object?> get props => [];
}

class CategoriaSubCategoriaSelecaoIniciou
    extends CategoriaSubCategoriaSelecaoEvent {
  final int? categoriaAtualId;
  final int? subCategoriaAtualId;

  const CategoriaSubCategoriaSelecaoIniciou({
    this.categoriaAtualId,
    this.subCategoriaAtualId,
  });

  @override
  List<Object?> get props => [categoriaAtualId, subCategoriaAtualId];
}

class CategoriaSubCategoriaCategoriaSelecionada
    extends CategoriaSubCategoriaSelecaoEvent {
  final Categoria categoria;

  const CategoriaSubCategoriaCategoriaSelecionada({required this.categoria});

  @override
  List<Object?> get props => [categoria];
}

class CategoriaSubCategoriaSubCategoriaSelecionada
    extends CategoriaSubCategoriaSelecaoEvent {
  final SubCategoria? subCategoria;

  const CategoriaSubCategoriaSubCategoriaSelecionada({this.subCategoria});

  @override
  List<Object?> get props => [subCategoria];
}

class CategoriaSubCategoriaEtapaAvancou
    extends CategoriaSubCategoriaSelecaoEvent {
  const CategoriaSubCategoriaEtapaAvancou();
}

class CategoriaSubCategoriaEtapaVoltou
    extends CategoriaSubCategoriaSelecaoEvent {
  const CategoriaSubCategoriaEtapaVoltou();
}
