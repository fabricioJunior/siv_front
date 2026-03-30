import 'package:core/isar_anotacoes.dart';
import 'package:core/local_data_sourcers/isar/isar_local_data_source_base.dart';
import 'package:core/paginacao/i_paginacao_data_source.dart';
import 'package:core/paginacao/paginacao.dart';

class PaginacaoDataSource extends IsarLocalDataSourceBase<Paginacao, Paginacao>
    implements IPaginacaoDataSource {
  PaginacaoDataSource({required super.getIsar});

  @override
  Future<Paginacao?> buscarPaginacao(String key) {
    return fetchById(fastHash(key));
  }

  @override
  Future<void> salvarPaginacao(Paginacao paginacao) {
    return put(paginacao);
  }

  @override
  Paginacao toDto(Paginacao entity) {
    return entity;
  }
}
