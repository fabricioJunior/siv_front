import 'package:financeiro/domain/data/remote/i_despesas_calendario_remote_data_source.dart';
import 'package:financeiro/domain/data/repositories/i_despesas_calendario_repository.dart';
import 'package:financeiro/domain/models/despesa.dart';
import 'package:financeiro/domain/models/despesa_ocorrencia_calendario.dart';

class DespesasCalendarioRepository implements IDespesasCalendarioRepository {
  final IDespesasCalendarioRemoteDataSource remoteDataSource;

  DespesasCalendarioRepository({required this.remoteDataSource});

  @override
  Future<List<DespesaOcorrenciaCalendario>> recuperarCalendario({
    required int empresaId,
    required int ano,
    required int mes,
  }) {
    return remoteDataSource.recuperarCalendario(
      empresaId: empresaId,
      ano: ano,
      mes: mes,
    );
  }

  @override
  Future<void> registrarOcorrencia(
    int id, {
    required int ano,
    required int mes,
    double? valor,
    DateTime? dataPagamento,
    StatusDespesa? status,
  }) {
    return remoteDataSource.registrarOcorrencia(
      id,
      ano: ano,
      mes: mes,
      valor: valor,
      dataPagamento: dataPagamento,
      status: status,
    );
  }
}
