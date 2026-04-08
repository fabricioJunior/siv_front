import 'package:core/data_sourcers.dart';
import 'package:core/isar_anotacoes.dart';
import 'package:precos/domain/data/local/i_precos_de_referencias_local_data_source.dart';
import 'package:precos/models.dart';

import 'dtos/preco_da_referencia_dto.dart';

class PrecosDeReferenciasLocalDataSource
    extends IsarLocalDataSourceBase<PrecoDaReferenciaDto, PrecoDaReferencia>
    implements IPrecosDeReferenciasLocalDataSource {
  PrecosDeReferenciasLocalDataSource({required super.getIsar});

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
      PrecoDaReferenciaDto.databaseIdFor(
        tabelaDePrecoId: tabelaDePrecoId,
        referenciaId: referenciaId,
      ),
    );
  }

  @override
  Future<List<PrecoDaReferencia>> obterPrecosDasReferencias({
    required int tabelaDePrecoId,
  }) async {
    final isarInstance = await getIsar();
    final precos = await isarInstance.txn(() {
      return isarInstance
          .collection<PrecoDaReferenciaDto>()
          .filter()
          .tabelaDePrecoIdEqualTo(tabelaDePrecoId)
          .findAll();
    });

    return precos;
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
  PrecoDaReferenciaDto toDto(PrecoDaReferencia entity) {
    return PrecoDaReferenciaDto(
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
