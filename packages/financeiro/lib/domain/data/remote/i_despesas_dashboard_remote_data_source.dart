import 'package:financeiro/domain/models/despesa_dashboard.dart';

abstract class IDespesasDashboardRemoteDataSource {
  Future<DespesaDashboard> recuperarDashboard({
    required int empresaId,
    required int ano,
    required int mes,
  });
}
