import 'package:produtos/models.dart';
import 'package:produtos/repositorios.dart';

class RecuperarReferencia {
  final IReferenciasRepository _referenciasRepository;

  RecuperarReferencia({required IReferenciasRepository referenciasRepository})
    : _referenciasRepository = referenciasRepository;

  Future<Referencia> call({required int id}) {
    return _referenciasRepository.obterReferencia(id: id);
  }
}
