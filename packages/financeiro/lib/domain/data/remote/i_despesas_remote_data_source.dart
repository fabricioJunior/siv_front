import 'package:financeiro/domain/models/despesa.dart';

abstract class IDespesasRemoteDataSource {
  Future<Despesa> criarDespesa(Despesa despesa);

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
