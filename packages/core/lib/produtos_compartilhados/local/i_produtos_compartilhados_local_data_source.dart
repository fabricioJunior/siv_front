import '../models/produto_compartilhado.dart';

abstract class IProdutosCompartilhadosLocalDataSource {
  Future<void> salvarProdutos(List<ProdutoCompartilhado> produtos);
  Future<void> salvarProduto(ProdutoCompartilhado produto);

  Future<Iterable<ProdutoCompartilhado>> recuperarPorLista(String hashLista);

  Future<ProdutoCompartilhado?> recuperarProduto(String produtoHash);

  Future<void> removerPorLista(String hashLista);

  Future<void> deletarPorHash(String hash);

  Future<void> limpar();
}
