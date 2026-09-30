part of 'lancar_despesa_bloc.dart';

abstract class LancarDespesaEvent {}

class LancarDespesaIniciou extends LancarDespesaEvent {
  final int empresaId;
  final int? caixaId;
  final DateTime? dataInicial;

  LancarDespesaIniciou({required this.empresaId, this.caixaId, this.dataInicial});
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
  final bool? pago;

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
    this.pago,
  });
}

class LancarDespesaSalvou extends LancarDespesaEvent {}
