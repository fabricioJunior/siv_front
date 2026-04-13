import 'package:core/data_sourcers.dart';
import 'package:core/isar_anotacoes.dart';

import '../models/lista_de_produtos_compartilhada.dart';
import 'dtos/lista_de_produtos_compartilhada_dto.dart';
import 'i_lista_de_produtos_compartilhada_local_data_source.dart';

class ListaDeProdutosCompartilhadaLocalDataSource
    extends IsarLocalDataSourceBase<ListaDeProdutosCompartilhadaDto,
        ListaDeProdutosCompartilhada>
    implements IListaDeProdutosCompartilhadaLocalDataSource {
  ListaDeProdutosCompartilhadaLocalDataSource({required super.getIsar});

  @override
  Future<void> apagar(String hash) {
    return deleteById(fastHash(hash));
  }

  @override
  Future<ListaDeProdutosCompartilhada?> recuperar(String hash) {
    return fetchById(fastHash(hash));
  }

  @override
  Future<Iterable<ListaDeProdutosCompartilhada>> recuperarTodas() {
    return fetchAll();
  }

  @override
  Future<Iterable<ListaDeProdutosCompartilhada>> recuperarWhere({
    OrigemCompartilhadaTipo? origem,
    int? idLista,
  }) {
    return fetchWhere(FindLista(origem: origem, idLista: idLista));
  }

  @override
  Future<void> salvar(ListaDeProdutosCompartilhada lista) {
    return put(lista);
  }

  @override
  ListaDeProdutosCompartilhadaDto toDto(ListaDeProdutosCompartilhada entity) {
    return ListaDeProdutosCompartilhadaDto(
      hash: entity.hash,
      criadaEm: entity.criadaEm,
      atualizadaEm: entity.atualizadaEm,
      origemIndex: entity.origem.index,
      idLista: entity.idLista,
      funcionarioId: entity.funcionarioId,
      tabelaPrecoId: entity.tabelaPrecoId,
    );
  }
}

class FindLista
    implements
        Test<Iterable<ListaDeProdutosCompartilhadaDto>,
            IsarCollection<ListaDeProdutosCompartilhadaDto>> {
  final OrigemCompartilhadaTipo? origem;
  final int? idLista;

  FindLista({this.origem, this.idLista});

  @override
  Future<Iterable<ListaDeProdutosCompartilhadaDto>> call(
    IsarCollection<ListaDeProdutosCompartilhadaDto> collection,
  ) async {
    return await collection
        .filter()
        .optional(origem != null, (q) => q.origemIndexEqualTo(origem!.index))
        .and()
        .optional(idLista != null, (q) => q.idListaEqualTo(idLista!))
        .findAll();
  }
}
