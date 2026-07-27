import 'package:comercial/domain/data/repositories/i_relatorio_repository.dart';
import 'package:comercial/domain/models/relatorios.dart';

class GetRelatorioPontosFidelidade {
  final IRelatorioRepository _repository;
  GetRelatorioPontosFidelidade(this._repository);

  Future<RelatorioPontosFidelidade> call({
    required List<int> empresaIds,
    String? situacaoCadastro,
    int page = 1,
    int limit = 100,
  }) =>
      _repository.pontosFidelidade(
        empresaIds: empresaIds,
        situacaoCadastro: situacaoCadastro,
        page: page,
        limit: limit,
      );
}
