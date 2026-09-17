import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';
import 'package:comercial/domain/models/pedido.dart';

class RecuperarPedidos {
  final IPedidosRepository _repository;

  RecuperarPedidos({
    required IPedidosRepository repository,
  }) : _repository = repository;

  Future<List<Pedido>> call({
    int page = 1,
    int limit = 30,
    String? searchTerm,
    List<String>? situacoes,
    List<String>? situacoesPagamento,
    List<String>? origens,
    DateTime? dataInicial,
    DateTime? dataFinal,
  }) =>
      _repository.recuperarPedidos(
        page: page,
        limit: limit,
        searchTerm: searchTerm,
        situacoes: situacoes,
        situacoesPagamento: situacoesPagamento,
        origens: origens,
        dataInicial: dataInicial,
        dataFinal: dataFinal,
      );
}
