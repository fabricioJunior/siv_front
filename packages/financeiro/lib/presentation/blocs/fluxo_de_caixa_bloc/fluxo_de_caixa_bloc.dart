import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/use_cases.dart';

part 'fluxo_de_caixa_event.dart';
part 'fluxo_de_caixa_state.dart';

class FluxoDeCaixaBloc extends Bloc<FluxoDeCaixaEvent, FluxoDeCaixaState> {
  final AbrirCaixa _abrirCaixa;
  final BuscarExtratoCaixa _buscarExtratoCaixa;
  final BuscarExtratoCaixaPorDocumento _buscarExtratoCaixaPorDocumento;
  final RecuperarCaixaAberto _recuperarCaixaAberto;

  FluxoDeCaixaBloc(
    this._abrirCaixa,
    this._buscarExtratoCaixa,
    this._buscarExtratoCaixaPorDocumento,
    this._recuperarCaixaAberto,
  ) : super(const FluxoDeCaixaInitial()) {
    on<FluxoDeCaixaRecuperouCaixaAberto>(_onRecuperouCaixaAberto);
    on<FluxoDeCaixaIniciou>(_onIniciou);
    on<FluxoDeCaixaAbriuCaixa>(_onAbriuCaixa);
    on<FluxoDeCaixaFiltrouDocumento>(_onFiltrouDocumento);
  }

  FutureOr<void> _onRecuperouCaixaAberto(
    FluxoDeCaixaRecuperouCaixaAberto event,
    Emitter<FluxoDeCaixaState> emit,
  ) async {
    try {
      emit(
        FluxoDeCaixaCarregarEmProgresso(
          caixa: state.caixa,
          caixaId: state.caixaId,
          extratos: state.extratos,
        ),
      );

      final caixa = await _recuperarCaixaAberto.call(
        idEmpresa: event.empresaId,
        idTerminal: event.terminalId,
      );

      if (caixa == null) {
        emit(
          const FluxoDeCaixaCarregarSucesso(
            caixa: null,
            caixaId: null,
            extratos: [],
          ),
        );
        return;
      }

      final extratos = await _buscarExtratoCaixa.call(caixaId: caixa.id);

      emit(
        FluxoDeCaixaCarregarSucesso(
          caixa: caixa,
          caixaId: caixa.id,
          extratos: extratos,
        ),
      );
    } catch (e, s) {
      emit(
        FluxoDeCaixaCarregarFalha(
          caixa: state.caixa,
          caixaId: state.caixaId,
          extratos: state.extratos,
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onIniciou(
    FluxoDeCaixaIniciou event,
    Emitter<FluxoDeCaixaState> emit,
  ) async {
    try {
      emit(
        FluxoDeCaixaCarregarEmProgresso(
          caixa: state.caixa,
          caixaId: event.caixaId,
          extratos: state.extratos,
        ),
      );

      final extratos = await _buscarExtratoCaixa.call(caixaId: event.caixaId);

      emit(
        FluxoDeCaixaCarregarSucesso(
          caixa: state.caixa,
          caixaId: event.caixaId,
          extratos: extratos,
        ),
      );
    } catch (e, s) {
      emit(
        FluxoDeCaixaCarregarFalha(
          caixa: state.caixa,
          caixaId: event.caixaId,
          extratos: state.extratos,
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onAbriuCaixa(
    FluxoDeCaixaAbriuCaixa event,
    Emitter<FluxoDeCaixaState> emit,
  ) async {
    try {
      emit(
        FluxoDeCaixaAbrirEmProgresso(
          caixa: state.caixa,
          caixaId: state.caixaId,
          extratos: state.extratos,
        ),
      );

      final caixa = await _abrirCaixa.call(
        idEmpresa: event.empresaId,
        terminalId: event.terminalId,
      );

      final extratos = await _buscarExtratoCaixa.call(caixaId: caixa.id);

      emit(
        FluxoDeCaixaAbrirSucesso(
          caixa: caixa,
          caixaId: caixa.id,
          extratos: extratos,
        ),
      );
    } catch (e, s) {
      emit(
        FluxoDeCaixaAbrirFalha(
          caixa: state.caixa,
          caixaId: state.caixaId,
          extratos: state.extratos,
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onFiltrouDocumento(
    FluxoDeCaixaFiltrouDocumento event,
    Emitter<FluxoDeCaixaState> emit,
  ) async {
    final caixaId = state.caixaId;
    if (caixaId == null) {
      return;
    }

    try {
      emit(
        FluxoDeCaixaCarregarEmProgresso(
          caixa: state.caixa,
          caixaId: caixaId,
          extratos: state.extratos,
        ),
      );

      final documento = event.documento.trim();
      final extratos = documento.isEmpty
          ? await _buscarExtratoCaixa.call(caixaId: caixaId)
          : await _buscarExtratoCaixaPorDocumento.call(
              caixaId: caixaId,
              documento: documento,
            );

      emit(
        FluxoDeCaixaCarregarSucesso(
          caixa: state.caixa,
          caixaId: caixaId,
          extratos: extratos,
        ),
      );
    } catch (e, s) {
      emit(
        FluxoDeCaixaCarregarFalha(
          caixa: state.caixa,
          caixaId: caixaId,
          extratos: state.extratos,
        ),
      );
      addError(e, s);
    }
  }
}
