import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:empresas/domain/entities/terminal.dart';
import 'package:empresas/use_cases.dart';

part 'terminal_event.dart';
part 'terminal_state.dart';

class TerminalBloc extends Bloc<TerminalEvent, TerminalState> {
  final RecuperarTerminal _recuperarTerminal;
  final CriarTerminal _criarTerminal;
  final AtualizarTerminal _atualizarTerminal;

  TerminalBloc(
    this._recuperarTerminal,
    this._criarTerminal,
    this._atualizarTerminal,
  ) : super(const TerminalState(terminalStep: TerminalStep.inicial)) {
    on<TerminalIniciou>(_onTerminalIniciou);
    on<TerminalEditou>(_onTerminalEditou);
    on<TerminalSalvou>(_onTerminalSalvou);
  }

  FutureOr<void> _onTerminalIniciou(
    TerminalIniciou event,
    Emitter<TerminalState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          terminalStep: TerminalStep.carregando,
          empresaId: event.empresaId,
        ),
      );

      if (event.idTerminal != null) {
        final terminal = await _recuperarTerminal.call(
          empresaId: event.empresaId,
          id: event.idTerminal!,
        );

        if (terminal != null) {
          emit(TerminalState.fromModel(terminal));
        } else {
          emit(state.copyWith(terminalStep: TerminalStep.falha));
        }
      } else {
        emit(
          TerminalState(
            empresaId: event.empresaId,
            inativo: false,
            terminalStep: TerminalStep.editando,
          ),
        );
      }
    } catch (e, s) {
      emit(state.copyWith(terminalStep: TerminalStep.falha));
      addError(e, s);
    }
  }

  FutureOr<void> _onTerminalEditou(
    TerminalEditou event,
    Emitter<TerminalState> emit,
  ) {
    emit(state.copyWith(terminalStep: TerminalStep.editando, nome: event.nome));
  }

  FutureOr<void> _onTerminalSalvou(
    TerminalSalvou event,
    Emitter<TerminalState> emit,
  ) async {
    try {
      final empresaId = state.empresaId;
      final nome = state.nome?.trim();

      if (empresaId == null || nome == null || nome.isEmpty) {
        emit(state.copyWith(terminalStep: TerminalStep.falha));
        return;
      }

      emit(state.copyWith(terminalStep: TerminalStep.carregando));

      if (state.id != null) {
        final terminal = await _atualizarTerminal.call(
          empresaId: empresaId,
          id: state.id!,
          nome: nome,
        );
        emit(TerminalState.fromModel(terminal, step: TerminalStep.salvo));
      } else {
        final terminal = await _criarTerminal.call(
          empresaId: empresaId,
          nome: nome,
        );
        emit(TerminalState.fromModel(terminal, step: TerminalStep.criado));
      }
    } catch (e, s) {
      emit(state.copyWith(terminalStep: TerminalStep.falha));
      addError(e, s);
    }
  }
}
