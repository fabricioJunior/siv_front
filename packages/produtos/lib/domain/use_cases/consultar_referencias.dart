import 'package:produtos/domain/data/repositorios/i_consulta_referencias_repository.dart';
import 'package:produtos/domain/models/consulta_referencias.dart';

class ConsultarReferencias {
  final IConsultaReferenciasRepository _repository;

  ConsultarReferencias({required IConsultaReferenciasRepository repository})
    : _repository = repository;

  Future<ConsultaReferenciasPagina> call({
    String? busca,
    List<int> corIds = const [],
    List<int> tamanhoIds = const [],
    List<int> estampaIds = const [],
    int? tabelaPrecoId,
    int page = 1,
    int limit = 30,
  }) => _repository.consultar(
    busca: busca,
    corIds: corIds,
    tamanhoIds: tamanhoIds,
    estampaIds: estampaIds,
    tabelaPrecoId: tabelaPrecoId,
    page: page,
    limit: limit,
  );
}
