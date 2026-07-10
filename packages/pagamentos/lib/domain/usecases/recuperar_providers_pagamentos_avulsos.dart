import 'package:pagamentos/domain/data/repositories/i_pagamento_avulso_repository.dart';

class RecuperarProvidersPagamentosAvulsos {
  final IPagamentoAvulsoRepository _repository;

  RecuperarProvidersPagamentosAvulsos({
    required IPagamentoAvulsoRepository repository,
  }) : _repository = repository;

  Future<List<String>> call() {
    return _repository.recuperarProvidersDisponiveis();
  }
}
