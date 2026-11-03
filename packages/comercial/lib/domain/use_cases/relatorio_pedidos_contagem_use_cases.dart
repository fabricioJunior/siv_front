import 'package:comercial/domain/data/gateways/i_filtros_pedidos_contagem_gateway.dart';
import 'package:comercial/domain/data/remote/i_relatorio_pedidos_contagem_remote_data_source.dart';
import 'package:comercial/domain/models/relatorio_pedidos_contagem.dart';

class ObterRelatorioPedidosContagem {
  final IRelatorioPedidosContagemRemoteDataSource _remote;
  ObterRelatorioPedidosContagem(this._remote);

  Future<RelatorioPedidosContagem> call(
    FiltroPedidosContagem filtro, {
    int pagina = 1,
    int tamanho = 30,
  }) =>
      _remote.relatorio(filtro, pagina: pagina, tamanho: tamanho);
}

class ObterItensPedidoContagem {
  final IRelatorioPedidosContagemRemoteDataSource _remote;
  ObterItensPedidoContagem(this._remote);

  Future<List<ItemPedidoContagem>> call(
    int pedidoId, {
    int? categoriaId,
    int? referenciaId,
    int? produtoId,
  }) =>
      _remote.itens(
        pedidoId,
        categoriaId: categoriaId,
        referenciaId: referenciaId,
        produtoId: produtoId,
      );
}

class ListarCategoriasFiltroContagem {
  final IFiltrosPedidosContagemGateway _gateway;
  List<OpcaoFiltro>? _cache;
  ListarCategoriasFiltroContagem(this._gateway);

  Future<List<OpcaoFiltro>> call() async =>
      _cache ??= await _gateway.categorias();
}

class BuscarReferenciasFiltroContagem {
  final IFiltrosPedidosContagemGateway _gateway;
  BuscarReferenciasFiltroContagem(this._gateway);

  Future<List<OpcaoFiltro>> call({int? categoriaId, required String busca}) =>
      _gateway.referencias(categoriaId: categoriaId, busca: busca);
}

class ListarProdutosFiltroContagem {
  final IFiltrosPedidosContagemGateway _gateway;
  ListarProdutosFiltroContagem(this._gateway);

  Future<List<OpcaoFiltro>> call(int referenciaId) =>
      _gateway.produtos(referenciaId);
}
