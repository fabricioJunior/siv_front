import 'package:comercial/domain/data/remote/i_saldo_total_credito_devolucao_remote_data_source.dart';
import 'package:core/remote_data_sourcers.dart';

class SaldoTotalCreditoDevolucaoRemoteDataSource extends RemoteDataSourceBase
    implements ISaldoTotalCreditoDevolucaoRemoteDataSource {
  SaldoTotalCreditoDevolucaoRemoteDataSource({
    required super.informacoesParaRequest,
  });

  @override
  String get path => '/v1/pessoas/{pessoaId}/extrato/saldo';

  @override
  Future<double> buscarSaldo({required int pessoaId}) async {
    final response = await get(
      pathParameters: {'pessoaId': pessoaId},
    );

    return _parseSaldo(response.body);
  }

  double _parseSaldo(dynamic body) {
    if (body is num) return body.toDouble();

    if (body is Map<String, dynamic>) {
      for (final key in const ['saldo', 'saldoTotal', 'total', 'valor']) {
        final value = body[key];
        if (value is num) return value.toDouble();
      }
    }

    throw const FormatException('Resposta invalida ao consultar saldo.');
  }
}