part of 'creditos_devolucao_bloc.dart';

sealed class CreditosDevolucaoEvent {}

class CreditosDevolucaoCarregou extends CreditosDevolucaoEvent {
  final int pessoaId;
  CreditosDevolucaoCarregou(this.pessoaId);
}

class CreditosDevolucaoAdicionou extends CreditosDevolucaoEvent {
  final double valor;
  final String motivo;
  final String observacao;
  final DateTime? validade;
  final int? empresaId;

  CreditosDevolucaoAdicionou({
    required this.valor,
    required this.motivo,
    required this.observacao,
    this.validade,
    this.empresaId,
  });
}

class CreditosDevolucaoRemoveu extends CreditosDevolucaoEvent {
  final int creditoId;

  /// Nulo remove todo o restante.
  final double? valor;
  final String motivo;
  final String? observacao;

  CreditosDevolucaoRemoveu({
    required this.creditoId,
    this.valor,
    required this.motivo,
    this.observacao,
  });
}

class CreditosDevolucaoExpirou extends CreditosDevolucaoEvent {
  final int creditoId;
  final String? motivo;
  CreditosDevolucaoExpirou({required this.creditoId, this.motivo});
}
