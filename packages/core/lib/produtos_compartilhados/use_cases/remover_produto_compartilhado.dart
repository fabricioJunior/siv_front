import 'package:core/produtos_compartilhados/repositories/i_lista_de_produtos_compartilhada_repository.dart';

class RemoverProdutoCompartilhado {
  final IListaDeProdutosCompartilhadaRepository _repository;

  RemoverProdutoCompartilhado(
      {required IListaDeProdutosCompartilhadaRepository repository})
      : _repository = repository;

  Future<void> call(String produtoHash) async {
    await _repository.removerProduto(produtoHash);
  }
}
