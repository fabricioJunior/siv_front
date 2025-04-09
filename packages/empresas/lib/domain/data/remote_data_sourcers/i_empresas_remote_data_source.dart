import '../../entities/empresa.dart';

abstract class IEmpresasRemoteDataSource {
  Future<Empresa> postEmpresa(Empresa empresa);

  Future<Empresa> putEmpresa(Empresa empresa);

  Future<List<Empresa>> getEmpresas();

  Future<Empresa?> getEmpresa(int id);
}
