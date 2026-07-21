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
  Future<List<Produto>> createProdutos(List<NovoProdutoCombinacao> itens) async {
    final response = await put(
      body: itens
          .map(
            (item) => {
              'referenciaId': item.referenciaId,
              if (item.idExterno != null && item.idExterno!.isNotEmpty)
                'idExterno': item.idExterno,
              'corId': item.corId,
              'tamanhoId': item.tamanhoId,
              if (item.codigoDeBarras != null && item.codigoDeBarras!.isNotEmpty)
                'codigoBarras': [
                  {'tipo': 'EAN13', 'codigo': item.codigoDeBarras},
                ],
            },
          )
          .toList(),
    );

    return (response.body as List)
        .map((item) => ProdutoDto.fromJson(item as Map<String, dynamic>))
        .toList();
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
    int? corId,
    int? tamanhoId,
  }) async {
    const limitePorPagina = 500;
    var pagina = 1;
    final acumulados = <Produto>[];
    final chavesVistas = <String>{};

    while (true) {
      final response = await get(
        queryParameters: {
          'incluir': 'tudo',
          if (idExterno != null && idExterno.isNotEmpty) 'idExterno': idExterno,
          if (referenciaId != null) 'referencia': referenciaId.toString(),
          if (corId != null) 'corId': corId.toString(),
          if (tamanhoId != null) 'tamanhoId': tamanhoId.toString(),
          'page': pagina.toString(),
          'limit': limitePorPagina.toString(),
        },
      );

      final produtosPagina =
          ProdutosDto.fromJson(response.body).items.map((item) => item as Produto).toList();

      if (produtosPagina.isEmpty) {
        break;
      }

      var adicionouNovos = false;
      for (final produto in produtosPagina) {
        final chave = produto.id != null
            ? 'id:${produto.id}'
            : 'r:${produto.referenciaId}-c:${produto.corId}-t:${produto.tamanhoId}-x:${produto.idExterno}';
        if (chavesVistas.add(chave)) {
          acumulados.add(produto);
          adicionouNovos = true;
        }
      }

      // Evita loop infinito quando backend ignora paginação e repete a mesma página.
      if (!adicionouNovos || produtosPagina.length < limitePorPagina) {
        break;
      }

      pagina++;
    }

    return acumulados;
  }
}
