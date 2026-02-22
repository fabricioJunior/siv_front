part of 'categoria_sub_categoria_selecao_bloc.dart';

enum CategoriaSubCategoriaSelecaoStep { categoria, subCategoria }

class CategoriaSubCategoriaSelecaoState extends Equatable {
  final bool carregandoCategorias;
  final bool carregandoSubCategorias;
  final List<Categoria> categorias;
  final List<SubCategoria> subCategorias;
  final Categoria? categoriaSelecionada;
  final SubCategoria? subCategoriaSelecionada;
  final CategoriaSubCategoriaSelecaoStep step;
  final String? mensagem;

  const CategoriaSubCategoriaSelecaoState({
    this.carregandoCategorias = false,
    this.carregandoSubCategorias = false,
    this.categorias = const [],
    this.subCategorias = const [],
    this.categoriaSelecionada,
    this.subCategoriaSelecionada,
    this.step = CategoriaSubCategoriaSelecaoStep.categoria,
    this.mensagem,
  });

  CategoriaSubCategoriaSelecaoState copyWith({
    bool? carregandoCategorias,
    bool? carregandoSubCategorias,
    List<Categoria>? categorias,
    List<SubCategoria>? subCategorias,
    Categoria? categoriaSelecionada,
    bool limparCategoriaSelecionada = false,
    SubCategoria? subCategoriaSelecionada,
    bool limparSubCategoriaSelecionada = false,
    CategoriaSubCategoriaSelecaoStep? step,
    String? mensagem,
    bool limparMensagem = false,
  }) {
    return CategoriaSubCategoriaSelecaoState(
      carregandoCategorias: carregandoCategorias ?? this.carregandoCategorias,
      carregandoSubCategorias:
          carregandoSubCategorias ?? this.carregandoSubCategorias,
      categorias: categorias ?? this.categorias,
      subCategorias: subCategorias ?? this.subCategorias,
      categoriaSelecionada: limparCategoriaSelecionada
          ? null
          : (categoriaSelecionada ?? this.categoriaSelecionada),
      subCategoriaSelecionada: limparSubCategoriaSelecionada
          ? null
          : (subCategoriaSelecionada ?? this.subCategoriaSelecionada),
      step: step ?? this.step,
      mensagem: limparMensagem ? null : (mensagem ?? this.mensagem),
    );
  }

  @override
  List<Object?> get props => [
    carregandoCategorias,
    carregandoSubCategorias,
    categorias,
    subCategorias,
    categoriaSelecionada,
    subCategoriaSelecionada,
    step,
    mensagem,
  ];
}
