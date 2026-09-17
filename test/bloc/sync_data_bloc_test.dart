import 'dart:async';

import 'package:autenticacao/models.dart';
import 'package:core/injecoes.dart';
import 'package:core/paginacao.dart';
import 'package:core/sync.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:siv_front/presentation/bloc/sync_data/sync_data_bloc.dart';

import '../doubles/use_cases.mocks.dart';

class FakeEmpresa implements Empresa {
  @override
  int get id => 1;

  @override
  String get nome => 'empresa teste';
}

class FakePermissaoDoUsuario implements PermissaoDoUsuario {
  FakePermissaoDoUsuario(this.componenteId);

  @override
  final String componenteId;

  @override
  int get id => 1;

  @override
  int get empresaId => 1;

  @override
  int get grupoId => 1;

  @override
  String get grupoNome => 'grupo teste';

  @override
  String get componenteNome => 'componente teste';

  @override
  int get descontinuado => 0;

  @override
  bool get estaDescontinuado => false;

  @override
  List<Object?> get props => [componenteId];

  @override
  bool? get stringify => true;
}

void main() {
  late MockSincronizarCodigos sincronizarCodigos;
  late MockSincronizarEstoque sincronizarEstoque;
  late MockSincronziarTabelasDePreco sincronizarTabelasDePreco;
  late MockSincronizarPrecos sincronizarPrecos;
  late MockEstaAutenticado estaAutenticado;
  late MockRecuperarUsuarioDaSessao recuperarUsuarioDaSessao;
  late MockRecuperarEmpresaDaSessao recuperarEmpresaDaSessao;
  late MockRecuperarPermissoesDoUsuario recuperarPermissoesDoUsuario;
  late MockLimparSincronizacaoIncremental limparSincronizacaoIncremental;
  late MockSyncWebSocketService syncWebSocketService;
  late MockRecuperarTokenJwt recuperarTokenJwt;
  late ApiBaseUrlConfig apiBaseUrlConfig;
  late MockOnDesautenticado onDesautenticado;
  late StreamController<SyncMudancaEvent> mudancasController;
  late StreamController<bool> conectadoController;
  late StreamController<Null> onDesautenticadoController;
  late SyncDataBloc bloc;
  late Usuario usuario;

  setUp(() {
    sincronizarCodigos = MockSincronizarCodigos();
    sincronizarEstoque = MockSincronizarEstoque();
    sincronizarTabelasDePreco = MockSincronziarTabelasDePreco();
    sincronizarPrecos = MockSincronizarPrecos();
    estaAutenticado = MockEstaAutenticado();
    recuperarUsuarioDaSessao = MockRecuperarUsuarioDaSessao();
    recuperarEmpresaDaSessao = MockRecuperarEmpresaDaSessao();
    recuperarPermissoesDoUsuario = MockRecuperarPermissoesDoUsuario();
    limparSincronizacaoIncremental = MockLimparSincronizacaoIncremental();
    syncWebSocketService = MockSyncWebSocketService();
    recuperarTokenJwt = MockRecuperarTokenJwt();
    apiBaseUrlConfig = ApiBaseUrlConfig()..atualizar('https://api.teste/v1');
    onDesautenticado = MockOnDesautenticado();

    mudancasController = StreamController<SyncMudancaEvent>.broadcast();
    conectadoController = StreamController<bool>.broadcast();
    onDesautenticadoController = StreamController<Null>.broadcast();

    usuario = Usuario.create(
      id: 1,
      login: 'login',
      nome: 'usuario teste',
      tipo: TipoUsuario.padrao,
      ativo: true,
    );

    when(estaAutenticado.call()).thenAnswer((_) async => true);
    when(recuperarEmpresaDaSessao.call()).thenAnswer((_) async => FakeEmpresa());
    when(recuperarUsuarioDaSessao.call()).thenAnswer((_) async => usuario);
    when(recuperarPermissoesDoUsuario.call(usuario.id)).thenAnswer(
      (_) async => [FakePermissaoDoUsuario('PRDFL001')],
    );
    when(recuperarTokenJwt.call()).thenAnswer((_) async => 'jwt-fake');
    when(syncWebSocketService.mudancas)
        .thenAnswer((_) => mudancasController.stream);
    when(syncWebSocketService.conectado)
        .thenAnswer((_) => conectadoController.stream);
    when(onDesautenticado.call())
        .thenAnswer((_) => onDesautenticadoController.stream);

    bloc = SyncDataBloc(
      sincronizarCodigos,
      sincronizarEstoque,
      sincronizarTabelasDePreco,
      sincronizarPrecos,
      estaAutenticado,
      recuperarUsuarioDaSessao,
      recuperarEmpresaDaSessao,
      recuperarPermissoesDoUsuario,
      limparSincronizacaoIncremental,
      syncWebSocketService,
      recuperarTokenJwt,
      apiBaseUrlConfig,
      onDesautenticado,
    );
  });

  tearDown(() async {
    await bloc.close();
    await mudancasController.close();
    await conectadoController.close();
    await onDesautenticadoController.close();
  });

  test(
    'reagenda automaticamente sincronizacao pendente descartada quando a '
    'sincronizacao em andamento termina',
    () async {
      final controllerA = StreamController<Paginacao>();
      final controllerB = StreamController<Paginacao>();
      var chamada = 0;
      when(sincronizarEstoque.call()).thenAnswer((_) {
        chamada++;
        return chamada == 1 ? controllerA.stream : controllerB.stream;
      });

      bloc.add(const SyncDataSolicitouSincronizacao(origem: SyncDataOrigem.vendas));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.origemUltimaSincronizacao, SyncDataOrigem.vendas);
      expect(
        bloc.state.modulos[SyncModulo.estoque]!.status,
        SyncModuloStatus.sincronizando,
      );

      bloc.add(const SyncDataSolicitouSincronizacao(origem: SyncDataOrigem.estoque));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.origemUltimaSincronizacao, SyncDataOrigem.vendas);
      verify(sincronizarEstoque.call()).called(1);

      await controllerA.close();

      final estadoAposReagendamento = await bloc.stream.firstWhere(
        (state) => state.origemUltimaSincronizacao == SyncDataOrigem.estoque,
      ).timeout(const Duration(seconds: 2));

      expect(
        estadoAposReagendamento.modulos[SyncModulo.estoque]!.status,
        SyncModuloStatus.sincronizando,
      );
      verify(sincronizarEstoque.call()).called(1);

      await controllerB.close();
      await Future<void>.delayed(Duration.zero);
    },
  );

  test(
    'debounce: rajada de eventos sync:mudanca dispara apenas 1 sincronizacao',
    () async {
      when(sincronizarEstoque.call()).thenAnswer((_) => const Stream.empty());

      mudancasController.add(const SyncMudancaEvent(modulo: 'estoque'));
      await Future<void>.delayed(const Duration(milliseconds: 500));
      mudancasController.add(const SyncMudancaEvent(modulo: 'estoque'));
      await Future<void>.delayed(const Duration(milliseconds: 500));
      mudancasController.add(const SyncMudancaEvent(modulo: 'estoque'));

      await Future<void>.delayed(const Duration(seconds: 4));

      verify(sincronizarEstoque.call()).called(1);
      expect(bloc.state.origemUltimaSincronizacao, SyncDataOrigem.tempoReal);
    },
  );

  test('reconexao do WS dispara sincronizacao completa', () async {
    when(sincronizarEstoque.call()).thenAnswer((_) => const Stream.empty());

    // Primeira conexao -- nao ha o que "recuperar", nao dispara sync extra.
    conectadoController.add(true);
    await Future<void>.delayed(Duration.zero);
    verifyNever(sincronizarEstoque.call());

    conectadoController.add(false);
    await Future<void>.delayed(Duration.zero);
    conectadoController.add(true);
    await Future<void>.delayed(Duration.zero);

    verify(sincronizarEstoque.call()).called(1);
    expect(bloc.state.origemUltimaSincronizacao, SyncDataOrigem.tempoReal);
  });

  test(
    'mudanca global (sem empresaId) sincroniza igual a uma mudanca escopada '
    '-- nao ha filtro client-side por empresaId, o servidor ja escopa via room',
    () async {
      when(sincronizarEstoque.call()).thenAnswer((_) => const Stream.empty());

      mudancasController.add(
        const SyncMudancaEvent(modulo: 'estoque', empresaId: null),
      );
      await Future<void>.delayed(const Duration(seconds: 4));

      verify(sincronizarEstoque.call()).called(1);
    },
  );
}
