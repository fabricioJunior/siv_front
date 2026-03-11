import 'package:empresas/domain/data/repositories/i_empresa_parametro_repository.dart';
import 'package:empresas/domain/entities/empresa_parametro.dart';

class AtualizarParametrosEmpresa {
  final IEmpresaParametroRepository _repository;

  AtualizarParametrosEmpresa({required IEmpresaParametroRepository repository})
      : _repository = repository;

  Future<List<EmpresaParametro>> call({
    required int empresaId,
    required List<EmpresaParametro> parametros,
  }) {
    return _repository.atualizarParametros(
      empresaId: empresaId,
      parametros: parametros,
    );
  }
}
