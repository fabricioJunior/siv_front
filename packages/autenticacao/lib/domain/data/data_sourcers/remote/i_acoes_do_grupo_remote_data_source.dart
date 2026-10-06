import 'package:autenticacao/domain/models/acoes_do_grupo.dart';

abstract class IAcoesDoGrupoRemoteDataSource {
  Future<AcoesDoGrupo> getAcoes({required int idGrupoDeAcesso});

  /// Liga/desliga ações no servidor, que aplica TODAS as permissões que cada
  /// ação exige (e só remove as que nenhuma ação ligada ainda precisa).
  /// Devolve o novo estado.
  Future<AcoesDoGrupo> aplicarAcoes({
    required int idGrupoDeAcesso,
    List<String> ativar = const [],
    List<String> desativar = const [],
  });
}
