import 'package:comercial/domain/data/repositories/i_relatorio_repository.dart';
import 'package:comercial/domain/models/relatorios.dart';

class GetRelatorioClientesAtivos {
  final IRelatorioRepository _repository;
  GetRelatorioClientesAtivos(this._repository);

  Future<RelatorioClientesAtivos> call({
    required List<int> empresaIds,
    required int dias,
    String? dataReferencia,
    int page = 1,
    int limit = 100,
  }) =>
      _repository.clientesAtivos(
        empresaIds: empresaIds,
        dias: dias,
        dataReferencia: dataReferencia,
        page: page,
        limit: limit,
      );
}
