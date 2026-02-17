part of 'referencia_cadastro_bloc.dart';

enum ReferenciaCadastroStep { categoria, subCategoria, id, nome, resumo }

class ReferenciaCadastroState extends Equatable {
  final ReferenciaCadastroStep step;
  final List<Categoria> categorias;
  final List<SubCategoria> subCategorias;
  final Categoria? categoria;
  final SubCategoria? subCategoria;
  final int? referenciaId;
  final String? nome;
  final bool carregandoCategorias;
  final bool carregandoSubCategorias;
  final String? mensagem;

  const ReferenciaCadastroState({
    this.step = ReferenciaCadastroStep.categoria,
    this.categorias = const [],
    this.subCategorias = const [],
    this.categoria,
    this.subCategoria,
    this.referenciaId,
    this.nome,
    this.carregandoCategorias = false,
    this.carregandoSubCategorias = false,
    this.mensagem,
  });

  ReferenciaCadastroState copyWith({
    ReferenciaCadastroStep? step,
    List<Categoria>? categorias,
    List<SubCategoria>? subCategorias,
    Categoria? categoria,
    SubCategoria? subCategoria,
    int? referenciaId,
    String? nome,
    bool? carregandoCategorias,
    bool? carregandoSubCategorias,
    String? mensagem,
  }) {
    return ReferenciaCadastroState(
      step: step ?? this.step,
      categorias: categorias ?? this.categorias,
      subCategorias: subCategorias ?? this.subCategorias,
      categoria: categoria ?? this.categoria,
      subCategoria: subCategoria ?? this.subCategoria,
      referenciaId: referenciaId ?? this.referenciaId,
      nome: nome ?? this.nome,
      carregandoCategorias: carregandoCategorias ?? this.carregandoCategorias,
      carregandoSubCategorias:
          carregandoSubCategorias ?? this.carregandoSubCategorias,
      mensagem: mensagem,
    );
  }

  @override
  List<Object?> get props => [
    step,
    categorias,
    subCategorias,
    categoria,
    subCategoria,
    referenciaId,
    nome,
    carregandoCategorias,
    carregandoSubCategorias,
    mensagem,
  ];
}
