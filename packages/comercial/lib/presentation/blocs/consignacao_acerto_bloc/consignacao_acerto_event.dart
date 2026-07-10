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
  final bool incluirCpfNaNota;
  final String cpfNaNota;

  const ConsignacaoAcertoPagamentoConfirmado({
    required this.formasDePagamentoRealizadas,
    this.descontosItens = const [],
    this.incluirCpfNaNota = true,
    this.cpfNaNota = '',
  });

  @override
  List<Object?> get props => [
        formasDePagamentoRealizadas,
        descontosItens,
        incluirCpfNaNota,
        cpfNaNota,
      ];
}
