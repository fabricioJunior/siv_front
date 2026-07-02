import 'package:produtos/domain/data/repositorios/i_referencias_pendentes_ncm_repository.dart';

export 'package:produtos/domain/data/repositorios/i_referencias_pendentes_ncm_repository.dart'
    show ReferenciasSemNcmResultado;

class RecuperarReferenciasSemNcm {
  final IReferenciasPendentesNcmRepository _repository;

  RecuperarReferenciasSemNcm({
    required IReferenciasPendentesNcmRepository repository,
  }) : _repository = repository;

  Future<ReferenciasSemNcmResultado> call({
    String? search,
    String orderBy = 'nome',
    String orderDir = 'ASC',
    int page = 1,
  }) {
    return _repository.obterReferenciasSemNcm(
      search: search,
      orderBy: orderBy,
      orderDir: orderDir,
      page: page,
    );
  }
}
