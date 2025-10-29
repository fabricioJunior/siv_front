import 'package:autenticacao/domain/models/permissao.dart';
import 'package:autenticacao/domain/models/vinculo_grupo_de_acesso_e_usuario.dart';

import '../../models/grupo_de_acesso.dart';

abstract class IGruposDeAcessoRepository {
  Future<Iterable<GrupoDeAcesso>> getGruposDeAcesso();

  Future<GrupoDeAcesso?> getGrupoDeAcesso(int idGrupoDeAcesso);

  Future<List<VinculoGrupoDeAcessoEUsuario>> grupoDeAcessoDoUsuarioEIdEmpresa(
      int idUsuario);

  Future<VinculoGrupoDeAcessoEUsuario> vincularGrupoDeAcessoComUsuario(
    int idUsuario,
    int idGrupoDeAcesso,
    int idEmpresa,
  );

  Future<GrupoDeAcesso> novoGrupoDeAcesso(String nome);

  Future<GrupoDeAcesso> salvarGrupoDeAcesso(
    GrupoDeAcesso grupoDeAcesso,
    List<Permissao> permissoesRemovidas,
    List<Permissao> permissoesAdicionadas,
  );

  Future<void> deleteGrupoDeAcesso(int idGrupoDeAcesso);
}
