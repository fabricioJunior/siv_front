abstract class PortaObterPrecoDaReferencia {
  Future<double> call({
    required int tabelaDePrecoId,
    required int referenciaId,
  });
}
