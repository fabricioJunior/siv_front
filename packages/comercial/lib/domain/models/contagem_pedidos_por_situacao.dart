class ContagemPedidosPorSituacao {
  final int total;
  final int pago;
  final Map<String, int> porSituacao;

  const ContagemPedidosPorSituacao({
    required this.total,
    required this.pago,
    required this.porSituacao,
  });

  int contar(String situacao) => porSituacao[situacao] ?? 0;
}
