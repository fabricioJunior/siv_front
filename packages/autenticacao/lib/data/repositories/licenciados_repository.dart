import 'package:autenticacao/domain/data/data_sourcers/local/i_licenciado_da_sessao_local_data_source.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_licenciados_remote_data_source.dart';
import 'package:autenticacao/domain/data/repositories/i_licenciados_repository.dart';
import 'package:autenticacao/domain/models/licenciado.dart';

class LicenciadosRepository implements ILicenciadosRepository {
  final ILicenciadosRemoteDataSource _remoteDataSource;
  final ILicenciadoDaSessaoLocalDataSource _licenciadoDaSessaoLocalDataSource;

  LicenciadosRepository({
    required ILicenciadosRemoteDataSource remoteDataSource,
    required ILicenciadoDaSessaoLocalDataSource
        licenciadoDaSessaoLocalDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _licenciadoDaSessaoLocalDataSource = licenciadoDaSessaoLocalDataSource;

  @override
  Future<List<Licenciado>> recuperarLicenciados() {
    return _remoteDataSource.recuperarLicenciados();
  }

  @override
  Future<Licenciado?> recuperarLicenciadoDaSessao() async {
    final licenciados = await _licenciadoDaSessaoLocalDataSource.fetchAll();
    return licenciados.isEmpty ? null : licenciados.first;
  }

  @override
  Future<void> salvarLicenciadoDaSessao(Licenciado licenciado) async {
    await _licenciadoDaSessaoLocalDataSource.deleteAll();
    await _licenciadoDaSessaoLocalDataSource.put(licenciado);
  }

  @override
  Future<void> limparLicenciadoDaSessao() {
    return _licenciadoDaSessaoLocalDataSource.deleteAll();
  }
}
