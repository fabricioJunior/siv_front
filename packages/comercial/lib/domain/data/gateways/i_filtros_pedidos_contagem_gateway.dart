class OpcaoFiltro {
  final int id;
  final String nome;

  /// Só nas referências: permite limpar a referência ao trocar a categoria.
  final int? categoriaId;

  const OpcaoFiltro(this.id, this.nome, {this.categoriaId});
}

/// Porta para as opções dos filtros de item (categoria > referência > produto).
/// A implementação fica em `lib/` (composition root), que enxerga o produtos.
abstract class IFiltrosPedidosContagemGateway {
  Future<List<OpcaoFiltro>> categorias();

  Future<List<OpcaoFiltro>> referencias({
    int? categoriaId,
    required String busca,
  });

  Future<List<OpcaoFiltro>> produtos(int referenciaId);
}
