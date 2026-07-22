import 'package:produtos/models.dart';

abstract class IProdutosRepository {
  Future<Produto> criarProduto({
    required int referenciaId,
    String? idExterno,
    required int corId,
    required int tamanhoId,
  });

  Future<List<Produto>> criarProdutos(List<NovoProdutoCombinacao> itens);

  Future<Produto> atualizarProduto({
    required int id,
    required int referenciaId,
    required String idExterno,
    required int corId,
    required int tamanhoId,
  });

  Future<void> excluirProduto(int id);

  Future<List<Produto>> obterProdutos({
    String? idExterno,
    int? referenciaId,
    int idCor,
    int idTamanho,
  });
}
