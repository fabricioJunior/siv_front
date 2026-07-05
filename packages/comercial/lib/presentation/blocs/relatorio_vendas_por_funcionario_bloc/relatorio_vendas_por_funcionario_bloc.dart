import 'dart:async';

import 'package:comercial/domain/models/relatorios.dart';
import 'package:comercial/domain/use_cases/get_relatorio_vendas_por_funcionario.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:core/sessao.dart';

part 'relatorio_vendas_por_funcionario_event.dart';
part 'relatorio_vendas_por_funcionario_state.dart';

class RelatorioVendasPorFuncionarioBloc extends Bloc<
    RelatorioVendasPorFuncionarioEvent, RelatorioVendasPorFuncionarioState> {
  final GetRelatorioVendasPorFuncionario _useCase;

  RelatorioVendasPorFuncionarioBloc(this._useCase)
      : super(RelatorioVendasPorFuncionarioState.initial()) {
    on<RelatorioVendasPorFuncionarioCarregar>(_onCarregar);
  }

  FutureOr<void> _onCarregar(
    RelatorioVendasPorFuncionarioCarregar event,
    Emitter<RelatorioVendasPorFuncionarioState> emit,
  ) async {
    final empresaId = sl<IAcessoGlobalSessao>().empresaIdDaSessao;
    if (empresaId == null) return;

    if (event.funcionariosSelecionados.isEmpty) {
      emit(state.copyWith(
        step: RelatorioVendasPorFuncionarioStep.inicial,
        dados: const [],
        funcionariosSelecionados: event.funcionariosSelecionados,
        dataInicial: event.dataInicial,
        dataFinal: event.dataFinal,
      ));
      return;
    }

    try {
      emit(state.copyWith(
        step: RelatorioVendasPorFuncionarioStep.carregando,
        funcionariosSelecionados: event.funcionariosSelecionados,
        dataInicial: event.dataInicial,
        dataFinal: event.dataFinal,
      ));
      final dados = await _useCase.call(
        empresaIds: [empresaId],
        funcionarioIds:
            event.funcionariosSelecionados.map((f) => f.id).toList(),
        dataInicial: event.dataInicial,
        dataFinal: event.dataFinal,
      );
      emit(state.copyWith(
        step: RelatorioVendasPorFuncionarioStep.sucesso,
        dados: dados,
      ));
    } catch (e, s) {
      emit(state.copyWith(
        step: RelatorioVendasPorFuncionarioStep.falha,
        erro: 'Falha ao carregar relatório de vendas por funcionário.',
      ));
      addError(e, s);
    }
  }
}
