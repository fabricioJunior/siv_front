import 'package:financeiro/domain/data/repositories/i_origens_pagamento_despesa_repository.dart';
import 'package:financeiro/domain/models/origem_pagamento_despesa.dart';

class RecuperarOrigemPagamentoDespesa {
  final IOrigensPagamentoDespesaRepository repository;

  RecuperarOrigemPagamentoDespesa({required this.repository});

  Future<OrigemPagamentoDespesa?> call(int id) => repository.recuperarOrigem(id);
}
