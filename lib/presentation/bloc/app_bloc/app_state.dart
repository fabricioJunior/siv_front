part of 'app_bloc.dart';

class AppState extends Equatable {
  final StatusAutenticacao statusAutenticacao;
  final Usuario? usuarioDaSessao;
  final Empresa? empresaDaSessao;
  final List<TerminalDoUsuario> terminaisDaEmpresaDaSessao;
  final TerminalDoUsuario? terminalDaSessao;
  final int? caixaIdDaSessao;
  final Licenciado? licenciadoDaSessao;
  final Map<String, PermissaoDoUsuario> permissoesDoUsuario;
  final String? mensagemErroInicializacao;
  final String? detalhesErroInicializacao;
  final String? etapaAtualInicializacao;
  final List<String> etapasInicializacaoConcluidas;
  const AppState({
    this.statusAutenticacao = StatusAutenticacao.naoAutenticao,
    this.usuarioDaSessao,
    this.empresaDaSessao,
    this.terminaisDaEmpresaDaSessao = const [],
    this.terminalDaSessao,
    this.caixaIdDaSessao,
    this.licenciadoDaSessao,
    this.permissoesDoUsuario = const {},
    this.mensagemErroInicializacao,
    this.detalhesErroInicializacao,
    this.etapaAtualInicializacao,
    this.etapasInicializacaoConcluidas = const [],
  });

  AppState copyWith({
    StatusAutenticacao? statusAutenticacao,
    Usuario? Function()? usuarioDaSessao,
    Empresa? Function()? empresaDaSessao,
    List<TerminalDoUsuario>? terminaisDaEmpresaDaSessao,
    TerminalDoUsuario? Function()? terminalDaSessao,
    int? Function()? caixaIdDaSessao,
    Licenciado? Function()? licenciadoDaSessao,
    Map<String, PermissaoDoUsuario>? permissoesDoUsuario,
    Object? mensagemErroInicializacao = _sentinelaAppState,
    Object? detalhesErroInicializacao = _sentinelaAppState,
    Object? etapaAtualInicializacao = _sentinelaAppState,
    List<String>? etapasInicializacaoConcluidas,
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
    caixaIdDaSessao: caixaIdDaSessao != null
        ? caixaIdDaSessao()
        : this.caixaIdDaSessao,
    licenciadoDaSessao: licenciadoDaSessao != null
        ? licenciadoDaSessao()
        : this.licenciadoDaSessao,
    permissoesDoUsuario: permissoesDoUsuario ?? this.permissoesDoUsuario,
    mensagemErroInicializacao:
        identical(mensagemErroInicializacao, _sentinelaAppState)
        ? this.mensagemErroInicializacao
        : mensagemErroInicializacao as String?,
    detalhesErroInicializacao:
        identical(detalhesErroInicializacao, _sentinelaAppState)
        ? this.detalhesErroInicializacao
        : detalhesErroInicializacao as String?,
    etapaAtualInicializacao:
        identical(etapaAtualInicializacao, _sentinelaAppState)
        ? this.etapaAtualInicializacao
        : etapaAtualInicializacao as String?,
    etapasInicializacaoConcluidas:
        etapasInicializacaoConcluidas ?? this.etapasInicializacaoConcluidas,
  );

  @override
  List<Object?> get props => [
    statusAutenticacao,
    usuarioDaSessao,
    empresaDaSessao,
    terminaisDaEmpresaDaSessao,
    terminalDaSessao,
    caixaIdDaSessao,
    permissoesDoUsuario,
    mensagemErroInicializacao,
    detalhesErroInicializacao,
    etapaAtualInicializacao,
    etapasInicializacaoConcluidas,
  ];
}

const Object _sentinelaAppState = Object();

enum StatusAutenticacao {
  autenticado,
  autenticando,
  naoAutenticao,
  carregandoDados,
  falhaInicializacao,
}
