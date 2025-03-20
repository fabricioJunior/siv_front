import 'package:autenticacao/domain/models/token.dart';
import 'package:autenticacao/domain/usecases/criar_token_de_autenticacao.dart';
import 'package:autenticacao/presentation/bloc/login_bloc/login_bloc.dart';
import 'package:core/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../doubles/fakes.dart';
import '../../doubles/uses_cases.mocks.dart';

final CriarTokenDeAutenticacao criarTokenDeAutenticacao =
    MockCriarTokenDeAutenticacao();

late LoginBloc loginBloc;
void main() {
  setUp(() {
    loginBloc = LoginBloc(criarTokenDeAutenticacao);
  });

  group('login bloc', () {
    var estadoInicial = const LoginInicial();
    var estadoSucessoAdicioanarUsuario =
        LoginAdicionarUsuarioSucesso(const LoginInicial(), usuario: 'usuario');
    var estadoSucessoAdicionarSenha = LoginAdicionarSenhaSucesso(
      estadoSucessoAdicioanarUsuario,
      senha: 'senha',
    );
    var estadoDeAutenticacaoEmProgresso =
        LoginAutenticarEmProgresso(estadoSucessoAdicionarSenha);
    var estadoDeSucessoNaAutenticao =
        LoginAutenticarSucesso(estadoDeAutenticacaoEmProgresso);

    var estadoDeFalhaNaAutenticacao = LoginAutenticarFalha(
      estadoDeAutenticacaoEmProgresso,
      erro: 'Usuário ou senha incorretos',
    );

    blocTest<LoginBloc, LoginState>(
      'armazena usuario informado pelo usuário',
      build: () => loginBloc,
      seed: () => estadoInicial,
      act: (bloc) {
        bloc.add(LoginAdicionouUsuario(usuario: 'usuario'));
      },
      expect: () => [estadoSucessoAdicioanarUsuario],
    );
    blocTest<LoginBloc, LoginState>(
      'armazena senha informado pelo usuário',
      build: () => loginBloc,
      seed: () => estadoSucessoAdicioanarUsuario,
      act: (bloc) {
        bloc.add(LoginAdicionouSenha(senha: 'senha'));
      },
      expect: () => [estadoSucessoAdicionarSenha],
    );

    blocTest<LoginBloc, LoginState>(
      'emite estado de sucesso após criar token de autenticacao para aplicação',
      build: () => loginBloc,
      seed: () => estadoSucessoAdicionarSenha,
      setUp: () {
        var token = fakeToken();
        _setupCriarTokenDeAutenticacao('usuario', 'senha', token);
      },
      act: (bloc) {
        bloc.add(LoginAutenticou());
      },
      expect: () => [
        estadoDeAutenticacaoEmProgresso,
        estadoDeSucessoNaAutenticao,
      ],
    );
    blocTest<LoginBloc, LoginState>(
      'emite estado de falha após criação de token retorna nulo',
      build: () => loginBloc,
      seed: () => estadoSucessoAdicionarSenha,
      setUp: () {
        _setupCriarTokenDeAutenticacao('usuario', 'senha', null);
      },
      act: (bloc) {
        bloc.add(LoginAutenticou());
      },
      expect: () => [
        estadoDeAutenticacaoEmProgresso,
        estadoDeFalhaNaAutenticacao,
      ],
    );
    blocTest<LoginBloc, LoginState>(
      'emite estado de falha após erro desconhecido na criação do token',
      build: () => loginBloc,
      seed: () => estadoSucessoAdicionarSenha,
      setUp: () {
        _setupFalhaCriarTokenDeAutenticacao('usuario', 'senha');
      },
      act: (bloc) {
        bloc.add(LoginAutenticou());
      },
      expect: () => [
        estadoDeAutenticacaoEmProgresso,
        estadoDeFalhaNaAutenticacao,
      ],
    );
  });
}

void _setupCriarTokenDeAutenticacao(
  String usuario,
  String senha,
  Token? response,
) {
  when(criarTokenDeAutenticacao.call(usuario: usuario, senha: senha))
      .thenAnswer((_) async => response);
}

void _setupFalhaCriarTokenDeAutenticacao(
  String usuario,
  String senha,
) {
  when(criarTokenDeAutenticacao.call(usuario: usuario, senha: senha))
      .thenThrow((_) async => Exception('erro desconhecido'));
}
