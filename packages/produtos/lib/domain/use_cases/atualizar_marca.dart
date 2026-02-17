import 'package:produtos/repositorios.dart';

class AtualizarMarca {
  final IMarcasRepository _marcasRepository;

  AtualizarMarca({required IMarcasRepository marcasRepository})
    : _marcasRepository = marcasRepository;

  Future<dynamic> call(int id, String nome) async {
    return _marcasRepository.atualizarMarca(id, nome);
  }
}
