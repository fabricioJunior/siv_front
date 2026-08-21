import 'dart:io';

import 'package:comunicados/domain/data/repositorios/i_comunicado_repository.dart';

class EnviarImagemComunicado {
  final IComunicadoRepository repository;

  EnviarImagemComunicado({required this.repository});

  Future<String> call(File file) {
    return repository.enviarImagem(file);
  }
}
