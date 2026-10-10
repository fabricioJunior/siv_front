import 'package:comercial/domain/data/repositories/i_listas_grupos_repository.dart';

class DefinirListasDoGrupo {
  final IListasGruposRepository _repository;

  DefinirListasDoGrupo({required IListasGruposRepository repository}) : _repository = repository;

  Future<void> call(int id, List<int> listaIds) =>
      _repository.definirListas(id, listaIds);
}
