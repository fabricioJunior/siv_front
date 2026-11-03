import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siv_front/main.dart' show NavigationObserver;

// Regressão: diálogo/bottom sheet (rotas sem nome) zerava rotaAtual, a AppShell tirava a casca
// (Scaffold/Material) e as telas por baixo quebravam com "No Material widget found".
void main() {
  testWidgets('diálogo e bottom sheet não alteram a rota ativa', (tester) async {
    final obs = NavigationObserver();
    final navKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navKey,
        navigatorObservers: [obs],
        initialRoute: '/a',
        routes: {
          '/a': (_) => const Scaffold(body: Text('A')),
          '/b': (_) => const Scaffold(body: Text('B')),
        },
      ),
    );
    expect(obs.rotaAtual.value, '/a');

    final ctx = navKey.currentContext!;
    final dialogo = showDialog<void>(context: ctx, builder: (_) => const AlertDialog(title: Text('d')));
    await tester.pumpAndSettle();
    expect(obs.rotaAtual.value, '/a', reason: 'diálogo aberto não pode zerar a rota');
    navKey.currentState!.pop();
    await dialogo;
    await tester.pumpAndSettle();
    expect(obs.rotaAtual.value, '/a');

    final sheet = showModalBottomSheet<void>(context: ctx, builder: (_) => const SizedBox(height: 80, child: Text('s')));
    await tester.pumpAndSettle();
    expect(obs.rotaAtual.value, '/a', reason: 'bottom sheet aberto não pode zerar a rota');
    navKey.currentState!.pop();
    await sheet;
    await tester.pumpAndSettle();
    expect(obs.rotaAtual.value, '/a');
  });

  testWidgets('páginas continuam atualizando a rota ativa (push, pop e replace)', (tester) async {
    final obs = NavigationObserver();
    final navKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navKey,
        navigatorObservers: [obs],
        initialRoute: '/a',
        routes: {
          '/a': (_) => const Scaffold(body: Text('A')),
          '/b': (_) => const Scaffold(body: Text('B')),
          '/c': (_) => const Scaffold(body: Text('C')),
        },
      ),
    );
    navKey.currentState!.pushNamed('/b');
    await tester.pumpAndSettle();
    expect(obs.rotaAtual.value, '/b');
    navKey.currentState!.pushReplacementNamed('/c');
    await tester.pumpAndSettle();
    expect(obs.rotaAtual.value, '/c');
    navKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(obs.rotaAtual.value, '/a');
  });
}
