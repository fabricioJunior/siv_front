import 'package:financeiro/domain/models/origem_pagamento_despesa.dart';

abstract class IOrigensPagamentoDespesaRemoteDataSource {
  Future<List<OrigemPagamentoDespesa>> recuperarOrigens({
    required int empresaId,
    String? filtro,
  });

  Future<OrigemPagamentoDespesa?> recuperarOrigem(int id);

  Future<OrigemPagamentoDespesa> criarOrigem(OrigemPagamentoDespesa origem);

  Future<OrigemPagamentoDespesa> atualizarOrigem(OrigemPagamentoDespesa origem);
}
