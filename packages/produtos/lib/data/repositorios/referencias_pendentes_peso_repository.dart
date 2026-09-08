import 'package:produtos/domain/data/remote/i_referencias_pendentes_peso_remote_data_source.dart';
import 'package:produtos/domain/data/repositorios/i_referencias_pendentes_peso_repository.dart';

class ReferenciasPendentesPesoRepository
    implements IReferenciasPendentesPesoRepository {
  final IReferenciasPendentesPesoRemoteDataSource _dataSource;

  ReferenciasPendentesPesoRepository({
    required IReferenciasPendentesPesoRemoteDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<ReferenciasSemPesoResultado> obterReferenciasSemPeso({
    String? search,
    String orderBy = 'nome',
    String orderDir = 'ASC',
    int page = 1,
  }) {
    return _dataSource.fetchReferenciasSemPeso(
      search: search,
      orderBy: orderBy,
      orderDir: orderDir,
      page: page,
    );
  }

  @override
  Future<AtualizarDadosLogisticosEmMassaResultado>
      atualizarDadosLogisticosEmMassa() {
    return _dataSource.atualizarDadosLogisticosEmMassa();
  }
}
