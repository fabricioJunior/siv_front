import 'package:core/data_sourcers.dart';
import 'package:core/local_data_sourcers/hive/hive_hash.dart';

import '../models/lista_de_produtos_compartilhada.dart';
import 'dtos/lista_de_produtos_compartilhada_hive_dto.dart';
import 'i_lista_de_produtos_compartilhada_local_data_source.dart';

class ListaDeProdutosCompartilhadaHiveDataSource
    extends HiveLocalDataSourceBase<ListaDeProdutosCompartilhadaHiveDto,
        ListaDeProdutosCompartilhada>
    implements IListaDeProdutosCompartilhadaLocalDataSource {
  ListaDeProdutosCompartilhadaHiveDataSource({required super.getBox});

  @override
  Future<void> apagar(String hash) {
    return deleteById(hiveHash(hash));
  }

  @override
  Future<ListaDeProdutosCompartilhada?> recuperar(String hash) {
    return fetchById(hiveHash(hash));
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
      if (origem != null && dto.origem != origem) return false;
      if (idLista != null && dto.idLista != idLista) return false;
      return true;
    });
  }

  @override
  Future<void> salvar(ListaDeProdutosCompartilhada lista) {
    return put(lista);
  }

  @override
  ListaDeProdutosCompartilhadaHiveDto toDto(
    ListaDeProdutosCompartilhada entity,
  ) {
    return ListaDeProdutosCompartilhadaHiveDto(
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
