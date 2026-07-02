import 'package:produtos/domain/data/repositorios/i_referencias_pendentes_ncm_repository.dart';

export 'package:produtos/domain/data/repositorios/i_referencias_pendentes_ncm_repository.dart'
    show AtualizarNcmEmMassaResultado;

class AtualizarNcmEmMassa {
  final IReferenciasPendentesNcmRepository _repository;

  AtualizarNcmEmMassa({
    required IReferenciasPendentesNcmRepository repository,
  }) : _repository = repository;

  Future<AtualizarNcmEmMassaResultado> call() {
    return _repository.atualizarNcmEmMassa();
  }
}
