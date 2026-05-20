import 'package:comercial/data.dart';

class BuscarSaldoCreditoDevolucao {
  final ICreditoDevolucaoRepository _repository;

  BuscarSaldoCreditoDevolucao({
    required ICreditoDevolucaoRepository repository,
  }) : _repository = repository;

  Future<double> call({
    required int pessoaId,
    List<int>? empresaIds,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    final saldo = await _repository.buscarSaldo(pessoaId: pessoaId);
    return double.parse(saldo.toStringAsFixed(2));
  }
}
