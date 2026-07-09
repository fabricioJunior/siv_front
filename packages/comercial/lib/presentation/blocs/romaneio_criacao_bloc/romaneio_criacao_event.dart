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
  final bool incluirCpfNaNota;
  final String cpfNaNota;

  const RomaneioCriacaoSolicitada({
    required this.hashLista,
    this.formasDePagamentoRealizadas = const [],
    this.desconto = 0,
    this.descontosItens = const [],
    this.incluirCpfNaNota = true,
    this.cpfNaNota = '',
  });

  @override
  List<Object?> get props => [
        hashLista,
        formasDePagamentoRealizadas,
        desconto,
        descontosItens,
        incluirCpfNaNota,
        cpfNaNota,
      ];
}
