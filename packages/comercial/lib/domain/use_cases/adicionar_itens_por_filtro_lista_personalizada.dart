import 'package:comercial/domain/data/repositories/i_lista_personalizada_repository.dart';
import 'package:comercial/domain/models/lista_personalizada.dart';

class AdicionarItensPorFiltroListaPersonalizada {
  final IListaPersonalizadaRepository _repository;

  AdicionarItensPorFiltroListaPersonalizada({
    required IListaPersonalizadaRepository repository,
  }) : _repository = repository;

  Future<ListaItensLoteResultado> call(int id, ListaItensLote lote) =>
      _repository.adicionarPorFiltro(id, lote);
}
