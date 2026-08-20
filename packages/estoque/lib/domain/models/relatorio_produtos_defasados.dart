enum ModoAgrupamentoReferencia { todos, qualquer }

abstract class RelatorioProdutoDefasadoItem {
  int? get produtoId;
  String get produtoIdExterno;
  int get referenciaId;
  String get referenciaIdExterno;
  String get referenciaNome;
  int? get corId;
  String get corNome;
  int? get tamanhoId;
  String get tamanhoNome;
  int get quantidadeProdutos;
  int get saldo;
  double get valorUnitario;
  double get valorTotal;
  String? get ultimaEntrada;
  String? get ultimaSaida;
  int? get diasSemMovimentacao;
}

abstract class RelatorioProdutosDefasadosMeta {
  int get totalItems;
  int get itemCount;
  int get itemsPerPage;
  int get currentPage;
  int get totalPages;
}

abstract class RelatorioProdutosDefasadosResumo {
  int get quantidadeDefasados;
  int get totalEmEstoque;
  double get percentualDefasado;
  double get valorTotalDefasado;
}

abstract class RelatorioProdutosDefasados {
  List<RelatorioProdutoDefasadoItem> get items;
  RelatorioProdutosDefasadosMeta get meta;
  RelatorioProdutosDefasadosResumo get resumo;
}
