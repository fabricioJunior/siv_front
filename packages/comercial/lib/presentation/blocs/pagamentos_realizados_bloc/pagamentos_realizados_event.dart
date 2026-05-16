part of 'pagamentos_realizados_bloc.dart';

sealed class PagamentosRealizadosEvent extends Equatable {
  const PagamentosRealizadosEvent();

  @override
  List<Object?> get props => [];
}

class PagamentosRealizadosIniciado extends PagamentosRealizadosEvent {
  final String hashLista;
  final PagamentosRealizadosResumo? resumoInicial;

  const PagamentosRealizadosIniciado({
    required this.hashLista,
    this.resumoInicial,
  });

  @override
  List<Object?> get props => [hashLista, resumoInicial];
}

class PagamentosRealizadosLinhaAdicionada extends PagamentosRealizadosEvent {
  const PagamentosRealizadosLinhaAdicionada();
}

class PagamentosRealizadosLinhaRemovida extends PagamentosRealizadosEvent {
  final String linhaId;

  const PagamentosRealizadosLinhaRemovida({required this.linhaId});

  @override
  List<Object?> get props => [linhaId];
}

class PagamentosRealizadosFormaAlterada extends PagamentosRealizadosEvent {
  final String linhaId;
  final SelectData? formaDePagamento;

  const PagamentosRealizadosFormaAlterada({
    required this.linhaId,
    required this.formaDePagamento,
  });

  @override
  List<Object?> get props => [linhaId, formaDePagamento];
}

class PagamentosRealizadosValorAlterado extends PagamentosRealizadosEvent {
  final String linhaId;
  final String valorTexto;

  const PagamentosRealizadosValorAlterado({
    required this.linhaId,
    required this.valorTexto,
  });

  @override
  List<Object?> get props => [linhaId, valorTexto];
}

class PagamentosRealizadosParcelasAlteradas extends PagamentosRealizadosEvent {
  final String linhaId;
  final String parcelasTexto;

  const PagamentosRealizadosParcelasAlteradas({
    required this.linhaId,
    required this.parcelasTexto,
  });

  @override
  List<Object?> get props => [linhaId, parcelasTexto];
}

class PagamentosRealizadosFinalizacaoSolicitada extends PagamentosRealizadosEvent {
  const PagamentosRealizadosFinalizacaoSolicitada();
}