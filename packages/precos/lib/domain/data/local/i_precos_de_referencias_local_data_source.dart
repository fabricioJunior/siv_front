import 'package:precos/models.dart';

abstract class IPrecosDeReferenciasLocalDataSource {
  Future<void> salvarPrecoDaReferencia(PrecoDaReferencia preco);

  Future<PrecoDaReferencia?> obterPrecoDaReferencia({
    required int tabelaDePrecoId,
    required int referenciaId,
  });

  Future<List<PrecoDaReferencia>> obterPrecosDasReferencias({
    required int tabelaDePrecoId,
  });

  Future<void> salvarPrecosDasReferencias(List<PrecoDaReferencia> precos);

  Future<void> limparPrecosDasReferencias();
}
