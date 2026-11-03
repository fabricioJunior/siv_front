import 'package:produtos/domain/data/remote/i_consulta_referencias_remote_data_source.dart';
import 'package:produtos/domain/data/repositorios/i_consulta_referencias_repository.dart';
import 'package:produtos/domain/models/consulta_referencias.dart';

class ConsultaReferenciasRepository implements IConsultaReferenciasRepository {
  final IConsultaReferenciasRemoteDataSource _dataSource;

  ConsultaReferenciasRepository({
    required IConsultaReferenciasRemoteDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<ConsultaReferenciasPagina> consultar({
    String? busca,
    List<int> corIds = const [],
    List<int> tamanhoIds = const [],
    List<int> estampaIds = const [],
    int? tabelaPrecoId,
    int page = 1,
    int limit = 30,
  }) => _dataSource.consultar(
    busca: busca,
    corIds: corIds,
    tamanhoIds: tamanhoIds,
    estampaIds: estampaIds,
    tabelaPrecoId: tabelaPrecoId,
    page: page,
    limit: limit,
  );
}
