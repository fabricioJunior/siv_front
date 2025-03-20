part of 'usuario_bloc.dart';

abstract class UsuarioState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UsuarioNaoInicializado extends UsuarioState {}

class UsuarioCarregarEmProgresso extends UsuarioState {}

class UsuarioCarregarSucesso extends UsuarioState {
  final Usuario usuario;

  UsuarioCarregarSucesso({required this.usuario});

  @override
  List<Object?> get props => [usuario];
}

class UsuarioCarregarFalha extends UsuarioState {}

// class UsuarioEditarEmProgresso extends UsuarioState { 
   
//   final String? nome;
//   final String? login;
//   final String? senha;
//   final String? tipo;
//   UsuarioEditarEmProgresso(Usuario usuario);
// }