import 'package:comercial/domain/data/repositories/i_lista_personalizada_repository.dart';
import 'package:comercial/domain/models/lista_personalizada.dart';

class AdicionarItensListaPersonalizada {
  final IListaPersonalizadaRepository _repository;

  AdicionarItensListaPersonalizada({
    required IListaPersonalizadaRepository repository,
  }) : _repository = repository;

  Future<ListaPersonalizada> call(int id, List<int> referenciaIds) =>
      _repository.adicionarItens(id, referenciaIds);
}
