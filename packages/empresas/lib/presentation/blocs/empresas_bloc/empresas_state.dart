part of 'empresas_bloc.dart';

abstract class EmpresasState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EmpresasNaoInicializado extends EmpresasState {}

class EmpresasCarregarEmProgresso extends EmpresasState {}

class EmpresasCarregarSucesso extends EmpresasState {
  final List<Empresa> empresas;

  EmpresasCarregarSucesso({required this.empresas});

  @override
  List<Object?> get props => [empresas];
}

class EmpresasCarregarFalha extends EmpresasState {}
