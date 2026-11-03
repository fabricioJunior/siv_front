import 'package:comercial/domain/data/remote/i_relatorio_pedidos_contagem_remote_data_source.dart';
import 'package:comercial/domain/models/relatorio_pedidos_contagem.dart';
import 'package:core/remote_data_sourcers.dart';

class RelatorioPedidosContagemRemoteDataSource extends RemoteDataSourceBase
    implements IRelatorioPedidosContagemRemoteDataSource {
  RelatorioPedidosContagemRemoteDataSource({
    required super.informacoesParaRequest,
  });

  @override
  String get path => '/v1/pedidos{path}';

  @override
  Future<RelatorioPedidosContagem> relatorio(
    FiltroPedidosContagem filtro, {
    int pagina = 1,
    int tamanho = 30,
  }) async {
    final response = await get(
      pathParameters: {'path': '/entrada/contagens/relatorio'},
      queryParameters: filtro.toQuery(pagina: pagina, tamanho: tamanho),
    );
    return RelatorioPedidosContagem.fromJson(
      response.body as Map<String, dynamic>,
    );
  }

  @override
  Future<List<ItemPedidoContagem>> itens(
    int pedidoId, {
    int? categoriaId,
    int? referenciaId,
    int? produtoId,
  }) async {
    final response = await get(
      pathParameters: {'path': '/$pedidoId/entrada/contagens/itens'},
      queryParameters: {
        if (categoriaId != null) 'categoriaId': '$categoriaId',
        if (referenciaId != null) 'referenciaId': '$referenciaId',
        if (produtoId != null) 'produtoId': '$produtoId',
      },
    );
    return [
      for (final e in response.body as List)
        ItemPedidoContagem.fromJson(e as Map<String, dynamic>),
    ];
  }
}
