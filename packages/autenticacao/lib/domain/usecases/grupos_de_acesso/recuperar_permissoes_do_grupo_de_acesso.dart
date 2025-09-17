import 'package:autenticacao/domain/data/repositories/i_permissoes_repository.dart';
import 'package:autenticacao/models.dart';

class RecuperarPermissoesDoGrupoDeAcesso {
  final IPermissoesRepository _repository;

  RecuperarPermissoesDoGrupoDeAcesso({
    required IPermissoesRepository repository,
  }) : _repository = repository;

  Future<Iterable<Permissao>> call(int idGrupoDeAcesso) async {
    return _repository.recuperarPermissoesDoGrupoDeAcesso(idGrupoDeAcesso);
  }
}
