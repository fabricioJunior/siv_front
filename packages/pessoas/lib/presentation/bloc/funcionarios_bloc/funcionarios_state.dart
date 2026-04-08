part of 'funcionarios_bloc.dart';

abstract class FuncionariosState extends Equatable {
  List<Funcionario> get funcionarios => [];

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

  const FuncionariosCarregarSucesso({required this.funcionarios});
}

class FuncionariosCarregarFalha extends FuncionariosState {
  const FuncionariosCarregarFalha();
}
