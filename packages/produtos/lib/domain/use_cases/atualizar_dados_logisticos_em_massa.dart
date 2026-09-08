import 'package:produtos/domain/data/repositorios/i_referencias_pendentes_peso_repository.dart';

export 'package:produtos/domain/data/repositorios/i_referencias_pendentes_peso_repository.dart'
    show AtualizarDadosLogisticosEmMassaResultado;

class AtualizarDadosLogisticosEmMassa {
  final IReferenciasPendentesPesoRepository _repository;

  AtualizarDadosLogisticosEmMassa({
    required IReferenciasPendentesPesoRepository repository,
  }) : _repository = repository;

  Future<AtualizarDadosLogisticosEmMassaResultado> call() {
    return _repository.atualizarDadosLogisticosEmMassa();
  }
}
