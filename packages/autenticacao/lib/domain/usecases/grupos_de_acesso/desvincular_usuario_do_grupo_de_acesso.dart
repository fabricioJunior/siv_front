import 'package:autenticacao/domain/data/repositories/i_grupos_de_acesso_repository.dart';

class DesvincularUsuarioDoGrupoDeAcesso {
  final IGruposDeAcessoRepository _repository;

  DesvincularUsuarioDoGrupoDeAcesso({
    required IGruposDeAcessoRepository repository,
  }) : _repository = repository;

  Future<void> call({
    required int idUsuario,
    required int idGrupoDeAcesso,
    required int idEmpresa,
  }) {
    return _repository.desvincularGrupoDeAcessoComUsuario(
      idUsuario,
      idGrupoDeAcesso,
      idEmpresa,
    );
  }
}
