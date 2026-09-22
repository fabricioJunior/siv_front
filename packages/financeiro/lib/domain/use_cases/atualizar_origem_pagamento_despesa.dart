import 'package:financeiro/domain/data/repositories/i_origens_pagamento_despesa_repository.dart';
import 'package:financeiro/domain/models/origem_pagamento_despesa.dart';

class AtualizarOrigemPagamentoDespesa {
  final IOrigensPagamentoDespesaRepository repository;

  AtualizarOrigemPagamentoDespesa({required this.repository});

  Future<OrigemPagamentoDespesa> call(OrigemPagamentoDespesa origem) =>
      repository.atualizarOrigem(origem);
}
