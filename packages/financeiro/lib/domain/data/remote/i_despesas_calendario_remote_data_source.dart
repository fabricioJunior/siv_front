import 'package:financeiro/domain/models/despesa.dart';
import 'package:financeiro/domain/models/despesa_ocorrencia_calendario.dart';

abstract class IDespesasCalendarioRemoteDataSource {
  Future<List<DespesaOcorrenciaCalendario>> recuperarCalendario({
    required int empresaId,
    required int ano,
    required int mes,
  });

  Future<void> registrarOcorrencia(
    int id, {
    required int ano,
    required int mes,
    double? valor,
    DateTime? dataPagamento,
    StatusDespesa? status,
  });
}
