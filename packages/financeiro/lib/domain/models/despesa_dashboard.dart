class DespesaDashboard {
  final double pagamentosDoMesPago;
  final double pagamentosDoMesPendente;
  final double pagamentosFuturos;
  final double totalPendenteParcelasEmAberto;
  final double faturamentoDoPeriodo;
  final double percentualDespesaSobreFaturamento;

  const DespesaDashboard({
    required this.pagamentosDoMesPago,
    required this.pagamentosDoMesPendente,
    required this.pagamentosFuturos,
    required this.totalPendenteParcelasEmAberto,
    required this.faturamentoDoPeriodo,
    required this.percentualDespesaSobreFaturamento,
  });

  factory DespesaDashboard.fromJson(Map<String, dynamic> json) {
    double asDouble(dynamic value) => (value as num?)?.toDouble() ?? 0;
    return DespesaDashboard(
      pagamentosDoMesPago: asDouble(json['pagamentosDoMesPago']),
      pagamentosDoMesPendente: asDouble(json['pagamentosDoMesPendente']),
      pagamentosFuturos: asDouble(json['pagamentosFuturos']),
      totalPendenteParcelasEmAberto:
          asDouble(json['totalPendenteParcelasEmAberto']),
      faturamentoDoPeriodo: asDouble(json['faturamentoDoPeriodo']),
      percentualDespesaSobreFaturamento:
          asDouble(json['percentualDespesaSobreFaturamento']),
    );
  }
}
