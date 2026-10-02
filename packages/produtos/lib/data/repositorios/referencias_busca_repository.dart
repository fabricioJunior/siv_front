import 'package:produtos/domain/data/remote/i_referencias_busca_remote_data_source.dart';
import 'package:produtos/domain/data/repositorios/i_referencias_busca_repository.dart';
import 'package:produtos/domain/models/referencias_busca.dart';

class ReferenciasBuscaRepository implements IReferenciasBuscaRepository {
  final IReferenciasBuscaRemoteDataSource _dataSource;

  ReferenciasBuscaRepository({
    required IReferenciasBuscaRemoteDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<ReferenciasBuscaResultado> buscar({
    String? busca,
    int? categoriaId,
    bool semNcm = false,
    bool semPeso = false,
    String orderBy = 'nome',
    String orderDir = 'ASC',
    int page = 1,
  }) {
    return _dataSource.buscar(
      busca: busca,
      categoriaId: categoriaId,
      semNcm: semNcm,
      semPeso: semPeso,
      orderBy: orderBy,
      orderDir: orderDir,
      page: page,
    );
  }
}
