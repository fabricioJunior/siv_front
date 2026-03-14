import 'package:pagamentos/domain/data/data_sourcers/remote/i_pagamento_avulso_remote_data_source.dart';
import 'package:pagamentos/domain/data/repositories/i_pagamento_avulso_repository.dart';
import 'package:pagamentos/domain/models/pagamento_avulso.dart';

class PagamentoAvulsoRepository implements IPagamentoAvulsoRepository {
  final IPagamentoAvulsoRemoteDataSource remoteDataSource;

  PagamentoAvulsoRepository({required this.remoteDataSource});

  @override
  Future<List<PagamentoAvulso>> recuperarPagamentosAvulsos() {
    return remoteDataSource.recuperarPagamentosAvulsos();
  }

  @override
  Future<PagamentoAvulso> criarPagamentoAvulso(PagamentoAvulso pagamento) {
    return remoteDataSource.criarPagamentoAvulso(pagamento);
  }
}
