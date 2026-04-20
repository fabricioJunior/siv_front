import 'package:sistema/domain/data/repositories/i_dispositivo_repository.dart';

class ApagarDadosLocais {
  final IDispositivoRepository _repository;

  ApagarDadosLocais({required IDispositivoRepository repository})
      : _repository = repository;

  Future<void> call() {
    return _repository.apagarDadosLocais();
  }
}
