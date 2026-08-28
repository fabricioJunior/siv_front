import 'package:produtos/domain/models/estampa.dart';
import 'package:produtos/repositorios.dart';

class RecuperarEstampa {
  final IEstampasRepository _estampasRepository;

  RecuperarEstampa({required IEstampasRepository estampasRepository})
    : _estampasRepository = estampasRepository;

  Future<Estampa?> call(int id) {
    return _estampasRepository.obterEstampa(id);
  }
}
