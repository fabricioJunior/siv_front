import '../../models/empresa.dart';

abstract class IEmpresasRepository {
  Future<Empresa?> getEmpresaPorId(int idEmpresa);

  Future<List<Empresa>> getEmpresas();
}
