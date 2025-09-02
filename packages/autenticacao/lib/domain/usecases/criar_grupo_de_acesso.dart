import 'package:autenticacao/domain/data/repositories/i_grupos_de_acesso_repository.dart';
import 'package:autenticacao/domain/models/grupo_de_acesso.dart';

class CriarGrupoDeAcesso {
  final IGruposDeAcessoRepository _gruposDeAcessoRepository;

  CriarGrupoDeAcesso({
    required IGruposDeAcessoRepository gruposDeAcessoRepository,
  }) : _gruposDeAcessoRepository = gruposDeAcessoRepository;

  Future<GrupoDeAcesso> call(String nome) {
    return _gruposDeAcessoRepository.novoGrupoDeAcesso(nome);
  }
}
