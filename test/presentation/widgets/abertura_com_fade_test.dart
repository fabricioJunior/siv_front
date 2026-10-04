import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siv_front/presentation/widgets/abertura_com_fade.dart';

class _Contador extends StatefulWidget {
  const _Contador();

  @override
  State<_Contador> createState() => _ContadorState();
}

class _ContadorState extends State<_Contador> {
  int vezes = 0;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () => setState(() => vezes++),
    child: Text('conteudo $vezes'),
  );
}

Widget _app(Widget filho, {bool reduzir = false}) => MediaQuery(
  data: MediaQueryData(size: const Size(400, 400), disableAnimations: reduzir),
  child: Directionality(textDirection: TextDirection.ltr, child: filho),
);

double _opacidadeDaCarga(WidgetTester tester) => tester
    .widget<Opacity>(
      find.descendant(
        of: find.byKey(const ValueKey('abertura_saindo')),
        matching: find.byType(Opacity),
      ),
    )
    .opacity;

void main() {
  const carga = Text('carregando');
  const conteudo = _Contador();

  testWidgets('enquanto carrega mostra só a carga (o conteúdo nem é montado)', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const AberturaComFade(carregando: carga)));

    expect(find.text('carregando'), findsOneWidget);
    expect(find.byType(_Contador), findsNothing);
  });

  testWidgets(
    'ao terminar, o conteúdo já está montado e a carga esmaece e sai',
    (tester) async {
      await tester.pumpWidget(_app(const AberturaComFade(carregando: carga)));
      await tester.pumpWidget(_app(const AberturaComFade(conteudo: conteudo)));

      expect(find.text('conteudo 0'), findsOneWidget);
      expect(find.text('carregando'), findsOneWidget); // ainda por cima
      expect(_opacidadeDaCarga(tester), 1);

      await tester.pump(const Duration(milliseconds: 125));
      expect(_opacidadeDaCarga(tester), lessThan(1));
      expect(_opacidadeDaCarga(tester), greaterThan(0));

      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(find.text('carregando'), findsNothing);
      expect(find.text('conteudo 0'), findsOneWidget);
    },
  );

  testWidgets('a carga que está saindo não captura toques', (tester) async {
    await tester.pumpWidget(_app(const AberturaComFade(carregando: carga)));
    await tester.pumpWidget(_app(const AberturaComFade(conteudo: conteudo)));
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.text('conteudo 0'), warnIfMissed: false);
    await tester.pump();

    expect(find.text('conteudo 1'), findsOneWidget);
  });

  testWidgets(
    'rebuild do conteúdo preserva o estado (sem recriar o AppShell)',
    (tester) async {
      await tester.pumpWidget(_app(const AberturaComFade(conteudo: conteudo)));
      await tester.tap(find.text('conteudo 0'));
      await tester.pump();
      expect(find.text('conteudo 1'), findsOneWidget);

      await tester.pumpWidget(
        _app(const AberturaComFade(conteudo: _Contador())),
      );

      expect(find.text('conteudo 1'), findsOneWidget);
    },
  );

  testWidgets('com animações desligadas a carga sai na hora', (tester) async {
    await tester.pumpWidget(
      _app(const AberturaComFade(carregando: carga), reduzir: true),
    );
    await tester.pumpWidget(
      _app(const AberturaComFade(conteudo: conteudo), reduzir: true),
    );

    expect(find.text('carregando'), findsNothing);
    expect(find.text('conteudo 0'), findsOneWidget);
  });

  testWidgets('voltar a carregar remove o conteúdo e mostra a carga de novo', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const AberturaComFade(conteudo: conteudo)));
    await tester.pumpWidget(_app(const AberturaComFade(carregando: carga)));
    await tester.pumpAndSettle();

    expect(find.byType(_Contador), findsNothing);
    expect(find.text('carregando'), findsOneWidget);
  });

  testWidgets(
    'carga segurada (conteúdo montado por baixo) fica opaca até ser liberada',
    (tester) async {
      await tester.pumpWidget(
        _app(const AberturaComFade(carregando: carga, conteudo: conteudo)),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('conteudo 0'), findsOneWidget); // já montado
      expect(find.text('carregando'), findsOneWidget); // ainda por cima
      expect(find.byKey(const ValueKey('abertura_saindo')), findsNothing);

      // liberada: esmaece e sai
      await tester.pumpWidget(_app(const AberturaComFade(conteudo: conteudo)));
      await tester.pump(const Duration(milliseconds: 100));
      expect(_opacidadeDaCarga(tester), lessThan(1));
      await tester.pumpAndSettle();
      expect(find.text('carregando'), findsNothing);
    },
  );

  testWidgets(
    'carga segurada não fica presa: some sozinha depois do tempo máximo',
    (tester) async {
      await tester.pumpWidget(
        _app(
          const AberturaComFade(
            carregando: carga,
            conteudo: conteudo,
            tempoMaximo: Duration(seconds: 1),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 900));
      expect(
        find.byKey(const ValueKey('abertura_saindo')),
        findsNothing,
      ); // ainda opaca

      await tester.pump(const Duration(milliseconds: 200)); // passou de 1 s
      await tester.pump(const Duration(milliseconds: 100));
      expect(_opacidadeDaCarga(tester), lessThan(1));
      await tester.pumpAndSettle();
      expect(find.text('conteudo 0'), findsOneWidget);
    },
  );

  testWidgets('a carga segurada cobre o conteúdo e não deixa tocar nele', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const AberturaComFade(carregando: carga, conteudo: conteudo)),
    );

    final carregando = tester.getRect(find.text('carregando'));
    expect(carregando.isEmpty, isFalse);
    // o conteúdo existe, mas a carga é o último filho do Stack (por cima)
    final stack = tester.widget<Stack>(find.byType(Stack).first);
    expect(
      (stack.children.last as KeyedSubtree).key,
      const ValueKey('abertura_carga'),
    );
  });
}
