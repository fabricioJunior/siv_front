import 'package:comercial/domain/data/repositories/i_lista_personalizada_repository.dart';

class BuscarLinkListaPersonalizada {
  final IListaPersonalizadaRepository _repository;

  BuscarLinkListaPersonalizada({required IListaPersonalizadaRepository repository})
      : _repository = repository;

  Future<String> call(int id) => _repository.buscarLink(id);
}
