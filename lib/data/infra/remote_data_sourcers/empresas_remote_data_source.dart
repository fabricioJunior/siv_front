import 'package:autenticacao/domain/models/empresa.dart';
import 'package:empresas/data.dart' as empresas;
import 'package:empresas/models.dart' as empresas_models;
import 'package:autenticacao/data.dart' as auth;
import 'package:autenticacao/models.dart' as auth_models;

class EmpresasRemoteDataSource extends empresas.EmpresasRemoteDataSource
    implements auth.IEmpresasRemoteDataSource {
  EmpresasRemoteDataSource({required super.informacoesParaRequest});

  @override
  Future<Empresa?> recuperarEmpresaPorId(int idEmpresa) {
    // TODO: implement recuperarEmpresaPorId
    throw UnimplementedError();
  }

  @override
  Future<List<Empresa>> recuperarEmpresas() async {
    var empresas = await getEmpresas();
    return empresas.map((e) => _EmpresaAdapter(e)).toList();
  }
}

class _EmpresaAdapter implements auth_models.Empresa {
  final empresas_models.Empresa empresa;

  _EmpresaAdapter(this.empresa);

  @override
  int get id => empresa.id!;

  @override
  String get nome => empresa.nome;
}
