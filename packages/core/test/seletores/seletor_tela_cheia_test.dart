import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _nomes = [
  for (var i = 1; i <= 16; i++) 'Cor ${i.toString().padLeft(2, '0')}',
  'Açaí',
];

Future<Future<List<String>?> Function()> _abrir(
  WidgetTester t, {
  SeletorGenericoModo modo = SeletorGenericoModo.multipla,
  List<String> jaUsados = const [],
  Future<String?> Function(String)? onCadastrar,
}) async {
  List<String>? resultado;
  var chamado = false;
  await t.pumpWidget(MaterialApp(
    theme: SivTheme.tema,
    home: Builder(
      builder: (c) => TextButton(
        onPressed: () async {
          resultado = await SeletorTelaCheia.abrir<String>(
            c,
            SeletorTelaCheia<String>(
              titulo: 'Cores',
              itens: _nomes,
              itemLabel: (s) => s,
              modo: modo,
              jaUsados: jaUsados,
              nomeSingular: 'cor',
              nomePlural: 'cores',
              onCadastrar: onCadastrar,
            ),
          );
          chamado = true;
        },
        child: const Text('abrir'),
      ),
    ),
  ));
  return () async => chamado ? resultado : null;
}

Future<void> _entrar(WidgetTester t) async {
  await t.pumpAndSettle();
  await t.tap(find.text('abrir'));
  await t.pumpAndSettle();
}

void main() {
  testWidgets('16ª cor marcável com teclado aberto; rolar não fecha',
      (t) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    t.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(t.view.reset);
    final r = await _abrir(t);
    await _entrar(t);

    final foco = FocusManager.instance.primaryFocus;
    await t.scrollUntilVisible(find.byKey(const Key('sel_item_Cor 16')), 52,
        scrollable: find.descendant(
            of: find.byKey(const Key('sel_lista')),
            matching: find.byType(Scrollable)));
    await t.drag(find.byKey(const Key('sel_lista')), const Offset(0, -150));
    await t.pump();
    expect(FocusManager.instance.primaryFocus, foco); // busca segue com foco
    await t.tap(find.byKey(const Key('sel_item_Cor 16')));
    await t.pump();
    expect(find.text('CONFIRMAR · 1 COR'), findsOneWidget);
    // o rodapé fica acima do teclado
    final rodape = t.getBottomLeft(find.byKey(const Key('sel_confirmar'))).dy;
    expect(rodape, lessThanOrEqualTo(844 - 300));
    await t.tap(find.byKey(const Key('sel_confirmar')));
    await t.pumpAndSettle();
    expect(await r(), ['Cor 16']);
  });

  testWidgets('Cadastrar aparece só sem nome igual (sem acento/caixa)',
      (t) async {
    await _abrir(t, onCadastrar: (n) async => n);
    await _entrar(t);
    await t.enterText(find.byKey(const Key('sel_busca')), 'violeta');
    await t.pump();
    expect(find.byKey(const Key('sel_cadastrar')), findsOneWidget);
    expect(find.text('Cadastrar “violeta” como nova cor'), findsOneWidget);
    await t.enterText(find.byKey(const Key('sel_busca')), 'ACAI');
    await t.pump();
    expect(find.byKey(const Key('sel_cadastrar')), findsNothing);
  });

  testWidgets('cadastrar marca o item novo', (t) async {
    final r = await _abrir(t, onCadastrar: (n) async => n);
    await _entrar(t);
    await t.enterText(find.byKey(const Key('sel_busca')), 'Violeta');
    await t.pump();
    await t.tap(find.byKey(const Key('sel_cadastrar')));
    await t.pump();
    await t.tap(find.byKey(const Key('sel_confirmar')));
    await t.pumpAndSettle();
    expect(await r(), ['Violeta']);
  });

  testWidgets('grupos: usadas no topo, restantes A–Z sem repetir', (t) async {
    await _abrir(t, jaUsados: ['Cor 05']);
    await _entrar(t);
    expect(find.text('JÁ USADAS NESTA REFERÊNCIA'), findsOneWidget);
    expect(find.text('TODAS AS CORES'), findsOneWidget);
    expect(find.text('Cor 05'), findsOneWidget);
    expect(t.getTopLeft(find.text('Cor 05')).dy,
        lessThan(t.getTopLeft(find.text('Açaí')).dy));
  });

  testWidgets('múltipla: chip remove, confirmar devolve lista', (t) async {
    final r = await _abrir(t);
    await _entrar(t);
    await t.tap(find.byKey(const Key('sel_item_Cor 01')));
    await t.tap(find.byKey(const Key('sel_item_Cor 02')));
    await t.pump();
    expect(find.text('CONFIRMAR · 2 CORES'), findsOneWidget);
    await t.tap(find
        .descendant(
            of: find.byKey(const Key('sel_chip_Cor 01')),
            matching: find.byType(Icon))
        .last);
    await t.pump();
    expect(find.text('CONFIRMAR · 1 COR'), findsOneWidget);
    await t.tap(find.byKey(const Key('sel_confirmar')));
    await t.pumpAndSettle();
    expect(await r(), ['Cor 02']);
  });

  testWidgets('única: toque escolhe e fecha', (t) async {
    final r = await _abrir(t, modo: SeletorGenericoModo.unica);
    await _entrar(t);
    expect(find.byKey(const Key('sel_confirmar')), findsNothing);
    await t.tap(find.byKey(const Key('sel_item_Cor 03')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('sel_busca')), findsNothing);
    expect(await r(), ['Cor 03']);
  });

  Widget compacto(List<String> escolhidos) => MaterialApp(
        theme: SivTheme.tema,
        home: Scaffold(
          body: SeletorGenericoCompacto<String>(
            seletor: SeletorGenerico<String>(
              itens: _nomes,
              itemLabel: (s) => s,
              toSelectData: (s) => SelectData(id: 0, nome: s, data: const {}),
              hintText: 'Escolha',
              onChanged: (l) => escolhidos.addAll(l),
            ),
          ),
        ),
      );

  testWidgets('Compacto no mobile abre tela cheia e aplica a escolha',
      (t) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final escolhidos = <String>[];
    await t.pumpWidget(compacto(escolhidos));
    await t.tap(find.text('Escolha'));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('sel_busca')), findsOneWidget);
    await t.tap(find.byKey(const Key('sel_item_Cor 07')));
    await t.pumpAndSettle();
    expect(escolhidos, ['Cor 07']);
    expect(find.text('Cor 07'), findsOneWidget); // campo mostra o escolhido
  });

  testWidgets('Compacto no desktop segue com a folha do SeletorGenerico',
      (t) async {
    t.view.physicalSize = const Size(1200, 800);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(compacto([]));
    await t.tap(find.text('Escolha'));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('sel_busca')), findsNothing);
    expect(find.byType(SeletorGenerico<String>), findsOneWidget);
  });

  group('estado de carga', () {
    Widget app({bool carregando = false, String? erro, VoidCallback? tentar,
            List<String> itens = const []}) =>
        MaterialApp(
          theme: SivTheme.tema,
          home: SeletorTelaCheia<String>(
            titulo: 'Cores',
            itens: itens,
            itemLabel: (s) => s,
            nomeSingular: 'cor',
            nomePlural: 'cores',
            onCadastrar: (n) async => n,
            carregando: carregando,
            erro: erro,
            onTentarNovamente: tentar,
          ),
        );

    testWidgets('carregando: busca e título aparecem, lista é spinner', (t) async {
      await t.pumpWidget(app(carregando: true));
      expect(find.byKey(const Key('sel_busca')), findsOneWidget);
      expect(find.text('Cores'), findsOneWidget);
      expect(find.byKey(const Key('sel_carregando')), findsOneWidget);
      expect(find.byKey(const Key('sel_lista')), findsNothing);
      await t.enterText(find.byKey(const Key('sel_busca')), 'x');
      await t.pump();
      expect(find.byKey(const Key('sel_cadastrar')), findsNothing);
    });

    testWidgets('carregando -> pronto troca o spinner pela lista', (t) async {
      await t.pumpWidget(app(carregando: true));
      await t.pumpWidget(app(itens: ['Azul']));
      expect(find.byKey(const Key('sel_carregando')), findsNothing);
      expect(find.byKey(const Key('sel_item_Azul')), findsOneWidget);
    });

    testWidgets('erro: mensagem e TENTAR DE NOVO chama o callback', (t) async {
      var n = 0;
      await t.pumpWidget(app(erro: 'Falhou', tentar: () => n++));
      expect(find.text('Falhou'), findsOneWidget);
      await t.tap(find.byKey(const Key('sel_tentar_novamente')));
      expect(n, 1);
    });
  });
}
