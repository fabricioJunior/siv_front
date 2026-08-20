import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';
import 'package:estoque/domain/models/relatorio_produtos_defasados.dart';
import 'package:estoque/domain/usecases/get_relatorio_produtos_defasados.dart';

part 'relatorio_produtos_defasados_event.dart';
part 'relatorio_produtos_defasados_state.dart';

class RelatorioProdutosDefasadosBloc extends Bloc<
    RelatorioProdutosDefasadosEvent, RelatorioProdutosDefasadosState> {
  final GetRelatorioProdutosDefasados _useCase;

  RelatorioProdutosDefasadosBloc(this._useCase)
      : super(const RelatorioProdutosDefasadosState.initial()) {
    on<RelatorioProdutosDefasadosCarregar>(_onCarregar);
  }

  FutureOr<void> _onCarregar(
    RelatorioProdutosDefasadosCarregar event,
    Emitter<RelatorioProdutosDefasadosState> emit,
  ) async {
    final empresaId = sl<IAcessoGlobalSessao>().empresaIdDaSessao;
    if (empresaId == null) return;
    try {
      emit(state.copyWith(
        step: RelatorioProdutosDefasadosStep.carregando,
        dias: event.dias,
        tipoMovimentacao: event.tipoMovimentacao,
        visualizacao: event.visualizacao,
        dataReferencia: event.dataReferencia,
        corIds: event.corIds,
        tamanhoIds: event.tamanhoIds,
        modoAgrupamentoReferencia: event.modoAgrupamentoReferencia,
        busca: event.busca,
        page: event.page,
      ));
      final dados = await _useCase.call(
        empresaIds: [empresaId],
        dias: event.dias,
        tipoMovimentacao: event.tipoMovimentacao,
        visualizacao: event.visualizacao,
        dataReferencia: event.dataReferencia,
        corIds: event.corIds,
        tamanhoIds: event.tamanhoIds,
        modoAgrupamentoReferencia: event.modoAgrupamentoReferencia,
        busca: event.busca,
        page: event.page,
      );
      emit(state.copyWith(
        step: RelatorioProdutosDefasadosStep.sucesso,
        dados: dados,
        totalPages: dados.meta.totalPages,
      ));
    } catch (e, s) {
      emit(state.copyWith(
        step: RelatorioProdutosDefasadosStep.falha,
        erro: 'Falha ao carregar relatório de produtos defasados.',
      ));
      addError(e, s);
    }
  }
}
