import '../models/lista_de_produtos_compartilhada.dart';
import '../models/produto_compartilhado.dart';

abstract class IListaDeProdutosCompartilhadaRepository {
  Future<ListaDeProdutosCompartilhada?> recuperar(String hash);

  Future<void> removerLista(String hash);

  Future<void> salvarLista(ListaDeProdutosCompartilhada lista);

  Future<void> atualizarLista(ListaDeProdutosCompartilhada lista);

  Future<Iterable<ListaDeProdutosCompartilhada>> recuperarListas({
    int? idLista,
    OrigemCompartilhadaTipo? origem,
  });

  Future<List<ProdutoCompartilhado>> recuperarProdutos(String hashLista);

  Future<ProdutoCompartilhado?> recuperarProduto(
    String produtoHash,
  );

  Future<void> salvarProdutos(List<ProdutoCompartilhado> produtos);

  Future<void> salvarProduto(ProdutoCompartilhado produto);

  Future<void> removerProduto(String produtoHash);

  Future<void> removerProdutosPorLista(String hashLista);
}
