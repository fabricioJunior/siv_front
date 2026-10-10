import 'package:comercial/domain/data/repositories/i_lista_personalizada_repository.dart';
import 'package:comercial/domain/models/lista_personalizada.dart';

class RecuperarPreviaListaPersonalizada {
  final IListaPersonalizadaRepository _repository;

  RecuperarPreviaListaPersonalizada({required IListaPersonalizadaRepository repository})
      : _repository = repository;

  Future<ListaPrevia> call(int id, {int page = 1, int limit = 20}) =>
      _repository.previa(id, page: page, limit: limit);
}
