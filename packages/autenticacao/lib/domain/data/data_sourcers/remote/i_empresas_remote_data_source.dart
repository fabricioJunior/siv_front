import 'package:autenticacao/domain/models/empresa.dart';

abstract class IEmpresasRemoteDataSource {
  Future<List<Empresa>> recuperarEmpresas();

  Future<Empresa?> recuperarEmpresaPorId(int idEmpresa);
}
