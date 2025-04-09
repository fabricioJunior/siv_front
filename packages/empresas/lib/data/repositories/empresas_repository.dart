import 'package:empresas/domain/data/remote_data_sourcers/i_empresas_remote_data_source.dart';
import 'package:empresas/domain/data/repositories/i_empresas_repository.dart';
import 'package:empresas/domain/entities/empresa.dart';

class EmpresasRepository implements IEmpresasRepository {
  final IEmpresasRemoteDataSource empresasRemoteDataSource;

  EmpresasRepository({required this.empresasRemoteDataSource});
  @override
  Future<Empresa> criarNovaEmpresa(Empresa empresa) {
    return empresasRemoteDataSource.postEmpresa(empresa);
  }

  @override
  Future<List<Empresa>> getEmpresas() async {
    return empresasRemoteDataSource.getEmpresas();
  }

  @override
  Future<Empresa?> getEmpresa(int id) {
    return empresasRemoteDataSource.getEmpresa(id);
  }

  @override
  Future<Empresa> atualizarEmpresa(Empresa empresa) {
    return empresasRemoteDataSource.putEmpresa(empresa);
  }
}
