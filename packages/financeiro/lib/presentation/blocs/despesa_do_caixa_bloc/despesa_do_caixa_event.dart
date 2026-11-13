part of 'despesa_do_caixa_bloc.dart';

abstract class DespesaDoCaixaEvent extends Equatable {
  const DespesaDoCaixaEvent();

  @override
  List<Object?> get props => [];
}

class DespesaDoCaixaIniciou extends DespesaDoCaixaEvent {
  final int caixaId;

  const DespesaDoCaixaIniciou({required this.caixaId});

  @override
  List<Object?> get props => [caixaId];
}

class DespesaDoCaixaCampoAlterado extends DespesaDoCaixaEvent {
  final String? valor;
  final String? descricao;
  final int? categoriaId;

  const DespesaDoCaixaCampoAlterado({
    this.valor,
    this.descricao,
    this.categoriaId,
  });

  @override
  List<Object?> get props => [valor, descricao, categoriaId];
}

class DespesaDoCaixaSalvou extends DespesaDoCaixaEvent {}
