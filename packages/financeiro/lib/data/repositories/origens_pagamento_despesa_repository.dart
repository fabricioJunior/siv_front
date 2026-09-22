import 'package:financeiro/domain/data/remote/i_origens_pagamento_despesa_remote_data_source.dart';
import 'package:financeiro/domain/data/repositories/i_origens_pagamento_despesa_repository.dart';
import 'package:financeiro/domain/models/origem_pagamento_despesa.dart';

class OrigensPagamentoDespesaRepository
    implements IOrigensPagamentoDespesaRepository {
  final IOrigensPagamentoDespesaRemoteDataSource remoteDataSource;

  OrigensPagamentoDespesaRepository({required this.remoteDataSource});

  @override
  Future<List<OrigemPagamentoDespesa>> recuperarOrigens({
    required int empresaId,
    String? filtro,
  }) {
    return remoteDataSource.recuperarOrigens(
      empresaId: empresaId,
      filtro: filtro,
    );
  }

  @override
  Future<OrigemPagamentoDespesa?> recuperarOrigem(int id) {
    return remoteDataSource.recuperarOrigem(id);
  }

  @override
  Future<OrigemPagamentoDespesa> criarOrigem(OrigemPagamentoDespesa origem) {
    return remoteDataSource.criarOrigem(origem);
  }

  @override
  Future<OrigemPagamentoDespesa> atualizarOrigem(OrigemPagamentoDespesa origem) {
    return remoteDataSource.atualizarOrigem(origem);
  }
}
