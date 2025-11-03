import '../../models/empresa.dart';

abstract class IEmpresasRepository {
  Future<Empresa?> getEmpresaPorId(int idEmpresa);

  Future<List<Empresa>> getEmpresas();

  Future<Empresa?> getEmpressaDaSessaoSalva();

  Future<void> salvarEmpresaDaSessao(Empresa empresa);

  Future<void> limparEmpresaDaSessao();
}
