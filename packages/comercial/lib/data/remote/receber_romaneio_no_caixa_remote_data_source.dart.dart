import 'package:comercial/data.dart';
import 'package:core/remote_data_sourcers.dart';

class ReceberRomaneioNoCaixaRemoteDataSource extends RemoteDataSourceBase
    implements IReceberRomaneioNoCaixaRemoteDataSource {
  ReceberRomaneioNoCaixaRemoteDataSource(
      {required super.informacoesParaRequest});

  @override
  String get path => '/v1/caixas/{caixaId}/receber/romaneio';

  @override
  Future<void> receberRomaneio({
    required int caixaId,
    required int romaneioId,
  }) async {
    await post(
      pathParameters: {'caixaId': caixaId},
      body: {'romaneioId': romaneioId},
    );
  }
}
