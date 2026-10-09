import 'package:comercial/domain/data/repositories/i_listas_grupos_repository.dart';
import 'package:comercial/domain/models/lista_grupo.dart';

class AtualizarListaGrupo {
  final IListasGruposRepository _repository;

  AtualizarListaGrupo({required IListasGruposRepository repository}) : _repository = repository;

  Future<ListaGrupo> call(int id, {required String nome, String? descricao}) =>
      _repository.atualizar(id, nome: nome, descricao: descricao);
}
