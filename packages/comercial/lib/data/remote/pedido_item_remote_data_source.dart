import 'package:comercial/data/remote/dtos/pedido_item_dto.dart';
import 'package:comercial/domain/data/remote/i_pedido_item_remote_data_source.dart';
import 'package:comercial/models.dart';
import 'package:core/remote_data_sourcers.dart';

class PedidoItemRemoteDataSource extends RemoteDataSourceBase
    implements IPedidoItemRemoteDataSource {
  PedidoItemRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/pedidos-itens/{id}';

  @override
  Future<List<PedidoItem>> listarItens(int pedidoId) async {
    final response = await get(pathParameters: {'id': pedidoId.toString()});
    return (response.body as List<dynamic>)
        .map((json) => PedidoItemDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PedidoItem> adicionarItem(
    int pedidoId, {
    required int produtoId,
    required double quantidade,
  }) async {
    final response = await post(
      pathParameters: {'id': '$pedidoId/adicionar'},
      body: {
        'produtoId': produtoId,
        'quantidade': quantidade,
      },
    );
    return PedidoItemDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<void> removerItem(
    int pedidoId, {
    required int produtoId,
    required int sequencia,
    required double quantidade,
  }) async {
    await put(
      pathParameters: {'id': '$pedidoId/remover'},
      body: {
        'produtoId': produtoId,
        'sequencia': sequencia,
        'quantidade': quantidade,
      },
    );
  }

  @override
  Future<void> conferirItem(
    int pedidoId, {
    required int produtoId,
    required int sequencia,
    required double quantidade,
  }) async {
    await put(
      pathParameters: {'id': '$pedidoId/conferir'},
      body: [
        {
          'produtoId': produtoId,
          'sequencia': sequencia,
          'quantidade': quantidade,
        },
      ],
    );
  }
}
