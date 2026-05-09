import 'package:estoque/estoque.dart';

abstract class IProdutoEstoqueLocalDataSource {
  Future<void> salvarProduto(ProdutoDoEstoque produto);
  Future<void> salvarProdutos(List<ProdutoDoEstoque> produtos);
  Future<SaldoDoEstoque> obterSaldo({required FiltroProdutoDoEstoque filtro}); 

  Future<List<ProdutoDoEstoque>> buscarProdutosPorTexto(
    String texto, {
    String? tamanho,
    String? cor,
  });
  Future<ProdutoDoEstoque?> obterProduto(int id);
  Future<List<ProdutoDoEstoque>> obterTodosProdutos();
  Future<void> excluirProduto(int id);
  Future<void> excluirTodosProdutos();
  Future<void> excluirProdutosWhere({DateTime? produtosAtualizadosAntesDe});
}
