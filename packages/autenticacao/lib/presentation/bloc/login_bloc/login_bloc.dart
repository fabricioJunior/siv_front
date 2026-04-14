import 'dart:async';
import 'dart:io' show SocketException;

import 'package:autenticacao/domain/usecases/criar_token_de_autenticacao.dart';
import 'package:autenticacao/uses_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/injecoes.dart';
import 'package:core/remote_data_sourcers.dart' show HttpException;

import '../../../domain/models/empresa.dart';
import '../../../domain/models/licenciado.dart';
import '../../../domain/models/terminal_do_usuario.dart';
import '../../../domain/models/usuario.dart';

part 'login_state.dart';
part 'login_event.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final CriarTokenDeAutenticacao _criarTokenDeAutenticacao;
  final RecuperarUsuarioDaSessao _recuperarUsuarioDaSessao;
  final RecuperarEmpresas _recuperarEmpresas;
  final RecuperarLicenciados _recuperarLicenciados;
  final SalvarLicenciadoDaSessao _salvarLicenciadoDaSessao;
  final SalvarTerminalDaSessao _salvarTerminalDaSessao;
  final LimparTerminalDaSessao _limparTerminalDaSessao;
  final ApiBaseUrlConfig _apiBaseUrlConfig;
  final RecuperarTerminaisDoUsuarioPorEmpresa
      _recuperarTerminaisDoUsuarioPorEmpresa;

  LoginBloc(
    this._criarTokenDeAutenticacao,
    this._recuperarUsuarioDaSessao,
    this._recuperarEmpresas,
    this._recuperarLicenciados,
    this._salvarLicenciadoDaSessao,
    this._salvarTerminalDaSessao,
    this._limparTerminalDaSessao,
    this._apiBaseUrlConfig,
    this._recuperarTerminaisDoUsuarioPorEmpresa,
  ) : super(const LoginInicial()) {
    on<LoginCarregouLicenciados>(_onLoginCarregouLicenciados);
    on<LoginCarregouEmpresas>(_onLoginCarregouEmpresas);
    on<LoginSelecionouLicenciado>(_onLoginSelecionouLicenciado);
    on<LoginAdicionouUsuario>(_onUsuarioAdicionoUsuario);
    on<LoginAdicionouSenha>(_onLoginAdicionouSenha);
    on<LoginAutenticou>(_onLoginAutenticou);
  }

  FutureOr<void> _onLoginCarregouEmpresas(
    LoginCarregouEmpresas event,
    Emitter<LoginState> emit,
  ) async {
    try {
      emit(LoginCarregarEmpresasEmProgresso(state));
      final empresas = await _recuperarEmpresas.call();
      emit(LoginCarregarEmpresasSucesso(state, empresas: empresas));
    } catch (e, s) {
      emit(
        _criarEstadoDeFalha(
          e,
          currentState: state,
          fallbackType: LoginErroTipo.carregamentoEmpresas,
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onLoginCarregouLicenciados(
    LoginCarregouLicenciados event,
    Emitter<LoginState> emit,
  ) async {
    if ((state.licenciados?.isNotEmpty ?? false)) {
      return;
    }

    try {
      emit(LoginCarregarLicenciadosEmProgresso(state));
      final licenciados = await _recuperarLicenciados.call();

      emit(LoginCarregarLicenciadosSucesso(state, licenciados: licenciados));
    } catch (e, s) {
      emit(
        _criarEstadoDeFalha(
          e,
          currentState: state,
          fallbackType: LoginErroTipo.carregamentoLicenciados,
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onLoginSelecionouLicenciado(
    LoginSelecionouLicenciado event,
    Emitter<LoginState> emit,
  ) async {
    emit(
      LoginSelecionarLicenciadoSucesso(
        state,
        licenciadoSelecionado: event.licenciado,
      ),
    );
  }

  FutureOr<void> _onUsuarioAdicionoUsuario(
    LoginAdicionouUsuario event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginAdicionarUsuarioSucesso(state, usuario: event.usuario));
  }

  FutureOr<void> _onLoginAdicionouSenha(
    LoginAdicionouSenha event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginAdicionarSenhaSucesso(state, senha: event.senha));
  }

  FutureOr<void> _onLoginAutenticou(
    LoginAutenticou event,
    Emitter<LoginState> emit,
  ) async {
    final usuario = state.usuario?.trim() ?? '';
    final senha = state.senha ?? '';

    if (state.licenciadoSelecionado == null) {
      emit(
        LoginAutenticarFalha(
          state,
          tipo: LoginErroTipo.validacao,
          erro: 'Selecione o licenciado para continuar.',
        ),
      );
      return;
    }

    if (usuario.isEmpty) {
      emit(
        LoginAutenticarFalha(
          state,
          tipo: LoginErroTipo.validacao,
          erro: 'Informe o usuário para continuar.',
        ),
      );
      return;
    }

    if (senha.isEmpty) {
      emit(
        LoginAutenticarFalha(
          state,
          tipo: LoginErroTipo.validacao,
          erro: 'Informe a senha para continuar.',
        ),
      );
      return;
    }

    try {
      _apiBaseUrlConfig.atualizar(state.licenciadoSelecionado!.urlApi);

      emit(LoginAutenticarEmProgresso(state, idEmpresa: event.empresa?.id));
      final token = await _criarTokenDeAutenticacao(
        usuario: usuario,
        senha: senha,
        empresa: event.empresa,
      );

      final usuarioDaSessao = await _recuperarUsuarioDaSessao.call();
      if (token == null) {
        emit(
          LoginAutenticarFalha(
            state,
            tipo: LoginErroTipo.credenciaisInvalidas,
            erro:
                'Usuário ou senha incorretos. Revise os dados e tente novamente.',
          ),
        );
        return;
      }

      await _salvarLicenciadoDaSessao.call(state.licenciadoSelecionado!);
      if (event.terminal != null) {
        await _salvarTerminalDaSessao.call(event.terminal!);
      } else if (event.empresa != null) {
        await _limparTerminalDaSessao.call();
      }

      List<Empresa> empresas;
      try {
        empresas = state.empresas ?? await _recuperarEmpresas.call();
      } catch (e, s) {
        emit(
          _criarEstadoDeFalha(
            e,
            currentState: state,
            fallbackType: LoginErroTipo.carregamentoEmpresas,
          ),
        );
        addError(e, s);
        return;
      }

      emit(
        LoginAutenticarSucesso(
          state,
          empresas: empresas,
          idEmpresa: event.empresa?.id,
          usuarioDaSessao: usuarioDaSessao,
        ),
      );
    } catch (e, s) {
      emit(
        _criarEstadoDeFalha(
          e,
          currentState: state,
          fallbackType: LoginErroTipo.desconhecido,
          empresaSelecionada: event.empresa != null,
        ),
      );
      addError(e, s);
    }
  }

  LoginAutenticarFalha _criarEstadoDeFalha(
    Object error, {
    required LoginState currentState,
    required LoginErroTipo fallbackType,
    bool empresaSelecionada = false,
  }) {
    if (error is SocketException) {
      return LoginAutenticarFalha(
        currentState,
        tipo: LoginErroTipo.semConexao,
        erro:
            'Não foi possível conectar com o servidor. Verifique sua internet e tente novamente.',
      );
    }

    if (error is TimeoutException) {
      return LoginAutenticarFalha(
        currentState,
        tipo: LoginErroTipo.tempoEsgotado,
        erro:
            'O servidor demorou para responder. Aguarde alguns instantes e tente novamente.',
      );
    }

    if (error is HttpException) {
      switch (error.statusCode) {
        case 400:
          return LoginAutenticarFalha(
            currentState,
            tipo: fallbackType == LoginErroTipo.carregamentoLicenciados
                ? LoginErroTipo.configuracaoInvalida
                : fallbackType,
            erro: fallbackType == LoginErroTipo.carregamentoLicenciados
                ? 'Não foi possível carregar os licenciados. Verifique a configuração do ambiente.'
                : 'Os dados enviados são inválidos. Revise as informações e tente novamente.',
          );
        case 401:
          return LoginAutenticarFalha(
            currentState,
            tipo: LoginErroTipo.credenciaisInvalidas,
            erro: empresaSelecionada
                ? 'Seu usuário não possui acesso à empresa selecionada. Escolha outra empresa ou fale com o suporte.'
                : 'Usuário ou senha incorretos. Revise as credenciais e tente novamente.',
          );
        case 403:
          return LoginAutenticarFalha(
            currentState,
            tipo: LoginErroTipo.acessoNegado,
            erro: empresaSelecionada
                ? 'A empresa selecionada não liberou acesso para este usuário.'
                : 'Seu acesso foi negado. Verifique as permissões com o administrador.',
          );
        case 404:
          return LoginAutenticarFalha(
            currentState,
            tipo: LoginErroTipo.configuracaoInvalida,
            erro: fallbackType == LoginErroTipo.carregamentoLicenciados
                ? 'Não foi possível localizar os dados do licenciado. Verifique a configuração informada.'
                : 'O serviço de autenticação não foi encontrado para este licenciado.',
          );
        case 500:
        case 503:
          return LoginAutenticarFalha(
            currentState,
            tipo: LoginErroTipo.servidorIndisponivel,
            erro:
                'O serviço de autenticação está indisponível no momento. Tente novamente mais tarde.',
          );
      }
    }

    return LoginAutenticarFalha(
      currentState,
      tipo: fallbackType,
      erro: switch (fallbackType) {
        LoginErroTipo.carregamentoLicenciados =>
          'Falha ao carregar os licenciados. Tente novamente em instantes.',
        LoginErroTipo.carregamentoEmpresas =>
          'Login realizado, mas não foi possível atualizar a lista de empresas agora.',
        _ =>
          'Falha na autenticação. Se o problema persistir, entre em contato com o suporte.',
      },
    );
  }

  Future<List<TerminalDoUsuario>> buscarTerminaisParaEmpresa(
    int idEmpresa,
  ) async {
    final usuarioId = state.usuarioDaSessao?.id;
    if (usuarioId == null) return const [];
    try {
      return await _recuperarTerminaisDoUsuarioPorEmpresa.call(
        idUsuario: usuarioId,
        idEmpresa: idEmpresa,
      );
    } catch (_) {
      return const [];
    }
  }
}
