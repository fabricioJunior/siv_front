import 'package:core/remote_data_sourcers.dart';
import 'package:entregas/data/remote/dtos/frete_dto.dart';
import 'package:entregas/domain/data/remote/i_frete_remote_data_source.dart';
import 'package:entregas/domain/models/frete.dart';

class FreteRemoteDataSource extends RemoteDataSourceBase
    implements IFreteRemoteDataSource {
  FreteRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/integracoes-frete{path}';

  @override
  Future<ConfiguracaoFrete> getConfiguracao() async {
    final response = await get(pathParameters: {'path': '/configuracao'});
    return ConfiguracaoFreteDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<List<String>> getTransportadoras() async {
    final response = await get(pathParameters: {'path': '/transportadoras'});
    return (response.body as List<dynamic>)
        .map((j) => (j as Map<String, dynamic>)['nome'] as String)
        .toList();
  }

  @override
  Future<void> salvarTransportadoras({
    required bool ativo,
    required List<String> transportadoras,
  }) async {
    await post(
      pathParameters: {'path': '/configuracao'},
      body: {
        'provider': 'melhor_envio',
        'ativo': ativo,
        'configuracao': {'transportadoras': transportadoras},
      },
    );
  }

  @override
  Future<void> salvarIntegracao({
    required bool ativo,
    required bool sandbox,
    required String clientId,
    String? clientSecret,
  }) async {
    await post(
      pathParameters: {'path': '/configuracao'},
      body: {
        'provider': 'melhor_envio',
        'ativo': ativo,
        'configuracao': {
          'clientId': clientId,
          'sandbox': sandbox,
          if (clientSecret != null) 'clientSecret': clientSecret,
        },
      },
    );
  }

  @override
  Future<String> getUrlAutorizacao() async {
    final response = await get(pathParameters: {'path': '/autorizar-url'});
    return (response.body as Map<String, dynamic>)['url'] as String;
  }
}
