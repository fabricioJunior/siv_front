import 'package:produtos/domain/data/remote/i_referencias_pendentes_ncm_remote_data_source.dart';
import 'package:produtos/domain/data/repositorios/i_referencias_pendentes_ncm_repository.dart';

class ReferenciasPendentesNcmRepository
    implements IReferenciasPendentesNcmRepository {
  final IReferenciasPendentesNcmRemoteDataSource _dataSource;

  ReferenciasPendentesNcmRepository({
    required IReferenciasPendentesNcmRemoteDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<ReferenciasSemNcmResultado> obterReferenciasSemNcm({
    String? search,
    String orderBy = 'nome',
    String orderDir = 'ASC',
    int page = 1,
  }) {
    return _dataSource.fetchReferenciasSemNcm(
      search: search,
      orderBy: orderBy,
      orderDir: orderDir,
      page: page,
    );
  }

  @override
  Future<AtualizarNcmEmMassaResultado> atualizarNcmEmMassa() {
    return _dataSource.atualizarNcmEmMassa();
  }
}
