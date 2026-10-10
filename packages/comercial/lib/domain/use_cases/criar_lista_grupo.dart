import 'package:comercial/domain/data/repositories/i_listas_grupos_repository.dart';
import 'package:comercial/domain/models/lista_grupo.dart';

class CriarListaGrupo {
  final IListasGruposRepository _repository;

  CriarListaGrupo({required IListasGruposRepository repository}) : _repository = repository;

  Future<ListaGrupo> call({required String nome, String? descricao, bool? ativo}) =>
      _repository.criar(nome: nome, descricao: descricao, ativo: ativo);
}
