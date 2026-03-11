import 'package:empresas/domain/data/remote_data_sourcers/i_empresa_parametro_remote_data_source.dart';
import 'package:empresas/domain/data/repositories/i_empresa_parametro_repository.dart';
import 'package:empresas/domain/entities/empresa_parametro.dart';

class EmpresaParametroRepository implements IEmpresaParametroRepository {
  final IEmpresaParametroRemoteDataSource remoteDataSource;

  EmpresaParametroRepository({required this.remoteDataSource});

  @override
  Future<List<EmpresaParametro>> recuperarParametros(int empresaId) {
    return remoteDataSource.recuperarParametros(empresaId);
  }

  @override
  Future<List<EmpresaParametro>> atualizarParametros({
    required int empresaId,
    required List<EmpresaParametro> parametros,
  }) {
    return remoteDataSource.atualizarParametros(
      empresaId: empresaId,
      parametros: parametros,
    );
  }
}
