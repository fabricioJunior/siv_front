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
    // Upsert primeiro (chave = hash do componenteId) e so depois remove as obsoletas: o
    // armazenamento nunca fica vazio entre as etapas. Resposta vazia nao apaga nada (quem
    // decide se aceita vazio e' o chamador, com o estado em maos).
    await _localDataSource.putAll(permissoes);
    if (permissoes.isNotEmpty) {
      await _localDataSource
          .removerExceto(permissoes.map((p) => p.componenteId).toSet());
    }
  }
}
