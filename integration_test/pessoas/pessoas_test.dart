import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:siv_front/main.dart' as app;

import '../utils/autenticacao_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('fluxo de controle de usuários', () {
    var application = app.MyApp(
      routeToTest: '/pessoas',
    );
    setUpAll(() async {
      await app.configs();
      await AutenticacaoUtils.logarComUsuarioDeTeste();
    });
    testWidgets('exibe carregamento quando acessa a página', (tester) async {
      await tester.pumpWidget(application);

      await tester.pumpAndSettle(const Duration(seconds: 1));
      var carregamento = find.byKey(const Key('pessoas_carregamento'));

      expect(carregamento, findsOneWidget);
    });

    testWidgets('exibe pessoas cadastradas', (tester) async {
      await tester.pumpWidget(application);

      await tester.pumpAndSettle(const Duration(seconds: 1));
      var developUserTest = 'apollo';
      var card = find.text(developUserTest);
      expect(card, findsOneWidget);
    });
    testWidgets('abre pagina do usuário', (tester) async {
      await tester.pumpWidget(application);

      Navigator.of(application.navigatorKey.currentContext!)
          .pushNamed('/usuarios');

      await tester.pumpAndSettle(const Duration(seconds: 2));
      var developUserTest = 'apollo';
      var card = find.text(developUserTest);
      await tester.tap(card);

      await tester.pumpAndSettle(const Duration(seconds: 1));

      var nomeTextField = find.byKey(const Key('nome_page_nome_text_field'));

      expect(nomeTextField, findsOneWidget);
    });
  });
}
