part of 'app_bloc.dart';

class AppState extends Equatable {
  final StatusAutenticacao statusAutenticacao;
  final Usuario? usuarioDaSessao;
  final Empresa? empresaDaSessao;
  final Licenciado? licenciadoDaSessao;
  final Map<String, PermissaoDoUsuario> permissoesDoUsuario;
  const AppState({
    this.statusAutenticacao = StatusAutenticacao.naoAutenticao,
    this.usuarioDaSessao,
    this.empresaDaSessao,
    this.licenciadoDaSessao,
    this.permissoesDoUsuario = const {},
  });

  AppState copyWith({
    StatusAutenticacao? statusAutenticacao,
    Usuario? Function()? usuarioDaSessao,
    Empresa? Function()? empresaDaSessao,
    Licenciado? Function()? licenciadoDaSessao,
    Map<String, PermissaoDoUsuario>? permissoesDoUsuario,
  }) =>
      AppState(
        statusAutenticacao: statusAutenticacao ?? this.statusAutenticacao,
        usuarioDaSessao:
            usuarioDaSessao != null ? usuarioDaSessao() : this.usuarioDaSessao,
        empresaDaSessao:
            empresaDaSessao != null ? empresaDaSessao() : this.empresaDaSessao,
        licenciadoDaSessao: licenciadoDaSessao != null
            ? licenciadoDaSessao()
            : this.licenciadoDaSessao,
        permissoesDoUsuario: permissoesDoUsuario ?? this.permissoesDoUsuario,
      );

  @override
  List<Object?> get props => [
        statusAutenticacao,
        usuarioDaSessao,
        empresaDaSessao,
        permissoesDoUsuario,
      ];
}

enum StatusAutenticacao {
  autenticado,
  autenticando,
  naoAutenticao,
}
