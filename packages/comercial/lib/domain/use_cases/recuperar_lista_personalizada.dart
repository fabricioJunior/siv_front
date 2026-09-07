import 'package:comercial/domain/data/repositories/i_lista_personalizada_repository.dart';
import 'package:comercial/domain/models/lista_personalizada.dart';

class RecuperarListaPersonalizada {
  final IListaPersonalizadaRepository _repository;

  RecuperarListaPersonalizada({required IListaPersonalizadaRepository repository})
      : _repository = repository;

  Future<ListaPersonalizada> call(int id) => _repository.buscarPorId(id);
}
