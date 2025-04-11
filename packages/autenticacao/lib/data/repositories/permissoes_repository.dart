import 'package:autenticacao/domain/data/data_sourcers/local/i_permissoes_local_data_source.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_permissoes_do_usuario_remote_data_source.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_permissoes_remote_data_source.dart';
import 'package:autenticacao/domain/data/repositories/i_permissoes_repository.dart';
import 'package:autenticacao/domain/models/permissao.dart';

class PermissoesRepository implements IPermissoesRepository {
  final IPermissoesRemoteDataSource _permissoesRemoteDataSource;
  final IPermissoesLocalDataSource _permissoesLocalDataSource;
  final IPermissoesDoUsuarioRemoteDataSource
      _permissoesDoUsuarioRemoteDataSource;

  PermissoesRepository(
    this._permissoesLocalDataSource,
    this._permissoesDoUsuarioRemoteDataSource, {
    required IPermissoesRemoteDataSource permissoesRemoteDataSource,
  }) : _permissoesRemoteDataSource = permissoesRemoteDataSource;

  @override
  Future<Iterable<Permissao>> recuperarPermissoes() {
    return _permissoesRemoteDataSource.getPermissoes();
  }

  @override
  Future<Iterable<Permissao>> recuperarPermissoesDoUsuario(
      int idUsuario) async {
    return _permissoesLocalDataSource.fetchAll();
  }

  @override
  Future<List<Permissao>> recuperarPermissoesPor({
    int? componenteId,
    String? nomeDoComponente,
    int? idGrupo,
    String? nomeGrupo,
  }) {
    return _permissoesLocalDataSource.getPermissoesPor(
      componenteId: componenteId,
      nomeDoComponente: nomeDoComponente,
      idGrupo: idGrupo,
      nomeGrupo: nomeGrupo,
    );
  }

  @override
  Future<void> syncPermissoesDoUsuario(int idUsuario) async {
    var permissoesDoServidor =
        await _permissoesDoUsuarioRemoteDataSource.getPermissoes(idUsuario);
    await _permissoesLocalDataSource.putAll(permissoesDoServidor);
  }
}
