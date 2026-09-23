import 'package:financeiro/domain/data/repositories/i_despesas_calendario_repository.dart';
import 'package:financeiro/domain/models/despesa.dart';

class RegistrarOcorrenciaDeDespesa {
  final IDespesasCalendarioRepository repository;

  RegistrarOcorrenciaDeDespesa({required this.repository});

  Future<void> call(
    int id, {
    required int ano,
    required int mes,
    double? valor,
    DateTime? dataPagamento,
    StatusDespesa? status,
  }) {
    return repository.registrarOcorrencia(
      id,
      ano: ano,
      mes: mes,
      valor: valor,
      dataPagamento: dataPagamento,
      status: status,
    );
  }
}
