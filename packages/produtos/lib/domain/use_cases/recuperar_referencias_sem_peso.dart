import 'package:produtos/domain/data/repositorios/i_referencias_pendentes_peso_repository.dart';

export 'package:produtos/domain/data/repositorios/i_referencias_pendentes_peso_repository.dart'
    show ReferenciasSemPesoResultado;

class RecuperarReferenciasSemPeso {
  final IReferenciasPendentesPesoRepository _repository;

  RecuperarReferenciasSemPeso({
    required IReferenciasPendentesPesoRepository repository,
  }) : _repository = repository;

  Future<ReferenciasSemPesoResultado> call({
    String? search,
    String orderBy = 'nome',
    String orderDir = 'ASC',
    int page = 1,
  }) {
    return _repository.obterReferenciasSemPeso(
      search: search,
      orderBy: orderBy,
      orderDir: orderDir,
      page: page,
    );
  }
}
