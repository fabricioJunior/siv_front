import 'package:core/produtos_compartilhados.dart';
import 'package:core/produtos_compartilhados/repositories/i_lista_de_produtos_compartilhada_repository.dart';

class SalvarProdutoCompartilhado {
  final IListaDeProdutosCompartilhadaRepository repository;

  SalvarProdutoCompartilhado({required this.repository});

  Future<void> call(ProdutoCompartilhado produto) {
    return repository.salvarProduto(produto);
  }
}
