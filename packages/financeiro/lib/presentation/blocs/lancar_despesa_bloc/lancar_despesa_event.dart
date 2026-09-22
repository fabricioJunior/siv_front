part of 'lancar_despesa_bloc.dart';

abstract class LancarDespesaEvent {}

class LancarDespesaIniciou extends LancarDespesaEvent {
  final int empresaId;
  final int? caixaId;

  LancarDespesaIniciou({required this.empresaId, this.caixaId});
}

class LancarDespesaCampoAlterado extends LancarDespesaEvent {
  final ModoLancamentoDespesa? modo;
  final String? descricao;
  final double? valor;
  final int? categoriaId;
  final int? origemPagamentoId;
  final int? formaPagamentoId;
  final bool limparFormaPagamento;
  final DateTime? dataPagamento;
  final int? diaVencimento;
  final int? parcelas;

  LancarDespesaCampoAlterado({
    this.modo,
    this.descricao,
    this.valor,
    this.categoriaId,
    this.origemPagamentoId,
    this.formaPagamentoId,
    this.limparFormaPagamento = false,
    this.dataPagamento,
    this.diaVencimento,
    this.parcelas,
  });
}

class LancarDespesaSalvou extends LancarDespesaEvent {}
