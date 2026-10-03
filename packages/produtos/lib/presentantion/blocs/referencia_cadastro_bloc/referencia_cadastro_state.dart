part of 'referencia_cadastro_bloc.dart';

enum ReferenciaCadastroStep {
  categoria,
  subCategoria,
  nome,
  preco,
  variacoes,
  concluido,
}

class ReferenciaCadastroState extends Equatable {
  final ReferenciaCadastroStep step;
  final List<Categoria> categorias;
  final List<SubCategoria> subCategorias;
  final Categoria? categoria;
  final SubCategoria? subCategoria;
  final String nome;
  final String preco;
  final String unidadeMedida;
  final String descricao;
  final String composicao;
  final String cuidados;
  final int? referenciaId;
  final bool carregandoCategorias;
  final bool carregandoSubCategorias;
  final bool salvando;
  final String? mensagem;

  const ReferenciaCadastroState({
    this.step = ReferenciaCadastroStep.categoria,
    this.categorias = const [],
    this.subCategorias = const [],
    this.categoria,
    this.subCategoria,
    this.nome = '',
    this.preco = '',
    this.unidadeMedida = '',
    this.descricao = '',
    this.composicao = '',
    this.cuidados = '',
    this.referenciaId,
    this.carregandoCategorias = false,
    this.carregandoSubCategorias = false,
    this.salvando = false,
    this.mensagem,
  });

  /// Etapas visíveis no stepper: subcategoria só existe quando a categoria tem.
  List<ReferenciaCadastroStep> get etapas => [
    ReferenciaCadastroStep.categoria,
    if (subCategorias.isNotEmpty) ReferenciaCadastroStep.subCategoria,
    ReferenciaCadastroStep.nome,
    ReferenciaCadastroStep.preco,
    ReferenciaCadastroStep.variacoes,
  ];

  /// Referência já foi criada na API -- não dá mais pra voltar e editar
  /// categoria/nome/preço por aqui.
  bool get criada => referenciaId != null;

  ReferenciaCadastroState copyWith({
    ReferenciaCadastroStep? step,
    List<Categoria>? categorias,
    List<SubCategoria>? subCategorias,
    Categoria? Function()? categoria,
    SubCategoria? Function()? subCategoria,
    String? nome,
    String? preco,
    String? unidadeMedida,
    String? descricao,
    String? composicao,
    String? cuidados,
    int? referenciaId,
    bool? carregandoCategorias,
    bool? carregandoSubCategorias,
    bool? salvando,
    String? mensagem,
  }) {
    return ReferenciaCadastroState(
      step: step ?? this.step,
      categorias: categorias ?? this.categorias,
      subCategorias: subCategorias ?? this.subCategorias,
      categoria: categoria == null ? this.categoria : categoria(),
      subCategoria: subCategoria == null ? this.subCategoria : subCategoria(),
      nome: nome ?? this.nome,
      preco: preco ?? this.preco,
      unidadeMedida: unidadeMedida ?? this.unidadeMedida,
      descricao: descricao ?? this.descricao,
      composicao: composicao ?? this.composicao,
      cuidados: cuidados ?? this.cuidados,
      referenciaId: referenciaId ?? this.referenciaId,
      carregandoCategorias: carregandoCategorias ?? this.carregandoCategorias,
      carregandoSubCategorias:
          carregandoSubCategorias ?? this.carregandoSubCategorias,
      salvando: salvando ?? this.salvando,
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
    nome,
    preco,
    unidadeMedida,
    descricao,
    composicao,
    cuidados,
    referenciaId,
    carregandoCategorias,
    carregandoSubCategorias,
    salvando,
    mensagem,
  ];
}
