class SaldoPorCorETamanho {
  final int corId;
  final int tamanhoId;
  final double saldo;

  const SaldoPorCorETamanho({
    required this.corId,
    required this.tamanhoId,
    required this.saldo,
  });
}

abstract class PortaRecuperarSaldoDoEstoque {
  Future<List<SaldoPorCorETamanho>> sincronizarPorReferencia({
    required int referenciaId,
    int limit = 10000,
  });
}
