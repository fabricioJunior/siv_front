import 'package:financeiro/domain/data/repositories/i_formas_de_pagamento_repository.dart';
import 'package:financeiro/domain/models/forma_de_pagamento.dart';

class RecuperarFormasDePagamento {
  final IFormasDePagamentoRepository _repository;

  RecuperarFormasDePagamento({
    required IFormasDePagamentoRepository repository,
  }) : _repository = repository;

  Future<List<FormaDePagamento>> call({String? filtro}) {
    return _repository.recuperarFormasDePagamento(filtro: filtro);
  }
}
