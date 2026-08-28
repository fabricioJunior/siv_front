import 'package:produtos/repositorios.dart';

class DesativarEstampa {
  final IEstampasRepository _estampasRepository;

  DesativarEstampa({required IEstampasRepository estampasRepository})
    : _estampasRepository = estampasRepository;

  Future<void> call(int id) {
    return _estampasRepository.desativarEstampa(id);
  }
}
