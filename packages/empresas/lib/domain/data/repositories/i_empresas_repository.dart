import 'package:empresas/domain/entities/empresa.dart';

abstract class IEmpresasRepository {
  Future<Empresa> criarNovaEmpresa(
    Empresa novaEmpresa,
  );

  Future<Empresa> atualizarEmpresa(Empresa empresa);

  Future<List<Empresa>> getEmpresas();

  Future<Empresa?> getEmpresa(int id);
}
