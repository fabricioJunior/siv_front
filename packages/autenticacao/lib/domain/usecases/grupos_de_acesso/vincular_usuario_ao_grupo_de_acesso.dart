import 'package:autenticacao/domain/data/repositories/i_grupos_de_acesso_repository.dart';

class VincularUsuarioAoGrupoDeAcesso {
  final IGruposDeAcessoRepository _repository;

  VincularUsuarioAoGrupoDeAcesso({
    required IGruposDeAcessoRepository repository,
  }) : _repository = repository;

  Future<void> call({
    required int idUsuario,
    required int idGrupoDeAcesso,
  }) {
    return _repository.vincularGrupoDeAcessoComUsuario(
      idUsuario,
      idGrupoDeAcesso,
    );
  }
}
