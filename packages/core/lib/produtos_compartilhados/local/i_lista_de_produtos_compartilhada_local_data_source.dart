import '../models/lista_de_produtos_compartilhada.dart';

abstract class IListaDeProdutosCompartilhadaLocalDataSource {
  Future<void> salvar(
    ListaDeProdutosCompartilhada lista,
  );

  Future<ListaDeProdutosCompartilhada?> recuperar(String hash);

  Future<void> apagar(String hash);

  Future<Iterable<ListaDeProdutosCompartilhada>> recuperarTodas();

  Future<Iterable<ListaDeProdutosCompartilhada>> recuperarWhere({
    OrigemCompartilhadaTipo? origem,
    int? idLista,
  });
}
