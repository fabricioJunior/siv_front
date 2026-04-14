import 'package:autenticacao/domain/usecases/criar_token_de_autenticacao.dart';
import 'package:autenticacao/models.dart';
import 'package:autenticacao/presentation/bloc/login_bloc/login_bloc.dart';
import 'package:autenticacao/uses_cases.dart';
import 'package:core/bloc_test.dart';
import 'package:core/injecoes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../doubles/fakes.dart';
import '../../doubles/uses_cases.mocks.dart';

final CriarTokenDeAutenticacao criarTokenDeAutenticacao =
    MockCriarTokenDeAutenticacao();
final RecuperarUsuarioDaSessao recuperarUsuarioDaSessao =
    MockRecuperarUsuarioDaSessao();
final RecuperarEmpresas recuperarEmpresas = MockRecuperarEmpresas();
final RecuperarLicenciados recuperarLicenciados = MockRecuperarLicenciados();
final SalvarLicenciadoDaSessao salvarLicenciadoDaSessao =
    MockSalvarLicenciadoDaSessao();
final SalvarTerminalDaSessao salvarTerminalDaSessao =
    MockSalvarTerminalDaSessao();
final LimparTerminalDaSessao limparTerminalDaSessao =
    MockLimparTerminalDaSessao();
final ApiBaseUrlConfig apiBaseUrlConfig = MockApiBaseUrlConfig();
final RecuperarTerminaisDoUsuarioPorEmpresa
    recuperarTerminaisDoUsuarioPorEmpresa =
    FakeRecuperarTerminaisDoUsuarioPorEmpresa();
late LoginBloc loginBloc;

class MockRecuperarLicenciados extends Mock implements RecuperarLicenciados {}

class MockSalvarLicenciadoDaSessao extends Mock
    implements SalvarLicenciadoDaSessao {
  @override
  Future<void> call(Licenciado licenciado) async {}
}

class MockApiBaseUrlConfig extends Mock implements ApiBaseUrlConfig {}

class MockSalvarTerminalDaSessao extends Mock
    implements SalvarTerminalDaSessao {
  @override
  Future<void> call(TerminalDoUsuario terminal) async {}
}

class MockLimparTerminalDaSessao extends Mock
    implements LimparTerminalDaSessao {
  @override
  Future<void> call() async {}
}

class FakeRecuperarTerminaisDoUsuarioPorEmpresa
    implements RecuperarTerminaisDoUsuarioPorEmpresa {
  @override
  Future<List<TerminalDoUsuario>> call({
    required int idUsuario,
    required int idEmpresa,
  }) async =>
      const [];
}

void main() {
  setUp(() {
    loginBloc = LoginBloc(
      criarTokenDeAutenticacao,
      recuperarUsuarioDaSessao,
      recuperarEmpresas,
      recuperarLicenciados,
      salvarLicenciadoDaSessao,
      salvarTerminalDaSessao,
      limparTerminalDaSessao,
      apiBaseUrlConfig,
      recuperarTerminaisDoUsuarioPorEmpresa,
    );
    var usuario = fakeUsuario();
    _setupRecuperarUsuarioDaSessao(usuario);
    _setupRecuperarEmpresas();
  });

  group('login bloc', () {
    var estadoInicial = const LoginInicial();
    var estadoSucessoAdicioanarUsuario =
        LoginAdicionarUsuarioSucesso(const LoginInicial(), usuario: 'usuario');
    var estadoSucessoAdicionarSenha = LoginAdicionarSenhaSucesso(
      estadoSucessoAdicioanarUsuario,
      senha: 'senha',
    );
    var estadoComLicenciadoSelecionado = LoginSelecionarLicenciadoSucesso(
      estadoSucessoAdicionarSenha,
      licenciadoSelecionado: const Licenciado(
        id: '1',
        nome: 'Licenciado Teste',
        urlApi: 'https://api.licenciado.com',
      ),
    );
    var estadoDeAutenticacaoEmProgresso =
        LoginAutenticarEmProgresso(estadoComLicenciadoSelecionado);

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
      seed: () => estadoComLicenciadoSelecionado,
      setUp: () {
        var token = fakeToken();
        _setupCriarTokenDeAutenticacao('usuario', 'senha', token);
      },
      act: (bloc) {
        bloc.add(LoginAutenticou());
      },
      expect: () => [
        estadoDeAutenticacaoEmProgresso,
        isA<LoginAutenticarSucesso>(),
      ],
    );
    blocTest<LoginBloc, LoginState>(
      'emite estado de falha após criação de token retorna nulo',
      build: () => loginBloc,
      seed: () => estadoComLicenciadoSelecionado,
      setUp: () {
        _setupCriarTokenDeAutenticacao('usuario', 'senha', null);
      },
      act: (bloc) {
        bloc.add(LoginAutenticou());
      },
      expect: () => [
        estadoDeAutenticacaoEmProgresso,
        isA<LoginAutenticarFalha>()
            .having((s) => s.tipo, 'tipo', LoginErroTipo.credenciaisInvalidas)
            .having(
              (s) => s.erro,
              'erro',
              'Usuário ou senha incorretos. Revise os dados e tente novamente.',
            ),
      ],
    );
    blocTest<LoginBloc, LoginState>(
      'emite estado de falha após erro desconhecido na criação do token',
      build: () => loginBloc,
      seed: () => estadoComLicenciadoSelecionado,
      setUp: () {
        _setupFalhaCriarTokenDeAutenticacao('usuario', 'senha');
      },
      act: (bloc) {
        bloc.add(LoginAutenticou());
      },
      expect: () => [
        estadoDeAutenticacaoEmProgresso,
        isA<LoginAutenticarFalha>()
            .having((s) => s.tipo, 'tipo', LoginErroTipo.desconhecido)
            .having(
              (s) => s.erro,
              'erro',
              'Falha na autenticação. Se o problema persistir, entre em contato com o suporte.',
            ),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'emite estado de falha quando tenta autenticar sem licenciado selecionado',
      build: () => loginBloc,
      seed: () => estadoSucessoAdicionarSenha,
      act: (bloc) {
        bloc.add(LoginAutenticou());
      },
      expect: () => [
        isA<LoginAutenticarFalha>()
            .having((s) => s.tipo, 'tipo', LoginErroTipo.validacao)
            .having(
              (s) => s.erro,
              'erro',
              'Selecione o licenciado para continuar.',
            ),
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
      .thenThrow(Exception('erro desconhecido'));
}

void _setupRecuperarUsuarioDaSessao(Usuario usuario) {
  when(recuperarUsuarioDaSessao.call()).thenAnswer((_) async => usuario);
}

void _setupRecuperarEmpresas() {
  when(recuperarEmpresas.call()).thenAnswer((_) async => []);
}
