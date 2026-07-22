import 'package:produtos/repositorios.dart';

class RecuperarProximoIdReferencia {
  final IReferenciasRepository _referenciasRepository;

  RecuperarProximoIdReferencia({
    required IReferenciasRepository referenciasRepository,
  }) : _referenciasRepository = referenciasRepository;

  Future<int> call() async {
    return _referenciasRepository.obterProximoId();
  }
}
