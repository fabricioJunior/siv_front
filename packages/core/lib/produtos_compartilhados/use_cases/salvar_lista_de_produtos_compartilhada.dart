import '../models/lista_de_produtos_compartilhada.dart';
import '../models/produto_compartilhado.dart';
import '../repositories/i_lista_de_produtos_compartilhada_repository.dart';

class SalvarListaDeProdutosCompartilhada {
  final IListaDeProdutosCompartilhadaRepository _repository;

  SalvarListaDeProdutosCompartilhada({
    required IListaDeProdutosCompartilhadaRepository repository,
  }) : _repository = repository;

  Future<ListaDeProdutosCompartilhada> call({
    required ListaDeProdutosCompartilhada listaCompartilhada,
    required List<ProdutoCompartilhado> produtos,
  }) async {
    await _repository.salvarLista(listaCompartilhada);
    var produtosAssociados = produtos
        .map((produto) => produto.copyWith(hashLista: listaCompartilhada.hash))
        .toList();
    await _repository.salvarProdutos(produtosAssociados);
    return listaCompartilhada;
  }
}
