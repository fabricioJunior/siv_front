import 'package:core/data_sourcers.dart';

import 'i_paginacao_data_source.dart';
import 'paginacao.dart';
import 'paginacao_hive_dto.dart';

class PaginacaoHiveDataSource
    extends HiveLocalDataSourceBase<PaginacaoHiveDto, Paginacao>
    implements IPaginacaoDataSource {
  PaginacaoHiveDataSource({required super.getBox});

  @override
  Future<Paginacao?> buscarPaginacao(String key) {
    return fetchById(PaginacaoHiveDto.databaseIdFor(key));
  }

  @override
  Future<void> salvarPaginacao(Paginacao paginacao) {
    return put(paginacao);
  }

  @override
  Future<void> limparTudo() => deleteAll();

  @override
  PaginacaoHiveDto toDto(Paginacao entity) {
    return PaginacaoHiveDto.fromModel(entity);
  }
}
