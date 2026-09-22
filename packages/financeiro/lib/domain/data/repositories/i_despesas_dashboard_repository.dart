import 'package:financeiro/domain/models/despesa_dashboard.dart';

abstract class IDespesasDashboardRepository {
  Future<DespesaDashboard> recuperarDashboard({
    required int empresaId,
    required int ano,
    required int mes,
  });
}
