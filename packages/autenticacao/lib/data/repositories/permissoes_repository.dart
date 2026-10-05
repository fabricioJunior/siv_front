import 'package:autenticacao/domain/data/data_sourcers/local/i_permissoes_do_usuario_local_data_source.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_acoes_do_grupo_remote_data_source.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_permissoes_do_grupo_acesso_remote_data_source.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_permissoes_do_usuario_remote_data_source.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_permissoes_remote_data_source.dart';
import 'package:autenticacao/domain/data/repositories/i_permissoes_repository.dart';
import 'package:autenticacao/domain/models/acoes_do_grupo.dart';
import 'package:autenticacao/domain/models/permissao.dart';
import 'package:autenticacao/domain/models/permissao_do_usuario.dart';

class PermissoesRepository implements IPermissoesRepository {
  final IPermissoesRemoteDataSource _permissoesRemoteDataSource;
  final IPermissoesDoUsuarioLocalDataSource _permissoesLocalDataSource;
  final IPermissoesDoUsuarioRemoteDataSource
      _permissoesDoUsuarioRemoteDataSource;
  final IPermissoesDoGrupoAcessoRemoteDataSource
      _permissoesDoGrupoAcessoRemoteDataSource;
  final IAcoesDoGrupoRemoteDataSource _acoesDoGrupoRemoteDataSource;

  PermissoesRepository(
    this._permissoesLocalDataSource,
    this._permissoesDoUsuarioRemoteDataSource,
    this._permissoesDoGrupoAcessoRemoteDataSource,
    this._acoesDoGrupoRemoteDataSource, {
    required IPermissoesRemoteDataSource permissoesRemoteDataSource,
  }) : _permissoesRemoteDataSource = permissoesRemoteDataSource;

  @override
  Future<Iterable<Permissao>> recuperarPermissoes() {
    return _permissoesRemoteDataSource.getPermissoes();
  }

  @override
  Future<Iterable<PermissaoDoUsuario>> recuperarPermissoesDoUsuario(
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

  @override
  Future<Iterable<Permissao>> recuperarPermissoesDoGrupoDeAcesso(
    int idGrupoDeAcesso,
  ) {
    return _permissoesDoGrupoAcessoRemoteDataSource
        .getPermissoesDoGrupoDeAcesso(idGrupoDeAcesso: idGrupoDeAcesso);
  }

  @override
  Future<AcoesDoGrupo> recuperarAcoesDoGrupoDeAcesso(int idGrupoDeAcesso) {
    return _acoesDoGrupoRemoteDataSource.getAcoes(
      idGrupoDeAcesso: idGrupoDeAcesso,
    );
  }

  @override
  Future<AcoesDoGrupo> aplicarAcoesDoGrupoDeAcesso({
    required int idGrupoDeAcesso,
    List<String> ativar = const [],
    List<String> desativar = const [],
  }) {
    return _acoesDoGrupoRemoteDataSource.aplicarAcoes(
      idGrupoDeAcesso: idGrupoDeAcesso,
      ativar: ativar,
      desativar: desativar,
    );
  }
}
