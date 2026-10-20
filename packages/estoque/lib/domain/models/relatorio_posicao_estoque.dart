class PosicaoEstoqueResumo {
  final double valorEstoque;
  final int pecas;
  final int skusAtivos;
  final int emRuptura;

  const PosicaoEstoqueResumo({
    this.valorEstoque = 0,
    this.pecas = 0,
    this.skusAtivos = 0,
    this.emRuptura = 0,
  });
}

class PosicaoEstoqueCategoria {
  final int? categoriaId;
  final String categoriaNome;
  final int pecas;
  final double valor;
  final double percentual;
  final int emRuptura;

  const PosicaoEstoqueCategoria({
    this.categoriaId,
    required this.categoriaNome,
    this.pecas = 0,
    this.valor = 0,
    this.percentual = 0,
    this.emRuptura = 0,
  });
}

class RelatorioPosicaoEstoque {
  final DateTime? dataReferencia;

  /// `venda` | `custo`; null se o backend não informar.
  final String? baseValor;
  final PosicaoEstoqueResumo resumo;
  final List<PosicaoEstoqueCategoria> items;

  const RelatorioPosicaoEstoque({
    this.dataReferencia,
    this.baseValor,
    this.resumo = const PosicaoEstoqueResumo(),
    this.items = const [],
  });
}
