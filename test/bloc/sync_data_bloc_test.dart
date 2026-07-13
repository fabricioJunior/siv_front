import 'dart:async';

import 'package:autenticacao/models.dart';
import 'package:core/paginacao.dart';
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
    );
  });

  tearDown(() async {
    await bloc.close();
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
}
