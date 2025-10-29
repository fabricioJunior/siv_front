import 'package:autenticacao/domain/data/repositories/i_empresas_repository.dart';
import 'package:autenticacao/domain/models/empresa.dart';

class RecuperarEmpresas {
  final IEmpresasRepository _repository;

  RecuperarEmpresas({required IEmpresasRepository repository})
      : _repository = repository;
  Future<List<Empresa>> call() {
    return _repository.getEmpresas();
  }
}
