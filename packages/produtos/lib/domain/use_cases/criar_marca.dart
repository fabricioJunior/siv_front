import 'package:produtos/models.dart';
import 'package:produtos/repositorios.dart';

class CriarMarca {
  final IMarcasRepository _marcasRepository;

  CriarMarca({required IMarcasRepository marcasRepository})
    : _marcasRepository = marcasRepository;

  Future<Marca> call(String nome) async {
    return _marcasRepository.criarMarca(nome);
  }
}
