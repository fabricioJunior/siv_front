part of 'recibo_fechamento_caixa_bloc.dart';

abstract class ReciboFechamentoCaixaEvent extends Equatable {
  const ReciboFechamentoCaixaEvent();

  @override
  List<Object?> get props => [];
}

class ReciboFechamentoCaixaIniciou extends ReciboFechamentoCaixaEvent {
  final int caixaId;

  const ReciboFechamentoCaixaIniciou({required this.caixaId});

  @override
  List<Object?> get props => [caixaId];
}
