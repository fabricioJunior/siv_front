import 'package:produtos/repositorios.dart';

class RecuperarCustoReferencia {
  final IReferenciasRepository _referenciasRepository;

  RecuperarCustoReferencia({
    required IReferenciasRepository referenciasRepository,
  }) : _referenciasRepository = referenciasRepository;

  Future<double?> call({required int id}) {
    return _referenciasRepository.obterCusto(id: id);
  }
}
