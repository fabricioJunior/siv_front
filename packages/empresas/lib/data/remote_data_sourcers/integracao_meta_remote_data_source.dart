import 'package:core/remote_data_sourcers.dart';
import 'package:empresas/data/remote_data_sourcers/dtos/integracao_meta_dto.dart';
import 'package:empresas/domain/data/remote_data_sourcers/i_integracao_meta_remote_data_source.dart';
import 'package:empresas/domain/entities/integracao_meta.dart';

class IntegracaoMetaRemoteDataSource extends RemoteDataSourceBase
    implements IIntegracaoMetaRemoteDataSource {
  IntegracaoMetaRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/empresas/{empresaId}/integracoes-meta{sub}';

  @override
  Future<IntegracaoMeta> recuperar(int empresaId) async {
    final response = await get(
      pathParameters: {'empresaId': empresaId.toString()},
    );
    return IntegracaoMetaDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<IntegracaoMeta> salvar(
    int empresaId,
    IntegracaoMetaAlteracoes alteracoes,
  ) async {
    final response = await put(
      pathParameters: {'empresaId': empresaId.toString()},
      body: IntegracaoMetaDto.alteracoesToJson(alteracoes),
    );
    return IntegracaoMetaDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<IntegracaoMetaTeste> testar(int empresaId) async {
    final response = await post(
      pathParameters: {'empresaId': empresaId.toString(), 'sub': '/testar'},
      body: <String, dynamic>{},
    );
    return IntegracaoMetaDto.testeFromJson(
      response.body as Map<String, dynamic>,
    );
  }
}
