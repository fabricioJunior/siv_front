part of 'app_bloc.dart';

class AppState extends Equatable {
  final StatusAutenticacao statusAutenticacao;
  final Usuario? usuarioDaSessao;

  const AppState({
    this.statusAutenticacao = StatusAutenticacao.naoAutenticao,
    this.usuarioDaSessao,
  });

  AppState copyWith({
    StatusAutenticacao? statusAutenticacao,
    Usuario? usuarioDaSessao,
  }) =>
      AppState(
        statusAutenticacao: statusAutenticacao ?? this.statusAutenticacao,
        usuarioDaSessao: usuarioDaSessao ?? this.usuarioDaSessao,
      );

  @override
  List<Object?> get props => [
        statusAutenticacao,
      ];
}

enum StatusAutenticacao {
  autenticado,
  naoAutenticao,
}
