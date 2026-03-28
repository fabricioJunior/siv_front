import 'package:core/data_sourcers.dart';
import 'package:core/isar_anotacoes.dart';
import 'package:core/leitor/data_source/i_leitor_data_datasource.dart';
import 'package:core/leitor/leitor_data.dart';

import 'dtos/produto_dto.dart';

class ProdutoLocalDataSource
    extends IsarLocalDataSourceBase<ProdutoDto, ProdutoDto>
    implements ILeitorDataDatasource {
  ProdutoLocalDataSource({required super.getIsar});

  @override
  Future<LeitorData?> getData(String codigo) {
    return fetchById(fastHash(codigo));
  }

  @override
  ProdutoDto toDto(ProdutoDto entity) {
    return entity;
  }
}
