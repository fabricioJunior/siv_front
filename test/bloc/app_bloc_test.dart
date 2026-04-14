import 'package:autenticacao/uses_cases.dart';
import 'package:autenticacao/models.dart';
import 'package:core/bloc_test.dart';
import 'package:core/injecoes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:siv_front/presentation/bloc/app_bloc/app_bloc.dart';

import '../doubles/doubles.dart';
import '../doubles/use_cases.mocks.dart';

final OnAutenticado onAutenticado = MockOnAutenticado();
final OnDesautenticado onDesautenticado = MockOnDesautenticado();
final EstaAutenticado estaAutenticado = MockEstaAutenticado();
final Deslogar deslogar = MockDeslogar();
final RecuperarUsuarioDaSessao recuperarUsuarioDaSessao =
    MockRecuperarUsuarioDaSessao();
final RecuperarLicenciadoDaSessao recuperarLicenciadoDaSessao =
    FakeRecuperarLicenciadoDaSessao();
final ApiBaseUrlConfig apiBaseUrlConfig = MockApiBaseUrlConfig();
final RecuperarEmpresaDaSessao recuperarEmpresaDaSessao =
    MockRecuperarEmpresaDaSessao();
final RecuperarTerminalDaSessao recuperarTerminalDaSessao =
    FakeRecuperarTerminalDaSessao();
final RecuperarTerminaisDoUsuarioPorEmpresa
recuperarTerminaisDoUsuarioPorEmpresa =
    FakeRecuperarTerminaisDoUsuarioPorEmpresa();
final SalvarTerminalDaSessao salvarTerminalDaSessao =
    FakeSalvarTerminalDaSessao();

final SincronizarPermissoesDoUsuario sincronizarPermissoesDoUsuario =
    MockSincronizarPermissoesDoUsuario();

var licenciado = const Licenciado(
  id: '1',
  nome: 'Licenciado teste',
  urlApi: 'https://api.teste.com',
);

class FakeRecuperarLicenciadoDaSessao implements RecuperarLicenciadoDaSessao {
  @override
  Future<Licenciado?> call() async => licenciado;
}

class MockApiBaseUrlConfig extends Mock implements ApiBaseUrlConfig {}

class FakeRecuperarTerminalDaSessao implements RecuperarTerminalDaSessao {
  @override
  Future<TerminalDoUsuario?> call() async => null;
}

class FakeRecuperarTerminaisDoUsuarioPorEmpresa
    implements RecuperarTerminaisDoUsuarioPorEmpresa {
  @override
  Future<List<TerminalDoUsuario>> call({
    required int idUsuario,
    required int idEmpresa,
  }) async => const [];
}

class FakeSalvarTerminalDaSessao implements SalvarTerminalDaSessao {
  @override
  Future<void> call(TerminalDoUsuario terminal) async {}
}

late AppBloc appBloc;

var usuario = fakeUsuario();
void main() {
  setUp(() {
    _setupRecuperarUsuarioDaSessao(usuario);
    _setupOnDesautenticado();
    _setupRecuperarEmpresaDaSessao();
    _setupSincronizarPermissoes();
  });
  blocTest(
    'emite estado com informações salvas de autenticacao',
    setUp: () {
      _setupOnTokenCriado(null);
      _setupEstaAutenticado(true);
    },
    build: () {
      return AppBloc(
        estaAutenticado,
        onAutenticado,
        deslogar,
        recuperarUsuarioDaSessao,
        onDesautenticado,
        recuperarLicenciadoDaSessao,
        recuperarEmpresaDaSessao,
        recuperarTerminalDaSessao,
        recuperarTerminaisDoUsuarioPorEmpresa,
        salvarTerminalDaSessao,
        sincronizarPermissoesDoUsuario,
        apiBaseUrlConfig,
      );
    },
    act: (bloc) => bloc.add(AppIniciou()),
    expect: () => [
      const AppState(statusAutenticacao: StatusAutenticacao.carregandoDados),
      AppState(
        statusAutenticacao: StatusAutenticacao.autenticado,
        usuarioDaSessao: usuario,
      ),
    ],
  );
  blocTest(
    'emite estado status de autenticado quando recebe evento de autenticado com informações da sessão',
    setUp: () {
      _setupOnTokenCriado(
        Token(
          jwtToken: '',
          dataDeCriacao: DateTime.now(),
          dataDeExpiracao: DateTime.now(),
        ),
      );
    },
    build: () {
      return AppBloc(
        estaAutenticado,
        onAutenticado,
        deslogar,
        recuperarUsuarioDaSessao,
        onDesautenticado,
        recuperarLicenciadoDaSessao,
        recuperarEmpresaDaSessao,
        recuperarTerminalDaSessao,
        recuperarTerminaisDoUsuarioPorEmpresa,
        salvarTerminalDaSessao,
        sincronizarPermissoesDoUsuario,
        apiBaseUrlConfig,
      );
    },
    expect: () => [
      AppState(
        statusAutenticacao: StatusAutenticacao.autenticando,
        usuarioDaSessao: usuario,
      ),
    ],
  );
  blocTest(
    'emite estado status de desautenticado quando recebe evento de desautenticacao',
    setUp: () {
      _setupOnTokenCriado(null);
    },
    act: (bloc) {
      bloc.add(AppDesautenticou());
    },
    build: () {
      return AppBloc(
        estaAutenticado,
        onAutenticado,
        deslogar,
        recuperarUsuarioDaSessao,
        onDesautenticado,
        recuperarLicenciadoDaSessao,
        recuperarEmpresaDaSessao,
        recuperarTerminalDaSessao,
        recuperarTerminaisDoUsuarioPorEmpresa,
        salvarTerminalDaSessao,
        sincronizarPermissoesDoUsuario,
        apiBaseUrlConfig,
      );
    },
    expect: () => [
      const AppState(statusAutenticacao: StatusAutenticacao.naoAutenticao),
    ],
  );
}

void _setupOnTokenCriado(Token? token) {
  if (token == null) {
    when(onAutenticado.call()).thenAnswer((_) => Stream.fromIterable([]));
  } else {
    when(onAutenticado.call()).thenAnswer((_) => Stream.value(token));
  }
}

void _setupOnDesautenticado() {
  when(onDesautenticado.call()).thenAnswer((_) => Stream.fromIterable([]));
}

void _setupEstaAutenticado(bool autenticacao) {
  when(estaAutenticado.call()).thenAnswer((_) async => autenticacao);
}

void _setupRecuperarUsuarioDaSessao(Usuario usuario) {
  when(recuperarUsuarioDaSessao.call()).thenAnswer((_) async => usuario);
}

void _setupRecuperarEmpresaDaSessao() {
  when(recuperarEmpresaDaSessao.call()).thenAnswer((_) async => null);
}

void _setupSincronizarPermissoes() {
  when(
    sincronizarPermissoesDoUsuario.call(idUsuario: usuario.id),
  ).thenAnswer((_) async => <PermissaoDoUsuario>[]);
}
