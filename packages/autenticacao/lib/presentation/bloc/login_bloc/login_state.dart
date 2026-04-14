part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  final String? usuario;
  final String? senha;
  final int? idEmpresa;
  final List<Empresa>? empresas;
  final List<Licenciado>? licenciados;
  final Licenciado? licenciadoSelecionado;
  final Usuario? usuarioDaSessao;

  const LoginState({
    this.usuario,
    this.senha,
    this.idEmpresa,
    this.empresas,
    this.licenciados,
    this.licenciadoSelecionado,
    this.usuarioDaSessao,
  });

  LoginState.fromLastState(
    LoginState lastState, {
    String? usuario,
    String? senha,
    int? idEmpresa,
    List<Empresa>? empresas,
    List<Licenciado>? licenciados,
    Licenciado? licenciadoSelecionado,
    Usuario? usuarioDaSessao,
  })  : usuario = usuario ?? lastState.usuario,
        senha = senha ?? lastState.senha,
        idEmpresa = idEmpresa ?? lastState.idEmpresa,
        empresas = empresas ?? lastState.empresas,
        licenciados = licenciados ?? lastState.licenciados,
        licenciadoSelecionado =
            licenciadoSelecionado ?? lastState.licenciadoSelecionado,
        usuarioDaSessao = usuarioDaSessao ?? lastState.usuarioDaSessao;

  @override
  List<Object?> get props => [
        usuario,
        senha,
        idEmpresa,
        empresas,
        licenciados,
        licenciadoSelecionado,
        usuarioDaSessao,
      ];
}

class LoginInicial extends LoginState {
  const LoginInicial({super.usuario, super.senha});
}

class LoginAdicionarUsuarioSucesso extends LoginState {
  LoginAdicionarUsuarioSucesso(super.lastState, {required super.usuario})
      : super.fromLastState();
}

class LoginAdicionarSenhaSucesso extends LoginState {
  LoginAdicionarSenhaSucesso(super.lastState, {required super.senha})
      : super.fromLastState();
}

class LoginAutenticarEmProgresso extends LoginState {
  LoginAutenticarEmProgresso(
    super.fromLastState, {
    super.idEmpresa,
  }) : super.fromLastState();
}

class LoginAutenticarSucesso extends LoginState {
  LoginAutenticarSucesso(
    super.lastState, {
    required super.empresas,
    required super.idEmpresa,
    required super.usuarioDaSessao,
  }) : super.fromLastState();
}

class LoginAutenticarFalha extends LoginState {
  final String erro;
  final LoginErroTipo tipo;

  LoginAutenticarFalha(
    super.lastState, {
    required this.erro,
    this.tipo = LoginErroTipo.desconhecido,
  }) : super.fromLastState();

  @override
  List<Object?> get props => [...super.props, erro, tipo];
}

class LoginCarregarLicenciadosEmProgresso extends LoginState {
  LoginCarregarLicenciadosEmProgresso(super.lastState) : super.fromLastState();
}

class LoginCarregarLicenciadosSucesso extends LoginState {
  LoginCarregarLicenciadosSucesso(
    super.lastState, {
    required super.licenciados,
  }) : super.fromLastState();
}

class LoginCarregarEmpresasEmProgresso extends LoginState {
  LoginCarregarEmpresasEmProgresso(super.lastState) : super.fromLastState();
}

class LoginCarregarEmpresasSucesso extends LoginState {
  LoginCarregarEmpresasSucesso(
    super.lastState, {
    required super.empresas,
  }) : super.fromLastState();
}

class LoginSelecionarLicenciadoSucesso extends LoginState {
  LoginSelecionarLicenciadoSucesso(
    super.lastState, {
    required super.licenciadoSelecionado,
  }) : super.fromLastState();
}

enum LoginErroTipo {
  validacao,
  credenciaisInvalidas,
  acessoNegado,
  semConexao,
  tempoEsgotado,
  servidorIndisponivel,
  carregamentoLicenciados,
  carregamentoEmpresas,
  configuracaoInvalida,
  desconhecido,
}
