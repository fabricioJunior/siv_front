import 'package:autenticacao/domain/data/data_sourcers/remote/i_grupo_de_acesso_remote_data_source.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_permissoes_do_grupo_acesso_remote_data_source.dart';
import 'package:autenticacao/domain/data/repositories/i_grupos_de_acesso_repository.dart';
import 'package:autenticacao/domain/models/grupo_de_acesso.dart';

class GruposDeAcessoRepository implements IGruposDeAcessoRepository {
  final IGruposDeAcessoRemoteDataSource gruposDeAcessoRemoteDataSource;
  final IPermissoesDoGrupoAcessoRemoteDataSource
      permissoesDoGrupoAcessoRemoteDataSource;

  GruposDeAcessoRepository({
    required this.gruposDeAcessoRemoteDataSource,
    required this.permissoesDoGrupoAcessoRemoteDataSource,
  });

  @override
  Future<Iterable<GrupoDeAcesso>> getGruposDeAcesso() {
    return gruposDeAcessoRemoteDataSource.getGruposDeAcesso();
  }

  @override
  Future<GrupoDeAcesso> grupoDeAcessoDoUsuario(int idUsuario) {
    // TODO: implement grupoDeAcessoDoUsuario
    throw UnimplementedError();
  }

  @override
  Future<GrupoDeAcesso> novoGrupoDeAcesso(String nome) {
    return gruposDeAcessoRemoteDataSource.postGrupoDeAcesso(nome);
  }

  @override
  Future<GrupoDeAcesso> salvarGrupoDeAcesso(GrupoDeAcesso grupoDeAcesso) async {
    var permissoes = grupoDeAcesso.permissoes;
    if (grupoDeAcesso.permissoes.isNotEmpty) {
      await permissoesDoGrupoAcessoRemoteDataSource
          .atualizarPermissoesGrupoDeAcesso(
        permissoes: permissoes.toList(),
        idGrupoDeAcesso: grupoDeAcesso.id,
      );
    }
    return grupoDeAcesso;
    return gruposDeAcessoRemoteDataSource.putGrupoDeAcesso(
      nome: grupoDeAcesso.nome,
      idGrupoDeAcesso: grupoDeAcesso.id,
    );
  }

  @override
  Future<GrupoDeAcesso?> getGrupoDeAcesso(int idGrupoDeAcesso) {
    return gruposDeAcessoRemoteDataSource.getGrupoDeAcesso(idGrupoDeAcesso);
  }
}
