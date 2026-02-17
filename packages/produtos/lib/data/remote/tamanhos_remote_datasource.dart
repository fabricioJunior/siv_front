import 'package:core/remote_data_sourcers.dart';
import 'package:produtos/domain/data/remote/i_tamanhos_remote_data_source.dart';
import 'package:produtos/domain/models/tamanho.dart';

import 'dtos/tamanho_dto.dart';

class TamanhosRemoteDatasource extends RemoteDataSourceBase
    implements ITamanhosRemoteDataSource {
  TamanhosRemoteDatasource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/tamanhos/{id}';

  @override
  Future<Tamanho> atualizarTamanho(int id, String nome) async {
    var response = await put(
      pathParameters: {'id': id.toString()},
      body: {'nome': nome},
    );
    return TamanhoDto.fromJson(response.body);
  }

  @override
  Future<Tamanho> createTamanho(String nome) async {
    var response = await post(body: {'nome': nome});
    return TamanhoDto.fromJson(response.body);
  }

  @override
  Future<void> desativarTamanho(int id) async {
    var response = await delete(pathParameters: {'id': id.toString()});
    if (response.statusCode != 200) {
      throw Exception('Falha ao desativar tamanho');
    }
  }

  @override
  Future<Tamanho> fetchTamanho(int id) async {
    var response = await get(pathParameters: {'id': id.toString()});
    return TamanhoDto.fromJson(response.body);
  }

  @override
  Future<List<Tamanho>> fetchTamanhos({String? nome, bool? inativo}) async {
    var response = await get(
      queryParameters: {
        if (nome != null) 'nome': nome,
        if (inativo != null) 'inativo': inativo.toString(),
      },
    );

    return (response.body as List<dynamic>)
        .map((e) => TamanhoDto.fromJson(e))
        .toList();
  }
}
