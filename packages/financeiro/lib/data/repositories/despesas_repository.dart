import 'package:financeiro/domain/data/remote/i_despesas_remote_data_source.dart';
import 'package:financeiro/domain/data/repositories/i_despesas_repository.dart';
import 'package:financeiro/domain/models/despesa.dart';

class DespesasRepository implements IDespesasRepository {
  final IDespesasRemoteDataSource remoteDataSource;

  DespesasRepository({required this.remoteDataSource});

  @override
  Future<Despesa> criarDespesa(Despesa despesa) {
    return remoteDataSource.criarDespesa(despesa);
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
