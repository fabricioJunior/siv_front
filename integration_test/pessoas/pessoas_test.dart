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
    testWidgets('exibe barra de título, busca e filtro', (tester) async {
      await tester.pumpWidget(application);

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Pessoas'), findsOneWidget);
      expect(find.text('Buscar por nome, CPF/CNPJ'), findsOneWidget);
      expect(find.text('Clientes'), findsOneWidget);
      expect(find.text('Fornecedores'), findsOneWidget);
    });

    testWidgets('alterna para fornecedores', (tester) async {
      await tester.pumpWidget(application);

      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text('Fornecedores'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Fornecedores'), findsOneWidget);
    });
  });
}
