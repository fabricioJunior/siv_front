import 'package:comercial/models.dart';

abstract class IPedidoItemRemoteDataSource {
  Future<List<PedidoItem>> listarItens(int pedidoId);

  Future<PedidoItem> adicionarItem(
    int pedidoId, {
    required int produtoId,
    required double quantidade,
  });

  Future<void> removerItem(
    int pedidoId, {
    required int produtoId,
    required int sequencia,
    required double quantidade,
  });

  Future<void> conferirItem(
    int pedidoId, {
    required int produtoId,
    required int sequencia,
    required double quantidade,
  });
}
