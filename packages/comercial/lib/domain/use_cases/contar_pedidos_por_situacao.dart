import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';
import 'package:comercial/domain/models/contagem_pedidos_por_situacao.dart';

class ContarPedidosPorSituacao {
  final IPedidosRepository _repository;

  ContarPedidosPorSituacao({
    required IPedidosRepository repository,
  }) : _repository = repository;

  Future<ContagemPedidosPorSituacao> call({
    String? searchTerm,
    DateTime? dataInicial,
    DateTime? dataFinal,
  }) =>
      _repository.contarPorSituacao(
        searchTerm: searchTerm,
        dataInicial: dataInicial,
        dataFinal: dataFinal,
      );
}
