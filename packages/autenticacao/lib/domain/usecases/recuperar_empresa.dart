import 'package:autenticacao/domain/data/repositories/i_empresas_repository.dart';
import 'package:autenticacao/domain/models/empresa.dart';

class RecuperaEmpresa {
  final IEmpresasRepository _repository;

  RecuperaEmpresa({required IEmpresasRepository repository})
      : _repository = repository;

  Future<Empresa?> call({
    required int idEmpresa,
  }) async {
    return _repository.getEmpresaPorId(idEmpresa);
  }
}
