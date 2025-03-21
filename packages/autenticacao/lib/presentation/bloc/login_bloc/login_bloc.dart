import 'dart:async';

import 'package:autenticacao/domain/usecases/criar_token_de_autenticacao.dart';
import 'package:autenticacao/uses_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';

part 'login_state.dart';
part 'login_event.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final CriarTokenDeAutenticacao _criarTokenDeAutenticacao;
  final RecuperarUsuarioDaSessao _recuperarUsuarioDaSessao;

  LoginBloc(
    this._criarTokenDeAutenticacao,
    this._recuperarUsuarioDaSessao,
  ) : super(const LoginInicial()) {
    on<LoginAdicionouUsuario>(_onUsuarioAdicionoUsuario);
    on<LoginAdicionouSenha>(_onLoginAdicionouSenha);
    on<LoginAutenticou>(_onLoginAutenticou);
  }

  FutureOr<void> _onUsuarioAdicionoUsuario(
    LoginAdicionouUsuario event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginAdicionarUsuarioSucesso(state, usuario: event.usuario));
  }

  FutureOr<void> _onLoginAdicionouSenha(
    LoginAdicionouSenha event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginAdicionarSenhaSucesso(state, senha: event.senha));
  }

  FutureOr<void> _onLoginAutenticou(
    LoginAutenticou event,
    Emitter<LoginState> emit,
  ) async {
    try {
      emit(LoginAutenticarEmProgresso(state));
      var token = await _criarTokenDeAutenticacao(
        usuario: state.usuario ?? '',
        senha: state.senha ?? '',
      );
      var usuario = await _recuperarUsuarioDaSessao.call();
      if (token == null) {
        emit(LoginAutenticarFalha(state, erro: 'Usuário ou senha incorretos'));
        return;
      }
      emit(LoginAutenticarSucesso(state));
    } catch (e, s) {
      emit(
        LoginAutenticarFalha(
          state,
          erro:
              'Falha na autenticação, verifique sua conexão, caso o problema continue entre em contato com o suporte',
        ),
      );
      addError(e, s);
    }
  }
}
