part of 'terminal_bloc.dart';

class TerminalState extends Equatable {
  final int? id;
  final int? empresaId;
  final String? nome;
  final bool? inativo;
  final String tipo;
  final TerminalStep terminalStep;
  final Terminal? terminal;

  const TerminalState({
    this.id,
    this.empresaId,
    this.nome,
    this.inativo,
    this.tipo = 'fisico',
    this.terminal,
    required this.terminalStep,
  });

  TerminalState.fromModel(this.terminal, {TerminalStep? step})
    : id = terminal!.id,
      empresaId = terminal.empresaId,
      nome = terminal.nome,
      inativo = terminal.inativo,
      tipo = terminal.tipo,
      terminalStep = step ?? TerminalStep.carregado;

  TerminalState copyWith({
    int? id,
    int? empresaId,
    String? nome,
    bool? inativo,
    String? tipo,
    TerminalStep? terminalStep,
    Terminal? terminal,
  }) {
    return TerminalState(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      nome: nome ?? this.nome,
      inativo: inativo ?? this.inativo,
      tipo: tipo ?? this.tipo,
      terminalStep: terminalStep ?? this.terminalStep,
      terminal: terminal ?? this.terminal,
    );
  }

  @override
  List<Object?> get props => [
    id,
    empresaId,
    nome,
    inativo,
    tipo,
    terminalStep,
  ];
}

enum TerminalStep {
  inicial,
  carregando,
  carregado,
  editando,
  salvo,
  criado,
  falha,
}
