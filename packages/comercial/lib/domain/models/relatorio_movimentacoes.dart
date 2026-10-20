class MovimentacaoItem {
  final String id;
  final DateTime? dataHora;

  /// venda|devolucao|transferencia|compra|consignacao; string livre (tipo novo não quebra).
  final String tipo;
  final int? produtoId;
  final String? produtoNome;
  final String? referenciaIdExterno;
  final String? descricao;
  final int quantidade;
  final int? responsavelId;
  final String? responsavelNome;
  final String? documentoTipo;
  final int? documentoId;

  const MovimentacaoItem({
    required this.id,
    this.dataHora,
    required this.tipo,
    this.produtoId,
    this.produtoNome,
    this.referenciaIdExterno,
    this.descricao,
    this.quantidade = 0,
    this.responsavelId,
    this.responsavelNome,
    this.documentoTipo,
    this.documentoId,
  });
}

class MovimentacoesMeta {
  final int totalItems;
  final int itemCount;
  final int itemsPerPage;
  final int totalPages;
  final int currentPage;

  const MovimentacoesMeta({
    this.totalItems = 0,
    this.itemCount = 0,
    this.itemsPerPage = 50,
    this.totalPages = 1,
    this.currentPage = 1,
  });
}

class RelatorioMovimentacoes {
  final List<MovimentacaoItem> items;
  final MovimentacoesMeta meta;

  /// Chaves ausentes devem ser lidas como 0.
  final Map<String, int> contagemPorTipo;

  const RelatorioMovimentacoes({
    this.items = const [],
    this.meta = const MovimentacoesMeta(),
    this.contagemPorTipo = const {},
  });
}
