import 'package:comercial/domain/data/repositories/i_lista_personalizada_repository.dart';
import 'package:comercial/domain/models/lista_personalizada.dart';

class RemoverItensListaPersonalizada {
  final IListaPersonalizadaRepository _repository;

  RemoverItensListaPersonalizada({
    required IListaPersonalizadaRepository repository,
  }) : _repository = repository;

  Future<ListaPersonalizada> call(int id, List<int> referenciaIds) =>
      _repository.removerItens(id, referenciaIds);
}
