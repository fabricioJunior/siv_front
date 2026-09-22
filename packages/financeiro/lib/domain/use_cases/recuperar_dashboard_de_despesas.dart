import 'package:financeiro/domain/data/repositories/i_despesas_dashboard_repository.dart';
import 'package:financeiro/domain/models/despesa_dashboard.dart';

class RecuperarDashboardDeDespesas {
  final IDespesasDashboardRepository repository;

  RecuperarDashboardDeDespesas({required this.repository});

  Future<DespesaDashboard> call({
    required int empresaId,
    required int ano,
    required int mes,
  }) {
    return repository.recuperarDashboard(empresaId: empresaId, ano: ano, mes: mes);
  }
}
