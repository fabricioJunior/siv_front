import 'package:produtos/domain/data/repositorios/i_produtos_repository.dart';
import 'package:produtos/models.dart';

class RecuperarProdutos {
  final IProdutosRepository _produtosRepository;

  RecuperarProdutos({required IProdutosRepository produtosRepository})
    : _produtosRepository = produtosRepository;

  Future<List<Produto>> call({String? idExterno, int? referenciaId}) async {
    final produtos = await _produtosRepository.obterProdutos(
      idExterno: idExterno,
      referenciaId: referenciaId,
    );

    produtos.sort((a, b) {
      final aId = a.id ?? 0;
      final bId = b.id ?? 0;
      return bId.compareTo(aId);
    });

    return produtos;
  }
}
