import 'package:core/data_sourcers.dart';

import 'i_leituras_entrada_local_data_source.dart';
import 'leituras_entrada_hive_dto.dart';
import 'leituras_entrada_pendentes.dart';

class LeiturasEntradaIndexedDbDataSource
    extends IndexedDbLocalDataSourceBase<LeiturasEntradaHiveDto,
        LeiturasEntradaPendentes>
    implements ILeiturasEntradaLocalDataSource {
  LeiturasEntradaIndexedDbDataSource({required super.getDb})
      : super(
          storeName: 'core_LeiturasEntradaHiveDto',
          fromStorage: LeiturasEntradaHiveDto.fromStorage,
        );

  @override
  Future<LeiturasEntradaPendentes?> recuperar(int pedidoId) async =>
      (await fetchById(pedidoId))?.entity;

  @override
  Future<void> salvar(LeiturasEntradaPendentes leituras) => put(leituras);

  @override
  Future<void> apagar(int pedidoId) => deleteById(pedidoId);

  @override
  LeiturasEntradaHiveDto toDto(LeiturasEntradaPendentes entity) =>
      LeiturasEntradaHiveDto(entity);
}
