import 'package:pagamentos/domain/data/repositories/i_pagamento_avulso_repository.dart';
import 'package:pagamentos/domain/models/pagamento_avulso.dart';

class RecuperarPagamentosAvulsos {
  final IPagamentoAvulsoRepository _repository;

  RecuperarPagamentosAvulsos({required IPagamentoAvulsoRepository repository})
      : _repository = repository;

  Future<List<PagamentoAvulso>> call() {
    return _repository.recuperarPagamentosAvulsos();
  }
}
