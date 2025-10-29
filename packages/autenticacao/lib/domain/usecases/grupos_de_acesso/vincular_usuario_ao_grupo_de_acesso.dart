import 'package:autenticacao/domain/data/repositories/i_grupos_de_acesso_repository.dart';
import 'package:autenticacao/domain/models/vinculo_grupo_de_acesso_e_usuario.dart';

class VincularUsuarioAoGrupoDeAcesso {
  final IGruposDeAcessoRepository _repository;

  VincularUsuarioAoGrupoDeAcesso({
    required IGruposDeAcessoRepository repository,
  }) : _repository = repository;

  Future<VinculoGrupoDeAcessoEUsuario> call({
    required int idUsuario,
    required int idGrupoDeAcesso,
    required int idEmpresa,
  }) {
    return _repository.vincularGrupoDeAcessoComUsuario(
      idUsuario,
      idGrupoDeAcesso,
      idEmpresa,
    );
  }
}
