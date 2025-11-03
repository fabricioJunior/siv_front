import 'dart:async';

import 'package:autenticacao/models.dart';
import 'package:autenticacao/uses_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';

part 'app_state.dart';
part 'app_event.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final OnAutenticado _onAutenticado;
  final OnDesautenticado _onDesautenticado;
  final EstaAutenticado _estaAutenticado;
  final Deslogar _deslogar;
  final RecuperarUsuarioDaSessao _recuperarUsuarioDaSessao;

  late StreamSubscription<Token> _onAutenticacoSubscription;
  late StreamSubscription<Null> _onDesautenticadoSubscription;
  AppBloc(
    this._estaAutenticado,
    this._onAutenticado,
    this._deslogar,
    this._recuperarUsuarioDaSessao,
    this._onDesautenticado,
  ) : super(const AppState()) {
    _onAutenticacoSubscription = _onAutenticado
        .call()
        .listen((token) => add(AppAutenticou(token: token)));
    _onDesautenticadoSubscription =
        _onDesautenticado.call().listen((_) => add(AppDesautenticou()));
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
      if (event.token.idEmpresa == null) {}
      emit(state.copyWith(
        statusAutenticacao: event.token.idEmpresa == null
            ? StatusAutenticacao.autenticando
            : StatusAutenticacao.autenticado,
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
      var usuarioDaSessao =
          estaAutenticado ? await _recuperarUsuarioDaSessao() : null;
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

  @override
  Future<void> close() async {
    await _onAutenticacoSubscription.cancel();
    await _onDesautenticadoSubscription.cancel();
    return super.close();
  }
}
