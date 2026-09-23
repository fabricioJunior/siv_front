import 'package:financeiro/domain/data/repositories/i_despesas_calendario_repository.dart';
import 'package:financeiro/domain/models/despesa_ocorrencia_calendario.dart';

class RecuperarCalendarioDeDespesas {
  final IDespesasCalendarioRepository repository;

  RecuperarCalendarioDeDespesas({required this.repository});

  Future<List<DespesaOcorrenciaCalendario>> call({
    required int empresaId,
    required int ano,
    required int mes,
  }) {
    return repository.recuperarCalendario(empresaId: empresaId, ano: ano, mes: mes);
  }
}
