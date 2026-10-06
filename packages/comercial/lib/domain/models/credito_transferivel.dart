import 'package:core/equals.dart';

class CreditoTransferivel extends Equatable {
  final int romaneioId;
  final int faturaId;
  final int faturaParcela;
  final DateTime data;
  final double valor;
  final String observacao;

  const CreditoTransferivel({
    required this.romaneioId,
    required this.faturaId,
    required this.faturaParcela,
    required this.data,
    required this.valor,
    this.observacao = '',
  });

  @override
  List<Object?> get props =>
      [romaneioId, faturaId, faturaParcela, data, valor, observacao];
}

class ResultadoTransferenciaCredito extends Equatable {
  final double valorTotal;
  final double saldoCreditoDevolucaoDestino;

  const ResultadoTransferenciaCredito({
    required this.valorTotal,
    required this.saldoCreditoDevolucaoDestino,
  });

  @override
  List<Object?> get props => [valorTotal, saldoCreditoDevolucaoDestino];
}
