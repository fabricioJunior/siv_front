import 'package:comercial/domain/data/repositories/i_relatorio_repository.dart';
import 'package:comercial/domain/models/relatorios.dart';

class GetRelatorioFaturamentoComparativo {
  final IRelatorioRepository _repository;
  GetRelatorioFaturamentoComparativo(this._repository);

  Future<RelatorioFaturamentoComparativo> call({
    required List<int> empresaIds,
    required String dataInicial,
    required String dataFinal,
    required String agruparPor,
  }) =>
      _repository.faturamentoComparativo(
        empresaIds: empresaIds,
        dataInicial: dataInicial,
        dataFinal: dataFinal,
        agruparPor: agruparPor,
      );
}
