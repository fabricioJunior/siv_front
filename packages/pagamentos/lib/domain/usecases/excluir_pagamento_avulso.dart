import 'package:pagamentos/domain/data/repositories/i_pagamento_avulso_repository.dart';

class ExcluirPagamentoAvulso {
  final IPagamentoAvulsoRepository _repository;

  ExcluirPagamentoAvulso({required IPagamentoAvulsoRepository repository})
      : _repository = repository;

  Future<void> call(int id) {
    return _repository.excluirPagamentoAvulso(id);
  }
}
