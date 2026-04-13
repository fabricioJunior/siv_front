part of 'terminais_do_usuario_bloc.dart';

abstract class TerminaisDoUsuarioState extends Equatable {
  List<TerminalDoUsuario> get terminais => const [];
  int? get idUsuario => null;
  List<Empresa> get empresas => const [];

  @override
  List<Object?> get props => [terminais, idUsuario, empresas];
}

class TerminaisDoUsuarioInitial extends TerminaisDoUsuarioState {}

class TerminaisDoUsuarioCarregarEmProgresso extends TerminaisDoUsuarioState {
  @override
  final int? idUsuario;

  TerminaisDoUsuarioCarregarEmProgresso({required this.idUsuario});
}

class TerminaisDoUsuarioCarregarSucesso extends TerminaisDoUsuarioState {
  @override
  final List<TerminalDoUsuario> terminais;
  @override
  final int? idUsuario;
  @override
  final List<Empresa> empresas;

  TerminaisDoUsuarioCarregarSucesso({
    required this.terminais,
    required this.idUsuario,
    required this.empresas,
  });
}

class TerminaisDoUsuarioCarregarFalha extends TerminaisDoUsuarioState {
  @override
  final int? idUsuario;

  TerminaisDoUsuarioCarregarFalha({required this.idUsuario});
}

class TerminaisDoUsuarioVincularEmProgresso extends TerminaisDoUsuarioState {
  @override
  final int? idUsuario;

  TerminaisDoUsuarioVincularEmProgresso({required this.idUsuario});
}

class TerminaisDoUsuarioVincularSucesso extends TerminaisDoUsuarioState {
  @override
  final List<TerminalDoUsuario> terminais;
  @override
  final int? idUsuario;
  @override
  final List<Empresa> empresas;

  TerminaisDoUsuarioVincularSucesso({
    required this.terminais,
    required this.idUsuario,
    required this.empresas,
  });
}

class TerminaisDoUsuarioVincularFalha extends TerminaisDoUsuarioState {
  @override
  final int? idUsuario;

  TerminaisDoUsuarioVincularFalha({required this.idUsuario});
}

class TerminaisDoUsuarioDesvincularEmProgresso extends TerminaisDoUsuarioState {
  @override
  final int? idUsuario;

  TerminaisDoUsuarioDesvincularEmProgresso({required this.idUsuario});
}

class TerminaisDoUsuarioDesvincularSucesso extends TerminaisDoUsuarioState {
  @override
  final List<TerminalDoUsuario> terminais;
  @override
  final int? idUsuario;
  @override
  final List<Empresa> empresas;

  TerminaisDoUsuarioDesvincularSucesso({
    required this.terminais,
    required this.idUsuario,
    required this.empresas,
  });
}

class TerminaisDoUsuarioDesvincularFalha extends TerminaisDoUsuarioState {
  @override
  final int? idUsuario;

  TerminaisDoUsuarioDesvincularFalha({required this.idUsuario});
}
