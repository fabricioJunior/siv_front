import 'package:autenticacao/domain/data/repositories/i_grupos_de_acesso_repository.dart';

import '../../models/grupo_de_acesso.dart';

class RecuperarGrupoDeAcessos {
  final IGruposDeAcessoRepository _gruposDeAcessoRepository;

  RecuperarGrupoDeAcessos(this._gruposDeAcessoRepository);

  Future<Iterable<GrupoDeAcesso>> call() async {
    return await _gruposDeAcessoRepository.getGruposDeAcesso();
  }
}
