import 'package:autenticacao/domain/data/repositories/i_licenciados_repository.dart';
import 'package:autenticacao/domain/models/licenciado.dart';

class RecuperarLicenciados {
  final ILicenciadosRepository _repository;

  RecuperarLicenciados({required ILicenciadosRepository repository})
      : _repository = repository;

  Future<List<Licenciado>> call() {
    return _repository.recuperarLicenciados();
  }
}
