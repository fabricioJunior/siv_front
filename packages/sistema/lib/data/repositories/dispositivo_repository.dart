import 'package:sistema/domain/data/data_sourcers/local/i_dispositivo_local_datasource.dart';
import 'package:sistema/domain/data/repositories/i_dispositivo_repository.dart';
import 'package:sistema/domain/models/info_dispositivo.dart';

class DispositivoRepository implements IDispositivoRepository {
  final IDispositivoLocalDataSource _localDataSource;

  DispositivoRepository({required IDispositivoLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<InfoDispositivo> obterInfo() {
    return _localDataSource.obterInfo();
  }

  @override
  Future<void> apagarDadosLocais() {
    return _localDataSource.apagarDadosLocais();
  }
}
