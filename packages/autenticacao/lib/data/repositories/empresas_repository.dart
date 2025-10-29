import 'package:autenticacao/domain/data/data_sourcers/remote/i_empresas_remote_data_source.dart';
import 'package:autenticacao/domain/data/repositories/i_empresas_repository.dart';
import 'package:autenticacao/domain/models/empresa.dart';

class EmpresasRepository implements IEmpresasRepository {
  final IEmpresasRemoteDataSource empresasRemoteDataSource;

  EmpresasRepository({required this.empresasRemoteDataSource});
  @override
  Future<Empresa?> getEmpresaPorId(int idEmpresa) {
    return empresasRemoteDataSource.recuperarEmpresaPorId(idEmpresa);
  }

  @override
  Future<List<Empresa>> getEmpresas() {
    return empresasRemoteDataSource.recuperarEmpresas();
  }
}
