import 'package:financeiro/domain/data/repositories/i_formas_de_pagamento_repository.dart';
import 'package:financeiro/domain/models/forma_de_pagamento.dart';

class RecuperarFormaDePagamento {
  final IFormasDePagamentoRepository _repository;

  RecuperarFormaDePagamento({
    required IFormasDePagamentoRepository repository,
  }) : _repository = repository;

  Future<FormaDePagamento?> call(int id) {
    return _repository.recuperarFormaDePagamento(id);
  }
}
