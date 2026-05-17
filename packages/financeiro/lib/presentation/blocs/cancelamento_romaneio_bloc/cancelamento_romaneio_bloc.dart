import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/sessao.dart';
import 'package:financeiro/use_cases.dart';

part 'cancelamento_romaneio_event.dart';
part 'cancelamento_romaneio_state.dart';

class CancelamentoRomaneioBloc
    extends Bloc<CancelamentoRomaneioEvent, CancelamentoRomaneioState> {
  final CancelarRomaneio _cancelarRomaneio;
  final IAcessoGlobalSessao _acessoGlobalSessao;

  CancelamentoRomaneioBloc(
    this._cancelarRomaneio,
    this._acessoGlobalSessao,
  ) : super(const CancelamentoRomaneioState.initial()) {
    on<CancelamentoRomaneioIniciou>(_onIniciou);
    on<CancelamentoRomaneioMotivoAlterado>(_onMotivoAlterado);
    on<CancelamentoRomaneioConfirmado>(_onConfirmado);
  }

  FutureOr<void> _onIniciou(
    CancelamentoRomaneioIniciou event,
    Emitter<CancelamentoRomaneioState> emit,
  ) {
    final idRomaneio = event.idRomaneio;
    if (idRomaneio == null || idRomaneio <= 0) {
      emit(
        state.copyWith(
          step: CancelamentoRomaneioStep.falha,
          erro: 'Romaneio inválido para cancelamento.',
        ),
      );
    } else {
      emit(
        state.copyWith(
          idRomaneio: idRomaneio,
          step: CancelamentoRomaneioStep.editando,
          erro: null,
        ),
      );
    }
  }

  FutureOr<void> _onMotivoAlterado(
    CancelamentoRomaneioMotivoAlterado event,
    Emitter<CancelamentoRomaneioState> emit,
  ) {
    emit(
      state.copyWith(
        motivo: event.motivo,
        step: CancelamentoRomaneioStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onConfirmado(
    CancelamentoRomaneioConfirmado event,
    Emitter<CancelamentoRomaneioState> emit,
  ) async {
    final motivo = state.motivo.trim();
    if (motivo.isEmpty) {
      emit(
        state.copyWith(
          step: CancelamentoRomaneioStep.validacaoInvalida,
          erro: 'Informe o motivo do cancelamento.',
        ),
      );
      return;
    }

    final romaneioId = state.idRomaneio;
    if (romaneioId == null || romaneioId <= 0) {
      emit(
        state.copyWith(
          step: CancelamentoRomaneioStep.falha,
          erro: 'Não foi possível identificar o romaneio.',
        ),
      );
      return;
    }

    final caixaId = _acessoGlobalSessao.caixaIdDaSessao;
    if (caixaId == null || caixaId <= 0) {
      emit(
        state.copyWith(
          step: CancelamentoRomaneioStep.falha,
          erro: 'Não há caixa aberto na sessão para cancelar este romaneio.',
        ),
      );
      return;
    }

    try {
      emit(
        state.copyWith(
          step: CancelamentoRomaneioStep.cancelando,
          erro: null,
        ),
      );

      await _cancelarRomaneio.call(
        caixaId: caixaId,
        idRomaneio: romaneioId,
        motivo: motivo,
      );

      emit(
        state.copyWith(
          step: CancelamentoRomaneioStep.cancelado,
          erro: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          step: CancelamentoRomaneioStep.falha,
          erro: 'Falha ao cancelar o romaneio. Tente novamente.',
        ),
      );
    }
  }
}