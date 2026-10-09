import 'package:comercial/domain/data/remote/i_pedido_entrada_remote_data_source.dart';
import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/domain/use_cases/conferir_pedido.dart';
import 'package:comercial/domain/use_cases/faturar_pedido.dart';
import 'package:comercial/domain/use_cases/pedido_entrada/pedido_entrada_use_cases.dart';
import 'package:comercial/presentation/blocs/pedido_entrada_bloc/pedido_entrada_bloc.dart';
import 'package:comercial/presentation/pages/entrada_por_contagem_page.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:core/sessao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Sessao implements IAcessoGlobalSessao {
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _Conferir implements ConferirPedido {
  @override
  Future<void> call(int id, {bool processarComDivergencia = false}) async {}
}

class _Faturar implements FaturarPedido {
  @override
  Future<void> call(int id, {required int caixaId}) async {}
}

class _Remoto implements IPedidoEntradaRemoteDataSource {
  ({int pessoaId, int tabelaPrecoId, int? funcionarioId})? criada;

  @override
  Future<EntradaResumo> criarPorContagem({
    required int pessoaId,
    required int tabelaPrecoId,
    int? funcionarioId,
    String? observacao,
  }) async {
    criada = (
      pessoaId: pessoaId,
      tabelaPrecoId: tabelaPrecoId,
      funcionarioId: funcionarioId,
    );
    return EntradaResumo.fromJson({
      'pedidoId': 9,
      'origemEntrada': 'CONTAGEM',
      'linhas': <dynamic>[],
      'contagens': <dynamic>[],
      'contagensLivres': <dynamic>[],
      'totais': {'nfe': 0, 'contado': 0},
      'pendencias': <dynamic>[],
    });
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

void main() {
  late _Remoto remoto;

  setUp(() => remoto = _Remoto());
  tearDown(() async => sl.reset());

  Future<void> abrir(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await sl.reset();
    sl.registerFactory<PedidoEntradaBloc>(
      () => PedidoEntradaBloc(
        ImportarNfeEntrada(remoto),
        CriarEntradaPorContagem(remoto),
        ObterPedidoEntrada(remoto),
        VincularLinhaEntrada(remoto),
        PreCadastrarLinhaEntrada(remoto),
        IgnorarLinhaEntrada(remoto),
        ResolverDivergenciaEntrada(remoto),
        RegistrarContagemEntrada(remoto),
        RegistrarContagemLivreEntrada(remoto),
        AssociarContagemLivreEntrada(remoto),
        CorrigirContagemEntrada(remoto),
        DecidirDivergenciaEntrada(remoto),
        RegistrarEtiquetasEntrada(remoto),
        FaturarEntrada(_Conferir(), _Faturar()),
        _Sessao(),
      ),
    );
    SeletorWidget escolhe(String nome, int id) => (data) => Wrap(
          children: [
            Text('seletor $nome'),
            TextButton(
              key: Key('escolher_$nome'),
              onPressed: () =>
                  data.onChanged?.call([SelectData(id: id, nome: nome, data: const {})]),
              child: Text('escolher $nome'),
            ),
            TextButton(
              key: Key('limpar_$nome'),
              onPressed: () => data.onChanged?.call(const []),
              child: Text('limpar $nome'),
            ),
          ],
        );
    await tester.pumpWidget(
      MaterialApp(
        home: EntradaPorContagemPage(
          fornecedorSeletor: escolhe('fornecedor', 2379),
          tabelaDePrecoSeletor: escolhe('tabela', 3),
          funcionarioSeletor: escolhe('funcionario', 1),
        ),
        routes: {'/pedido_entrada': (_) => const Scaffold(body: Text('tela de contagem'))},
      ),
    );
    await tester.pumpAndSettle();
  }

  VoidCallback? acao(WidgetTester tester) => tester
      .widget<FilledButton>(
        find.descendant(
          of: find.byKey(const Key('iniciar_contagem_button')),
          matching: find.byType(FilledButton),
        ),
      )
      .onPressed;

  testWidgets('pede o funcionário responsável e só libera "Iniciar" com os 3 preenchidos', (tester) async {
    await abrir(tester);

    expect(find.text('3. Funcionário responsável'), findsOneWidget);
    expect(find.text('seletor funcionario'), findsOneWidget);
    expect(acao(tester), isNull);

    await tester.tap(find.byKey(const Key('escolher_fornecedor')));
    await tester.tap(find.byKey(const Key('escolher_tabela')));
    await tester.pump();
    expect(acao(tester), isNull, reason: 'falta o funcionário');

    await tester.tap(find.byKey(const Key('escolher_funcionario')));
    await tester.pump();
    expect(acao(tester), isNotNull);

    await tester.tap(find.byKey(const Key('limpar_funcionario')));
    await tester.pump();
    expect(acao(tester), isNull, reason: 'limpar o funcionário volta a bloquear');
  });

  testWidgets('manda o funcionário escolhido ao criar a entrada', (tester) async {
    await abrir(tester);

    await tester.tap(find.byKey(const Key('escolher_fornecedor')));
    await tester.tap(find.byKey(const Key('escolher_tabela')));
    await tester.tap(find.byKey(const Key('escolher_funcionario')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('iniciar_contagem_button')));
    await tester.pumpAndSettle();

    expect(remoto.criada, (pessoaId: 2379, tabelaPrecoId: 3, funcionarioId: 1));
    expect(find.text('tela de contagem'), findsOneWidget);
  });
}
