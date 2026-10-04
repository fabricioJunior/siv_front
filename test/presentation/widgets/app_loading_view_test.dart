import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siv_front/presentation/widgets/app_loading_view.dart';

Future<void> abrir(
  WidgetTester tester, {
  required Size tela,
  String? etapaAtual,
  List<String> concluidas = const [],
  Map<String, WidgetBuilder> rotas = const {},
}) async {
  tester.view.physicalSize = tela;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MediaQuery(
      // Animações em laço (barra e quadrado) impediriam o pumpAndSettle.
      data: MediaQueryData(size: tela, disableAnimations: true),
      child: MaterialApp(
        theme: SivTheme.tema,
        routes: rotas,
        home: AppLoadingView(
          etapaAtual: etapaAtual,
          etapasConcluidas: concluidas,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  const desktop = Size(960, 600);
  const mobile = Size(360, 740);

  testWidgets('desktop: rótulo INICIANDO, etapas concluídas e a atual', (
    tester,
  ) async {
    await abrir(
      tester,
      tela: desktop,
      etapaAtual: 'Carregando terminal da sessão',
      concluidas: ['Validando licenciamento', 'Verificando autenticação'],
    );

    expect(find.text('INICIANDO'), findsOneWidget);
    expect(find.text('Validando licenciamento'), findsOneWidget);
    expect(find.text('Verificando autenticação'), findsOneWidget);
    expect(find.text('Carregando terminal da sessão'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNWidgets(2)); // só as concluídas
    expect(find.text('VALE DO CEARÁ'), findsOneWidget);
  });

  testWidgets('mobile: sem o rótulo INICIANDO', (tester) async {
    await abrir(tester, tela: mobile, etapaAtual: 'Validando licenciamento');

    expect(find.text('INICIANDO'), findsNothing);
    expect(find.text('Validando licenciamento'), findsOneWidget);
  });

  testWidgets('sem etapa nenhuma (splash): uma linha "Preparando ambiente"', (
    tester,
  ) async {
    await abrir(tester, tela: desktop);

    expect(find.text('Preparando ambiente'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('mostra só as últimas 5 concluídas mais a ativa', (tester) async {
    await abrir(
      tester,
      tela: desktop,
      etapaAtual: 'ativa',
      concluidas: [for (var i = 1; i <= 8; i++) 'etapa $i'],
    );

    expect(find.text('etapa 1'), findsNothing);
    expect(find.text('etapa 3'), findsNothing);
    expect(find.text('etapa 4'), findsOneWidget);
    expect(find.text('etapa 8'), findsOneWidget);
    expect(find.text('ativa'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNWidgets(5));
  });

  testWidgets('só a etapa ativa é anunciada (liveRegion)', (tester) async {
    await abrir(
      tester,
      tela: desktop,
      etapaAtual: 'Sincronizando permissões',
      concluidas: ['Validando licenciamento'],
    );

    Finder anunciada(String label) => find.byWidgetPredicate(
      (w) =>
          w is Semantics &&
          w.properties.liveRegion == true &&
          w.properties.label == label,
    );
    expect(anunciada('Sincronizando permissões'), findsOneWidget);
    expect(anunciada('Validando licenciamento'), findsNothing);
  });

  for (final tela in [desktop, mobile]) {
    testWidgets(
      'botão de configurações abre /configuracao_dispositivo ($tela)',
      (tester) async {
        await abrir(
          tester,
          tela: tela,
          etapaAtual: 'x',
          rotas: {
            '/configuracao_dispositivo': (_) =>
                const Scaffold(body: Text('tela de configuração')),
          },
        );

        await tester.tap(
          find.byKey(const Key('app_loading_configuracao_dispositivo_button')),
        );
        await tester.pumpAndSettle();

        expect(find.text('tela de configuração'), findsOneWidget);
      },
    );
  }

  testWidgets(
    'com animações ligadas: barra e quadrado correm sem erro e a etapa nova entra',
    (tester) async {
      tester.view.physicalSize = desktop;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      Widget tela(String? atual, List<String> feitas) => MaterialApp(
        theme: SivTheme.tema,
        home: AppLoadingView(etapaAtual: atual, etapasConcluidas: feitas),
      );

      await tester.pumpWidget(tela('Etapa A', const []));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpWidget(tela('Etapa B', const ['Etapa A']));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      expect(tester.takeException(), isNull);
      expect(find.text('Etapa A'), findsOneWidget);
      expect(find.text('Etapa B'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    },
  );
}
