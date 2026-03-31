import 'package:comercial/data.dart';
import 'package:comercial/models.dart';

class PedidosRepository implements IPedidosRepository {
  final IPedidosRemoteDataSource remoteDataSource;

  PedidosRepository({required this.remoteDataSource});

  @override
  Future<Pedido> atualizarPedido(Pedido pedido) {
    return remoteDataSource.atualizarPedido(pedido);
  }

  @override
  Future<void> cancelarPedido(
    int id, {
    required String motivoCancelamento,
  }) {
    return remoteDataSource.cancelarPedido(
      id,
      motivoCancelamento: motivoCancelamento,
    );
  }

  @override
  Future<void> conferirPedido(int id, {bool processarComDivergencia = false}) {
    return remoteDataSource.conferirPedido(
      id,
      processarComDivergencia: processarComDivergencia,
    );
  }

  @override
  Future<Pedido> criarPedido(Pedido pedido) {
    return remoteDataSource.criarPedido(pedido);
  }

  @override
  Future<void> faturarPedido(int id) {
    return remoteDataSource.faturarPedido(id);
  }

  @override
  Future<Pedido> recuperarPedido(int id) {
    return remoteDataSource.recuperarPedido(id);
  }

  @override
  Future<List<Pedido>> recuperarPedidos() {
    return remoteDataSource.recuperarPedidos();
  }
}
