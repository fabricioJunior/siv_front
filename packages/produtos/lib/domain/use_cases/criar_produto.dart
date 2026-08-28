import 'package:produtos/domain/data/repositorios/i_produtos_repository.dart';
import 'package:produtos/models.dart';

class CriarProduto {
  final IProdutosRepository _produtosRepository;

  CriarProduto({required IProdutosRepository produtosRepository})
    : _produtosRepository = produtosRepository;

  Future<Produto> call({
    required int referenciaId,
    String? idExterno,
    required int corId,
    required int tamanhoId,
    int? estampaId,
  }) async {
    var busca = await _produtosRepository.obterProdutos(
      referenciaId: referenciaId,
      idCor: corId,
      idTamanho: tamanhoId,
      idEstampa: estampaId,
    );
    if (busca.isNotEmpty) {
      return busca.first;
    }
    return _produtosRepository.criarProduto(
      referenciaId: referenciaId,
      idExterno: idExterno,
      corId: corId,
      tamanhoId: tamanhoId,
      estampaId: estampaId,
    );
  }
}
