import '../../data/repositories/i_grupos_de_acesso_repository.dart';
import '../../models/grupo_de_acesso.dart';

class RecuperarGrupoDeAcessoDoUsuario {
  final IGruposDeAcessoRepository _repository;

  RecuperarGrupoDeAcessoDoUsuario(
      {required IGruposDeAcessoRepository repository})
      : _repository = repository;

  Future<GrupoDeAcesso?> call({required int idUsuario}) async {
    return _repository.grupoDeAcessoDoUsuario(idUsuario);
  }
}
