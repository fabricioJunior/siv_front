import 'package:autenticacao/domain/data/repositories/i_grupos_de_acesso_repository.dart';

class ExcluirGrupoDeAcesso {
  final IGruposDeAcessoRepository _repository;

  ExcluirGrupoDeAcesso({required IGruposDeAcessoRepository repository})
      : _repository = repository;

  Future<void> call(int idGrupoDeAcesso) async {
    return _repository.deleteGrupoDeAcesso(idGrupoDeAcesso);
  }
}
