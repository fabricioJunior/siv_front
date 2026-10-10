import 'package:comercial/domain/data/repositories/i_lista_personalizada_repository.dart';
import 'package:comercial/domain/models/lista_personalizada.dart';

class CriarListaPersonalizada {
  final IListaPersonalizadaRepository _repository;

  CriarListaPersonalizada({required IListaPersonalizadaRepository repository})
      : _repository = repository;

  Future<ListaPersonalizada> call(ListaPersonalizadaInput input) =>
      _repository.criar(input);
}
