import 'package:comercial/domain/data/repositories/i_lista_personalizada_repository.dart';
import 'package:comercial/domain/models/lista_personalizada.dart';

class AtualizarListaPersonalizada {
  final IListaPersonalizadaRepository _repository;

  AtualizarListaPersonalizada({required IListaPersonalizadaRepository repository})
      : _repository = repository;

  Future<ListaPersonalizada> call(int id, ListaPersonalizadaInput input) =>
      _repository.atualizar(id, input);
}
