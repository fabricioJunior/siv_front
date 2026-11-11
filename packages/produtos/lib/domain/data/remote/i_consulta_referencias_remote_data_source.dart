import 'package:produtos/domain/models/consulta_referencias.dart';

abstract class IConsultaReferenciasRemoteDataSource {
  Future<ConsultaReferenciasPagina> consultar({
    String? busca,
    List<int> corIds = const [],
    List<int> tamanhoIds = const [],
    List<int> estampaIds = const [],
    int? tabelaPrecoId,
    int page = 1,
    int limit = 30,
  });
}
