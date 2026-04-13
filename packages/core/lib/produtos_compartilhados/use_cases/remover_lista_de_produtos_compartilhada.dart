import '../repositories/i_lista_de_produtos_compartilhada_repository.dart';

class RemoverListaDeProdutosCompartilhada {
  final IListaDeProdutosCompartilhadaRepository _repository;

  RemoverListaDeProdutosCompartilhada({
    required IListaDeProdutosCompartilhadaRepository repository,
  }) : _repository = repository;

  Future<void> call(String hash) async {
    await _repository.removerLista(hash);
    await _repository.removerProdutosPorLista(hash);
  }
}
