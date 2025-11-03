import 'package:autenticacao/data.dart';
import 'package:autenticacao/domain/data/repositories/i_empresas_repository.dart';
import 'package:autenticacao/domain/models/empresa.dart';

class EmpresasRepository implements IEmpresasRepository {
  final IEmpresasRemoteDataSource empresasRemoteDataSource;
  final IEmpresaDaSessaoLocalDataSource empresaDaSessaoLocalDataSource;

  EmpresasRepository({
    required this.empresasRemoteDataSource,
    required this.empresaDaSessaoLocalDataSource,
  });
  @override
  Future<Empresa?> getEmpresaPorId(int idEmpresa) {
    return empresasRemoteDataSource.recuperarEmpresaPorId(idEmpresa);
  }

  @override
  Future<List<Empresa>> getEmpresas() {
    return empresasRemoteDataSource.recuperarEmpresas();
  }

  @override
  Future<Empresa?> getEmpressaDaSessaoSalva() async {
    var result = await empresaDaSessaoLocalDataSource.fetchAll();
    return result.first;
  }

  @override
  Future<void> limparEmpresaDaSessao() {
    return empresaDaSessaoLocalDataSource.deleteAll();
  }

  @override
  Future<void> salvarEmpresaDaSessao(Empresa empresa) async {
    await empresaDaSessaoLocalDataSource.deleteAll();
    return empresaDaSessaoLocalDataSource.put(empresa);
  }
}
