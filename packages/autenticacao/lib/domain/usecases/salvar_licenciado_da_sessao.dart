import 'package:autenticacao/domain/data/repositories/i_licenciados_repository.dart';
import 'package:autenticacao/domain/models/licenciado.dart';

class SalvarLicenciadoDaSessao {
  final ILicenciadosRepository _repository;

  SalvarLicenciadoDaSessao({required ILicenciadosRepository repository})
      : _repository = repository;

  Future<void> call(Licenciado licenciado) {
    return _repository.salvarLicenciadoDaSessao(licenciado);
  }
}
