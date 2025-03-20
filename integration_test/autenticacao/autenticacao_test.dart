import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:siv_front/main.dart' as app;

import '../utils/autenticacao_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('fluxo de login', () {
    setUpAll(() async {
      await app.configs();

      await AutenticacaoUtils.reiniciarAutenticacao();
    });
    testWidgets(
        '''não tenta realizar login caso o usuário não informe o usuário ou senha''',
        timeout: const Timeout(Duration(minutes: 1)),
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(app.MyApp());
      await tester.pumpAndSettle();

      var entryButton = find.byKey(const Key('login_page_entrar_button'));
      await tester.tap(entryButton, kind: PointerDeviceKind.mouse);
      await tester.pump(const Duration(seconds: 1));
      var solicitacaoDeSenhaTxt = find.text('Informe a senha para continuar');
      var solicitacaoDeUsuarioTxt = find.text('Informe o usuário');
      expect(solicitacaoDeSenhaTxt, findsOne);

      expect(solicitacaoDeUsuarioTxt, findsOne);
    });

    testWidgets('''realiza login com usuário de teste e abre pagina inicial''',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(app.MyApp());
      await tester.pumpAndSettle();
      // escreve o login do usuário
      var userTextField = find.byKey(const Key('login_page_user_input'));
      await tester.enterText(userTextField, 'apollo');
      // escreve a senha do usuário
      await Future.delayed(const Duration(seconds: 1));
      var passwordTextField = find.byKey(const Key('login_page_user_senha'));
      await tester.enterText(passwordTextField, 'start');
      await Future.delayed(const Duration(seconds: 1));
      var entryButton = find.byKey(const Key('login_page_entrar_button'));

      await tester.tap(entryButton);
      await tester.pumpAndSettle(const Duration(seconds: 10));
      var homePageText = find.text('Home page');
      expect(homePageText, findsOneWidget);
    });

    testWidgets('''desloga o usuário e retorna para pagina de login''',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.

      await tester.pumpWidget(app.MyApp());
      await tester.pumpAndSettle();
      final sairButton = find.byKey(const Key('sair_button'));

      await tester.tap(sairButton);
      await tester.pumpAndSettle();
      final loginPage = find.byKey(const Key('login_page_key'));
      expect(loginPage, findsOneWidget);
    });
  });
}
