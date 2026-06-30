import 'package:comercial/domain/data/repositories/i_relatorio_repository.dart';
import 'package:comercial/domain/models/relatorios.dart';

class GetRelatorioCurvaAbc {
  final IRelatorioRepository _repository;
  GetRelatorioCurvaAbc(this._repository);

  Future<RelatorioCurvaAbc> call({
    required List<int> empresaIds,
    required String dataInicial,
    required String dataFinal,
    int page = 1,
    int limit = 100,
  }) =>
      _repository.curvaAbc(
        empresaIds: empresaIds,
        dataInicial: dataInicial,
        dataFinal: dataFinal,
        page: page,
        limit: limit,
      );
}
