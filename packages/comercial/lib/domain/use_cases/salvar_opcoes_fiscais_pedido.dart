import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';
import 'package:comercial/domain/models/pedido.dart';

class SalvarOpcoesFiscaisPedido {
  final IPedidosRepository _repository;

  SalvarOpcoesFiscaisPedido({required IPedidosRepository repository})
      : _repository = repository;

  Future<Pedido> call(
    int id, {
    bool? incluirCpfNaNota,
    String? cpfNaNota,
    bool? enviarNotaPorEmail,
    String? emailNota,
  }) =>
      _repository.salvarOpcoesFiscais(
        id,
        incluirCpfNaNota: incluirCpfNaNota,
        cpfNaNota: cpfNaNota,
        enviarNotaPorEmail: enviarNotaPorEmail,
        emailNota: emailNota,
      );
}
