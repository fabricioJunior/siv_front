import 'package:empresas/domain/data/repositories/i_empresa_parametro_repository.dart';
import 'package:empresas/domain/entities/empresa_parametro.dart';

class RecuperarParametrosEmpresa {
  final IEmpresaParametroRepository _repository;

  RecuperarParametrosEmpresa({required IEmpresaParametroRepository repository})
      : _repository = repository;

  Future<List<EmpresaParametro>> call(int empresaId) {
    return _repository.recuperarParametros(empresaId);
  }
}
