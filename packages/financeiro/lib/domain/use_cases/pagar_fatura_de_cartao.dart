import 'package:financeiro/domain/data/repositories/i_despesas_repository.dart';
import 'package:financeiro/domain/models/pagamento_de_fatura.dart';

class PagarFaturaDeCartao {
  final IDespesasRepository repository;

  PagarFaturaDeCartao({required this.repository});

  Future<PagamentoDeFatura> call({
    required int empresaId,
    required int origemPagamentoId,
    required int ano,
    required int mes,
  }) {
    return repository.pagarFatura(empresaId: empresaId, origemPagamentoId: origemPagamentoId, ano: ano, mes: mes);
  }
}
