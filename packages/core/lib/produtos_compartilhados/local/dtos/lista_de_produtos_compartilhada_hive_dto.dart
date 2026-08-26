import 'package:core/hive_anotacoes.dart';

import '../../models/lista_de_produtos_compartilhada.dart';

class ListaDeProdutosCompartilhadaHiveDto extends ListaDeProdutosCompartilhada
    with HiveDto<ListaDeProdutosCompartilhada>, StorageEntity {
  ListaDeProdutosCompartilhadaHiveDto({
    required super.hash,
    required super.criadaEm,
    required super.atualizadaEm,
    required int origemIndex,
    super.idLista,
    super.pessoaId,
    super.funcionarioId,
    super.tabelaPrecoId,
    super.processada,
    super.clienteNome,
    super.funcionarioNome,
    super.tabelaPrecoNome,
  }) : super(origem: OrigemCompartilhadaTipo.values[origemIndex]);

  @override
  int get dataBaseId => hiveHash(hash);

  @override
  Map<String, dynamic> get storageProperties => {
    'hash': hash,
    'idLista': idLista,
    'origemIndex': origem.index,
    'criadaEm': criadaEm,
    'atualizadaEm': atualizadaEm,
    'pessoaId': pessoaId,
    'funcionarioId': funcionarioId,
    'tabelaPrecoId': tabelaPrecoId,
    'processada': processada,
    'clienteNome': clienteNome,
    'funcionarioNome': funcionarioNome,
    'tabelaPrecoNome': tabelaPrecoNome,
  };

  static ListaDeProdutosCompartilhadaHiveDto fromStorage(
    Map<String, dynamic> props,
  ) {
    return ListaDeProdutosCompartilhadaHiveDto(
      hash: props['hash'] as String,
      idLista: props['idLista'] as int?,
      origemIndex: props['origemIndex'] as int,
      criadaEm: props['criadaEm'] as DateTime,
      atualizadaEm: props['atualizadaEm'] as DateTime,
      pessoaId: props['pessoaId'] as int?,
      funcionarioId: props['funcionarioId'] as int?,
      tabelaPrecoId: props['tabelaPrecoId'] as int?,
      processada: props['processada'] as bool?,
      clienteNome: props['clienteNome'] as String?,
      funcionarioNome: props['funcionarioNome'] as String?,
      tabelaPrecoNome: props['tabelaPrecoNome'] as String?,
    );
  }
}
