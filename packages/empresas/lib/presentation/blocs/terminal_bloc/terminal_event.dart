part of 'terminal_bloc.dart';

abstract class TerminalEvent extends Equatable {
  const TerminalEvent();

  @override
  List<Object?> get props => [];
}

class TerminalIniciou extends TerminalEvent {
  final int empresaId;
  final int? idTerminal;

  const TerminalIniciou({required this.empresaId, this.idTerminal});

  @override
  List<Object?> get props => [empresaId, idTerminal];
}

class TerminalEditou extends TerminalEvent {
  final String nome;
  final String? tipo;

  const TerminalEditou({required this.nome, this.tipo});

  @override
  List<Object?> get props => [nome, tipo];
}

class TerminalSalvou extends TerminalEvent {
  const TerminalSalvou();
}
