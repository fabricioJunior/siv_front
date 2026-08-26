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
    return fetchWhere((dto) {
      if (origem != null && dto.origemIndex != origem.index) return false;
      if (idLista != null && dto.idLista != idLista) return false;
      return true;
    });
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
      pessoaId: entity.pessoaId,
      funcionarioId: entity.funcionarioId,
      tabelaPrecoId: entity.tabelaPrecoId,
      clienteNome: entity.clienteNome,
      funcionarioNome: entity.funcionarioNome,
      tabelaPrecoNome: entity.tabelaPrecoNome,
    );
  }
}
