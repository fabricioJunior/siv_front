import 'dart:async';
import 'dart:math';

import 'package:autenticacao/domain/usecases/criar_token_de_autenticacao.dart';
import 'package:autenticacao/uses_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/injecoes.dart';

import '../../../domain/models/empresa.dart';
import '../../../domain/models/licenciado.dart';

part 'login_state.dart';
part 'login_event.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final CriarTokenDeAutenticacao _criarTokenDeAutenticacao;
  final RecuperarUsuarioDaSessao _recuperarUsuarioDaSessao;
  final RecuperarEmpresas _recuperarEmpresas;
  final RecuperarLicenciados _recuperarLicenciados;
  final SalvarLicenciadoDaSessao _salvarLicenciadoDaSessao;
  final ApiBaseUrlConfig _apiBaseUrlConfig;

  LoginBloc(
    this._criarTokenDeAutenticacao,
    this._recuperarUsuarioDaSessao,
    this._recuperarEmpresas,
    this._recuperarLicenciados,
    this._salvarLicenciadoDaSessao,
    this._apiBaseUrlConfig,
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
        LoginAutenticarFalha(
          state,
          erro: 'Não foi possível atualizar a lista de empresas.',
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
        LoginAutenticarFalha(
          state,
          erro:
              'Não foi possível carregar os licenciados. Verifique sua conexão e configuração do Firebase.',
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
    if (state.licenciadoSelecionado == null) {
      emit(
        LoginAutenticarFalha(
          state,
          erro: 'Selecione o licenciado para continuar',
        ),
      );
      return;
    }

    try {
      _apiBaseUrlConfig.atualizar(
        state.licenciadoSelecionado!.urlApi,
      );

      emit(LoginAutenticarEmProgresso(state, idEmpresa: event.empresa?.id));
      var token = await _criarTokenDeAutenticacao(
        usuario: state.usuario ?? '',
        senha: state.senha ?? '',
        empresa: event.empresa,
      );

      await _recuperarUsuarioDaSessao.call();
      if (token == null) {
        emit(LoginAutenticarFalha(state, erro: 'Usuário ou senha incorretos'));
        return;
      }

      await _salvarLicenciadoDaSessao.call(
        state.licenciadoSelecionado!,
      );

      List<Empresa> empresas =
          state.empresas ?? await _recuperarEmpresas.call();

      emit(
        LoginAutenticarSucesso(state,
            empresas: empresas, idEmpresa: event.empresa?.id),
      );
    } catch (e, s) {
      emit(
        LoginAutenticarFalha(
          state,
          erro:
              'Falha na autenticação, verifique sua conexão, caso o problema continue entre em contato com o suporte',
        ),
      );
      addError(e, s);
    }
  }
}
