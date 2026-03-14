import 'package:pagamentos/domain/models/pagamento_avulso.dart';

abstract class IPagamentoAvulsoRepository {
  Future<List<PagamentoAvulso>> recuperarPagamentosAvulsos();

  Future<PagamentoAvulso> criarPagamentoAvulso(PagamentoAvulso pagamento);
}
