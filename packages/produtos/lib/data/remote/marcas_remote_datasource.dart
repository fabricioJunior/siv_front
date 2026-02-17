import 'package:core/remote_data_sourcers.dart';
import 'package:produtos/data/remote/dtos/marca_dto.dart';
import 'package:produtos/domain/data/remote/i_marcas_remote_data_source.dart';
import 'package:produtos/domain/models/marca.dart';

class MarcasRemoteDatasource extends RemoteDataSourceBase
    implements IMarcasRemoteDataSource {
  MarcasRemoteDatasource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/marcas/{id}';

  @override
  Future<Marca> atualizarMarca(int id, String nome) async {
    var response = await put(
      pathParameters: {'id': id.toString()},
      body: {'nome': nome},
    );
    return MarcaDto.fromJson(response.body);
  }

  @override
  Future<Marca> createMarca(String nome) async {
    var response = await post(body: {'nome': nome});
    return MarcaDto.fromJson(response.body);
  }

  @override
  Future<void> desativarMarca(int id) async {
    var response = await delete(pathParameters: {'id': id.toString()});
    if (response.statusCode != 200) {
      throw Exception('Falha ao desativar marca');
    }
  }

  @override
  Future<Marca?> fetchMarca(int id) async {
    var response = await get(pathParameters: {'id': id.toString()});
    return MarcaDto.fromJson(response.body);
  }

  @override
  Future<List<Marca>> fetchMarcas({String? nome, bool? inativa}) async {
    var response = await get(
      queryParameters: {
        if (nome != null) 'nome': nome,
        if (inativa != null) 'inativa': inativa.toString(),
      },
    );

    return (response.body as List<dynamic>)
        .map((e) => MarcaDto.fromJson(e))
        .toList();
  }
}
