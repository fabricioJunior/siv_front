import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> abrir(WidgetTester t, double largura) async {
    t.view.physicalSize = Size(largura, 900);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        theme: SivTheme.tema,
        home: Scaffold(
          body: RelatorioScaffold(
            titulo: 'Vendas',
            kpis: const [
              RelatorioKpiCard(rotulo: 'Vendas', valor: '449', variacao: 16.1),
            ],
            corpo: RelatorioTabela<String>(
              colunas: const [
                RelatorioColuna(id: 'n', titulo: 'Nome'),
                RelatorioColuna(id: 'v', titulo: 'Valor', numerica: true),
              ],
              itens: const ['A'],
              celulas: (_, i) => [Text(i), const Text('10')],
              itemMobile: (_, i) =>
                  RelatorioItemMobile(titulo: i, apoio: const ['x', 'y']),
              ordenarPor: 'n',
              onOrdenar: (_) {},
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('desktop: cabeçalho, variação completa e ordenação', (t) async {
    await abrir(t, 1200);
    expect(find.text('Relatórios /'), findsOneWidget);
    expect(find.text('▲ 16,1% vs. período anterior'), findsOneWidget);
    expect(find.text('NOME'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
  });

  testWidgets('mobile: cartões, só %', (t) async {
    await abrir(t, 400);
    expect(find.text('Relatórios /'), findsNothing);
    expect(find.text('▲ 16,1%'), findsOneWidget);
    expect(find.text('x · y'), findsOneWidget);
    expect(find.text('NOME'), findsNothing);
  });

  testWidgets('estado vazio', (t) async {
    await t.pumpWidget(
      MaterialApp(
        theme: SivTheme.tema,
        home: const Scaffold(
          body: RelatorioScaffold(titulo: 'R', corpo: SizedBox(), vazio: true),
        ),
      ),
    );
    expect(find.text('Nenhum resultado para o filtro selecionado.'), findsOneWidget);
  });
}
