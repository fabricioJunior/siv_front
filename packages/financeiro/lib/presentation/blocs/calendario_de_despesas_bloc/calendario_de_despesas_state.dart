part of 'calendario_de_despesas_bloc.dart';

class CalendarioDeDespesasState extends Equatable {
  final int empresaId;
  final int ano;
  final int mes;
  final List<DespesaOcorrenciaCalendario> ocorrencias;
  final CalendarioDeDespesasStep step;

  const CalendarioDeDespesasState({
    required this.empresaId,
    required this.ano,
    required this.mes,
    this.ocorrencias = const [],
    required this.step,
  });

  /// Ocorrências agrupadas por dia do mês, já ordenadas.
  Map<int, List<DespesaOcorrenciaCalendario>> get porDia {
    final mapa = <int, List<DespesaOcorrenciaCalendario>>{};
    for (final ocorrencia in ocorrencias) {
      mapa.putIfAbsent(ocorrencia.dataPagamento.day, () => []).add(ocorrencia);
    }
    return Map.fromEntries(
      mapa.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  CalendarioDeDespesasState copyWith({
    int? empresaId,
    int? ano,
    int? mes,
    List<DespesaOcorrenciaCalendario>? ocorrencias,
    CalendarioDeDespesasStep? step,
  }) {
    return CalendarioDeDespesasState(
      empresaId: empresaId ?? this.empresaId,
      ano: ano ?? this.ano,
      mes: mes ?? this.mes,
      ocorrencias: ocorrencias ?? this.ocorrencias,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [empresaId, ano, mes, ocorrencias, step];
}

class CalendarioDeDespesasInitial extends CalendarioDeDespesasState {
  const CalendarioDeDespesasInitial()
      : super(
          empresaId: 0,
          ano: 0,
          mes: 0,
          step: CalendarioDeDespesasStep.inicial,
        );
}

enum CalendarioDeDespesasStep { inicial, carregando, carregado, falha }
