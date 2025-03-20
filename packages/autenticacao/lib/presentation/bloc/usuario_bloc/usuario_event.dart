part of 'usuario_bloc.dart';

abstract class UsuarioEvent {}

class UsuarioIniciou extends UsuarioEvent {
  final int? idUsuario;

  UsuarioIniciou({this.idUsuario});
}
