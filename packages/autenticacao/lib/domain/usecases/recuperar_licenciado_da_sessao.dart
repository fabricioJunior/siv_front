import 'package:autenticacao/domain/data/repositories/i_licenciados_repository.dart';
import 'package:autenticacao/domain/models/licenciado.dart';

class RecuperarLicenciadoDaSessao {
  final ILicenciadosRepository _repository;

  RecuperarLicenciadoDaSessao({required ILicenciadosRepository repository})
      : _repository = repository;

  Future<Licenciado?> call() {
    return _repository.recuperarLicenciadoDaSessao();
  }
}
