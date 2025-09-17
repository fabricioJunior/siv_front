import 'package:autenticacao/domain/data/repositories/i_grupos_de_acesso_repository.dart';

import '../../models/grupo_de_acesso.dart';

class RecuperarGrupoDeAcesso {
  final IGruposDeAcessoRepository _gruposDeAcessoRepository;

  RecuperarGrupoDeAcesso(
      {required IGruposDeAcessoRepository gruposDeAcessoRepository})
      : _gruposDeAcessoRepository = gruposDeAcessoRepository;

  Future<GrupoDeAcesso?> call(int idGrupoDeAcesso) async {
    return _gruposDeAcessoRepository.getGrupoDeAcesso(idGrupoDeAcesso);
  }
}
