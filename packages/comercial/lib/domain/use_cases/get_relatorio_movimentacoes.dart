import 'package:comercial/domain/data/repositories/i_relatorio_repository.dart';
import 'package:comercial/domain/models/relatorio_movimentacoes.dart';

class GetRelatorioMovimentacoes {
  final IRelatorioRepository _repository;
  GetRelatorioMovimentacoes(this._repository);

  Future<RelatorioMovimentacoes> call({
    required List<int> empresaIds,
    required String dataInicial,
    required String dataFinal,
    List<String>? tipos,
    String? busca,
    int page = 1,
    int limit = 50,
  }) =>
      _repository.movimentacoes(
        empresaIds: empresaIds,
        dataInicial: dataInicial,
        dataFinal: dataFinal,
        tipos: tipos,
        busca: busca,
        page: page,
        limit: limit,
      );
}
