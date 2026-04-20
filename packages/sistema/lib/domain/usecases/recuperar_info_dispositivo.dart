import 'package:sistema/domain/data/repositories/i_dispositivo_repository.dart';
import 'package:sistema/domain/models/info_dispositivo.dart';

class RecuperarInfoDispositivo {
  final IDispositivoRepository _repository;

  RecuperarInfoDispositivo({required IDispositivoRepository repository})
      : _repository = repository;

  Future<InfoDispositivo> call() {
    return _repository.obterInfo();
  }
}
