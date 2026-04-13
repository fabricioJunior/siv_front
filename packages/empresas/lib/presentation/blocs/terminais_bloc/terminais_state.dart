part of 'terminais_bloc.dart';

abstract class TerminaisState extends Equatable {
  List<Terminal> get terminais => [];

  const TerminaisState();

  @override
  List<Object?> get props => [terminais];
}

class TerminaisInitial extends TerminaisState {
  const TerminaisInitial();
}

class TerminaisCarregarEmProgresso extends TerminaisState {
  const TerminaisCarregarEmProgresso();
}

class TerminaisCarregarSucesso extends TerminaisState {
  @override
  final List<Terminal> terminais;

  const TerminaisCarregarSucesso({required this.terminais});
}

class TerminaisCarregarFalha extends TerminaisState {
  const TerminaisCarregarFalha();
}

class TerminaisDesativarEmProgresso extends TerminaisState {
  @override
  final List<Terminal> terminais;

  const TerminaisDesativarEmProgresso({required this.terminais});
}

class TerminaisDesativarSucesso extends TerminaisState {
  @override
  final List<Terminal> terminais;

  const TerminaisDesativarSucesso({required this.terminais});
}

class TerminaisDesativarFalha extends TerminaisState {
  @override
  final List<Terminal> terminais;

  const TerminaisDesativarFalha({required this.terminais});
}
