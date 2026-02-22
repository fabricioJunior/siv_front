part of 'login_bloc.dart';

abstract class LoginEvent {}

class LoginCarregouLicenciados extends LoginEvent {}

class LoginAdicionouUsuario extends LoginEvent {
  final String usuario;

  LoginAdicionouUsuario({required this.usuario});
}

class LoginAdicionouSenha extends LoginEvent {
  final String senha;

  LoginAdicionouSenha({required this.senha});
}

class LoginAutenticou extends LoginEvent {
  final Empresa? empresa;

  LoginAutenticou({this.empresa});
}

class LoginSelecionouLicenciado extends LoginEvent {
  final Licenciado licenciado;

  LoginSelecionouLicenciado({required this.licenciado});
}
