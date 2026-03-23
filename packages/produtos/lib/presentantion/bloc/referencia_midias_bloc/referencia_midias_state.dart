part of 'referencia_midias_bloc.dart';

abstract class ReferenciaMidiasState {}

class ReferenciaMidiasInicial extends ReferenciaMidiasState {}

class ReferenciaMidiasCarregando extends ReferenciaMidiasState {}

class ReferenciaMidiasCarregado extends ReferenciaMidiasState {
  final List<ReferenciaMidia> midias;
  ReferenciaMidiasCarregado(this.midias);
}

class ReferenciaMidiasErro extends ReferenciaMidiasState {
  final String mensagem;
  ReferenciaMidiasErro(this.mensagem);
}

class ReferenciaMidiaAdicionada extends ReferenciaMidiasState {}

class ReferenciaMidiaRemovida extends ReferenciaMidiasState {}
