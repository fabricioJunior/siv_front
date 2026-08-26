import 'package:core/local_data_sourcers/isar/isar_local_data_source_base.dart';
import 'package:core/paginacao/i_paginacao_data_source.dart';
import 'package:core/paginacao/paginacao.dart';
import 'package:core/paginacao/paginacao_isar_dto.dart';

class PaginacaoDataSource
    extends IsarLocalDataSourceBase<PaginacaoIsarDto, Paginacao>
    implements IPaginacaoDataSource {
  PaginacaoDataSource({required super.getIsar});

  @override
  Future<Paginacao?> buscarPaginacao(String key) {
    return fetchById(PaginacaoIsarDto.databaseIdFor(key));
  }

  @override
  Future<void> salvarPaginacao(Paginacao paginacao) {
    return put(paginacao);
  }

  @override
  Future<void> limparTudo() => deleteAll();

  @override
  PaginacaoIsarDto toDto(Paginacao entity) {
    return PaginacaoIsarDto(
      paginaAtual: entity.paginaAtual,
      totalPaginas: entity.totalPaginas,
      itensPorPagina: entity.itensPorPagina,
      itensProcessadosNaPagina: entity.itensProcessadosNaPagina,
      totalItens: entity.totalItens,
      key: entity.key,
      dataAtualizacao: entity.dataAtualizacao,
      ended: entity.ended,
    );
  }
}
