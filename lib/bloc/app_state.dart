part of 'app_bloc.dart';

class AppState extends Equatable {
  final StatusAutenticacao statusAutenticacao;
  final Usuario? usuarioDaSessao;
  final Empresa? empresaDaSessao;

  const AppState({
    this.statusAutenticacao = StatusAutenticacao.naoAutenticao,
    this.usuarioDaSessao,
    this.empresaDaSessao,
  });

  AppState copyWith({
    StatusAutenticacao? statusAutenticacao,
    Usuario? usuarioDaSessao,
    Empresa? empresaDaSessao,
  }) =>
      AppState(
        statusAutenticacao: statusAutenticacao ?? this.statusAutenticacao,
        usuarioDaSessao: usuarioDaSessao ?? this.usuarioDaSessao,
        empresaDaSessao: empresaDaSessao ?? this.empresaDaSessao,
      );

  @override
  List<Object?> get props => [
        statusAutenticacao,
        usuarioDaSessao,
        empresaDaSessao,
      ];
}

enum StatusAutenticacao {
  autenticado,
  autenticando,
  naoAutenticao,
}
