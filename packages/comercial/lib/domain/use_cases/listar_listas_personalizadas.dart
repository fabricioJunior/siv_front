import 'package:comercial/domain/data/repositories/i_lista_personalizada_repository.dart';
import 'package:comercial/domain/models/lista_personalizada_resumo.dart';

class ListarListasPersonalizadas {
  final IListaPersonalizadaRepository _repository;

  ListarListasPersonalizadas({required IListaPersonalizadaRepository repository})
      : _repository = repository;

  Future<PaginaListasPersonalizadas> call({int page = 1, int limit = 20}) =>
      _repository.listar(page: page, limit: limit);
}
