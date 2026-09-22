import 'package:financeiro/domain/data/repositories/i_origens_pagamento_despesa_repository.dart';
import 'package:financeiro/domain/models/origem_pagamento_despesa.dart';

class CriarOrigemPagamentoDespesa {
  final IOrigensPagamentoDespesaRepository repository;

  CriarOrigemPagamentoDespesa({required this.repository});

  Future<OrigemPagamentoDespesa> call(OrigemPagamentoDespesa origem) =>
      repository.criarOrigem(origem);
}
