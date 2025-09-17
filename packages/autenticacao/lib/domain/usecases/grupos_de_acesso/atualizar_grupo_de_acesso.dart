import 'package:autenticacao/models.dart';

import '../../data/repositories/i_grupos_de_acesso_repository.dart';

class AtualizarGrupoDeAcesso {
  final IGruposDeAcessoRepository _gruposDeAcessoRepository;

  AtualizarGrupoDeAcesso({
    required IGruposDeAcessoRepository gruposDeAcessoRepository,
  }) : _gruposDeAcessoRepository = gruposDeAcessoRepository;

  Future<GrupoDeAcesso> call({
    required GrupoDeAcesso grupoDeAcesso,
    required String novoNome,
    required List<Permissao> permissoesAtualizadas,
  }) async {
    var grupoDeAcessoUpdate = grupoDeAcesso.copyWith(
      nome: novoNome,
    );
    var permissoesAdicionadas = permissoesAtualizadas
        .where((permissao) => !grupoDeAcesso.permissoes.contains(permissao))
        .toList();
    var permissoesRemovidas = grupoDeAcessoUpdate.permissoes
        .where((permissao) => !permissoesAtualizadas.contains(permissao))
        .toList();

    return _gruposDeAcessoRepository.salvarGrupoDeAcesso(
      grupoDeAcessoUpdate,
      permissoesRemovidas,
      permissoesAdicionadas,
    );
  }
}
