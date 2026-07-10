part of 'consignacoes_bloc.dart';

abstract class ConsignacoesEvent extends Equatable {
  const ConsignacoesEvent();

  @override
  List<Object?> get props => [];
}

class ConsignacoesIniciou extends ConsignacoesEvent {
  final List<SituacaoConsignacao>? situacoes;

  const ConsignacoesIniciou({this.situacoes});

  @override
  List<Object?> get props => [situacoes];
}
