class ProdutoRejeitadoExclusao {
  final int produtoId;
  final String motivo;

  const ProdutoRejeitadoExclusao({required this.produtoId, required this.motivo});

  factory ProdutoRejeitadoExclusao.fromJson(Map<String, dynamic> json) {
    return ProdutoRejeitadoExclusao(
      produtoId: json['produtoId'] as int,
      motivo: json['motivo'] as String? ?? 'Não foi possível excluir o produto.',
    );
  }
}

class ExclusaoProdutosEmLoteResultado {
  final int totalRecebidos;
  final List<int> excluidos;
  final List<ProdutoRejeitadoExclusao> rejeitados;

  const ExclusaoProdutosEmLoteResultado({
    required this.totalRecebidos,
    required this.excluidos,
    required this.rejeitados,
  });

  factory ExclusaoProdutosEmLoteResultado.fromJson(Map<String, dynamic> json) {
    return ExclusaoProdutosEmLoteResultado(
      totalRecebidos: json['totalRecebidos'] as int? ?? 0,
      excluidos: (json['excluidos'] as List? ?? [])
          .map((item) => item as int)
          .toList(),
      rejeitados: (json['rejeitados'] as List? ?? [])
          .map((item) =>
              ProdutoRejeitadoExclusao.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
