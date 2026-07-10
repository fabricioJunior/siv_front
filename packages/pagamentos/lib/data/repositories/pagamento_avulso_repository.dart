import 'package:pagamentos/domain/data/data_sourcers/remote/i_pagamento_avulso_remote_data_source.dart';
import 'package:pagamentos/domain/data/repositories/i_pagamento_avulso_repository.dart';
import 'package:pagamentos/domain/models/pagamento_avulso.dart';

class PagamentoAvulsoRepository implements IPagamentoAvulsoRepository {
  final IPagamentoAvulsoRemoteDataSource remoteDataSource;

  PagamentoAvulsoRepository({required this.remoteDataSource});

  @override
  Future<List<PagamentoAvulso>> recuperarPagamentosAvulsos({
    String? orderBy,
    String? orderDir,
    String? descricao,
    String? provider,
  }) {
    return remoteDataSource.recuperarPagamentosAvulsos(
      orderBy: orderBy,
      orderDir: orderDir,
      descricao: descricao,
      provider: provider,
    );
  }

  @override
  Future<PagamentoAvulso> criarPagamentoAvulso(
    PagamentoAvulso pagamento, {
    int? expiracaoHoras,
  }) {
    return remoteDataSource.criarPagamentoAvulso(
      pagamento,
      expiracaoHoras: expiracaoHoras,
    );
  }

  @override
  Future<void> excluirPagamentoAvulso(int id) {
    return remoteDataSource.excluirPagamentoAvulso(id);
  }

  @override
  Future<List<String>> recuperarProvidersDisponiveis() {
    return remoteDataSource.recuperarProvidersDisponiveis();
  }
}
