import 'package:core/remote_data_sourcers.dart';
import 'package:financeiro/domain/data/remote/i_cancelamentos_remote_data_source.dart';

class CancelamentosRemoteDataSource extends RemoteDataSourceBase
    implements ICancelamentosRemoteDataSource {
  CancelamentosRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/caixas/{caixaId}/cancelar/{tipo}';
                  //  /v1/caixas/{caixaId}/cancelar/romaneio///

  @override
  Future<void> cancelarAdiantamento({
    required int idRomaneio,
    required String motivo,
    required int idCaixa,
  }) async {
    var pathParameters = {
      'caixaId': idCaixa.toString(),
      'tipo': 'adiantamento',
    };
    await put(
      body: {
        'idRomaneio': idRomaneio,
        'motivo': motivo,
      },
      pathParameters: pathParameters,
    );
  }

  @override
  Future<void> cancelarRomaneio({
    required int idRomaneio,
    required String motivo,
    required int idCaixa,
  }) async {
    var pathParameters = {
      'caixaId': idCaixa.toString(),
      'tipo': 'romaneio',
    };
    await put(
      body: {
        'romaneioId': idRomaneio,
        'motivo': motivo,
      },
      pathParameters: pathParameters,
    );
  }
}
