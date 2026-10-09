import 'package:comercial/domain/data/remote/i_pedido_entrada_remote_data_source.dart';
import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/domain/use_cases/conferir_pedido.dart';
import 'package:comercial/domain/use_cases/faturar_pedido.dart';
import 'package:comercial/domain/use_cases/pedido_entrada/pedido_entrada_use_cases.dart';
import 'package:comercial/presentation/blocs/pedido_entrada_bloc/pedido_entrada_bloc.dart';
import 'package:comercial/presentation/pages/pedido_entrada/passo_conferir.dart';
import 'package:comercial/presentation/pages/pedido_entrada/passo_revisar_faturar.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/leitor.dart';
import 'package:core/sessao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Sessao implements IAcessoGlobalSessao {
  @override
  dynamic noSuchMethod(Invocation i) {
    if (i.memberName == #dadosSincronizados) return true;
    if (i.memberName == #sincronizandoDados) return const Stream<bool>.empty();
    return null;
  }
}

class _Fonte implements ILeitorDataDatasource {
  @override
  Future<LeitorData?> getData(String codigo, {int? tabelaDePrecoId}) async =>
      null;
  @override
  Future<LeitorData?> getDataPorProdutoId(int id, {int? tabelaDePrecoId}) async =>
      null;
}

class _Remoto implements IPedidoEntradaRemoteDataSource {
  final chamadas = <String>[];
  @override
  Future<EntradaResumo> corrigirContagem(int p, int produtoId, double para,
      {String? motivo, required String origem}) async {
    chamadas.add('corrigir $produtoId $para $origem $motivo');
    return _resumo();
  }

  @override
  Future<EntradaResumo> decidirDivergencia(int p, int produtoId, AcaoDivergencia a,
      {String? observacao}) async {
    chamadas.add('decidir $produtoId ${a.name} $observacao');
    return _resumo();
  }

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

class _Conferir implements ConferirPedido {
  @override
  Future<void> call(int id, {bool processarComDivergencia = false}) async {}
}

class _Faturar implements FaturarPedido {
  @override
  Future<void> call(int id, {required int caixaId}) async {}
}

EntradaResumo _resumo({List<Map<String, dynamic>> divergencias = const []}) =>
    EntradaResumo.fromJson({
      'pedidoId': 9,
      'contagens': [],
      'totais': {'contado': 7},
      'conferencia': {
        'totalContado': 7,
        'totalLido': 2,
        'itens': [
          {'produtoId': 1, 'codigoDeBarras': 'A', 'descricao': 'Calcinha', 'cor': 'Preto', 'tamanho': 'M', 'contado': 4, 'lido': 2, 'situacao': 'parcial'},
          {'produtoId': 2, 'codigoDeBarras': 'B', 'descricao': 'Sutiã', 'cor': 'Nude', 'tamanho': '42', 'contado': 3, 'lido': 0, 'situacao': 'pendente'},
        ],
      },
      'divergencias': divergencias,
    });

void main() {
  late _Remoto remoto;
  final bipes = <(String, int)>[];

  Future<void> montar(WidgetTester t, Widget Function() filho) async {
    t.view.physicalSize = const Size(420, 1400);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await sl.reset();
    sl.registerSingleton<IAcessoGlobalSessao>(_Sessao());
    final bloc = PedidoEntradaBloc(
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
    );
    addTearDown(bloc.close);
    bloc.add(const PedidoEntradaCarregou(9));
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<PedidoEntradaBloc>.value(
            value: bloc,
            child: filho(),
          ),
        ),
      ),
    );
    await t.pump();
  }

  setUp(() {
    remoto = _Remoto();
    bipes.clear();
  });
  tearDown(() async => sl.reset());

  testWidgets('Conferir: leitor em modo conferência com câmera de 48px', (t) async {
    await montar(
      t,
      () => PassoConferir(
        resumo: _resumo(),
        dataSource: _Fonte(),
        onConferirCodigo: (c, q) => bipes.add((c, q)),
        onIrParaPasso: (_) {},
      ),
    );
    expect(find.text('MODO CONFERÊNCIA · CONTADO × LIDO'), findsOneWidget);
    expect(find.text('BIPE O PRODUTO'), findsOneWidget);
    expect(t.getSize(find.byKey(const Key('leitor_camera'))).height,
        greaterThanOrEqualTo(48));
    expect(find.text('A CONFERIR · 2'), findsOneWidget);
    expect(find.text('2 de 7 peças'), findsOneWidget);
    expect(find.text('CONTINUAR · REVISAR'), findsOneWidget);
  });

  testWidgets('Conferir: Corrigir abre a folha e corrige com origem conferencia',
      (t) async {
    await montar(
      t,
      () => PassoConferir(
        resumo: _resumo(),
        dataSource: _Fonte(),
        onConferirCodigo: (c, q) => bipes.add((c, q)),
        onIrParaPasso: (_) {},
      ),
    );
    // só a linha parcial (lido>0) oferece Corrigir
    expect(find.byKey(const Key('conferencia_corrigir_1')), findsOneWidget);
    expect(find.byKey(const Key('conferencia_corrigir_2')), findsNothing);
    await t.tap(find.byKey(const Key('conferencia_corrigir_1')));
    await t.pumpAndSettle();

    expect(find.text('Corrigir contagem'), findsOneWidget);
    expect(find.text('A contagem estava errada'), findsOneWidget);
    expect(find.text('Contado passa a ser 2.'), findsOneWidget);
    expect(find.text('A contagem está certa, ainda há peças para bipar'),
        findsOneWidget);
    expect(find.text('CORRIGIR CONTAGEM'), findsOneWidget);

    await t.enterText(find.byKey(const Key('corrigir_obs')), 'contei 2x a caixa');
    await t.tap(find.byKey(const Key('corrigir_confirmar')));
    await t.pumpAndSettle();
    expect(remoto.chamadas, ['corrigir 1 2.0 conferencia contei 2x a caixa']);
  });

  testWidgets('Conferir: "ainda há peças" não corrige nada', (t) async {
    await montar(
      t,
      () => PassoConferir(
        resumo: _resumo(),
        dataSource: _Fonte(),
        onConferirCodigo: (c, q) {},
        onIrParaPasso: (_) {},
      ),
    );
    await t.tap(find.byKey(const Key('conferencia_corrigir_1')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('opcao_continuar')));
    await t.pump();
    expect(find.text('CONTINUAR BIPANDO'), findsOneWidget);
    await t.tap(find.byKey(const Key('corrigir_confirmar')));
    await t.pumpAndSettle();
    expect(remoto.chamadas, isEmpty);
  });

  testWidgets('Revisar: divergência sem decisão bloqueia FATURAR; manter exige explicação',
      (t) async {
    final div = [
      {'produtoId': 1, 'descricao': 'Calcinha', 'grade': 'Preto · M', 'contado': 12, 'lido': 11, 'tipo': 'falta'},
    ];
    await montar(
      t,
      () => PassoRevisarFaturar(
        resumo: _resumo(divergencias: div),
        salvando: false,
        faturado: false,
      ),
    );
    expect(find.text('1 ITENS PARA DECIDIR ANTES DE FATURAR'), findsOneWidget);
    expect(find.text('Corrigir para 11'), findsOneWidget);
    expect(find.text('Manter e explicar'), findsOneWidget);
    expect(find.text('Decida os 1 itens restantes para liberar.'), findsOneWidget);
    expect(
      t.widget<FilledButton>(find.descendant(
        of: find.byKey(const Key('revisao_faturar')),
        matching: find.byType(FilledButton),
      )).onPressed,
      isNull,
    );

    await t.tap(find.byKey(const Key('decidir_1_manter')));
    await t.pump();
    expect(
      t.widget<FilledButton>(find.byKey(const Key('explicacao_confirmar_1'))).onPressed,
      isNull,
    );
    await t.enterText(find.byKey(const Key('explicacao_1')), 'Veio 1 a menos');
    await t.pump();
    await t.tap(find.byKey(const Key('explicacao_confirmar_1')));
    await t.pumpAndSettle();
    expect(remoto.chamadas, ['decidir 1 manter Veio 1 a menos']);
  });

  testWidgets('Revisar: tudo decidido libera FATURAR N PEÇAS', (t) async {
    final div = [
      {'produtoId': 1, 'descricao': 'Calcinha', 'grade': 'Preto · M', 'contado': 12, 'lido': 11, 'tipo': 'falta', 'decisao': 'manter', 'observacao': 'a menos'},
    ];
    await montar(
      t,
      () => PassoRevisarFaturar(
        resumo: _resumo(divergencias: div),
        salvando: false,
        faturado: false,
      ),
    );
    expect(find.text('FATURAR 2 PEÇAS'), findsOneWidget);
    expect(find.text('Só as peças conferidas entram no estoque.'), findsOneWidget);
    expect(
      t.widget<FilledButton>(find.descendant(
        of: find.byKey(const Key('revisao_faturar')),
        matching: find.byType(FilledButton),
      )).onPressed,
      isNotNull,
    );
  });
}
