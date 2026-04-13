import 'package:core/produtos_compartilhados.dart';
import 'package:core/produtos_compartilhados/local/i_lista_de_produtos_compartilhada_local_data_source.dart';
import 'package:core/produtos_compartilhados/local/i_produtos_compartilhados_local_data_source.dart';
import 'package:core/produtos_compartilhados/repositories/i_lista_de_produtos_compartilhada_repository.dart';

class ListaDeProdutosCompartilhadaRepository
    implements IListaDeProdutosCompartilhadaRepository {
  final IListaDeProdutosCompartilhadaLocalDataSource listasLocalDataSource;
  final IProdutosCompartilhadosLocalDataSource produtosLocalDataSource;
  final Map<String, ListaDeProdutosCompartilhada> _cache = {};

  ListaDeProdutosCompartilhadaRepository({
    required this.listasLocalDataSource,
    required this.produtosLocalDataSource,
  });

  @override
  Future<void> atualizarLista(ListaDeProdutosCompartilhada lista) {
    _cache[lista.hash] = lista;
    return listasLocalDataSource.salvar(lista);
  }

  @override
  Future<ListaDeProdutosCompartilhada?> recuperar(String hash) async {
    final cached = _cache[hash];
    if (cached != null) {
      return cached;
    }

    final lista = await listasLocalDataSource.recuperar(hash);
    if (lista != null) {
      _cache[hash] = lista;
    }
    return lista;
  }

  @override
  Future<Iterable<ListaDeProdutosCompartilhada>> recuperarListas({
    int? idLista,
    OrigemCompartilhadaTipo? origem,
  }) {
    return listasLocalDataSource.recuperarWhere(
      idLista: idLista,
      origem: origem,
    );
  }

  @override
  Future<ProdutoCompartilhado?> recuperarProduto(String produtoHash) {
    return produtosLocalDataSource.recuperarProduto(produtoHash);
  }

  @override
  Future<List<ProdutoCompartilhado>> recuperarProdutos(String hashLista) {
    return produtosLocalDataSource
        .recuperarPorLista(hashLista)
        .then((value) => value.toList());
  }

  @override
  Future<void> removerLista(String hash) {
    _cache.remove(hash);
    return listasLocalDataSource.apagar(hash);
  }

  @override
  Future<void> removerProdutosPorLista(String hashLista) {
    return produtosLocalDataSource.removerPorLista(hashLista);
  }

  @override
  Future<void> salvarLista(ListaDeProdutosCompartilhada lista) {
    _cache[lista.hash] = lista;
    return listasLocalDataSource.salvar(lista);
  }

  @override
  Future<void> salvarProdutos(List<ProdutoCompartilhado> produtos) {
    return produtosLocalDataSource.salvarProdutos(produtos);
  }

  @override
  Future<void> removerProduto(String produtoHash) {
    return produtosLocalDataSource.deletarPorHash(produtoHash);
  }

  @override
  Future<void> salvarProduto(ProdutoCompartilhado produto) {
    return produtosLocalDataSource.salvarProdutos([produto]);
  }
}
