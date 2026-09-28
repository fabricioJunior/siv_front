import 'package:financeiro/domain/data/remote/i_despesas_remote_data_source.dart';
import 'package:financeiro/domain/data/repositories/i_despesas_repository.dart';
import 'package:financeiro/domain/models/despesa.dart';
import 'package:financeiro/domain/models/pagamento_de_fatura.dart';

class DespesasRepository implements IDespesasRepository {
  final IDespesasRemoteDataSource remoteDataSource;

  DespesasRepository({required this.remoteDataSource});

  @override
  Future<Despesa> criarDespesa(Despesa despesa) {
    return remoteDataSource.criarDespesa(despesa);
  }

  @override
  Future<PagamentoDeFatura> pagarFatura({
    required int empresaId,
    required int origemPagamentoId,
    required int ano,
    required int mes,
  }) {
    return remoteDataSource.pagarFatura(empresaId: empresaId, origemPagamentoId: origemPagamentoId, ano: ano, mes: mes);
  }

  @override
  Future<Despesa> atualizarDespesa(
    int id, {
    double? valor,
    int? categoriaId,
    int? origemPagamentoId,
    DateTime? dataPagamento,
    StatusDespesa? status,
  }) {
    return remoteDataSource.atualizarDespesa(
      id,
      valor: valor,
      categoriaId: categoriaId,
      origemPagamentoId: origemPagamentoId,
      dataPagamento: dataPagamento,
      status: status,
    );
  }

  @override
  Future<List<Despesa>> recuperarDespesas({
    required int empresaId,
    int? categoriaId,
    StatusDespesa? status,
    DateTime? dataInicial,
    DateTime? dataFinal,
    bool? recorrente,
    String? grupoParcelamentoId,
  }) {
    return remoteDataSource.recuperarDespesas(
      empresaId: empresaId,
      categoriaId: categoriaId,
      status: status,
      dataInicial: dataInicial,
      dataFinal: dataFinal,
      recorrente: recorrente,
      grupoParcelamentoId: grupoParcelamentoId,
    );
  }
}
