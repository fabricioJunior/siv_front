import 'package:financeiro/domain/data/remote/i_despesas_dashboard_remote_data_source.dart';
import 'package:financeiro/domain/data/repositories/i_despesas_dashboard_repository.dart';
import 'package:financeiro/domain/models/despesa_dashboard.dart';

class DespesasDashboardRepository implements IDespesasDashboardRepository {
  final IDespesasDashboardRemoteDataSource remoteDataSource;

  DespesasDashboardRepository({required this.remoteDataSource});

  @override
  Future<DespesaDashboard> recuperarDashboard({
    required int empresaId,
    required int ano,
    required int mes,
  }) {
    return remoteDataSource.recuperarDashboard(
      empresaId: empresaId,
      ano: ano,
      mes: mes,
    );
  }
}
