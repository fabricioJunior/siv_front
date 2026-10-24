part of 'consignacao_acerto_bloc.dart';

abstract class ConsignacaoAcertoEvent extends Equatable {
  const ConsignacaoAcertoEvent();

  @override
  List<Object?> get props => [];
}

class ConsignacaoAcertoIniciado extends ConsignacaoAcertoEvent {
  const ConsignacaoAcertoIniciado();
}

class ConsignacaoAcertoPagamentoConfirmado extends ConsignacaoAcertoEvent {
  final List<Map<String, dynamic>> formasDePagamentoRealizadas;
  final List<Map<String, dynamic>> descontosItens;
  final List<Map<String, dynamic>> descontosPromocao;
  final List<Map<String, dynamic>>? cupons;
  final double valorTaxaEntrega;
  final bool incluirCpfNaNota;
  final String cpfNaNota;
  final bool enviarNotaPorEmail;
  final String emailNota;

  const ConsignacaoAcertoPagamentoConfirmado({
    required this.formasDePagamentoRealizadas,
    this.descontosItens = const [],
    this.descontosPromocao = const [],
    this.cupons,
    this.valorTaxaEntrega = 0,
    this.incluirCpfNaNota = true,
    this.cpfNaNota = '',
    this.enviarNotaPorEmail = false,
    this.emailNota = '',
  });

  @override
  List<Object?> get props => [
        formasDePagamentoRealizadas,
        descontosItens,
        descontosPromocao,
        cupons,
        valorTaxaEntrega,
        incluirCpfNaNota,
        cpfNaNota,
        enviarNotaPorEmail,
        emailNota,
      ];
}
