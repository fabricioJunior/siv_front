import 'package:autenticacao/domain/data/data_sourcers/remote/i_grupo_de_acesso_do_usuario_remote_data_source.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_grupo_de_acesso_remote_data_source.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_permissoes_do_grupo_acesso_remote_data_source.dart';
import 'package:autenticacao/domain/data/repositories/i_grupos_de_acesso_repository.dart';
import 'package:autenticacao/domain/models/grupo_de_acesso.dart';
import 'package:autenticacao/domain/models/vinculo_grupo_de_acesso_e_usuario.dart';

import '../../domain/models/permissao.dart';

class GruposDeAcessoRepository implements IGruposDeAcessoRepository {
  final IGruposDeAcessoRemoteDataSource gruposDeAcessoRemoteDataSource;
  final IVinculoGrupoDeAcessoDoUsuarioRemoteDataSource
      vinculosGrupoDeAcessoUsuarioRemoteDataSource;
  final IPermissoesDoGrupoAcessoRemoteDataSource
      permissoesDoGrupoAcessoRemoteDataSource;

  GruposDeAcessoRepository({
    required this.gruposDeAcessoRemoteDataSource,
    required this.permissoesDoGrupoAcessoRemoteDataSource,
    required this.vinculosGrupoDeAcessoUsuarioRemoteDataSource,
  });

  @override
  Future<Iterable<GrupoDeAcesso>> getGruposDeAcesso() {
    return gruposDeAcessoRemoteDataSource.getGruposDeAcesso();
  }

  @override
  Future<GrupoDeAcesso> novoGrupoDeAcesso(String nome) {
    return gruposDeAcessoRemoteDataSource.postGrupoDeAcesso(nome);
  }

  @override
  Future<GrupoDeAcesso> salvarGrupoDeAcesso(
    GrupoDeAcesso grupoDeAcesso,
    List<Permissao> permissoesRemovidas,
    List<Permissao> permissoesAdicionadas,
  ) async {
    await permissoesDoGrupoAcessoRemoteDataSource
        .vincularPermissoesGrupoDeAcesso(
      permissoes: permissoesAdicionadas,
      idGrupoDeAcesso: grupoDeAcesso.id!,
    );
    await permissoesDoGrupoAcessoRemoteDataSource
        .removerPermissoesGrupoDeAcesso(
      permissoes: permissoesRemovidas,
      idGrupoDeAcesso: grupoDeAcesso.id!,
    );
    await gruposDeAcessoRemoteDataSource.putGrupoDeAcesso(
      nome: grupoDeAcesso.nome,
      idGrupoDeAcesso: grupoDeAcesso.id!,
    );
    var grupoDeAcessoAtualizado = await getGrupoDeAcesso(grupoDeAcesso.id!);
    return grupoDeAcessoAtualizado!;
  }

  @override
  Future<GrupoDeAcesso?> getGrupoDeAcesso(int idGrupoDeAcesso) {
    return gruposDeAcessoRemoteDataSource.getGrupoDeAcesso(idGrupoDeAcesso);
  }

  @override
  Future<VinculoGrupoDeAcessoEUsuario> vincularGrupoDeAcessoComUsuario(
    int idUsuario,
    int idGrupoDeAcesso,
    int idEmpresa,
  ) {
    return vinculosGrupoDeAcessoUsuarioRemoteDataSource
        .vincularGrupoDeAcessoComUsuario(
      idUsuario,
      idGrupoDeAcesso,
      idEmpresa,
    );
  }

  @override
  Future<void> deleteGrupoDeAcesso(int idGrupoDeAcesso) {
    return gruposDeAcessoRemoteDataSource.excluirGrupoDeAcesso(
        idGrupoDeAcesso: idGrupoDeAcesso);
  }

  @override
  Future<List<VinculoGrupoDeAcessoEUsuario>> grupoDeAcessoDoUsuarioEIdEmpresa(
      int idUsuario) {
    return vinculosGrupoDeAcessoUsuarioRemoteDataSource
        .recuperarGrupoDeAcessoDoUsuarioEIdEmpresa(idUsuario);
  }
}
