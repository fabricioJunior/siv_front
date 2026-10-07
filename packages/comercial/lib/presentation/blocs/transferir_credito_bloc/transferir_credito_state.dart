part of 'transferir_credito_bloc.dart';

enum TransferirCreditoStatus {
  carregando,
  pronto,
  erroCarga,
  transferindo,
  sucesso,
}

class TransferirCreditoState extends Equatable {
  final int pessoaId;
  final TransferirCreditoStatus status;
  final List<CreditoTransferivel> creditos;
  final Set<int> selecionados;
  final String? erro;
  final ResultadoTransferenciaCredito? resultado;

  const TransferirCreditoState({
    this.pessoaId = 0,
    this.status = TransferirCreditoStatus.carregando,
    this.creditos = const [],
    this.selecionados = const {},
    this.erro,
    this.resultado,
  });

  double get total => double.parse(
        creditos
            .where((c) => selecionados.contains(c.romaneioId))
            .fold<double>(0, (a, c) => a + c.valor)
            .toStringAsFixed(2),
      );

  TransferirCreditoState copyWith({
    TransferirCreditoStatus? status,
    List<CreditoTransferivel>? creditos,
    Set<int>? selecionados,
    String? erro,
    bool limparErro = false,
    ResultadoTransferenciaCredito? resultado,
  }) {
    return TransferirCreditoState(
      pessoaId: pessoaId,
      status: status ?? this.status,
      creditos: creditos ?? this.creditos,
      selecionados: selecionados ?? this.selecionados,
      erro: limparErro ? null : (erro ?? this.erro),
      resultado: resultado ?? this.resultado,
    );
  }

  @override
  List<Object?> get props =>
      [pessoaId, status, creditos, selecionados, erro, resultado];
}
