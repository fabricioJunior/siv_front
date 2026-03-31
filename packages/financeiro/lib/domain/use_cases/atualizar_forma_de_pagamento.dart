import 'package:financeiro/domain/data/repositories/i_formas_de_pagamento_repository.dart';
import 'package:financeiro/domain/models/forma_de_pagamento.dart';

class AtualizarFormaDePagamento {
  final IFormasDePagamentoRepository _repository;

  AtualizarFormaDePagamento({
    required IFormasDePagamentoRepository repository,
  }) : _repository = repository;

  Future<FormaDePagamento> call(FormaDePagamento forma) {
    return _repository.atualizarFormaDePagamento(forma);
  }
}
