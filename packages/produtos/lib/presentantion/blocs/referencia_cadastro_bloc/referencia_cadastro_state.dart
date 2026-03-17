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
  final String unidadeMedida;
  final String descricao;
  final String composicao;
  final String cuidados;
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
    this.unidadeMedida = '',
    this.descricao = '',
    this.composicao = '',
    this.cuidados = '',
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
    int? Function()? referenciaId,
    String? Function()? nome,
    String? unidadeMedida,
    String Function()? descricao,
    String? composicao,
    String? cuidados,
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
      referenciaId: referenciaId == null ? this.referenciaId : referenciaId(),
      nome: nome == null ? this.nome : nome(),
      unidadeMedida: unidadeMedida ?? this.unidadeMedida,
      descricao: descricao == null ? this.descricao : descricao(),
      composicao: composicao ?? this.composicao,
      cuidados: cuidados ?? this.cuidados,
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
    unidadeMedida,
    descricao,
    composicao,
    cuidados,
    carregandoCategorias,
    carregandoSubCategorias,
    mensagem,
  ];
}
