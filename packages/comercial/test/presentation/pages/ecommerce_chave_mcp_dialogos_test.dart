import 'package:comercial/models.dart';
import 'package:comercial/presentation/widgets/ecommerce_chave_mcp_dialogos.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(void Function(BuildContext) abrir) => MaterialApp(
      theme: SivTheme.tema,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(onPressed: () => abrir(context), child: const Text('abrir')),
        ),
      ),
    );

Future<void> _abrirExibicao(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1400, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_app((c) => abrirModalChaveMcp<void>(
        c,
        mobile: false,
        dispensavel: false,
        builder: (_) => const ChaveMcpExibicaoUnica(
          mobile: false,
          nome: 'agente',
          chave: 'ch-segredo123',
          urlMcp: 'https://x/v1/mcp/vendas',
          ecommerceId: 3,
        ),
      )));
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
}

bool _concluirHabilitado(WidgetTester tester) =>
    tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'CONCLUIR')).onPressed != null;

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
  });

  group('exibição única', () {
    testWidgets('Concluir começa desabilitado e habilita ao copiar a chave', (tester) async {
      await _abrirExibicao(tester);
      expect(_concluirHabilitado(tester), isFalse);
      await tester.tap(find.text('Copiar chave'));
      await tester.pump();
      expect(_concluirHabilitado(tester), isTrue);
    });

    testWidgets('habilita ao copiar tudo', (tester) async {
      await _abrirExibicao(tester);
      await tester.tap(find.text('Copiar tudo'));
      await tester.pump();
      expect(_concluirHabilitado(tester), isTrue);
    });

    testWidgets('habilita ao marcar "Já guardei a chave"', (tester) async {
      await _abrirExibicao(tester);
      await tester.tap(find.text('Já guardei a chave'));
      await tester.pump();
      expect(_concluirHabilitado(tester), isTrue);
    });

    testWidgets('não fecha por Esc nem por toque no fundo; fecha em Concluir', (tester) async {
      await _abrirExibicao(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Guarde a chave agora'), findsOneWidget);

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('Guarde a chave agora'), findsOneWidget);

      await tester.tap(find.text('Já guardei a chave'));
      await tester.pump();
      await tester.tap(find.text('CONCLUIR'));
      await tester.pumpAndSettle();
      expect(find.text('Guarde a chave agora'), findsNothing);
    });
  });

  group('criar chave', () {
    Future<List<Object?>> abrir(WidgetTester tester, CriarChaveMcpCallback onCriar) async {
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final chamadas = <Object?>[];
      await tester.pumpWidget(_app((c) => abrirModalChaveMcp<CriarChaveMcpResultado>(
            c,
            mobile: false,
            builder: (_) => CriarChaveMcpDialogo(
              mobile: false,
              tituloCanal: 'Loja',
              onCriar: (n, e, d) {
                chamadas.add([n, e, d]);
                return onCriar(n, e, d);
              },
            ),
          )));
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      return chamadas;
    }

    Future<CriarChaveMcpResultado> ok(String n, List<String> e, DateTime? d) async =>
        CriarChaveMcpResultado(
          registro: const EcommerceChaveMcp(id: 1, nome: 'n', chaveMascarada: 'ch-...'),
          chave: 'ch-x',
        );

    testWidgets('nome vazio e nenhum escopo: mostra os dois erros e não envia', (tester) async {
      final chamadas = await abrir(tester, ok);
      await tester.tap(find.text('CRIAR CHAVE'));
      await tester.pump();
      expect(find.text('Informe um nome para identificar a chave.'), findsOneWidget);
      expect(find.text('Escolha pelo menos um escopo.'), findsOneWidget);
      expect(chamadas, isEmpty);
    });

    testWidgets('nome ok sem escopo: só o erro de escopo', (tester) async {
      final chamadas = await abrir(tester, ok);
      await tester.enterText(find.byType(TextField), 'agente CRM');
      await tester.tap(find.text('CRIAR CHAVE'));
      await tester.pump();
      expect(find.text('Informe um nome para identificar a chave.'), findsNothing);
      expect(find.text('Escolha pelo menos um escopo.'), findsOneWidget);
      expect(chamadas, isEmpty);
    });

    testWidgets('selecionar todos envia os 8 escopos; contador do nome', (tester) async {
      final chamadas = await abrir(tester, ok);
      await tester.enterText(find.byType(TextField), 'agente CRM');
      await tester.pump();
      expect(find.text('10/100'), findsOneWidget);
      await tester.tap(find.text('Selecionar todos para atendimento completo'));
      await tester.pump();
      expect(find.text('Limpar seleção'), findsOneWidget);
      await tester.tap(find.text('CRIAR CHAVE'));
      await tester.pumpAndSettle();
      expect((chamadas.single as List)[1], hasLength(8));
    });

    testWidgets('erro da API aparece no modal e mantém o digitado', (tester) async {
      await abrir(tester, (n, e, d) async => throw 'Escopo inválido');
      await tester.enterText(find.byType(TextField), 'agente CRM');
      await tester.tap(find.text('Selecionar todos para atendimento completo'));
      await tester.pump();
      await tester.tap(find.text('CRIAR CHAVE'));
      await tester.pumpAndSettle();
      expect(find.text('Escopo inválido'), findsOneWidget);
      expect(find.text('agente CRM'), findsOneWidget);
    });
  });
}
