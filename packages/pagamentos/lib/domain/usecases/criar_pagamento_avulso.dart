import 'package:pagamentos/domain/data/repositories/i_pagamento_avulso_repository.dart';
import 'package:pagamentos/domain/models/pagamento_avulso.dart';

class CriarPagamentoAvulso {
  final IPagamentoAvulsoRepository _repository;

  CriarPagamentoAvulso({required IPagamentoAvulsoRepository repository})
      : _repository = repository;

  Future<PagamentoAvulso> call(PagamentoAvulso pagamento) {
    return _repository.criarPagamentoAvulso(pagamento);
  }
}
