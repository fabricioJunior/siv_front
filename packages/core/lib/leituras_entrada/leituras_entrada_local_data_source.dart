import 'package:core/data_sourcers.dart';

import 'i_leituras_entrada_local_data_source.dart';
import 'leituras_entrada_dto.dart';
import 'leituras_entrada_pendentes.dart';

class LeiturasEntradaLocalDataSource
    extends IsarLocalDataSourceBase<LeiturasEntradaDto, LeiturasEntradaPendentes>
    implements ILeiturasEntradaLocalDataSource {
  LeiturasEntradaLocalDataSource({required super.getIsar});

  @override
  Future<LeiturasEntradaPendentes?> recuperar(int pedidoId) async =>
      (await fetchById(pedidoId))?.toEntity();

  @override
  Future<void> salvar(LeiturasEntradaPendentes leituras) => put(leituras);

  @override
  Future<void> apagar(int pedidoId) => deleteById(pedidoId);

  @override
  LeiturasEntradaDto toDto(LeiturasEntradaPendentes entity) =>
      LeiturasEntradaDto.fromEntity(entity);
}
