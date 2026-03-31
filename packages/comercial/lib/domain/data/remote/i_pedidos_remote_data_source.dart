import 'package:comercial/models.dart';

abstract class IPedidosRemoteDataSource {
  Future<List<Pedido>> recuperarPedidos();
  Future<Pedido> recuperarPedido(int id);
  Future<Pedido> criarPedido(Pedido pedido);
  Future<Pedido> atualizarPedido(Pedido pedido);
  Future<void> conferirPedido(int id, {bool processarComDivergencia = false});
  Future<void> faturarPedido(int id);
  Future<void> cancelarPedido(int id, {required String motivoCancelamento});
}
