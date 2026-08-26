import 'package:core/local_data_sourcers/hive/hive_hash.dart';
import 'package:core/local_data_sourcers/hive/hive_local_data_source_base.dart';
import 'package:produtos/domain/data/local/i_codigos_local_data_source.dart';
import 'package:produtos/domain/models/codigo.dart';

import 'dtos/codigo_hive_dto.dart';

class CodigosHiveDataSource extends HiveLocalDataSourceBase<CodigoHiveDto, Codigo>
    implements ICodigosLocalDataSource {
  CodigosHiveDataSource({required super.getBox});

  @override
  Future<Codigo?> recuperarCodigo(String codigo) {
    return fetchById(hiveHash(codigo));
  }

  @override
  Future<void> salvarCodigosDeBarras(List<Codigo> codigos) {
    return putAll(codigos);
  }

  @override
  CodigoHiveDto toDto(Codigo entity) {
    return CodigoHiveDto(
      codigo: entity.codigo,
      produtoId: entity.produtoId,
      tipoIndex: entity.tipo.index,
    );
  }

  @override
  Future<Iterable<Codigo>> recuperarCodigosPorProdutoId(int produtoId) {
    return fetchWhere((dto) => dto.produtoId == produtoId);
  }
}
