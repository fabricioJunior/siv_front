part of 'terminais_do_usuario_bloc.dart';

abstract class TerminaisDoUsuarioEvent {}

class TerminaisDoUsuarioIniciou extends TerminaisDoUsuarioEvent {
  final int idUsuario;

  TerminaisDoUsuarioIniciou({required this.idUsuario});
}

class TerminaisDoUsuarioVinculou extends TerminaisDoUsuarioEvent {
  final int idTerminal;
  final int idEmpresa;

  TerminaisDoUsuarioVinculou({
    required this.idTerminal,
    required this.idEmpresa,
  });
}

class TerminaisDoUsuarioDesvinculou extends TerminaisDoUsuarioEvent {
  final int idTerminal;

  TerminaisDoUsuarioDesvinculou({required this.idTerminal});
}
