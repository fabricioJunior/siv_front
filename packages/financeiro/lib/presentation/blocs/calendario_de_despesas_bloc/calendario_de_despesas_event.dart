part of 'calendario_de_despesas_bloc.dart';

abstract class CalendarioDeDespesasEvent {}

class CalendarioDeDespesasIniciou extends CalendarioDeDespesasEvent {
  final int empresaId;

  CalendarioDeDespesasIniciou({required this.empresaId});
}

class CalendarioDeDespesasMesAlterado extends CalendarioDeDespesasEvent {
  final int ano;
  final int mes;

  CalendarioDeDespesasMesAlterado({required this.ano, required this.mes});
}

/// Dispara `POST /despesas/{id}/ocorrencias` -- pagar/editar/cancelar uma
/// ocorrência do mês (materializando-a se ainda for virtual).
class CalendarioDeDespesasOcorrenciaRegistrada extends CalendarioDeDespesasEvent {
  final int id;
  final double? valor;
  final DateTime? dataPagamento;
  final StatusDespesa? status;

  CalendarioDeDespesasOcorrenciaRegistrada({
    required this.id,
    this.valor,
    this.dataPagamento,
    this.status,
  });
}
