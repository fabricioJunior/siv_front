abstract class RelatorioFaturamentoVendedor {
  int get funcionarioId;
  String get funcionarioNome;
  double get total;
  double get valorBrutoVendas;
  double get valorDevolucoes;
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
  double get valorBrutoVendas;
  double get valorDevolucoes;
  int get quantidadeProdutosVendidos;
  int get quantidadeVendas;
  double get ticketMedio;
  List<RelatorioFaturamentoVendedor> get vendedores;
  List<RelatorioFaturamentoProduto> get produtos;
}

abstract class RelatorioFaturamento {
  double get total;
  double get valorBrutoVendas;
  double get valorDevolucoes;
  int get quantidadeProdutosVendidos;
  int get quantidadeVendas;
  double get ticketMedio;
  List<RelatorioFaturamentoEmpresa> get empresas;
}

abstract class RelatorioFaturamentoComparativoPonto {
  String get periodo;
  double get faturamento;
  int get quantidadeVendas;
}

abstract class RelatorioFaturamentoComparativo {
  List<RelatorioFaturamentoComparativoPonto> get pontos;
}

abstract class RelatorioVendasPorFuncionarioItem {
  int get funcionarioId;
  String get funcionarioNome;
  double get total;
  double get valorBrutoVendas;
  double get valorDevolucoes;
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

abstract class RelatorioCurvaAbcClasse {
  String get classe;
  int get quantidadeItens;
  double get percentualItens;
  double get valorTotal;
  double get percentualFaturamento;
}

abstract class RelatorioCurvaAbcResumo {
  double get valorTotal;
  int get quantidadeItens;
  List<RelatorioCurvaAbcClasse> get classes;
}

abstract class RelatorioCurvaAbc {
  List<RelatorioCurvaAbcItem> get items;
  RelatorioCurvaAbcMeta get meta;
  RelatorioCurvaAbcResumo? get resumo;
}

abstract class RelatorioClienteAtivoItem {
  int get empresaId;
  String get empresaNome;
  int get clienteId;
  String get clienteNome;
  String get clienteDocumento;
  String? get clienteEmail;
  String? get clienteTelefone;
  String? get clienteMunicipio;
  String? get clienteUf;
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

abstract class RelatorioClientesAtivosResumo {
  int get quantidadeClientes;
  double get valorTotalComprado;
  int get quantidadeCompras;
  double get ticketMedio;
  double get comprasPorCliente;
}

abstract class RelatorioClientesAtivos {
  List<RelatorioClienteAtivoItem> get items;
  RelatorioClienteAtivoMeta get meta;
  RelatorioClientesAtivosResumo? get resumo;
}

abstract class RelatorioCompraClienteItem {
  int get clienteId;
  String get clienteNome;
  String get clienteDocumento;
  String? get clienteEmail;
  String? get clienteTelefone;
  int? get produtoId;
  String? get produtoNome;
  String? get corNome;
  String? get tamanhoNome;
  int? get referenciaId;
  String? get referenciaNome;
  int? get categoriaId;
  String? get categoriaNome;
  int get totalCompras;
  int get quantidadeProdutos;
  double get valorTotalCompras;
}

abstract class RelatorioCompraClienteMeta {
  int get totalItems;
  int get itemCount;
  int get itemsPerPage;
  int get totalPages;
  int get currentPage;
}

abstract class RelatorioComprasClientes {
  List<RelatorioCompraClienteItem> get items;
  RelatorioCompraClienteMeta get meta;
}

abstract class RelatorioClienteAniversarianteItem {
  int get pessoaId;
  String get nome;
  String get documento;
  String? get email;
  String? get contato;
  String get nascimento;
  String? get dataUltimaCompra;
}

abstract class RelatorioClienteAniversarianteMeta {
  int get totalItems;
  int get itemCount;
  int get itemsPerPage;
  int get totalPages;
  int get currentPage;
}

abstract class RelatorioClientesAniversariantes {
  List<RelatorioClienteAniversarianteItem> get items;
  RelatorioClienteAniversarianteMeta get meta;
}

abstract class RelatorioClienteCompraItem {
  int get romaneioId;
  int get empresaId;
  String get empresaNome;
  String get data;
  double get valorLiquido;
  String? get numeroCupom;
  int? get quantidadeItens;
  String? get formaPagamento;
}

abstract class RelatorioClienteCompras {
  List<RelatorioClienteCompraItem> get items;
  int? get totalNoPeriodo;
}

abstract class RelatorioPontoFidelidadeItem {
  int get clienteId;
  String get clienteNome;
  String get clienteDocumento;
  bool get cadastradoPortal;
  String? get dataCadastroPortal;
  double get saldoPontos;
  String? get dataUltimoCredito;
}

abstract class RelatorioPontoFidelidadeMeta {
  int get totalItems;
  int get itemCount;
  int get itemsPerPage;
  int get totalPages;
  int get currentPage;
}

abstract class RelatorioPontosFidelidade {
  List<RelatorioPontoFidelidadeItem> get items;
  RelatorioPontoFidelidadeMeta get meta;
  double get saldoPontosTotal;
}
