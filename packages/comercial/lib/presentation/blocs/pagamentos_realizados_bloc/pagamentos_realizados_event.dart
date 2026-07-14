part of 'pagamentos_realizados_bloc.dart';

sealed class PagamentosRealizadosEvent extends Equatable {
  const PagamentosRealizadosEvent();

  @override
  List<Object?> get props => [];
}

class PagamentosRealizadosIniciado extends PagamentosRealizadosEvent {
  final String hashLista;
  final PagamentosRealizadosResumo? resumoInicial;
  final int? pessoaId;
  final String? cpfClienteInicial;
  final double descontoJaAplicadoNoRomaneio;

  const PagamentosRealizadosIniciado({
    required this.hashLista,
    this.resumoInicial,
    this.pessoaId,
    this.cpfClienteInicial,
    this.descontoJaAplicadoNoRomaneio = 0,
  });

  @override
  List<Object?> get props => [
        hashLista,
        resumoInicial,
        pessoaId,
        cpfClienteInicial,
        descontoJaAplicadoNoRomaneio,
      ];
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

class PagamentosRealizadosDescontoAlterado extends PagamentosRealizadosEvent {
  final DescontoTipo? tipo;
  final String valorTexto;

  const PagamentosRealizadosDescontoAlterado({
    required this.tipo,
    required this.valorTexto,
  });

  @override
  List<Object?> get props => [tipo, valorTexto];
}

class PagamentosRealizadosDescontoItemAlterado
    extends PagamentosRealizadosEvent {
  final int produtoId;
  final DescontoTipo? tipo;
  final String valorTexto;

  const PagamentosRealizadosDescontoItemAlterado({
    required this.produtoId,
    this.tipo,
    required this.valorTexto,
  });

  @override
  List<Object?> get props => [produtoId, tipo, valorTexto];
}

class PagamentosRealizadosDescontosItensLimpos
    extends PagamentosRealizadosEvent {
  const PagamentosRealizadosDescontosItensLimpos();
}

class PagamentosRealizadosFinalizacaoSolicitada
    extends PagamentosRealizadosEvent {
  const PagamentosRealizadosFinalizacaoSolicitada();
}

class PagamentosRealizadosIncluirCpfAlterado extends PagamentosRealizadosEvent {
  final bool incluirCpfNaNota;

  const PagamentosRealizadosIncluirCpfAlterado({
    required this.incluirCpfNaNota,
  });

  @override
  List<Object?> get props => [incluirCpfNaNota];
}

class PagamentosRealizadosCpfAlterado extends PagamentosRealizadosEvent {
  final String cpfNaNota;

  const PagamentosRealizadosCpfAlterado({required this.cpfNaNota});

  @override
  List<Object?> get props => [cpfNaNota];
}

class PagamentosRealizadosPontuarFidelidadeAlterado
    extends PagamentosRealizadosEvent {
  final bool pontuarFidelidade;

  const PagamentosRealizadosPontuarFidelidadeAlterado({
    required this.pontuarFidelidade,
  });

  @override
  List<Object?> get props => [pontuarFidelidade];
}
