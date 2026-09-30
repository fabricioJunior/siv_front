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

/// Apagar uma ocorrência. `escopo.esta` numa ocorrência virtual de recorrente
/// cancela só o mês; `escopo.todas` apaga a série (parcelas ou recorrência).
class CalendarioDeDespesasOcorrenciaApagada extends CalendarioDeDespesasEvent {
  final int id;
  final bool virtual;
  final EscopoExclusaoDespesa escopo;

  CalendarioDeDespesasOcorrenciaApagada({
    required this.id,
    required this.virtual,
    required this.escopo,
  });
}

/// Pagar/editar/cancelar uma ocorrência do mês. Ocorrência virtual (recorrente
/// ainda não materializada nesse mês) usa `POST /despesas/{id}/ocorrencias`;
/// ocorrência concreta (já é uma linha real de despesa) usa `PUT /despesas/{id}`
/// -- o endpoint de ocorrências só aceita templates recorrentes e rejeita
/// qualquer outra despesa com 400.
class CalendarioDeDespesasOcorrenciaRegistrada extends CalendarioDeDespesasEvent {
  final int id;
  final bool virtual;
  final double? valor;
  final int? categoriaId;
  final int? origemPagamentoId;
  final DateTime? dataPagamento;
  final StatusDespesa? status;

  CalendarioDeDespesasOcorrenciaRegistrada({
    required this.id,
    required this.virtual,
    this.valor,
    this.categoriaId,
    this.origemPagamentoId,
    this.dataPagamento,
    this.status,
  });
}
