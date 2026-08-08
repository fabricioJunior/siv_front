part of 'funcionario_vinculos_bloc.dart';

abstract class FuncionarioVinculosEvent {}

class FuncionarioVinculosIniciou extends FuncionarioVinculosEvent {
  final int idFuncionario;

  FuncionarioVinculosIniciou({required this.idFuncionario});
}

class FuncionarioVinculosEmpresaAdicionada extends FuncionarioVinculosEvent {
  final int idEmpresa;

  FuncionarioVinculosEmpresaAdicionada({required this.idEmpresa});
}

class FuncionarioVinculosDesativarSolicitado extends FuncionarioVinculosEvent {
  final int idEmpresa;

  FuncionarioVinculosDesativarSolicitado({required this.idEmpresa});
}

class FuncionarioVinculosReativarSolicitado extends FuncionarioVinculosEvent {
  final int idEmpresa;

  FuncionarioVinculosReativarSolicitado({required this.idEmpresa});
}
