part of 'app_bloc.dart';

class AppState extends Equatable {
  final StatusAutenticacao statusAutenticacao;
  final Usuario? usuarioDaSessao;
  final Empresa? empresaDaSessao;
  final List<TerminalDoUsuario> terminaisDaEmpresaDaSessao;
  final TerminalDoUsuario? terminalDaSessao;
  final Licenciado? licenciadoDaSessao;
  final Map<String, PermissaoDoUsuario> permissoesDoUsuario;
  const AppState({
    this.statusAutenticacao = StatusAutenticacao.naoAutenticao,
    this.usuarioDaSessao,
    this.empresaDaSessao,
    this.terminaisDaEmpresaDaSessao = const [],
    this.terminalDaSessao,
    this.licenciadoDaSessao,
    this.permissoesDoUsuario = const {},
  });

  AppState copyWith({
    StatusAutenticacao? statusAutenticacao,
    Usuario? Function()? usuarioDaSessao,
    Empresa? Function()? empresaDaSessao,
    List<TerminalDoUsuario>? terminaisDaEmpresaDaSessao,
    TerminalDoUsuario? Function()? terminalDaSessao,
    Licenciado? Function()? licenciadoDaSessao,
    Map<String, PermissaoDoUsuario>? permissoesDoUsuario,
  }) => AppState(
    statusAutenticacao: statusAutenticacao ?? this.statusAutenticacao,
    usuarioDaSessao: usuarioDaSessao != null
        ? usuarioDaSessao()
        : this.usuarioDaSessao,
    empresaDaSessao: empresaDaSessao != null
        ? empresaDaSessao()
        : this.empresaDaSessao,
    terminaisDaEmpresaDaSessao:
        terminaisDaEmpresaDaSessao ?? this.terminaisDaEmpresaDaSessao,
    terminalDaSessao: terminalDaSessao != null
        ? terminalDaSessao()
        : this.terminalDaSessao,
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
    terminaisDaEmpresaDaSessao,
    terminalDaSessao,
    permissoesDoUsuario,
  ];
}

enum StatusAutenticacao {
  autenticado,
  autenticando,
  naoAutenticao,
  carregandoDados,
}
