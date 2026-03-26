import 'package:precos/models.dart';

abstract class IPrecosDeReferenciasRepository {
  Future<PrecoDaReferencia> obterPrecoDaReferencia({
    required int tabelaDePrecoId,
    required int referenciaId,
  });

  Future<List<PrecoDaReferencia>> obterPrecosDasReferencias({
    required int tabelaDePrecoId,
  });

  Future<PrecoDaReferencia> atualizarPrecoDaReferencia({
    required int tabelaDePrecoId,
    required int referenciaId,
    required double valor,
  });

  Future<PrecoDaReferencia> criarPrecoDaReferencia({
    required int tabelaDePrecoId,
    required int referenciaId,
    required double valor,
  });

  Future<void> removerPrecoDaReferencia({
    required int tabelaDePrecoId,
    required int referenciaId,
  });
}
