import 'package:pagamentos/domain/models/pagamento_avulso.dart';

abstract class IPagamentoAvulsoRemoteDataSource {
  Future<List<PagamentoAvulso>> recuperarPagamentosAvulsos({
    String? orderBy,
    String? orderDir,
    String? descricao,
    String? provider,
  });

  Future<PagamentoAvulso> criarPagamentoAvulso(
    PagamentoAvulso pagamento, {
    int? expiracaoHoras,
  });

  Future<void> excluirPagamentoAvulso(int id);

  Future<List<String>> recuperarProvidersDisponiveis();
}
