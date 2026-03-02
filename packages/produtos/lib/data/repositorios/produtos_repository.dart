import 'package:produtos/domain/data/remote/i_produtos_remote_data_source.dart';
import 'package:produtos/domain/data/repositorios/i_produtos_repository.dart';
import 'package:produtos/models.dart';

class ProdutosRepository implements IProdutosRepository {
  final IProdutosRemoteDataSource produtosRemoteDataSource;

  ProdutosRepository({required this.produtosRemoteDataSource});

  @override
  Future<Produto> criarProduto({
    required int referenciaId,
    required String idExterno,
    required int corId,
    required int tamanhoId,
  }) {
    return produtosRemoteDataSource.createProduto(
      referenciaId: referenciaId,
      idExterno: idExterno,
      corId: corId,
      tamanhoId: tamanhoId,
    );
  }

  @override
  Future<Produto> atualizarProduto({
    required int id,
    required int referenciaId,
    required String idExterno,
    required int corId,
    required int tamanhoId,
  }) {
    return produtosRemoteDataSource.atualizarProduto(
      id: id,
      referenciaId: referenciaId,
      idExterno: idExterno,
      corId: corId,
      tamanhoId: tamanhoId,
    );
  }

  @override
  Future<void> excluirProduto(int id) {
    return produtosRemoteDataSource.excluirProduto(id);
  }

  @override
  Future<List<Produto>> obterProdutos({String? idExterno, int? referenciaId}) {
    return produtosRemoteDataSource.fetchProdutos(
      idExterno: idExterno,
      referenciaId: referenciaId,
    );
  }
}
