part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  final String? usuario;
  final String? senha;

  const LoginState({this.usuario, this.senha});

  LoginState.fromLastState(
    LoginState lastState, {
    String? usuario,
    String? senha,
  })  : usuario = usuario ?? lastState.usuario,
        senha = senha ?? lastState.senha;

  @override
  List<Object?> get props => [usuario, senha];
}

class LoginInicial extends LoginState {
  const LoginInicial({super.usuario, super.senha});
}

class LoginAdicionarUsuarioSucesso extends LoginState {
  LoginAdicionarUsuarioSucesso(super.lastState, {required super.usuario})
      : super.fromLastState();
}

class LoginAdicionarSenhaSucesso extends LoginState {
  LoginAdicionarSenhaSucesso(super.lastState, {required super.senha})
      : super.fromLastState();
}

class LoginAutenticarEmProgresso extends LoginState {
  LoginAutenticarEmProgresso(super.fromLastState) : super.fromLastState();
}

class LoginAutenticarSucesso extends LoginState {
  LoginAutenticarSucesso(super.lastState) : super.fromLastState();
}

class LoginAutenticarFalha extends LoginState {
  final String erro;

  LoginAutenticarFalha(super.lastState, {required this.erro})
      : super.fromLastState();
}
