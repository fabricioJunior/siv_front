import 'package:core/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:produtos/presentantion/widgets/consulta/consulta_grade_estoque.dart';

import 'package:core/injecoes.dart';
import 'package:core/arquivos.dart';
import 'consulta_fakes.dart';
import 'fotos_fakes.dart';

Widget _app(ConsultarProdutoBloc bloc) => MaterialApp(
  initialRoute: '/',
  onGenerateRoute: (s) => MaterialPageRoute(
    settings: s,
    builder: (_) => BlocProvider.value(
      value: bloc,
      child: s.name == rotaDetalheConsultarProduto
          ? const ConsultarProdutoDetalhePage()
          : ConsultarProdutoPage(tabelaDePrecoSeletor: (_) => const SizedBox()),
    ),
  ),
);

Future<ConsultarProdutoBloc> _preparar(WidgetTester t, Size tamanho) async {
  t.view.physicalSize = tamanho;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final bloc = novoBloc(FakeConsultaRepo(), FakeGradeRepo());
  addTearDown(bloc.close);
  await t.pumpWidget(_app(bloc));
  await t.enterText(find.byType(TextField).first, 'calça');
  await t.pump(const Duration(milliseconds: 50));
  await t.pumpAndSettle();
  return bloc;
}

void main() {
  setUp(() {
    sl.registerFactory<ReferenciaMidiasBloc>(() => novoMidiasBloc(FakeMidiasRepo([])));
    sl.registerLazySingleton<CompartilharService>(() => CompartilharService());
  });
  tearDown(() => sl.reset());

  testWidgets('desktop 1280: lista e detalhe lado a lado, sem navegação', (t) async {
    await _preparar(t, const Size(1280, 800));
    expect(find.text('Calça Jeans'), findsOneWidget);
    expect(find.text('Bipar código'), findsOneWidget);
    expect(find.text('Selecione um produto na lista.'), findsOneWidget);
    await t.tap(find.text('Calça Jeans'));
    await t.pumpAndSettle();
    expect(find.text('Total em estoque: 8'), findsOneWidget);
    expect(find.text('Cor · Estampa'), findsOneWidget);
  });

  testWidgets('mobile 400: lista -> detalhe -> volta mantendo busca e resultados', (t) async {
    final bloc = await _preparar(t, const Size(400, 800));
    expect(find.text('Bipar código'), findsNothing);
    await t.tap(find.text('Calça Jeans'));
    await t.pumpAndSettle();
    expect(find.text('Total em estoque: 8'), findsOneWidget);
    expect(find.text('Cor · Estampa'), findsOneWidget);
    await t.pageBack();
    await t.pumpAndSettle();
    expect(find.text('Blusa'), findsOneWidget);
    expect(bloc.state.busca, 'calça');
    expect(find.widgetWithText(TextField, 'calça'), findsOneWidget);
  });

  testWidgets('grade destaca células do filtro e a variação lida', (t) async {
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ConsultaGradeEstoque(
          produtos: (await FakeGradeRepo().obterGrade(referenciaId: 1)).produtos,
          estampaIds: const {7},
          produtoIdLido: 11,
        ),
      ),
    ));
    final cs = Theme.of(t.element(find.byType(Scaffold))).colorScheme;
    Color? cor(int id) => ((t.widget(find.byKey(ValueKey('celula-$id'))) as Container).decoration as BoxDecoration).color;
    expect(find.text('Azul · Liso'), findsOneWidget);
    expect(find.text('Azul · Floral'), findsOneWidget);
    expect(cor(11), cs.primary);
    expect(cor(12), cs.primaryContainer);
  });
}
