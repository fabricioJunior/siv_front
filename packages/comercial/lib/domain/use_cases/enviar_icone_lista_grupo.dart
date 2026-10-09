import 'dart:typed_data';

import 'package:comercial/domain/data/repositories/i_listas_grupos_repository.dart';
import 'package:comercial/domain/models/lista_grupo.dart';

class EnviarIconeListaGrupo {
  final IListasGruposRepository _repository;

  EnviarIconeListaGrupo({required IListasGruposRepository repository}) : _repository = repository;

  Future<ListaGrupo> call(int id, Uint8List bytes, String fileName) =>
      _repository.enviarIcone(id, bytes, fileName);
}
