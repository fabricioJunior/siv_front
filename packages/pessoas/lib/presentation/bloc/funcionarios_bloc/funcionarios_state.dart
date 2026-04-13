part of 'funcionarios_bloc.dart';

abstract class FuncionariosState extends Equatable {
  List<Funcionario> get funcionarios => [];

  Funcionario? get funcionarioSelecionado => null;

  const FuncionariosState();

  @override
  List<Object?> get props => [funcionarios];
}

class FuncionariosInitial extends FuncionariosState {
  const FuncionariosInitial();
}

class FuncionariosCarregarEmProgresso extends FuncionariosState {
  const FuncionariosCarregarEmProgresso();
}

class FuncionariosCarregarSucesso extends FuncionariosState {
  @override
  final List<Funcionario> funcionarios;

  final Funcionario? funcionarioSelecionado;

  const FuncionariosCarregarSucesso(
      {required this.funcionarios, required this.funcionarioSelecionado});
}

class FuncionariosCarregarFalha extends FuncionariosState {
  const FuncionariosCarregarFalha();
}
