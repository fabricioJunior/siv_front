import 'package:produtos/domain/data/remote/i_codigos_de_barras_da_referencia_remote_data_source.dart';
import 'package:produtos/domain/data/repositorios/i_codigos_de_barras_da_referencia_repository.dart';
import 'package:produtos/domain/models/pagina_codigos_de_barras.dart';

class CodigosDeBarrasDaReferenciaRepository
    implements ICodigosDeBarrasDaReferenciaRepository {
  final ICodigosDeBarrasDaReferenciaRemoteDataSource _remoteDataSource;

  CodigosDeBarrasDaReferenciaRepository({
    required ICodigosDeBarrasDaReferenciaRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<PaginaCodigosDeBarras> listar({
    required int referenciaId,
    required int page,
    required int limit,
  }) {
    return _remoteDataSource.listar(
      referenciaId: referenciaId,
      page: page,
      limit: limit,
    );
  }
}
