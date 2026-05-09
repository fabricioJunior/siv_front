import 'package:core/local_data_sourcers/isar/isar_local_data_source_base.dart';
import 'package:core/local_data_sourcers/isar/isar_utils.dart';
import 'package:isar_community/isar.dart';
import 'package:produtos/domain/data/local/i_codigos_local_data_source.dart';
import 'package:produtos/domain/models/codigo.dart';

import 'dtos/codigo_dto.dart';

class CodigosLocalDataSource extends IsarLocalDataSourceBase<CodigoDto, Codigo>
    implements ICodigosLocalDataSource {
  CodigosLocalDataSource({required super.getIsar});

  @override
  Future<Codigo?> recuperarCodigo(String codigo) {
    return fetchById(fastHash(codigo));
  }

  @override
  Future<void> salvarCodigosDeBarras(List<Codigo> codigos) {
    return putAll(codigos);
  }

  @override
  CodigoDto toDto(Codigo entity) {
    return CodigoDto(
      codigo: entity.codigo,
      produtoId: entity.produtoId,
      tipoIndex: entity.tipo.index,
    );
  }

  @override
  Future<Iterable<Codigo>> recuperarCodigosPorProdutoId(int produtoId) {
    return fetchWhere(_FindCodigo(produtoId: produtoId));
  }
}

class _FindCodigo extends IsarFind<CodigoDto> {
  final int? produtoId;

  _FindCodigo({required this.produtoId});

  @override
  Future<Iterable<CodigoDto>> call(IsarCollection<CodigoDto> t) {
    return t
        .filter()
        .optional(produtoId != null, (q) => q.produtoIdEqualTo(produtoId!))
        .findAll();
  }
}
