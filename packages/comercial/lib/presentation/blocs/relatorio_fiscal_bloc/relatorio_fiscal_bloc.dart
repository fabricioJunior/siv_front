import 'dart:async';

import 'package:comercial/domain/models/documento_fiscal.dart';
import 'package:comercial/domain/models/resumo_fiscal.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';

part 'relatorio_fiscal_event.dart';
part 'relatorio_fiscal_state.dart';

class RelatorioFiscalBloc extends Bloc<RelatorioFiscalEvent, RelatorioFiscalState> {
  final ListarDocumentosFiscais _listar;
  final GetResumoFiscal _getResumo;

  RelatorioFiscalBloc(this._listar, this._getResumo)
      : super(const RelatorioFiscalState.initial()) {
    on<RelatorioFiscalCarregar>(_onCarregar);
  }

  FutureOr<void> _onCarregar(
    RelatorioFiscalCarregar event,
    Emitter<RelatorioFiscalState> emit,
  ) async {
    try {
      emit(state.copyWith(step: RelatorioFiscalStep.carregando));
      final resultado = await _listar.call(
        romaneioId: event.romaneioId,
        pedidoId: event.pedidoId,
        cliente: event.cliente,
        status: event.status,
        formaPagamento: event.formaPagamento,
        dataInicio: event.dataInicio,
        dataFim: event.dataFim,
        page: event.page,
      );
      final resumo = await _getResumo.call(
        romaneioId: event.romaneioId,
        pedidoId: event.pedidoId,
        cliente: event.cliente,
        status: event.status,
        formaPagamento: event.formaPagamento,
        dataInicio: event.dataInicio,
        dataFim: event.dataFim,
      );
      emit(state.copyWith(
        items: resultado['items'] as List<DocumentoFiscal>,
        total: resultado['total'] as int,
        page: event.page,
        resumo: resumo,
        step: RelatorioFiscalStep.sucesso,
      ));
    } catch (e, s) {
      emit(state.copyWith(
        step: RelatorioFiscalStep.falha,
        erro: 'Falha ao carregar relatório fiscal.',
      ));
      addError(e, s);
    }
  }
}
