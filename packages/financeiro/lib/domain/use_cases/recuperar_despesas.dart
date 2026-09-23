import 'package:financeiro/domain/data/repositories/i_despesas_repository.dart';
import 'package:financeiro/domain/models/despesa.dart';

class RecuperarDespesas {
  final IDespesasRepository repository;

  RecuperarDespesas({required this.repository});

  Future<List<Despesa>> call({
    required int empresaId,
    int? categoriaId,
    StatusDespesa? status,
    DateTime? dataInicial,
    DateTime? dataFinal,
    bool? recorrente,
    String? grupoParcelamentoId,
  }) {
    return repository.recuperarDespesas(
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
