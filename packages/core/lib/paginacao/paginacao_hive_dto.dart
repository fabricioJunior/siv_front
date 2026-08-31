import 'package:core/hive_anotacoes.dart';

import 'paginacao.dart';

class PaginacaoHiveDto extends Paginacao with HiveDto<Paginacao>, StorageEntity {
  PaginacaoHiveDto({
    required super.key,
    required super.paginaAtual,
    required super.totalPaginas,
    required super.itensPorPagina,
    super.itensProcessadosNaPagina,
    required super.totalItens,
    required super.dataAtualizacao,
    super.ended,
  });

  @override
  int get dataBaseId => databaseIdFor(key);

  static int databaseIdFor(String key) => hiveHash(key);

  @override
  Map<String, dynamic> get storageProperties => {
        'key': key,
        'paginaAtual': paginaAtual,
        'totalPaginas': totalPaginas,
        'itensPorPagina': itensPorPagina,
        'itensProcessadosNaPagina': itensProcessadosNaPagina,
        'totalItens': totalItens,
        'dataAtualizacao': dataAtualizacao?.toIso8601String(),
        'ended': ended,
      };

  static PaginacaoHiveDto fromStorage(Map<String, dynamic> props) {
    return PaginacaoHiveDto(
      key: props['key'] as String,
      paginaAtual: props['paginaAtual'] as int,
      totalPaginas: props['totalPaginas'] as int,
      itensPorPagina: props['itensPorPagina'] as int,
      itensProcessadosNaPagina: props['itensProcessadosNaPagina'] as int,
      totalItens: props['totalItens'] as int,
      dataAtualizacao: props['dataAtualizacao'] == null
          ? null
          : DateTime.parse(props['dataAtualizacao'] as String),
      ended: props['ended'] as bool,
    );
  }

  factory PaginacaoHiveDto.fromModel(Paginacao model) {
    return PaginacaoHiveDto(
      key: model.key,
      paginaAtual: model.paginaAtual,
      totalPaginas: model.totalPaginas,
      itensPorPagina: model.itensPorPagina,
      itensProcessadosNaPagina: model.itensProcessadosNaPagina,
      totalItens: model.totalItens,
      dataAtualizacao: model.dataAtualizacao,
      ended: model.ended,
    );
  }
}
