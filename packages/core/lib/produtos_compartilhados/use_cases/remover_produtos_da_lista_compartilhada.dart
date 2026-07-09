import '../repositories/i_lista_de_produtos_compartilhada_repository.dart';

class RemoverProdutosDaListaCompartilhada {
  final IListaDeProdutosCompartilhadaRepository _repository;

  RemoverProdutosDaListaCompartilhada({
    required IListaDeProdutosCompartilhadaRepository repository,
  }) : _repository = repository;

  Future<void> call(String hashLista) {
    return _repository.removerProdutosPorLista(hashLista);
  }
}
