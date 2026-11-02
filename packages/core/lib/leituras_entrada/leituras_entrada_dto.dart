import 'dart:convert';

import 'package:core/isar_anotacoes.dart';

import 'leituras_entrada_pendentes.dart';

part 'leituras_entrada_dto.g.dart';

@Collection()
class LeiturasEntradaDto with IsarDto<LeiturasEntradaPendentes> {
  LeiturasEntradaDto({
    required this.pedidoId,
    required this.loteId,
    required this.atualizadoEm,
    required this.deltasJson,
    this.operador,
  });

  final int pedidoId;
  final String loteId;
  final DateTime atualizadoEm;
  final String? operador;

  /// Isar não guarda Map: `{"produtoId": delta}` serializado.
  final String deltasJson;

  @override
  Id get dataBaseId => pedidoId;

  factory LeiturasEntradaDto.fromEntity(LeiturasEntradaPendentes e) =>
      LeiturasEntradaDto(
        pedidoId: e.pedidoId,
        loteId: e.loteId,
        atualizadoEm: e.atualizadoEm,
        operador: e.operador,
        deltasJson: jsonEncode(e.deltas.map((k, v) => MapEntry('$k', v))),
      );

  LeiturasEntradaPendentes toEntity() => LeiturasEntradaPendentes(
        pedidoId: pedidoId,
        loteId: loteId,
        atualizadoEm: atualizadoEm,
        operador: operador,
        deltas: (jsonDecode(deltasJson) as Map)
            .map((k, v) => MapEntry(int.parse(k as String), v as int)),
      );
}
