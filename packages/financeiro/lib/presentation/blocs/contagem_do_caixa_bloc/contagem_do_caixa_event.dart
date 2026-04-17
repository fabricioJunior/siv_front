part of 'contagem_do_caixa_bloc.dart';

abstract class ContagemDoCaixaEvent extends Equatable {
  const ContagemDoCaixaEvent();

  @override
  List<Object?> get props => [];
}

class ContagemDoCaixaIniciou extends ContagemDoCaixaEvent {
  final int caixaId;

  const ContagemDoCaixaIniciou({required this.caixaId});

  @override
  List<Object?> get props => [caixaId];
}

class ContagemDoCaixaItemValorAlterado extends ContagemDoCaixaEvent {
  final TipoContagemDoCaixaItem tipo;
  final String valor;

  const ContagemDoCaixaItemValorAlterado({
    required this.tipo,
    required this.valor,
  });

  @override
  List<Object?> get props => [tipo, valor];
}

class ContagemDoCaixaItemSalvou extends ContagemDoCaixaEvent {
  final TipoContagemDoCaixaItem tipo;

  const ContagemDoCaixaItemSalvou({required this.tipo});

  @override
  List<Object?> get props => [tipo];
}

class ContagemDoCaixaSalvarTodosSolicitado extends ContagemDoCaixaEvent {}
