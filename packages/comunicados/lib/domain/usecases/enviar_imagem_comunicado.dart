import 'dart:typed_data';

import 'package:comunicados/domain/data/repositorios/i_comunicado_repository.dart';

class EnviarImagemComunicado {
  final IComunicadoRepository repository;

  EnviarImagemComunicado({required this.repository});

  Future<String> call(Uint8List bytes, String fileName) {
    return repository.enviarImagem(bytes, fileName);
  }
}
