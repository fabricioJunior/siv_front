import 'package:financeiro/domain/data/remote/i_cancelamentos_remote_data_source.dart';
import 'package:financeiro/domain/data/repositories/i_cancelamentos_repository.dart';

class CancelamentosRepository implements ICancelamentosRepository {
  final ICancelamentosRemoteDataSource remoteDataSource;

  CancelamentosRepository({required this.remoteDataSource});

  @override
  Future<void> cancelarRomaneio({
    required int caixaId,
    required int idRomaneio,
    required String motivo,
  }) {
    return remoteDataSource.cancelarRomaneio(
      idCaixa: caixaId,
      idRomaneio: idRomaneio,
      motivo: motivo,
    );
  }
}