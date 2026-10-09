import 'dart:typed_data';

import 'package:comercial/domain/data/repositories/i_lista_personalizada_repository.dart';
import 'package:comercial/domain/models/lista_personalizada.dart';

class EnviarIconeListaPersonalizada {
  final IListaPersonalizadaRepository _repository;

  EnviarIconeListaPersonalizada({required IListaPersonalizadaRepository repository})
      : _repository = repository;

  Future<ListaPersonalizada> call(int id, Uint8List bytes, String fileName) =>
      _repository.enviarIcone(id, bytes, fileName);
}
