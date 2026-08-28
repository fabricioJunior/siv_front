import 'package:produtos/models.dart';
import 'package:produtos/repositorios.dart';

class CriarEstampa {
  final IEstampasRepository _estampasRepository;

  CriarEstampa({required IEstampasRepository estampasRepository})
    : _estampasRepository = estampasRepository;

  Future<Estampa> call(String nome) async {
    return _estampasRepository.criarEstampa(nome);
  }
}
