import 'package:produtos/domain/models/referencias_busca.dart';

abstract class IReferenciasBuscaRepository {
  Future<ReferenciasBuscaResultado> buscar({
    String? busca,
    int? categoriaId,
    bool semNcm = false,
    bool semPeso = false,
    String orderBy = 'nome',
    String orderDir = 'ASC',
    int page = 1,
  });
}
