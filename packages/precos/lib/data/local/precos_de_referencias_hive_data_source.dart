import 'package:core/data_sourcers.dart';
import 'package:precos/domain/data/local/i_precos_de_referencias_local_data_source.dart';
import 'package:precos/models.dart';

import 'dtos/preco_da_referencia_hive_dto.dart';

class PrecosDeReferenciasHiveDataSource extends HiveLocalDataSourceBase<
    PrecoDaReferenciaHiveDto,
    PrecoDaReferencia> implements IPrecosDeReferenciasLocalDataSource {
  PrecosDeReferenciasHiveDataSource({required super.getBox});

  @override
  Future<void> limparPrecosDasReferencias() {
    return deleteAll();
  }

  @override
  Future<PrecoDaReferencia?> obterPrecoDaReferencia({
    required int tabelaDePrecoId,
    required int referenciaId,
  }) {
    return fetchById(
      PrecoDaReferenciaHiveDto.databaseIdFor(
        tabelaDePrecoId: tabelaDePrecoId,
        referenciaId: referenciaId,
      ),
    );
  }

  @override
  Future<List<PrecoDaReferencia>> obterPrecosDasReferencias({
    required int tabelaDePrecoId,
  }) async {
    return (await fetchWhere(
      (dto) => dto.tabelaDePrecoId == tabelaDePrecoId,
    )).toList();
  }

  @override
  Future<void> salvarPrecoDaReferencia(PrecoDaReferencia preco) {
    return put(preco);
  }

  @override
  Future<void> salvarPrecosDasReferencias(List<PrecoDaReferencia> precos) {
    return putAll(precos);
  }

  @override
  PrecoDaReferenciaHiveDto toDto(PrecoDaReferencia entity) {
    return PrecoDaReferenciaHiveDto(
      atualizadoEm: entity.atualizadoEm,
      tabelaDePrecoId: entity.tabelaDePrecoId,
      referenciaId: entity.referenciaId,
      referenciaIdExterno: entity.referenciaIdExterno,
      referenciaNome: entity.referenciaNome,
      valor: entity.valor,
      operadorId: entity.operadorId,
    );
  }
}
