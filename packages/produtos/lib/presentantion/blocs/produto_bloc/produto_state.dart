part of 'produto_bloc.dart';

enum ProdutoStep {
  inicial,
  carregando,
  carregado,
  editando,
  salvo,
  criado,
  falha,
}

class ProdutoState extends Equatable {
  final ProdutoStep produtoStep;
  final int etapaAtual;
  final bool criarCodigoBarrasAutomaticamente;
  final Referencia? referenciaSelecionada;
  final List<Cor> coresSelecionadas;
  final List<Tamanho> tamanhosSelecionados;
  final List<ProdutoCombinacaoCadastro> combinacoes;
  final int? id;
  final int? referenciaId;
  final String idExterno;
  final int? corId;
  final int? tamanhoId;
  final List<Cor> cores;
  final List<Tamanho> tamanhos;
  final String? erroMensagem;

  const ProdutoState({
    required this.produtoStep,
    this.etapaAtual = 0,
    this.criarCodigoBarrasAutomaticamente = false,
    this.referenciaSelecionada,
    this.coresSelecionadas = const [],
    this.tamanhosSelecionados = const [],
    this.combinacoes = const [],
    this.id,
    this.referenciaId,
    this.idExterno = '',
    this.corId,
    this.tamanhoId,
    this.cores = const [],
    this.tamanhos = const [],
    this.erroMensagem,
  });

  factory ProdutoState.fromModel(
    Produto produto, {
    ProdutoStep step = ProdutoStep.carregado,
    List<Cor> cores = const [],
    List<Tamanho> tamanhos = const [],
  }) {
    return ProdutoState(
      produtoStep: step,
      etapaAtual: 0,
      criarCodigoBarrasAutomaticamente: false,
      referenciaSelecionada: produto.referencia,
      coresSelecionadas: produto.cor == null ? const [] : [produto.cor!],
      tamanhosSelecionados: produto.tamanho == null
          ? const []
          : [produto.tamanho!],
      combinacoes: (produto.cor != null && produto.tamanho != null)
          ? [
              ProdutoCombinacaoCadastro(
                cor: produto.cor!,
                tamanho: produto.tamanho!,
              ),
            ]
          : const [],
      id: produto.id,
      referenciaId: produto.referenciaId,
      idExterno: produto.idExterno,
      corId: produto.corId,
      tamanhoId: produto.tamanhoId,
      cores: cores,
      tamanhos: tamanhos,
    );
  }

  ProdutoState copyWith({
    ProdutoStep? produtoStep,
    int? etapaAtual,
    bool? criarCodigoBarrasAutomaticamente,
    Referencia? referenciaSelecionada,
    List<Cor>? coresSelecionadas,
    List<Tamanho>? tamanhosSelecionados,
    List<ProdutoCombinacaoCadastro>? combinacoes,
    int? id,
    int? referenciaId,
    String? idExterno,
    int? corId,
    int? tamanhoId,
    List<Cor>? cores,
    List<Tamanho>? tamanhos,
    String? erroMensagem,
  }) {
    return ProdutoState(
      produtoStep: produtoStep ?? this.produtoStep,
      etapaAtual: etapaAtual ?? this.etapaAtual,
      criarCodigoBarrasAutomaticamente:
          criarCodigoBarrasAutomaticamente ??
          this.criarCodigoBarrasAutomaticamente,
      referenciaSelecionada:
          referenciaSelecionada ?? this.referenciaSelecionada,
      coresSelecionadas: coresSelecionadas ?? this.coresSelecionadas,
      tamanhosSelecionados: tamanhosSelecionados ?? this.tamanhosSelecionados,
      combinacoes: combinacoes ?? this.combinacoes,
      id: id ?? this.id,
      referenciaId: referenciaId ?? this.referenciaId,
      idExterno: idExterno ?? this.idExterno,
      corId: corId ?? this.corId,
      tamanhoId: tamanhoId ?? this.tamanhoId,
      cores: cores ?? this.cores,
      tamanhos: tamanhos ?? this.tamanhos,
      erroMensagem: erroMensagem,
    );
  }

  @override
  List<Object?> get props => [
    produtoStep,
    etapaAtual,
    criarCodigoBarrasAutomaticamente,
    referenciaSelecionada,
    coresSelecionadas,
    tamanhosSelecionados,
    combinacoes,
    id,
    referenciaId,
    idExterno,
    corId,
    tamanhoId,
    cores,
    tamanhos,
    erroMensagem,
  ];
}

class ProdutoCombinacaoCadastro extends Equatable {
  final Cor cor;
  final Tamanho tamanho;
  final bool selecionada;
  final String codigoDeBarras;

  const ProdutoCombinacaoCadastro({
    required this.cor,
    required this.tamanho,
    this.selecionada = true,
    this.codigoDeBarras = '',
  });

  String get chave => gerarChave(cor, tamanho);

  ProdutoCombinacaoCadastro copyWith({
    bool? selecionada,
    String? codigoDeBarras,
  }) {
    return ProdutoCombinacaoCadastro(
      cor: cor,
      tamanho: tamanho,
      selecionada: selecionada ?? this.selecionada,
      codigoDeBarras: codigoDeBarras ?? this.codigoDeBarras,
    );
  }

  static String gerarChave(Cor cor, Tamanho tamanho) {
    final corKey = cor.id?.toString() ?? cor.nome;
    final tamanhoKey = tamanho.id?.toString() ?? tamanho.nome;
    return '$corKey|$tamanhoKey';
  }

  @override
  List<Object?> get props => [cor, tamanho, selecionada, codigoDeBarras];
}
