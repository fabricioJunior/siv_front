abstract class RelatorioFaturamentoVendedor {
  int get funcionarioId;
  String get funcionarioNome;
  double get total;
  int get quantidadeProdutosVendidos;
  int get quantidadeVendas;
  double get ticketMedio;
}

abstract class RelatorioFaturamentoProduto {
  int get produtoId;
  String get produtoIdExterno;
  int get referenciaId;
  String get referenciaIdExterno;
  String get referenciaNome;
  int get corId;
  String get corNome;
  int get tamanhoId;
  String get tamanhoNome;
  double get total;
  int get quantidadeProdutosVendidos;
}

abstract class RelatorioFaturamentoEmpresa {
  int get empresaId;
  String get empresaNome;
  double get total;
  int get quantidadeProdutosVendidos;
  int get quantidadeVendas;
  double get ticketMedio;
  List<RelatorioFaturamentoVendedor> get vendedores;
  List<RelatorioFaturamentoProduto> get produtos;
}

abstract class RelatorioFaturamento {
  double get total;
  int get quantidadeProdutosVendidos;
  int get quantidadeVendas;
  double get ticketMedio;
  List<RelatorioFaturamentoEmpresa> get empresas;
}

abstract class RelatorioVendasPorFuncionarioItem {
  int get funcionarioId;
  String get funcionarioNome;
  double get total;
  int get quantidadeProdutosVendidos;
  int get quantidadeVendas;
  double get ticketMedio;
}

abstract class RelatorioCurvaAbcItem {
  int? get produtoId;
  String? get produtoIdExterno;
  int? get referenciaId;
  String? get referenciaIdExterno;
  String? get referenciaNome;
  int? get corId;
  String? get corNome;
  int? get tamanhoId;
  String? get tamanhoNome;
  int? get categoriaId;
  String? get categoriaNome;
  int get quantidadeVendida;
  double get valorTotalVendido;
  double get percentualParticipacao;
  double get percentualAcumulado;
  String get classeAbc;
}

abstract class RelatorioCurvaAbcMeta {
  int get totalItems;
  int get itemCount;
  int get itemsPerPage;
  int get totalPages;
  int get currentPage;
}

abstract class RelatorioCurvaAbc {
  List<RelatorioCurvaAbcItem> get items;
  RelatorioCurvaAbcMeta get meta;
}

abstract class RelatorioClienteAtivoItem {
  int get empresaId;
  String get empresaNome;
  int get clienteId;
  String get clienteNome;
  String get clienteDocumento;
  String get dataUltimaCompra;
  int get quantidadeCompras;
  double get valorTotalComprado;
}

abstract class RelatorioClienteAtivoMeta {
  int get totalItems;
  int get itemCount;
  int get itemsPerPage;
  int get totalPages;
  int get currentPage;
}

abstract class RelatorioClientesAtivos {
  List<RelatorioClienteAtivoItem> get items;
  RelatorioClienteAtivoMeta get meta;
}
