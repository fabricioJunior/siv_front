import 'package:comercial/domain/data/repositories/i_relatorio_repository.dart';
import 'package:comercial/domain/models/relatorios.dart';

class GetRelatorioFaturamento {
  final IRelatorioRepository _repository;
  GetRelatorioFaturamento(this._repository);

  Future<RelatorioFaturamento> call({
    required List<int> empresaIds,
    required String dataInicial,
    required String dataFinal,
  }) =>
      _repository.faturamento(
        empresaIds: empresaIds,
        dataInicial: dataInicial,
        dataFinal: dataFinal,
      );
}
