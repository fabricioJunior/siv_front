import 'package:produtos/domain/data/repositorios/i_produtos_repository.dart';

class ExcluirProduto {
  final IProdutosRepository _produtosRepository;

  ExcluirProduto({required IProdutosRepository produtosRepository})
    : _produtosRepository = produtosRepository;

  Future<void> call(int id) {
    return _produtosRepository.excluirProduto(id);
  }
}
