import 'package:financeiro/domain/data/repositories/i_origens_pagamento_despesa_repository.dart';
import 'package:financeiro/domain/models/origem_pagamento_despesa.dart';

class RecuperarOrigensPagamentoDespesa {
  final IOrigensPagamentoDespesaRepository repository;

  RecuperarOrigensPagamentoDespesa({required this.repository});

  Future<List<OrigemPagamentoDespesa>> call({
    required int empresaId,
    String? filtro,
  }) {
    return repository.recuperarOrigens(empresaId: empresaId, filtro: filtro);
  }
}
