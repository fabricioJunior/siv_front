import 'package:financeiro/domain/data/remote/i_formas_de_pagamento_remote_data_source.dart';
import 'package:financeiro/domain/data/repositories/i_formas_de_pagamento_repository.dart';
import 'package:financeiro/domain/models/forma_de_pagamento.dart';

class FormasDePagamentoRepository implements IFormasDePagamentoRepository {
  final IFormasDePagamentoRemoteDataSource remoteDataSource;

  FormasDePagamentoRepository({required this.remoteDataSource});

  @override
  Future<FormaDePagamento> atualizarFormaDePagamento(FormaDePagamento forma) {
    return remoteDataSource.atualizarFormaDePagamento(forma);
  }

  @override
  Future<FormaDePagamento> criarFormaDePagamento(FormaDePagamento forma) {
    return remoteDataSource.criarFormaDePagamento(forma);
  }

  @override
  Future<FormaDePagamento?> recuperarFormaDePagamento(int id) {
    return remoteDataSource.recuperarFormaDePagamento(id);
  }

  @override
  Future<List<FormaDePagamento>> recuperarFormasDePagamento({String? filtro}) {
    return remoteDataSource.recuperarFormasDePagamento(filtro: filtro);
  }
}
