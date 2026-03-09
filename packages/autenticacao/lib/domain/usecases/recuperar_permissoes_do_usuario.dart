import 'package:autenticacao/domain/data/repositories/i_permissoes_repository.dart';
import 'package:autenticacao/models.dart';

class RecuperarPermissoesDoUsuario {
  final IPermissoesRepository _permissoesRepository;

  RecuperarPermissoesDoUsuario({
    required IPermissoesRepository permissoesRepository,
  }) : _permissoesRepository = permissoesRepository;

  Future<Iterable<PermissaoDoUsuario>> call(int idUsuario) async {
    return _permissoesRepository.recuperarPermissoesDoUsuario(idUsuario);
  }
}
