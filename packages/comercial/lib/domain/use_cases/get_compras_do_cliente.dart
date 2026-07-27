import 'package:comercial/domain/data/repositories/i_relatorio_repository.dart';
import 'package:comercial/domain/models/relatorios.dart';

class GetComprasDoCliente {
  final IRelatorioRepository _repository;
  GetComprasDoCliente(this._repository);

  Future<RelatorioClienteCompras> call({
    required List<int> empresaIds,
    required int pessoaId,
    int limit = 10,
  }) =>
      _repository.comprasDoCliente(
        empresaIds: empresaIds,
        pessoaId: pessoaId,
        limit: limit,
      );
}
