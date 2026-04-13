import 'dart:async';

import 'package:autenticacao/models.dart';
import 'package:autenticacao/uses_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';

part 'terminais_do_usuario_event.dart';
part 'terminais_do_usuario_state.dart';

class TerminaisDoUsuarioBloc
    extends Bloc<TerminaisDoUsuarioEvent, TerminaisDoUsuarioState> {
  final RecuperarTerminaisDoUsuario _recuperarTerminaisDoUsuario;
  final RecuperarEmpresas _recuperarEmpresas;
  final VincularTerminalAoUsuario _vincularTerminalAoUsuario;
  final DesvincularTerminalDoUsuario _desvincularTerminalDoUsuario;

  TerminaisDoUsuarioBloc(
    this._recuperarTerminaisDoUsuario,
    this._recuperarEmpresas,
    this._vincularTerminalAoUsuario,
    this._desvincularTerminalDoUsuario,
  ) : super(TerminaisDoUsuarioInitial()) {
    on<TerminaisDoUsuarioIniciou>(_onIniciou);
    on<TerminaisDoUsuarioVinculou>(_onVinculou);
    on<TerminaisDoUsuarioDesvinculou>(_onDesvinculou);
  }

  FutureOr<void> _onIniciou(
    TerminaisDoUsuarioIniciou event,
    Emitter<TerminaisDoUsuarioState> emit,
  ) async {
    try {
      emit(TerminaisDoUsuarioCarregarEmProgresso(idUsuario: event.idUsuario));

      final terminais = await _recuperarTerminaisDoUsuario.call(
        idUsuario: event.idUsuario,
      );
      final empresas = await _recuperarEmpresas.call();

      emit(
        TerminaisDoUsuarioCarregarSucesso(
          idUsuario: event.idUsuario,
          empresas: empresas,
          terminais: terminais,
        ),
      );
    } catch (e, s) {
      emit(TerminaisDoUsuarioCarregarFalha(idUsuario: event.idUsuario));
      addError(e, s);
    }
  }

  FutureOr<void> _onVinculou(
    TerminaisDoUsuarioVinculou event,
    Emitter<TerminaisDoUsuarioState> emit,
  ) async {
    try {
      emit(TerminaisDoUsuarioVincularEmProgresso(idUsuario: state.idUsuario));

      await _vincularTerminalAoUsuario.call(
        usuarioId: state.idUsuario!,
        terminalId: event.idTerminal,
        idEmpresa: event.idEmpresa,
      );

      final terminais = await _recuperarTerminaisDoUsuario.call(
        idUsuario: state.idUsuario!,
      );

      emit(
        TerminaisDoUsuarioVincularSucesso(
          idUsuario: state.idUsuario!,
          empresas: state.empresas,
          terminais: terminais,
        ),
      );
    } catch (e, s) {
      emit(TerminaisDoUsuarioVincularFalha(idUsuario: state.idUsuario));
      addError(e, s);
    }
  }

  FutureOr<void> _onDesvinculou(
    TerminaisDoUsuarioDesvinculou event,
    Emitter<TerminaisDoUsuarioState> emit,
  ) async {
    try {
      emit(
        TerminaisDoUsuarioDesvincularEmProgresso(idUsuario: state.idUsuario),
      );

      await _desvincularTerminalDoUsuario.call(
        usuarioId: state.idUsuario!,
        terminalId: event.idTerminal,
      );

      final terminais = await _recuperarTerminaisDoUsuario.call(
        idUsuario: state.idUsuario!,
      );

      emit(
        TerminaisDoUsuarioDesvincularSucesso(
          idUsuario: state.idUsuario!,
          empresas: state.empresas,
          terminais: terminais,
        ),
      );
    } catch (e, s) {
      emit(TerminaisDoUsuarioDesvincularFalha(idUsuario: state.idUsuario));
      addError(e, s);
    }
  }
}
