import 'package:comercial/domain/data/repositories/i_listas_grupos_repository.dart';
import 'package:comercial/domain/models/lista_grupo.dart';

class ListarListasGrupos {
  final IListasGruposRepository _repository;

  ListarListasGrupos({required IListasGruposRepository repository}) : _repository = repository;

  Future<PaginaListasGrupos> call({int page = 1, int limit = 20}) =>
      _repository.listar(page: page, limit: limit);
}
