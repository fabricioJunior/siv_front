import 'package:comercial/domain/data/repositories/i_relatorio_repository.dart';
import 'package:comercial/domain/models/relatorios.dart';

class GetRelatorioVendasPorFuncionario {
  final IRelatorioRepository _repository;
  GetRelatorioVendasPorFuncionario(this._repository);

  Future<List<RelatorioVendasPorFuncionarioItem>> call({
    required List<int> empresaIds,
    required List<int> funcionarioIds,
    required String dataInicial,
    required String dataFinal,
  }) =>
      _repository.vendasPorFuncionario(
        empresaIds: empresaIds,
        funcionarioIds: funcionarioIds,
        dataInicial: dataInicial,
        dataFinal: dataFinal,
      );
}
