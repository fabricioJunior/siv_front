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
  }) async {
    var busca = await _produtosRepository.obterProdutos(
      idCor: corId,
      idTamanho: tamanhoId,
      referenciaId: referenciaId,
    );

    if (busca.isNotEmpty) {
      if (busca.first.id == id) {
        return busca.first;
      }
      throw InvalidProdutoException(
        'Produto com as mesmas características já existe.',
      );
    }
    return _produtosRepository.atualizarProduto(
      id: id,
      referenciaId: referenciaId,
      idExterno: idExterno,
      corId: corId,
      tamanhoId: tamanhoId,
    );
  }
}

class InvalidProdutoException implements Exception {
  final String message;

  InvalidProdutoException(this.message);

  @override
  String toString() => 'InvalidProdutoException: $message';
}
