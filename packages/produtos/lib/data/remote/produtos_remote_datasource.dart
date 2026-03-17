import 'package:core/remote_data_sourcers.dart';
import 'package:produtos/data/remote/dtos/produto_dto.dart';
import 'package:produtos/data/remote/dtos/produtos_dto.dart';
import 'package:produtos/domain/data/remote/i_produtos_remote_data_source.dart';
import 'package:produtos/models.dart';

class ProdutosRemoteDatasource extends RemoteDataSourceBase
    implements IProdutosRemoteDataSource {
  ProdutosRemoteDatasource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/produtos/{id}';

  @override
  Future<Produto> createProduto({
    required int referenciaId,
    String? idExterno,
    required int corId,
    required int tamanhoId,
  }) async {
    final response = await post(
      body: {
        'referenciaId': referenciaId,
        if (idExterno != null && idExterno.isNotEmpty) 'idExterno': idExterno,
        'corId': corId,
        'tamanhoId': tamanhoId,
      },
    );

    return ProdutoDto.fromJson(response.body);
  }

  @override
  Future<Produto> atualizarProduto({
    required int id,
    required int referenciaId,
    required String idExterno,
    required int corId,
    required int tamanhoId,
  }) async {
    final response = await put(
      pathParameters: {'id': id.toString()},
      body: {
        'id': id,
        'referenciaId': referenciaId,
        'idExterno': idExterno,
        'corId': corId,
        'tamanhoId': tamanhoId,
      },
    );

    return ProdutoDto.fromJson(response.body);
  }

  @override
  Future<void> excluirProduto(int id) {
    return delete(pathParameters: {'id': id.toString()});
  }

  @override
  Future<List<Produto>> fetchProdutos({
    String? idExterno,
    int? referenciaId,
  }) async {
    final response = await get(
      queryParameters: {
        'incluir': 'tudo',
        if (idExterno != null && idExterno.isNotEmpty) 'idExterno': idExterno,
        if (referenciaId != null) 'referenciaId': referenciaId.toString(),
      },
    );

    return ProdutosDto.fromJson(
      response.body,
    ).items.map((item) => item as Produto).toList();
  }
}
