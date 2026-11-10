part of 'despesas_do_caixa_bloc.dart';

abstract class DespesasDoCaixaEvent extends Equatable {
  const DespesasDoCaixaEvent();

  @override
  List<Object?> get props => [];
}

class DespesasDoCaixaIniciou extends DespesasDoCaixaEvent {
  final int caixaId;

  const DespesasDoCaixaIniciou({required this.caixaId});

  @override
  List<Object?> get props => [caixaId];
}

class DespesasDoCaixaRecarregarSolicitado extends DespesasDoCaixaEvent {}

class DespesaDoCaixaExclusaoSolicitada extends DespesasDoCaixaEvent {
  final int despesaId;
  final String motivo;

  const DespesaDoCaixaExclusaoSolicitada({
    required this.despesaId,
    required this.motivo,
  });

  @override
  List<Object?> get props => [despesaId, motivo];
}
