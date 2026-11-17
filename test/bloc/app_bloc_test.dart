import 'package:autenticacao/uses_cases.dart';
import 'package:autenticacao/models.dart';
import 'package:core/bloc_test.dart';
import 'package:core/injecoes.dart';
import 'package:financeiro/data.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/use_cases.dart';
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
final CriarTokenDeAutenticacao criarTokenDeAutenticacao =
  FakeCriarTokenDeAutenticacao();
final RecuperarCredenciaisDeAutenticacao recuperarCredenciaisDeAutenticacao =
  FakeRecuperarCredenciaisDeAutenticacao();
final RecuperarTerminalDaSessao recuperarTerminalDaSessao =
    FakeRecuperarTerminalDaSessao();
final RecuperarTerminaisDoUsuarioPorEmpresa
recuperarTerminaisDoUsuarioPorEmpresa =
    FakeRecuperarTerminaisDoUsuarioPorEmpresa();
final SalvarTerminalDaSessao salvarTerminalDaSessao =
    FakeSalvarTerminalDaSessao();
final LimparTerminalDaSessao limparTerminalDaSessao =
  FakeLimparTerminalDaSessao();

final SincronizarPermissoesDoUsuario sincronizarPermissoesDoUsuario =
    MockSincronizarPermissoesDoUsuario();
final RecuperarPermissoesDoUsuarioLocal recuperarPermissoesDoUsuarioLocal =
    MockRecuperarPermissoesDoUsuarioLocal();
final RecuperarCaixaAberto recuperarCaixaAberto = FakeRecuperarCaixaAberto();
final MockSyncDataBloc syncDataBloc = MockSyncDataBloc();

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

class FakeCriarTokenDeAutenticacao implements CriarTokenDeAutenticacao {
  @override
  Future<Token?> call({
    required String usuario,
    required String senha,
    Empresa? empresa,
  }) async {
    return Token(
      jwtToken: '',
      dataDeCriacao: DateTime.now(),
      dataDeExpiracao: DateTime.now(),
      idEmpresa: empresa?.id,
    );
  }
}

class FakeRecuperarCredenciaisDeAutenticacao
    implements RecuperarCredenciaisDeAutenticacao {
  @override
  Future<CredenciaisDeAutenticacao?> call() async =>
      const CredenciaisDeAutenticacao(usuario: 'user', senha: 'pass');
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

class FakeLimparTerminalDaSessao implements LimparTerminalDaSessao {
  @override
  Future<void> call() async {}
}

class FakeRecuperarCaixaAberto implements RecuperarCaixaAberto {
  @override
  ICaixaRepository get repository => throw UnimplementedError();

  @override
  Future<Caixa?> call({required int idEmpresa, required int idTerminal}) async {
    return null;
  }
}

class FakePermissao extends PermissaoDoUsuario {
  FakePermissao(this.componenteId);
  @override
  final String componenteId;
  @override
  int get id => 1;
  @override
  int get empresaId => 1;
  @override
  int get grupoId => 1;
  @override
  String get grupoNome => 'g';
  @override
  String get componenteNome => 'n';
  @override
  int get descontinuado => 0;
}

late AppBloc appBloc;

var usuario = fakeUsuario();
void main() {
  setUp(() {
    _setupRecuperarUsuarioDaSessao(usuario);
    _setupOnDesautenticado();
    _setupRecuperarEmpresaDaSessao();
    _setupSincronizarPermissoes();
    _setupRecuperarPermissoesDoUsuarioLocal();
    _setupSyncDataBloc();
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
        criarTokenDeAutenticacao,
        recuperarCredenciaisDeAutenticacao,
        recuperarTerminalDaSessao,
        recuperarTerminaisDoUsuarioPorEmpresa,
        salvarTerminalDaSessao,
        limparTerminalDaSessao,
        sincronizarPermissoesDoUsuario,
        recuperarPermissoesDoUsuarioLocal,
        recuperarCaixaAberto,
        syncDataBloc,
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
        criarTokenDeAutenticacao,
        recuperarCredenciaisDeAutenticacao,
        recuperarTerminalDaSessao,
        recuperarTerminaisDoUsuarioPorEmpresa,
        salvarTerminalDaSessao,
        limparTerminalDaSessao,
        sincronizarPermissoesDoUsuario,
        recuperarPermissoesDoUsuarioLocal,
        recuperarCaixaAberto,
        syncDataBloc,
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
        criarTokenDeAutenticacao,
        recuperarCredenciaisDeAutenticacao,
        recuperarTerminalDaSessao,
        recuperarTerminaisDoUsuarioPorEmpresa,
        salvarTerminalDaSessao,
        limparTerminalDaSessao,
        sincronizarPermissoesDoUsuario,
        recuperarPermissoesDoUsuarioLocal,
        recuperarCaixaAberto,
        syncDataBloc,
        apiBaseUrlConfig,
      );
    },
    expect: () => [
      const AppState(statusAutenticacao: StatusAutenticacao.naoAutenticao),
    ],
  );

  group('permissoes da sessao', () {
    final perm = FakePermissao('A');

    Future<AppBloc> iniciar(List<PermissaoDoUsuario> locais) async {
      _setupOnTokenCriado(null);
      _setupEstaAutenticado(true);
      when(recuperarPermissoesDoUsuarioLocal.call())
          .thenAnswer((_) async => locais);
      final bloc = _novoBloc();
      bloc.add(AppIniciou());
      await bloc.stream
          .firstWhere((s) => s.statusAutenticacao == StatusAutenticacao.autenticado);
      return bloc;
    }

    test('resposta vazia com permissoes atuais mantem o estado (ix)', () async {
      final bloc = await iniciar([perm]);
      when(sincronizarPermissoesDoUsuario.call(idUsuario: usuario.id))
          .thenAnswer((_) async => <PermissaoDoUsuario>[]);
      clearInteractions(sincronizarPermissoesDoUsuario);

      bloc.add(AppSincronizacaoDeDadosConcluida());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.permissoesDoUsuario.keys, ['A']);
      // tentou de novo antes de desistir
      verify(sincronizarPermissoesDoUsuario.call(idUsuario: usuario.id))
          .called(2);
      await bloc.close();
    });

    test('resposta vazia com estado vazio e aceita (x)', () async {
      final bloc = await iniciar([]);
      when(sincronizarPermissoesDoUsuario.call(idUsuario: usuario.id))
          .thenAnswer((_) async => <PermissaoDoUsuario>[]);
      clearInteractions(sincronizarPermissoesDoUsuario);

      bloc.add(AppSincronizacaoDeDadosConcluida());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.permissoesDoUsuario, isEmpty);
      verify(sincronizarPermissoesDoUsuario.call(idUsuario: usuario.id))
          .called(1);
      await bloc.close();
    });

    test('syncs concorrentes rodam em fila e nunca esvaziam o estado (viii)',
        () async {
      final bloc = await iniciar([perm]);
      var emVoo = 0;
      var maxEmVoo = 0;
      when(sincronizarPermissoesDoUsuario.call(idUsuario: usuario.id))
          .thenAnswer((_) async {
        maxEmVoo = ++emVoo > maxEmVoo ? emVoo : maxEmVoo;
        await Future<void>.delayed(const Duration(milliseconds: 20));
        emVoo--;
        return [perm];
      });
      final estados = <AppState>[];
      final sub = bloc.stream.listen(estados.add);

      bloc.add(AppSincronizacaoDeDadosConcluida());
      bloc.add(AppSincronizacaoDeDadosConcluida());
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(maxEmVoo, 1);
      expect(estados.every((s) => s.permissoesDoUsuario.isNotEmpty), isTrue);
      await sub.cancel();
      await bloc.close();
    });
  });
}

AppBloc _novoBloc() => AppBloc(
      estaAutenticado,
      onAutenticado,
      deslogar,
      recuperarUsuarioDaSessao,
      onDesautenticado,
      recuperarLicenciadoDaSessao,
      recuperarEmpresaDaSessao,
      criarTokenDeAutenticacao,
      recuperarCredenciaisDeAutenticacao,
      recuperarTerminalDaSessao,
      recuperarTerminaisDoUsuarioPorEmpresa,
      salvarTerminalDaSessao,
      limparTerminalDaSessao,
      sincronizarPermissoesDoUsuario,
      recuperarPermissoesDoUsuarioLocal,
      recuperarCaixaAberto,
      syncDataBloc,
      apiBaseUrlConfig,
    );

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

void _setupRecuperarPermissoesDoUsuarioLocal() {
  when(
    recuperarPermissoesDoUsuarioLocal.call(),
  ).thenAnswer((_) async => <PermissaoDoUsuario>[]);
}

void _setupSyncDataBloc() {
  when(syncDataBloc.stream).thenAnswer((_) => const Stream.empty());
}
