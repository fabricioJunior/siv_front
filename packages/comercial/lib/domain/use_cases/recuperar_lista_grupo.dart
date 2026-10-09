import 'package:comercial/domain/data/repositories/i_listas_grupos_repository.dart';
import 'package:comercial/domain/models/lista_grupo.dart';

class RecuperarListaGrupo {
  final IListasGruposRepository _repository;

  RecuperarListaGrupo({required IListasGruposRepository repository}) : _repository = repository;

  Future<ListaGrupo> call(int id) => _repository.buscarPorId(id);
}
