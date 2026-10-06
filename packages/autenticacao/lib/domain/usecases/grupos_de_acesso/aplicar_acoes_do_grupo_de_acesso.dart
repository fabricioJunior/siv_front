import 'package:autenticacao/domain/data/repositories/i_permissoes_repository.dart';
import 'package:autenticacao/models.dart';

class AplicarAcoesDoGrupoDeAcesso {
  final IPermissoesRepository _repository;

  AplicarAcoesDoGrupoDeAcesso({required IPermissoesRepository repository})
      : _repository = repository;

  Future<AcoesDoGrupo> call({
    required int idGrupoDeAcesso,
    List<String> ativar = const [],
    List<String> desativar = const [],
  }) {
    return _repository.aplicarAcoesDoGrupoDeAcesso(
      idGrupoDeAcesso: idGrupoDeAcesso,
      ativar: ativar,
      desativar: desativar,
    );
  }
}
