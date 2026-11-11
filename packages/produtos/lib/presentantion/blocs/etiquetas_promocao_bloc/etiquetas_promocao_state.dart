part of 'etiquetas_promocao_bloc.dart';

class EtiquetasPromocaoState extends Equatable {
  final List<PromocaoParaEtiqueta> promocoes;
  final bool apenasVigentes;
  final PromocaoParaEtiqueta? promocao;
  final SelectData? tabela;
  final Etiqueta? etiqueta;
  final List<ItemEtiquetaPromocao> itens;
  final Set<int> selecionados;
  final bool carregandoPromocoes;
  final bool carregandoItens;
  final bool imprimindo;

  /// Etiquetas prontas (um ZPL por etiqueta) aguardando a tela abrir a impressao.
  final List<EtiquetaImpressaoItem> pilha;
  final String tituloEmpresa;
  final String? erro;

  const EtiquetasPromocaoState({
    this.promocoes = const [],
    this.apenasVigentes = true,
    this.promocao,
    this.tabela,
    this.etiqueta,
    this.itens = const [],
    this.selecionados = const {},
    this.carregandoPromocoes = false,
    this.carregandoItens = false,
    this.imprimindo = false,
    this.pilha = const [],
    this.tituloEmpresa = 'EMPRESA',
    this.erro,
  });

  Iterable<ItemEtiquetaPromocao> get itensSelecionados =>
      itens.where((i) => i.imprimivel && selecionados.contains(i.produtoId));

  int get totalEtiquetas => itensSelecionados.fold(0, (s, i) => s + i.saldo);

  bool get todosSelecionados {
    final imprimiveis = itens.where((i) => i.imprimivel);
    return imprimiveis.isNotEmpty &&
        imprimiveis.every((i) => selecionados.contains(i.produtoId));
  }

  bool get podeImprimir =>
      !imprimindo && !carregandoItens && etiqueta != null && totalEtiquetas > 0;

  EtiquetasPromocaoState copyWith({
    List<PromocaoParaEtiqueta>? promocoes,
    bool? apenasVigentes,
    PromocaoParaEtiqueta? Function()? promocao,
    SelectData? Function()? tabela,
    Etiqueta? Function()? etiqueta,
    List<ItemEtiquetaPromocao>? itens,
    Set<int>? selecionados,
    bool? carregandoPromocoes,
    bool? carregandoItens,
    bool? imprimindo,
    List<EtiquetaImpressaoItem>? pilha,
    String? tituloEmpresa,
    String? Function()? erro,
  }) {
    return EtiquetasPromocaoState(
      promocoes: promocoes ?? this.promocoes,
      apenasVigentes: apenasVigentes ?? this.apenasVigentes,
      promocao: promocao != null ? promocao() : this.promocao,
      tabela: tabela != null ? tabela() : this.tabela,
      etiqueta: etiqueta != null ? etiqueta() : this.etiqueta,
      itens: itens ?? this.itens,
      selecionados: selecionados ?? this.selecionados,
      carregandoPromocoes: carregandoPromocoes ?? this.carregandoPromocoes,
      carregandoItens: carregandoItens ?? this.carregandoItens,
      imprimindo: imprimindo ?? this.imprimindo,
      pilha: pilha ?? this.pilha,
      tituloEmpresa: tituloEmpresa ?? this.tituloEmpresa,
      erro: erro != null ? erro() : this.erro,
    );
  }

  @override
  List<Object?> get props => [
    promocoes,
    apenasVigentes,
    promocao,
    tabela?.id,
    etiqueta,
    itens,
    selecionados,
    carregandoPromocoes,
    carregandoItens,
    imprimindo,
    pilha,
    tituloEmpresa,
    erro,
  ];
}
