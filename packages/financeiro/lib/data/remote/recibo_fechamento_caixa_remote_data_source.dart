import 'package:core/remote_data_sourcers.dart';
import 'package:financeiro/data.dart';
import 'package:financeiro/domain/models/recibo_fechamento_caixa.dart';

class ReciboFechamentoCaixaRemoteDataSource extends RemoteDataSourceBase
    implements IReciboFechamentoCaixaRemoteDataSource {
  ReciboFechamentoCaixaRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/caixas/{caixaId}/recibo-fechamento';

  @override
  Future<ReciboFechamentoCaixa> recuperarReciboFechamento({
    required int caixaId,
  }) async {
    final response = await get(
      pathParameters: {'caixaId': caixaId.toString()},
    );

    final body = response.body;
    if (body is! Map<String, dynamic>) {
      throw FormatException(
        'Formato invalido da resposta do recibo de fechamento: ${body.runtimeType}',
      );
    }

    return ReciboFechamentoCaixaDto.fromJson(body);
  }
}
