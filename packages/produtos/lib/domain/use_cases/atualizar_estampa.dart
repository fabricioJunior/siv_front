import 'package:produtos/models.dart';
import 'package:produtos/repositorios.dart';

class AtualizarEstampa {
  final IEstampasRepository _estampasRepository;

  AtualizarEstampa({required IEstampasRepository estampasRepository})
    : _estampasRepository = estampasRepository;

  Future<Estampa> call(int id, String nome) async {
    return await _estampasRepository.atualizarEstampa(id, nome);
  }
}
