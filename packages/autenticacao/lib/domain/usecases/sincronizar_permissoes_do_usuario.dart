import 'package:autenticacao/domain/data/repositories/i_permissoes_do_usuario_repository.dart';
import 'package:autenticacao/models.dart';

class SincronizarPermissoesDoUsuario {
  final IPermissoesDoUsuarioRepository _repository;

  SincronizarPermissoesDoUsuario(
      {required IPermissoesDoUsuarioRepository repository})
      : _repository = repository;
  Future<Iterable<PermissaoDoUsuario>> call({
    required int idUsuario,
  }) async {
    await _repository.sincronizarPermissoes(idUsuario);
    return _repository.recuperaPermissoes();
  }
}
