part of 'calendario_de_despesas_bloc.dart';

class CalendarioDeDespesasState extends Equatable {
  final int empresaId;
  final int ano;
  final int mes;
  final List<DespesaOcorrenciaCalendario> ocorrencias;
  final Map<int, String> categoriaPorId;
  final Map<int, String> origemPorId;
  final Map<int, OrigemPagamentoDespesa> origemPagamentoPorId;
  final CalendarioDeDespesasStep step;
  final String? erro;

  /// Ocorrências (por `idParaOcorrencia`) com pagar/editar/apagar em andamento:
  /// só o card delas mostra loading, a tela não recarrega inteira.
  final Set<int> processando;

  const CalendarioDeDespesasState({
    required this.empresaId,
    required this.ano,
    required this.mes,
    this.ocorrencias = const [],
    this.categoriaPorId = const {},
    this.origemPorId = const {},
    this.origemPagamentoPorId = const {},
    required this.step,
    this.erro,
    this.processando = const {},
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

  /// Soma do mês por estado -- pago, pendente, prevista (pendente virtual)
  /// e cancelado. Usado na legenda do calendário largo.
  Map<String, double> get totalPorEstado {
    var pago = 0.0, pendente = 0.0, prevista = 0.0, cancelado = 0.0;
    for (final o in ocorrencias) {
      switch (o.status) {
        case StatusDespesa.pago:
          pago += o.valor;
        case StatusDespesa.cancelado:
          cancelado += o.valor;
        case StatusDespesa.pendente:
          if (o.virtual) {
            prevista += o.valor;
          } else {
            pendente += o.valor;
          }
      }
    }
    return {'pago': pago, 'pendente': pendente, 'prevista': prevista, 'cancelado': cancelado};
  }

  double totalDoDia(int dia) => (porDia[dia] ?? const [])
      .where((o) => o.status != StatusDespesa.cancelado)
      .fold(0.0, (soma, o) => soma + o.valor);

  CalendarioDeDespesasState copyWith({
    int? empresaId,
    int? ano,
    int? mes,
    List<DespesaOcorrenciaCalendario>? ocorrencias,
    Map<int, String>? categoriaPorId,
    Map<int, String>? origemPorId,
    Map<int, OrigemPagamentoDespesa>? origemPagamentoPorId,
    CalendarioDeDespesasStep? step,
    String? erro,
    Set<int>? processando,
  }) {
    return CalendarioDeDespesasState(
      empresaId: empresaId ?? this.empresaId,
      ano: ano ?? this.ano,
      mes: mes ?? this.mes,
      ocorrencias: ocorrencias ?? this.ocorrencias,
      categoriaPorId: categoriaPorId ?? this.categoriaPorId,
      origemPorId: origemPorId ?? this.origemPorId,
      origemPagamentoPorId: origemPagamentoPorId ?? this.origemPagamentoPorId,
      step: step ?? this.step,
      erro: erro,
      processando: processando ?? this.processando,
    );
  }

  @override
  List<Object?> get props => [
        empresaId,
        ano,
        mes,
        ocorrencias,
        categoriaPorId,
        origemPorId,
        origemPagamentoPorId,
        step,
        erro,
        processando,
      ];
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
