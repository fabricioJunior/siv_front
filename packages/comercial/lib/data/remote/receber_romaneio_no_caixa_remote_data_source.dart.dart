import 'package:comercial/data.dart';
import 'package:comercial/models.dart';
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
    required List<RomaneioPagamentoRealizado> formasDePagamentoRealizadas,
  }) async {
    await post(
      pathParameters: {'caixaId': caixaId},
      body: {
        'romaneioId': romaneioId,
        'formasDePagamento': formasDePagamentoRealizadas
            .map((forma) => _formaDePagamentoToJson(forma))
            .toList(growable: false),
      },
    );
  }

  Map<String, dynamic> _formaDePagamentoToJson(RomaneioPagamentoRealizado forma) {
    return {
      'controle': forma.controle,
      'formaDePagamentoId': forma.formaDePagamentoId,
      'parcela': forma.parcela,
      'valor': forma.valor,
    };
  }
}
