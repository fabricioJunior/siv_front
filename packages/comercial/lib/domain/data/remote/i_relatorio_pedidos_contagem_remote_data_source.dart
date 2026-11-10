import 'package:comercial/domain/models/relatorio_pedidos_contagem.dart';

abstract class IRelatorioPedidosContagemRemoteDataSource {
  Future<RelatorioPedidosContagem> relatorio(
    FiltroPedidosContagem filtro, {
    int pagina = 1,
    int tamanho = 30,
  });

  Future<List<ItemPedidoContagem>> itens(
    int pedidoId, {
    int? categoriaId,
    int? referenciaId,
    int? produtoId,
    int? tabelaPrecoId,
  });
}
