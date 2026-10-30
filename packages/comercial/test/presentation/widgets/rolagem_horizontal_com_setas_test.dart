import 'package:comercial/presentation/widgets/rolagem_horizontal_com_setas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(double larguraConteudo) => MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 300,
            child: RolagemHorizontalComSetas(
              larguraConteudo: larguraConteudo,
              child: Container(height: 40, color: Colors.blue),
            ),
          ),
        ),
      ),
    );

VoidCallback? _onPressed(WidgetTester t, String dica) =>
    t.widget<IconButton>(find.widgetWithIcon(IconButton, dica == 'esq' ? Icons.chevron_left : Icons.chevron_right)).onPressed;

void main() {
  testWidgets('conteúdo que cabe não mostra setas', (t) async {
    await t.pumpWidget(_app(200));
    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('conteúdo largo mostra setas; esquerda começa desabilitada', (t) async {
    await t.pumpWidget(_app(1000));
    expect(find.byTooltip('Rolar para a esquerda'), findsOneWidget);
    expect(find.byTooltip('Rolar para a direita'), findsOneWidget);
    expect(_onPressed(t, 'esq'), isNull);
    expect(_onPressed(t, 'dir'), isNotNull);
  });

  testWidgets('seta da direita rola até o fim e habilita a da esquerda', (t) async {
    await t.pumpWidget(_app(1000));
    for (var i = 0; i < 6 && _onPressed(t, 'dir') != null; i++) {
      await t.tap(find.byTooltip('Rolar para a direita'));
      await t.pumpAndSettle();
    }
    expect(_onPressed(t, 'esq'), isNotNull);
    expect(_onPressed(t, 'dir'), isNull);
    await t.tap(find.byTooltip('Rolar para a esquerda'));
    await t.pumpAndSettle();
    expect(_onPressed(t, 'dir'), isNotNull);
  });
}
