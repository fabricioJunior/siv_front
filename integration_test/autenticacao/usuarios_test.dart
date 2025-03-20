import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:siv_front/main.dart' as app;
import '../utils/autenticacao_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('fluxo de controle de usuários', () {
    setUpAll(() async {
      await app.configs();
      await AutenticacaoUtils.logarComUsuarioDeTeste();
    });
    testWidgets('exibe usuários cadatrados', (tester) async {
      var application = app.MyApp(
        routeToTest: '/usuarios',
      );
      await tester.pumpWidget(application);

      await tester.pumpAndSettle(const Duration(seconds: 1));
      var developUserTest = 'apollo';
      var card = find.text(developUserTest);
      expect(card, findsOneWidget);
    });
    testWidgets('abre pagina do usuário', (tester) async {
      var application = app.MyApp(
        routeToTest: '/usuarios',
      );
      await tester.pumpWidget(application);

      await tester.pumpAndSettle(const Duration(seconds: 1));
      var developUserTest = 'apollo';
      var card = find.text(developUserTest);
      await tester.tap(card);

      await tester.pumpAndSettle();

      var nomeTextField = find.byKey(const Key('nome_page_nome_text_field'));

      expect(nomeTextField, findsOneWidget);
    });
  });
}
