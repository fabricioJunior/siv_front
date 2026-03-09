import 'package:autenticacao/domain/data/data_sourcers/local/i_permissoes_do_usuario_local_data_source.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_permissoes_do_usuario_remote_data_source.dart';
import 'package:autenticacao/domain/data/repositories/i_permissoes_do_usuario_repository.dart';
import 'package:autenticacao/domain/models/permissao_do_usuario.dart';

class PermissoesDoUsuarioRepository implements IPermissoesDoUsuarioRepository {
  final IPermissoesDoUsuarioLocalDataSource _localDataSource;
  final IPermissoesDoUsuarioRemoteDataSource _remoteDataSource;

  PermissoesDoUsuarioRepository({
    required IPermissoesDoUsuarioLocalDataSource localDataSource,
    required IPermissoesDoUsuarioRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  @override
  Future<Iterable<PermissaoDoUsuario>> recuperaPermissoes() {
    return _localDataSource.fetchAll();
  }

  @override
  Future<void> sincronizarPermissoes(int idUsuario) async {
    final permissoes = await _remoteDataSource.getPermissoes(idUsuario);
    await _localDataSource.deleteAll();
    await _localDataSource.putAll(permissoes);
  }
}
