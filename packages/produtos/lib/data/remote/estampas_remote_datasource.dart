import 'package:core/remote_data_sourcers.dart';
import 'package:produtos/domain/data/remote/i_estampas_remote_data_source.dart';
import 'package:produtos/domain/models/estampa.dart';

import 'dtos/estampa_dto.dart';

class EstampasRemoteDatasource extends RemoteDataSourceBase
    implements IEstampasRemoteDataSource {
  EstampasRemoteDatasource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/estampas/{id}';

  @override
  Future<Estampa> atualizarEstampa(int id, String nome) async {
    var response = await put(
      pathParameters: {'id': id.toString()},
      body: {'nome': nome},
    );
    return EstampaDto.fromJson(response.body);
  }

  @override
  Future<Estampa> createEstampa(String nome) async {
    var response = await post(body: {'nome': nome});
    return EstampaDto.fromJson(response.body);
  }

  @override
  Future<void> desativarEstampa(int id) async {
    var response = await delete(pathParameters: {'id': id.toString()});
    if (response.statusCode != 200) {
      throw Exception('Falha ao desativar estampa');
    }
  }

  @override
  Future<Estampa> fetchEstampa(int id) async {
    var response = await get(pathParameters: {'id': id.toString()});
    return EstampaDto.fromJson(response.body);
  }

  @override
  Future<List<Estampa>> fetchEstampas({String? nome, bool? inativo}) async {
    var response = await get(
      queryParameters: {
        if (nome != null) 'nome': nome,
        if (inativo != null) 'inativo': inativo.toString(),
      },
    );

    return (response.body as List<dynamic>)
        .map((e) => EstampaDto.fromJson(e))
        .toList();
  }
}
