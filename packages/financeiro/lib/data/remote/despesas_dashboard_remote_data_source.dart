import 'package:core/remote_data_sourcers.dart';
import 'package:financeiro/domain/data/remote/i_despesas_dashboard_remote_data_source.dart';
import 'package:financeiro/domain/models/despesa_dashboard.dart';

class DespesasDashboardRemoteDataSource extends RemoteDataSourceBase
    implements IDespesasDashboardRemoteDataSource {
  DespesasDashboardRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/despesas/dashboard';

  @override
  Future<DespesaDashboard> recuperarDashboard({
    required int empresaId,
    required int ano,
    required int mes,
  }) async {
    final response = await get(
      queryParameters: {
        'empresaId': empresaId.toString(),
        'ano': ano.toString(),
        'mes': mes.toString(),
      },
    );

    return DespesaDashboard.fromJson(response.body as Map<String, dynamic>);
  }
}
