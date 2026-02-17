import 'package:core/remote_data_sourcers.dart';
import 'package:produtos/domain/data/remote/i_cores_remote_data_source.dart';
import 'package:produtos/domain/models/cor.dart';

import 'dtos/cor_dto.dart';

class CoresRemoteDatasource extends RemoteDataSourceBase
    implements ICoresRemoteDataSource {
  CoresRemoteDatasource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/cores/{id}';

  @override
  Future<Cor> atualizarCor(int id, String nome) async {
    var response = await put(
      pathParameters: {'id': id.toString()},
      body: {'nome': nome},
    );
    return CorDto.fromJson(response.body);
  }

  @override
  Future<Cor> createCor(String nome) async {
    var response = await post(body: {'nome': nome});
    return CorDto.fromJson(response.body);
  }

  @override
  Future<void> desativarCor(int id) async {
    var response = await delete(pathParameters: {'id': id.toString()});
    if (response.statusCode != 200) {
      throw Exception('Falha ao desativar cor');
    }
  }

  @override
  Future<Cor?> fetchCor(int id) async {
    var response = await get(pathParameters: {'id': id.toString()});
    return CorDto.fromJson(response.body);
  }

  @override
  Future<List<Cor>> fetchCores({String? nome, bool? inativo}) async {
    var response = await get(
      queryParameters: {
        if (nome != null) 'nome': nome,
        if (inativo != null) 'inativo': inativo.toString(),
      },
    );

    return (response.body as List<dynamic>)
        .map((e) => CorDto.fromJson(e))
        .toList();
  }
}
