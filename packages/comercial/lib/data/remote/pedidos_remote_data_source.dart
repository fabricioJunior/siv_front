import 'package:comercial/data/remote/dtos/pedido_dto.dart';
import 'package:comercial/domain/data/remote/i_pedidos_remote_data_source.dart';
import 'package:comercial/models.dart';
import 'package:core/remote_data_sourcers.dart';

class PedidosRemoteDataSource extends RemoteDataSourceBase
    implements IPedidosRemoteDataSource {
  PedidosRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/pedidos/{id}';

  @override
  Future<Pedido> atualizarPedido(Pedido pedido) async {
    final response = await put(
      pathParameters: {'id': pedido.id.toString()},
      body: PedidoDto.fromModel(pedido).toUpdateJson(),
    );
    return PedidoDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<void> cancelarPedido(
    int id, {
    required String motivoCancelamento,
  }) async {
    await put(
      pathParameters: {'id': '$id/cancelar'},
      body: {'motivoCancelamento': motivoCancelamento},
    );
  }

  @override
  Future<void> conferirPedido(
    int id, {
    bool processarComDivergencia = false,
  }) async {
    await put(
      pathParameters: {'id': '$id/conferir'},
      queryParameters: {
        'processarComDivegencia': processarComDivergencia.toString(),
      },
      body: {},
    );
  }

  @override
  Future<Pedido> criarPedido(Pedido pedido) async {
    final response =
        await post(body: PedidoDto.fromModel(pedido).toCreateJson());
    return PedidoDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<void> faturarPedido(int id) async {
    await put(
      pathParameters: {'id': '$id/faturar'},
      body: {},
    );
  }

  @override
  Future<Pedido> recuperarPedido(int id) async {
    final response = await get(pathParameters: {'id': id.toString()});
    return PedidoDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<List<Pedido>> recuperarPedidos() async {
    final response = await get();
    return (response.body as List<dynamic>)
        .map((json) => PedidoDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
