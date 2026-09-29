import 'package:financeiro/domain/models/despesa.dart';
import 'package:financeiro/domain/models/pagamento_de_fatura.dart';

abstract class IDespesasRemoteDataSource {
  Future<Despesa> criarDespesa(Despesa despesa);

  Future<PagamentoDeFatura> pagarFatura({
    required int empresaId,
    required int origemPagamentoId,
    required int ano,
    required int mes,
  });

  Future<Despesa> atualizarDespesa(
    int id, {
    double? valor,
    int? categoriaId,
    int? origemPagamentoId,
    DateTime? dataPagamento,
    StatusDespesa? status,
  });

  Future<List<Despesa>> recuperarDespesas({
    required int empresaId,
    int? categoriaId,
    StatusDespesa? status,
    DateTime? dataInicial,
    DateTime? dataFinal,
    bool? recorrente,
    String? grupoParcelamentoId,
  });
}
