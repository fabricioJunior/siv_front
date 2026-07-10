import 'package:pagamentos/domain/data/repositories/i_pagamento_avulso_repository.dart';
import 'package:pagamentos/domain/models/pagamento_avulso.dart';

class RecuperarPagamentosAvulsos {
  final IPagamentoAvulsoRepository _repository;

  RecuperarPagamentosAvulsos({required IPagamentoAvulsoRepository repository})
      : _repository = repository;

  Future<List<PagamentoAvulso>> call({
    String? orderBy,
    String? orderDir,
    String? descricao,
    String? provider,
  }) {
    return _repository.recuperarPagamentosAvulsos(
      orderBy: orderBy,
      orderDir: orderDir,
      descricao: descricao,
      provider: provider,
    );
  }
}
