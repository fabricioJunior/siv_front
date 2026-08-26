import 'package:core/isar_anotacoes.dart';

import 'paginacao.dart';

part 'paginacao_isar_dto.g.dart';

@Collection(ignore: {'items', 'itensProcessadosNaPagina'})
class PaginacaoIsarDto<E> extends Paginacao<E> implements IsarDto {
  PaginacaoIsarDto({
    required super.paginaAtual,
    required super.totalPaginas,
    required super.itensPorPagina,
    super.itensProcessadosNaPagina,
    required super.totalItens,
    required super.key,
    required super.dataAtualizacao,
    super.ended,
  });

  @override
  Id get dataBaseId => databaseIdFor(key);

  static Id databaseIdFor(String key) => fastHash(key);
}
