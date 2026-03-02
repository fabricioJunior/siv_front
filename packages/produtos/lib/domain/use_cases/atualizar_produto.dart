import 'package:produtos/domain/data/repositorios/i_produtos_repository.dart';
import 'package:produtos/models.dart';

class AtualizarProduto {
  final IProdutosRepository _produtosRepository;

  AtualizarProduto({required IProdutosRepository produtosRepository})
    : _produtosRepository = produtosRepository;

  Future<Produto> call({
    required int id,
    required int referenciaId,
    required String idExterno,
    required int corId,
    required int tamanhoId,
  }) {
    return _produtosRepository.atualizarProduto(
      id: id,
      referenciaId: referenciaId,
      idExterno: idExterno,
      corId: corId,
      tamanhoId: tamanhoId,
    );
  }
}
