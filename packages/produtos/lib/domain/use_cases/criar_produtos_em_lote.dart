import 'package:produtos/domain/data/repositorios/i_produtos_repository.dart';
import 'package:produtos/models.dart';

class CriarProdutosEmLote {
  final IProdutosRepository _produtosRepository;

  CriarProdutosEmLote({required IProdutosRepository produtosRepository})
    : _produtosRepository = produtosRepository;

  Future<List<Produto>> call(List<NovoProdutoCombinacao> itens) {
    return _produtosRepository.criarProdutos(itens);
  }
}
