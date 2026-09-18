import 'package:autenticacao/domain/data/repositories/i_permissoes_do_usuario_repository.dart';
import 'package:autenticacao/models.dart';

class RecuperarPermissoesDoUsuarioLocal {
  final IPermissoesDoUsuarioRepository _repository;

  RecuperarPermissoesDoUsuarioLocal({
    required IPermissoesDoUsuarioRepository repository,
  }) : _repository = repository;

  Future<Iterable<PermissaoDoUsuario>> call() {
    return _repository.recuperaPermissoes();
  }
}
