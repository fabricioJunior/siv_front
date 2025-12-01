import 'package:core/remote_data_sourcers.dart';
import 'package:pessoas/data/remote/dtos/ponto_dto.dart';
import 'package:pessoas/domain/data/data_sourcers/remote/i_pontos_remote_data_source.dart';
import 'package:pessoas/domain/models/ponto.dart';

class PontosRemoteDataSource extends RemoteDataSourceBase
    implements IPontosRemoteDataSource {
  PontosRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/pessoas/{pessoaId}/transacoes-pontos/{id}';

  @override
  Future<List<Ponto>> getPontos({required int idPessoa}) async {
    var pathParameters = {
      'pessoaId': idPessoa,
    };
    var response = await get(pathParameters: pathParameters);
    return (response.body as List<dynamic>)
        .map((json) => PontoDto.fromJson(json))
        .toList();
  }

  @override
  Future<Ponto> postPonto({
    required int valor,
    required DateTime validade,
    required String descricao,
    required int idPessoa,
  }) async {
    var novoPonto =
        PontoDto(valor: valor, validade: validade, descricao: descricao);
    var pathParameters = {
      'pessoaId': idPessoa,
    };
    final response = await post(
      body: novoPonto,
      pathParameters: pathParameters,
    );
    return PontoDto.fromJson(response.body);
  }

  @override
  Future<Ponto> regatarPontos({
    required int idPessoa,
    required int quantidade,
    required String descricao,
  }) async {
    var pathParameters = {
      'pessoaId': idPessoa,
      'id': 'regastar',
    };
    var body = {
      'quantidade': quantidade,
      'observacao': descricao,
    };

    final response = await post(
      body: body,
      pathParameters: pathParameters,
    );

    return PontoDto.fromJson(response.body);
  }
}
