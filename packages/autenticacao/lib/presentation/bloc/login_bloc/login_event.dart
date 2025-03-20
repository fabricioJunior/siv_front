part of 'login_bloc.dart';

abstract class LoginEvent {}

class LoginAdicionouUsuario extends LoginEvent {
  final String usuario;

  LoginAdicionouUsuario({required this.usuario});
}

class LoginAdicionouSenha extends LoginEvent {
  final String senha;

  LoginAdicionouSenha({required this.senha});
}

class LoginAutenticou extends LoginEvent {}
