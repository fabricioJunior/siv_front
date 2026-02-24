import 'package:core/remote_data_sourcers.dart';
import 'package:sistema/sistema.dart';

class ConfiguracaoSTMPRemoteDataSource extends RemoteDataSourceBase
    implements IConfiguracaoSTMPRemoteDataSource {
  ConfiguracaoSTMPRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/sistema/config-smtp/{extraPath}';

  @override
  Future<ConfiguracaoSTMP> atualizarConfiguracao(
    ConfiguracaoSTMP configuracao,
  ) async {
    var response = await put(body: configuracao.toDto());
    return ConfiguracaoSTMPDto.fromJson(response.body);
  }

  @override
  Future<ConfiguracaoSTMP> criarConfiguracao(
    ConfiguracaoSTMP configuracao,
  ) async {
    var response = await post(body: configuracao.toDto());
    return ConfiguracaoSTMPDto.fromJson(response.body);
  }

  @override
  Future<ConfiguracaoSTMP?> recuperarConfiguracao() async {
    var response = await get();
    if (response.statusCode == 200) {
      return ConfiguracaoSTMPDto.fromJson(response.body);
    } else if (response.statusCode == 404) {
      return Future.value(null);
    } else {
      throw Exception(
          'Erro ao recuperar configuração STMP: ${response.statusCode}');
    }
  }

  @override
  Future<bool> verificarConexao() async {
    var path = {'extraPath': 'verificar-conexao'};
    var response = await get(pathParameters: path);

    return response.statusCode == 200;
  }
}
