import 'package:empresas/domain/entities/empresa_parametro.dart';

abstract class IEmpresaParametroRepository {
  Future<List<EmpresaParametro>> recuperarParametros(int empresaId);

  Future<List<EmpresaParametro>> atualizarParametros({
    required int empresaId,
    required List<EmpresaParametro> parametros,
  });
}
