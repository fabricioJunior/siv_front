import 'package:comercial/domain/data/repositories/i_relatorio_repository.dart';
import 'package:comercial/domain/models/relatorios.dart';

class GetRelatorioClientesAniversariantes {
  final IRelatorioRepository _repository;
  GetRelatorioClientesAniversariantes(this._repository);

  Future<RelatorioClientesAniversariantes> call({
    required List<int> empresaIds,
    int? mes,
    String? dataUltimaCompraInicial,
    String? dataUltimaCompraFinal,
    int page = 1,
    int limit = 100,
  }) =>
      _repository.clientesAniversariantes(
        empresaIds: empresaIds,
        mes: mes,
        dataUltimaCompraInicial: dataUltimaCompraInicial,
        dataUltimaCompraFinal: dataUltimaCompraFinal,
        page: page,
        limit: limit,
      );
}
