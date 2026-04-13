import '../models/lista_de_produtos_compartilhada.dart';
import '../models/produto_compartilhado.dart';
import '../repositories/i_lista_de_produtos_compartilhada_repository.dart';

class RecuperarListaDeProdutosCompartilhada {
  final IListaDeProdutosCompartilhadaRepository _repository;

  RecuperarListaDeProdutosCompartilhada({
    required IListaDeProdutosCompartilhadaRepository repository,
  }) : _repository = repository;

  Future<ListaDeProdutosCompartilhada?> call(String hash) {
    return _repository.recuperar(hash);
  }

  Future<List<ProdutoCompartilhado>> recuperarProdutos(String hashLista) {
    return _repository.recuperarProdutos(hashLista);
  }
}
