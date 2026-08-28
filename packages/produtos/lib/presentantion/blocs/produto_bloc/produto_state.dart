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
  final List<Estampa> estampasSelecionadas;
  final List<ProdutoCombinacaoCadastro> combinacoes;
  final int? id;
  final int? referenciaId;
  final String idExterno;
  final int? corId;
  final int? tamanhoId;
  final int? estampaId;
  final List<Cor> cores;
  final List<Tamanho> tamanhos;
  final List<Estampa> estampas;
  final String? erroMensagem;

  const ProdutoState({
    required this.produtoStep,
    this.etapaAtual = 0,
    this.criarCodigoBarrasAutomaticamente = true,
    this.referenciaSelecionada,
    this.coresSelecionadas = const [],
    this.tamanhosSelecionados = const [],
    this.estampasSelecionadas = const [],
    this.combinacoes = const [],
    this.id,
    this.referenciaId,
    this.idExterno = '',
    this.corId,
    this.tamanhoId,
    this.estampaId,
    this.cores = const [],
    this.tamanhos = const [],
    this.estampas = const [],
    this.erroMensagem,
  });

  factory ProdutoState.fromModel(
    Produto produto, {
    ProdutoStep step = ProdutoStep.carregado,
    List<Cor> cores = const [],
    List<Tamanho> tamanhos = const [],
    List<Estampa> estampas = const [],
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
      estampasSelecionadas: produto.estampa == null
          ? const []
          : [produto.estampa!],
      combinacoes: (produto.cor != null && produto.tamanho != null)
          ? [
              ProdutoCombinacaoCadastro(
                cor: produto.cor!,
                tamanho: produto.tamanho!,
                estampa: produto.estampa,
              ),
            ]
          : const [],
      id: produto.id,
      referenciaId: produto.referenciaId,
      idExterno: produto.idExterno,
      corId: produto.corId,
      tamanhoId: produto.tamanhoId,
      estampaId: produto.estampaId,
      cores: cores,
      tamanhos: tamanhos,
      estampas: estampas,
    );
  }

  ProdutoState copyWith({
    ProdutoStep? produtoStep,
    int? etapaAtual,
    bool? criarCodigoBarrasAutomaticamente,
    Referencia? referenciaSelecionada,
    List<Cor>? coresSelecionadas,
    List<Tamanho>? tamanhosSelecionados,
    List<Estampa>? estampasSelecionadas,
    List<ProdutoCombinacaoCadastro>? combinacoes,
    int? id,
    int? referenciaId,
    String? idExterno,
    int? corId,
    int? tamanhoId,
    int? estampaId,
    List<Cor>? cores,
    List<Tamanho>? tamanhos,
    List<Estampa>? estampas,
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
      estampasSelecionadas: estampasSelecionadas ?? this.estampasSelecionadas,
      combinacoes: combinacoes ?? this.combinacoes,
      id: id ?? this.id,
      referenciaId: referenciaId ?? this.referenciaId,
      idExterno: idExterno ?? this.idExterno,
      corId: corId ?? this.corId,
      tamanhoId: tamanhoId ?? this.tamanhoId,
      estampaId: estampaId ?? this.estampaId,
      cores: cores ?? this.cores,
      tamanhos: tamanhos ?? this.tamanhos,
      estampas: estampas ?? this.estampas,
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
    estampasSelecionadas,
    combinacoes,
    id,
    referenciaId,
    idExterno,
    corId,
    tamanhoId,
    estampaId,
    cores,
    tamanhos,
    estampas,
    erroMensagem,
  ];
}

class ProdutoCombinacaoCadastro extends Equatable {
  final Cor cor;
  final Tamanho tamanho;
  final Estampa? estampa;
  final bool selecionada;
  final String codigoDeBarras;

  const ProdutoCombinacaoCadastro({
    required this.cor,
    required this.tamanho,
    this.estampa,
    this.selecionada = true,
    this.codigoDeBarras = '',
  });

  String get chave => gerarChave(cor, tamanho, estampa);

  ProdutoCombinacaoCadastro copyWith({
    bool? selecionada,
    String? codigoDeBarras,
  }) {
    return ProdutoCombinacaoCadastro(
      cor: cor,
      tamanho: tamanho,
      estampa: estampa,
      selecionada: selecionada ?? this.selecionada,
      codigoDeBarras: codigoDeBarras ?? this.codigoDeBarras,
    );
  }

  static String gerarChave(Cor cor, Tamanho tamanho, [Estampa? estampa]) {
    final corKey = cor.id?.toString() ?? cor.nome;
    final tamanhoKey = tamanho.id?.toString() ?? tamanho.nome;
    final estampaKey = estampa == null
        ? ''
        : '|${estampa.id?.toString() ?? estampa.nome}';
    return '$corKey|$tamanhoKey$estampaKey';
  }

  @override
  List<Object?> get props => [
    cor,
    tamanho,
    estampa,
    selecionada,
    codigoDeBarras,
  ];
}
