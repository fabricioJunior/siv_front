import 'package:autenticacao/domain/data/repositories/i_licenciados_repository.dart';
import 'package:autenticacao/domain/models/licenciado.dart';

class RecuperarLicenciados {
  final ILicenciadosRepository _repository;

  RecuperarLicenciados({required ILicenciadosRepository repository})
      : _repository = repository;

  Future<List<Licenciado>> call() async {
    return <Licenciado>[
      Licenciado(
        nome: 'Licenciado 1',
        urlApi: 'http://localhost:5001',
        id: '1',
      ),
    ];
    return _repository.recuperarLicenciados();
  }
}
