import 'package:comercial/data.dart';
import 'package:comercial/models.dart';

class RecuperarPedidos {
  final IPedidosRepository repository;

  RecuperarPedidos({required this.repository});

  Future<List<Pedido>> call() => repository.recuperarPedidos();
}

class RecuperarPedido {
  final IPedidosRepository repository;

  RecuperarPedido({required this.repository});

  Future<Pedido> call(int id) => repository.recuperarPedido(id);
}

class CriarPedido {
  final IPedidosRepository repository;

  CriarPedido({required this.repository});

  Future<Pedido> call(Pedido pedido) => repository.criarPedido(pedido);
}

class AtualizarPedido {
  final IPedidosRepository repository;

  AtualizarPedido({required this.repository});

  Future<Pedido> call(Pedido pedido) => repository.atualizarPedido(pedido);
}

class ConferirPedido {
  final IPedidosRepository repository;

  ConferirPedido({required this.repository});

  Future<void> call(int id, {bool processarComDivergencia = false}) {
    return repository.conferirPedido(
      id,
      processarComDivergencia: processarComDivergencia,
    );
  }
}

class FaturarPedido {
  final IPedidosRepository repository;

  FaturarPedido({required this.repository});

  Future<void> call(int id) => repository.faturarPedido(id);
}

class CancelarPedido {
  final IPedidosRepository repository;

  CancelarPedido({required this.repository});

  Future<void> call(int id, {required String motivoCancelamento}) {
    return repository.cancelarPedido(id,
        motivoCancelamento: motivoCancelamento);
  }
}
