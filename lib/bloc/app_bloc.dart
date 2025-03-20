import 'dart:async';

import 'package:autenticacao/models.dart';
import 'package:autenticacao/uses_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';

part 'app_state.dart';
part 'app_event.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final OnAutenticado _onAutenticado;
  final EstaAutenticado _estaAutenticado;
  final Deslogar _deslogar;
  final RecuperarUsuarioDaSessao _recuperarUsuarioDaSessao;

  AppBloc(
    this._estaAutenticado,
    this._onAutenticado,
    this._deslogar,
    this._recuperarUsuarioDaSessao,
  ) : super(const AppState()) {
    _onAutenticado.call().listen((token) => add(AppAutenticou()));

    on<AppIniciou>(_onAppIniciou);
    on<AppAutenticou>(_onAppAutenticou);
    on<AppDesautenticou>(_onDesautenticou);
  }

  FutureOr<void> _onAppAutenticou(
    AppAutenticou event,
    Emitter<AppState> emit,
  ) async {
    try {
      var usuarioDaSessao = await _recuperarUsuarioDaSessao();
      emit(state.copyWith(
        statusAutenticacao: StatusAutenticacao.autenticado,
        usuarioDaSessao: usuarioDaSessao,
      ));
    } catch (e, s) {
      addError(e, s);
    }
  }

  FutureOr<void> _onDesautenticou(
    AppDesautenticou event,
    Emitter<AppState> emit,
  ) async {
    try {
      await _deslogar.call();
      emit(
        state.copyWith(statusAutenticacao: StatusAutenticacao.naoAutenticao),
      );
    } catch (e, s) {
      addError(e, s);
    }
  }

  FutureOr<void> _onAppIniciou(AppIniciou event, Emitter<AppState> emit) async {
    try {
      var estaAutenticado = await _estaAutenticado.call();
      var usuarioDaSessao = await _recuperarUsuarioDaSessao();
      emit(
        state.copyWith(
          usuarioDaSessao: usuarioDaSessao,
          statusAutenticacao: estaAutenticado
              ? StatusAutenticacao.autenticado
              : StatusAutenticacao.naoAutenticao,
        ),
      );
    } catch (e, s) {
      addError(e, s);
    }
  }
}
