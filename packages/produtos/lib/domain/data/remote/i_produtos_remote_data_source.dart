import 'package:produtos/models.dart';

abstract class IProdutosRemoteDataSource {
  Future<Produto> createProduto({
    required int referenciaId,
    String? idExterno,
    required int corId,
    required int tamanhoId,
    int? estampaId,
  });

  Future<List<Produto>> createProdutos(List<NovoProdutoCombinacao> itens);

  Future<Produto> atualizarProduto({
    required int id,
    required int referenciaId,
    required String idExterno,
    required int corId,
    required int tamanhoId,
    int? estampaId,
  });

  Future<void> excluirProduto(int id);

  Future<ExclusaoProdutosEmLoteResultado> excluirProdutosEmLote(List<int> ids);

  Future<List<Produto>> fetchProdutos({
    String? idExterno,
    int? referenciaId,
    int? corId,
    int? tamanhoId,
    int? estampaId,
  });
}
