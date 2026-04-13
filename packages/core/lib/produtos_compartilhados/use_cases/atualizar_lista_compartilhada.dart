import 'package:core/produtos_compartilhados/repositories/i_lista_de_produtos_compartilhada_repository.dart';

import '../models/lista_de_produtos_compartilhada.dart';

class AtualizarListaCompartilhada {
  final IListaDeProdutosCompartilhadaRepository _repository;

  AtualizarListaCompartilhada(
      {required IListaDeProdutosCompartilhadaRepository repository})
      : _repository = repository;

  Future<void> call(ListaDeProdutosCompartilhada lista) {
    return _repository.atualizarLista(lista);
  }
}
