import 'package:autenticacao/domain/models/grupo_de_acesso.dart';
import 'package:autenticacao/models.dart';

import '../data/repositories/i_grupos_de_acesso_repository.dart';

class AtualizarGrupoDeAcesso {
  final IGruposDeAcessoRepository _gruposDeAcessoRepository;

  AtualizarGrupoDeAcesso({
    required IGruposDeAcessoRepository gruposDeAcessoRepository,
  }) : _gruposDeAcessoRepository = gruposDeAcessoRepository;

  Future<GrupoDeAcesso> call({
    required GrupoDeAcesso grupoDeAcesso,
    required String novoNome,
    required List<Permissao> permissoes,
  }) async {
    var grupoDeAcessoUpdate = grupoDeAcesso.copyWith(
      nome: novoNome,
      permissoes: permissoes,
    );

    return _gruposDeAcessoRepository.salvarGrupoDeAcesso(grupoDeAcessoUpdate);
  }
}
