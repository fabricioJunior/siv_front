import 'dart:typed_data';

import 'package:produtos/models.dart';
import 'package:produtos/repositorios.dart';

class EnviarIconeCategoria {
  final ICategoriasRepository _categoriasRepository;

  EnviarIconeCategoria({required ICategoriasRepository categoriasRepository})
    : _categoriasRepository = categoriasRepository;

  Future<Categoria> call(int id, Uint8List bytes, String fileName) async {
    return _categoriasRepository.enviarIconeCategoria(id, bytes, fileName);
  }
}
