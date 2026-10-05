import 'package:autenticacao/domain/data/repositories/i_permissoes_repository.dart';
import 'package:autenticacao/models.dart';

class RecuperarAcoesDoGrupoDeAcesso {
  final IPermissoesRepository _repository;

  RecuperarAcoesDoGrupoDeAcesso({required IPermissoesRepository repository})
      : _repository = repository;

  Future<AcoesDoGrupo> call(int idGrupoDeAcesso) {
    return _repository.recuperarAcoesDoGrupoDeAcesso(idGrupoDeAcesso);
  }
}
