part of 'romaneio_criacao_bloc.dart';

abstract class RomaneioCriacaoEvent extends Equatable {
  const RomaneioCriacaoEvent();

  @override
  List<Object?> get props => [];
}

class RomaneioCriacaoSolicitada extends RomaneioCriacaoEvent {
  final String hashLista;
  final List<Map<String, dynamic>> formasDePagamentoRealizadas;
  final double desconto;
  final List<Map<String, dynamic>> descontosItens;
  final double valorTaxaEntrega;
  final bool incluirCpfNaNota;
  final String cpfNaNota;
  final bool pontuarFidelidade;
  final int? consignacaoId;
  final List<int> romaneiosConsignacao;

  const RomaneioCriacaoSolicitada({
    required this.hashLista,
    this.formasDePagamentoRealizadas = const [],
    this.desconto = 0,
    this.descontosItens = const [],
    this.valorTaxaEntrega = 0,
    this.incluirCpfNaNota = true,
    this.cpfNaNota = '',
    this.pontuarFidelidade = false,
    this.consignacaoId,
    this.romaneiosConsignacao = const [],
  });

  @override
  List<Object?> get props => [
        hashLista,
        formasDePagamentoRealizadas,
        desconto,
        descontosItens,
        valorTaxaEntrega,
        incluirCpfNaNota,
        cpfNaNota,
        pontuarFidelidade,
        consignacaoId,
        romaneiosConsignacao,
      ];
}
