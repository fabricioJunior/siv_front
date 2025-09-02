import 'package:autenticacao/data/remote/dtos/grupo_de_acesso_dto.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_grupo_de_acesso_remote_data_source.dart';
import 'package:autenticacao/domain/models/grupo_de_acesso.dart';
import 'package:core/remote_data_sourcers.dart';

class GruposDeAcessoRemoteDataSource extends RemoteDataSourceBase
    implements IGruposDeAcessoRemoteDataSource {
  GruposDeAcessoRemoteDataSource({required super.informacoesParaRequest});

  @override
  Future<Iterable<GrupoDeAcesso>> getGruposDeAcesso() async {
    var response = await get();

    return (response.body as List)
        .map((e) => GrupoDeAcessoDto.fromJson(e))
        .toList();
  }

  @override
  String get path => 'v1/componentes-grupos/{id}';

  @override
  Future<GrupoDeAcesso> postGrupoDeAcesso(String nome) async {
    var body = {
      'nome': nome,
    };

    var response = await post(body: body);

    return GrupoDeAcessoDto.fromJson(response.body);
  }

  @override
  Future<GrupoDeAcesso> putGrupoDeAcesso({
    required String nome,
    required int idGrupoDeAcesso,
  }) async {
    var body = {
      'nome': nome,
    };
    var pathParameters = {
      'id': idGrupoDeAcesso.toString(),
    };

    var response = await post(body: body, pathParameters: pathParameters);

    return GrupoDeAcessoDto.fromJson(response.body);
  }

  @override
  Future<GrupoDeAcesso?> getGrupoDeAcesso(int idGrupoDeAcesso) async {
    var pathParameters = {'id': idGrupoDeAcesso.toString()};
    var response = await get(pathParameters: pathParameters);

    if (response.statusCode == 404) {
      return null;
    }
    return GrupoDeAcessoDto.fromJson(response.body);
  }
}
