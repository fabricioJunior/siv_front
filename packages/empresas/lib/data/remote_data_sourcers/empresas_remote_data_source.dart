import 'package:core/remote_data_sourcers.dart';
import 'package:empresas/data/remote_data_sourcers/dtos/empresa_dto.dart';
import 'package:empresas/domain/data/remote_data_sourcers/i_empresas_remote_data_source.dart';
import 'package:empresas/domain/entities/empresa.dart';

class EmpresasRemoteDataSource extends RemoteDataSourceBase
    implements IEmpresasRemoteDataSource {
  EmpresasRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => 'v1/empresas/{id}';

  @override
  Future<Empresa> postEmpresa(Empresa empresa) async {
    var json = empresa.toDto().toJson();
    var response = await post(body: json);

    return EmpresaDto.fromJson(response.body);
  }

  @override
  Future<List<Empresa>> getEmpresas() async {
    var response = await get();

    return (response.body as List<dynamic>)
        .map((json) => EmpresaDto.fromJson(json))
        .toList();
  }

  @override
  Future<Empresa> getEmpresa(int id) async {
    var pathParaments = {'id': id};
    var response = await get(pathParameters: pathParaments);

    return EmpresaDto.fromJson(response.body);
  }

  @override
  Future<Empresa> putEmpresa(Empresa empresa) async {
    var pathParaments = {'id': empresa.id};
    var response = await put(
      body: empresa.toDto().toJson(),
      pathParameters: pathParaments,
    );

    return EmpresaDto.fromJson(response.body);
  }
}

extension ToDto on Empresa {
  EmpresaDto toDto() => EmpresaDto(
        cnpj: cnpj,
        codigoDeAtividade: codigoDeAtividade,
        codigoDeNaturezaJuridica: codigoDeNaturezaJuridica,
        email: email,
        id: id,
        inscricaoEstadual: inscricaoEstadual,
        nome: nome,
        nomeFantasia: nomeFantasia,
        regime: regime,
        registroMunicipal: registroMunicipal,
        substituicaoTributaria: substituicaoTributaria,
        telefone: telefone,
        uf: uf,
      );
}
