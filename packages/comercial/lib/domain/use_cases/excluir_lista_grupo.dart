import 'package:comercial/domain/data/repositories/i_listas_grupos_repository.dart';

class ExcluirListaGrupo {
  final IListasGruposRepository _repository;

  ExcluirListaGrupo({required IListasGruposRepository repository}) : _repository = repository;

  Future<void> call(int id) => _repository.excluir(id);
}
