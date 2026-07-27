import 'dart:async';

import 'package:comercial/domain/models/relatorios.dart';
import 'package:comercial/domain/use_cases/get_relatorio_compras_clientes.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';

part 'relatorio_compras_clientes_event.dart';
part 'relatorio_compras_clientes_state.dart';

class RelatorioComprasClientesBloc extends Bloc<RelatorioComprasClientesEvent,
    RelatorioComprasClientesState> {
  final GetRelatorioComprasClientes _useCase;

  RelatorioComprasClientesBloc(this._useCase)
      : super(RelatorioComprasClientesState.initial()) {
    on<RelatorioComprasClientesCarregar>(_onCarregar);
  }

  FutureOr<void> _onCarregar(
    RelatorioComprasClientesCarregar event,
    Emitter<RelatorioComprasClientesState> emit,
  ) async {
    final empresaId = sl<IAcessoGlobalSessao>().empresaIdDaSessao;
    if (empresaId == null) return;
    try {
      emit(state.copyWith(
        step: RelatorioComprasClientesStep.carregando,
        dataInicial: event.dataInicial,
        dataFinal: event.dataFinal,
        agruparPor: event.agruparPor,
        page: event.page,
      ));
      final dados = await _useCase.call(
        empresaIds: [empresaId],
        dataInicial: event.dataInicial,
        dataFinal: event.dataFinal,
        agruparPor: event.agruparPor,
        produtoIds: event.produtoIds,
        referenciaIds: event.referenciaIds,
        categoriaIds: event.categoriaIds,
        corIds: event.corIds,
        tamanhoIds: event.tamanhoIds,
        page: event.page,
      );
      emit(state.copyWith(
        step: RelatorioComprasClientesStep.sucesso,
        dados: dados,
        totalPages: dados.meta.totalPages,
      ));
    } catch (e, s) {
      emit(state.copyWith(
        step: RelatorioComprasClientesStep.falha,
        erro: 'Falha ao carregar relatório de compras de clientes.',
      ));
      addError(e, s);
    }
  }
}
