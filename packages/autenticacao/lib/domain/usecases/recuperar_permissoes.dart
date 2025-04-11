import 'package:autenticacao/domain/data/repositories/i_permissoes_repository.dart';
import 'package:autenticacao/domain/models/permissao.dart';

class RecuperarPermissoes {
  final IPermissoesRepository permissoesRepository;

  RecuperarPermissoes({required this.permissoesRepository});

  Future<Iterable<Permissao>> call() async {
    return permissoesRepository.recuperarPermissoes();
  }
}
