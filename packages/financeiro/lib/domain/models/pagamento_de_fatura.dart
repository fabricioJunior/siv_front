/// Resultado de pagar a fatura de um cartão de uma vez (`PATCH /despesas/pagar-fatura`).
class PagamentoDeFatura {
  final int atualizadas;
  final double valorTotal;

  const PagamentoDeFatura({required this.atualizadas, required this.valorTotal});
}
