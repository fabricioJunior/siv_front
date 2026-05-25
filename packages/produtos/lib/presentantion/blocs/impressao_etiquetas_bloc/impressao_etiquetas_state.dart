part of 'impressao_etiquetas_bloc.dart';

enum PilhaImpressaoOrdenacao {
  insercao,
  referencia,
  referenciaCor,
  referenciaTamanho,
  cor,
  tamanho,
}

class ImpressaoEtiquetasState extends Equatable {
  final Etiqueta? etiquetaSelecionada;
  final SelectData? tabelaSelecionada;
  final Referencia? referenciaSelecionada;
  final String tituloEmpresaSessao;

  final List<Produto> produtos;
  final List<Cor> cores;
  final List<Tamanho> tamanhos;
  final Map<String, Produto> mapaCorTamanhoParaProduto;
  final Map<int, int> quantidadesPorProdutoId;

  final List<EtiquetaImpressaoItem> pilhaImpressao;
  final PilhaImpressaoOrdenacao pilhaOrdenacao;

  final bool carregandoGrade;
  final bool processando;
  final bool imprimindo;

  final String? erro;
  final String? sucesso;

  const ImpressaoEtiquetasState({
    this.etiquetaSelecionada,
    this.tabelaSelecionada,
    this.referenciaSelecionada,
    this.tituloEmpresaSessao = 'EMPRESA',
    this.produtos = const [],
    this.cores = const [],
    this.tamanhos = const [],
    this.mapaCorTamanhoParaProduto = const {},
    this.quantidadesPorProdutoId = const {},
    this.pilhaImpressao = const [],
    this.pilhaOrdenacao = PilhaImpressaoOrdenacao.insercao,
    this.carregandoGrade = false,
    this.processando = false,
    this.imprimindo = false,
    this.erro,
    this.sucesso,
  });

  bool get podeAdicionarEtiquetas {
    if (etiquetaSelecionada == null ||
        tabelaSelecionada == null ||
        referenciaSelecionada?.id == null) {
      return false;
    }

    return quantidadesPorProdutoId.values.any((q) => q > 0);
  }

  ImpressaoEtiquetasState copyWith({
    Etiqueta? Function()? etiquetaSelecionada,
    SelectData? Function()? tabelaSelecionada,
    Referencia? Function()? referenciaSelecionada,
    String? tituloEmpresaSessao,
    List<Produto>? produtos,
    List<Cor>? cores,
    List<Tamanho>? tamanhos,
    Map<String, Produto>? mapaCorTamanhoParaProduto,
    Map<int, int>? quantidadesPorProdutoId,
    List<EtiquetaImpressaoItem>? pilhaImpressao,
    PilhaImpressaoOrdenacao? pilhaOrdenacao,
    bool? carregandoGrade,
    bool? processando,
    bool? imprimindo,
    String? Function()? erro,
    String? Function()? sucesso,
  }) {
    return ImpressaoEtiquetasState(
      etiquetaSelecionada: etiquetaSelecionada != null
          ? etiquetaSelecionada()
          : this.etiquetaSelecionada,
      tabelaSelecionada: tabelaSelecionada != null
          ? tabelaSelecionada()
          : this.tabelaSelecionada,
      referenciaSelecionada: referenciaSelecionada != null
          ? referenciaSelecionada()
          : this.referenciaSelecionada,
      tituloEmpresaSessao: tituloEmpresaSessao ?? this.tituloEmpresaSessao,
      produtos: produtos ?? this.produtos,
      cores: cores ?? this.cores,
      tamanhos: tamanhos ?? this.tamanhos,
      mapaCorTamanhoParaProduto:
          mapaCorTamanhoParaProduto ?? this.mapaCorTamanhoParaProduto,
      quantidadesPorProdutoId:
          quantidadesPorProdutoId ?? this.quantidadesPorProdutoId,
      pilhaImpressao: pilhaImpressao ?? this.pilhaImpressao,
        pilhaOrdenacao: pilhaOrdenacao ?? this.pilhaOrdenacao,
      carregandoGrade: carregandoGrade ?? this.carregandoGrade,
      processando: processando ?? this.processando,
      imprimindo: imprimindo ?? this.imprimindo,
      erro: erro != null ? erro() : this.erro,
      sucesso: sucesso != null ? sucesso() : this.sucesso,
    );
  }

  @override
  List<Object?> get props => [
    etiquetaSelecionada,
    tabelaSelecionada,
    referenciaSelecionada,
    tituloEmpresaSessao,
    produtos,
    cores,
    tamanhos,
    mapaCorTamanhoParaProduto,
    quantidadesPorProdutoId,
    pilhaImpressao,
    pilhaOrdenacao,
    carregandoGrade,
    processando,
    imprimindo,
    erro,
    sucesso,
  ];
}
