import 'dart:async';

import 'package:comercial/domain/models/relatorios.dart';
import 'package:comercial/domain/use_cases/get_relatorio_faturamento.dart';
import 'package:comercial/domain/use_cases/get_relatorio_faturamento_comparativo.dart';
import 'package:core/bloc.dart';
import 'package:core/sessao.dart';
import 'package:core/injecoes.dart';

part 'relatorio_faturamento_event.dart';
part 'relatorio_faturamento_state.dart';

class RelatorioFaturamentoBloc
    extends Bloc<RelatorioFaturamentoEvent, RelatorioFaturamentoState> {
  final GetRelatorioFaturamento _useCase;
  final GetRelatorioFaturamentoComparativo _useCaseComparativo;

  RelatorioFaturamentoBloc(this._useCase, this._useCaseComparativo)
      : super(RelatorioFaturamentoState.initial()) {
    on<RelatorioFaturamentoCarregar>(_onCarregar);
    on<RelatorioFaturamentoComparativoCarregar>(_onComparativoCarregar);
  }

  FutureOr<void> _onCarregar(
    RelatorioFaturamentoCarregar event,
    Emitter<RelatorioFaturamentoState> emit,
  ) async {
    final empresaId = sl<IAcessoGlobalSessao>().empresaIdDaSessao;
    if (empresaId == null) return;
    try {
      emit(state.copyWith(
        step: RelatorioFaturamentoStep.carregando,
        dataInicial: event.dataInicial,
        dataFinal: event.dataFinal,
        zerarAnterior: true,
      ));
      final dados = await _useCase.call(
        empresaIds: [empresaId],
        dataInicial: event.dataInicial,
        dataFinal: event.dataFinal,
      );
      emit(state.copyWith(
        step: RelatorioFaturamentoStep.sucesso,
        dados: dados,
      ));
      // Mesmo período do ano passado (igual ao gráfico), só para variação; falha é ignorada.
      final ini = DateTime.tryParse(event.dataInicial);
      final fim = DateTime.tryParse(event.dataFinal);
      if (ini == null || fim == null) return;
      try {
        final anterior = await _useCase.call(
          empresaIds: [empresaId],
          dataInicial: _iso(_mesmoDiaAnoAnterior(ini)),
          dataFinal: _iso(_mesmoDiaAnoAnterior(fim)),
        );
        emit(state.copyWith(anteriorDados: anterior));
      } catch (_) {}
    } catch (e, s) {
      emit(state.copyWith(
        step: RelatorioFaturamentoStep.falha,
        erro: 'Falha ao carregar relatório de faturamento.',
      ));
      addError(e, s);
    }
  }

  FutureOr<void> _onComparativoCarregar(
    RelatorioFaturamentoComparativoCarregar event,
    Emitter<RelatorioFaturamentoState> emit,
  ) async {
    final empresaId = sl<IAcessoGlobalSessao>().empresaIdDaSessao;
    if (empresaId == null) return;
    try {
      emit(state.copyWith(
        comparativoStep: RelatorioFaturamentoComparativoStep.carregando,
        agruparPor: event.agruparPor,
        zerarAnoAnterior: true,
      ));
      // Backend só agrupa por dia/mes; semana é agregada aqui.
      final semana = event.agruparPor == 'semana';
      final grupo = semana ? 'dia' : event.agruparPor;
      final dados = await _useCaseComparativo.call(
        empresaIds: [empresaId],
        dataInicial: event.dataInicial,
        dataFinal: event.dataFinal,
        agruparPor: grupo,
      );
      emit(state.copyWith(
        comparativoStep: RelatorioFaturamentoComparativoStep.sucesso,
        comparativoDados: semana ? _porSemana(dados.pontos) : dados,
      ));
      final ini = DateTime.tryParse(event.dataInicial);
      final fim = DateTime.tryParse(event.dataFinal);
      if (ini == null || fim == null) return;
      try {
        final anoAnt = await _useCaseComparativo.call(
          empresaIds: [empresaId],
          dataInicial: _iso(_mesmoDiaAnoAnterior(ini)),
          dataFinal: _iso(_mesmoDiaAnoAnterior(fim)),
          agruparPor: grupo,
        );
        // Chaves deslocadas +1 ano para casar com a série atual.
        final deslocados = [
          for (final p in anoAnt.pontos)
            _Ponto(_chaveMaisUmAno(p.periodo), p.faturamento,
                p.quantidadeVendas),
        ];
        emit(state.copyWith(
          anoAnteriorDados:
              semana ? _porSemana(deslocados) : _Comparativo(deslocados),
        ));
      } catch (_) {}
    } catch (e, s) {
      emit(state.copyWith(
        comparativoStep: RelatorioFaturamentoComparativoStep.falha,
      ));
      addError(e, s);
    }
  }
}

String _iso(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime _mesmoDiaAnoAnterior(DateTime d) => DateTime(d.year - 1, d.month, d.day);

String _chaveMaisUmAno(String k) {
  final ano = int.tryParse(k.substring(0, 4));
  return ano == null ? k : '${ano + 1}${k.substring(4)}';
}

class _Ponto implements RelatorioFaturamentoComparativoPonto {
  @override
  final String periodo;
  @override
  final double faturamento;
  @override
  final int quantidadeVendas;
  _Ponto(this.periodo, this.faturamento, this.quantidadeVendas);
}

class _Comparativo implements RelatorioFaturamentoComparativo {
  @override
  final List<RelatorioFaturamentoComparativoPonto> pontos;
  _Comparativo(this.pontos);
}

/// Agrega pontos diários em semanas (chave = segunda-feira, AAAA-MM-DD).
_Comparativo _porSemana(List<RelatorioFaturamentoComparativoPonto> dias) {
  final fat = <String, double>{};
  final vnd = <String, int>{};
  for (final p in dias) {
    final d = DateTime.tryParse(p.periodo);
    if (d == null) continue;
    final k = _iso(d.subtract(Duration(days: d.weekday - 1)));
    fat[k] = (fat[k] ?? 0) + p.faturamento;
    vnd[k] = (vnd[k] ?? 0) + p.quantidadeVendas;
  }
  final chaves = fat.keys.toList()..sort();
  return _Comparativo([for (final k in chaves) _Ponto(k, fat[k]!, vnd[k]!)]);
}
