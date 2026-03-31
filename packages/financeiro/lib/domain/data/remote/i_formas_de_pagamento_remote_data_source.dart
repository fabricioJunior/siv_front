import 'package:financeiro/domain/models/forma_de_pagamento.dart';

abstract class IFormasDePagamentoRemoteDataSource {
  Future<List<FormaDePagamento>> recuperarFormasDePagamento({String? filtro});

  Future<FormaDePagamento?> recuperarFormaDePagamento(int id);

  Future<FormaDePagamento> criarFormaDePagamento(FormaDePagamento forma);

  Future<FormaDePagamento> atualizarFormaDePagamento(FormaDePagamento forma);
}
