import 'package:core/remote_data_sourcers.dart';
import 'package:empresas/domain/data/remote_data_sourcers/i_config_credito_devolucao_remote_data_source.dart';
import 'package:empresas/domain/entities/config_credito_devolucao.dart';

class ConfigCreditoDevolucaoRemoteDataSource extends RemoteDataSourceBase
    implements IConfigCreditoDevolucaoRemoteDataSource {
  ConfigCreditoDevolucaoRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/empresas/{empresaId}/configuracoes/credito-de-devolucao';

  @override
  Future<ConfigCreditoDevolucao> recuperar(int empresaId) async {
    final response = await get(pathParameters: {'empresaId': empresaId});
    return _deJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<ConfigCreditoDevolucao> salvar(
    int empresaId,
    ConfigCreditoDevolucao config,
  ) async {
    final response = await put(
      pathParameters: {'empresaId': empresaId},
      body: {
        'validadeDiasPadrao': config.validadeDiasPadrao,
        'avisoDiasAntes': config.avisoDiasAntes,
      },
    );
    return _deJson(response.body as Map<String, dynamic>);
  }

  ConfigCreditoDevolucao _deJson(Map<String, dynamic> j) {
    final dias = j['validadeDiasPadrao'];
    final aviso = j['avisoDiasAntes'];
    return ConfigCreditoDevolucao(
      validadeDiasPadrao: dias is num ? dias.toInt() : null,
      avisoDiasAntes: aviso is num ? aviso.toInt() : 7,
    );
  }
}
