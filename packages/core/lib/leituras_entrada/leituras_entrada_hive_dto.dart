import 'package:core/hive_anotacoes.dart';

import 'leituras_entrada_pendentes.dart';

class LeiturasEntradaHiveDto
    with HiveDto<LeiturasEntradaPendentes>, StorageEntity {
  LeiturasEntradaHiveDto(this.entity);

  final LeiturasEntradaPendentes entity;

  @override
  int get dataBaseId => entity.pedidoId;

  @override
  Map<String, dynamic> get storageProperties => {
        'pedidoId': entity.pedidoId,
        'loteId': entity.loteId,
        'atualizadoEm': entity.atualizadoEm.toIso8601String(),
        'operador': entity.operador,
        'deltas': entity.deltas.map((k, v) => MapEntry('$k', v)),
      };

  static LeiturasEntradaHiveDto fromStorage(Map<String, dynamic> p) =>
      LeiturasEntradaHiveDto(
        LeiturasEntradaPendentes(
          pedidoId: p['pedidoId'] as int,
          loteId: p['loteId'] as String,
          atualizadoEm: DateTime.parse(p['atualizadoEm'] as String),
          operador: p['operador'] as String?,
          deltas: (p['deltas'] as Map)
              .map((k, v) => MapEntry(int.parse(k as String), v as int)),
        ),
      );
}
