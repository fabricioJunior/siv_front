import 'package:comercial/presentation/pages/pedido_entrada/componentes_entrada.dart';
import 'package:comercial/presentation/pages/pedido_entrada/painel_contagem_grade.dart';
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

SelectData _sd(int id, String n) => SelectData(id: id, nome: n, data: const {});

Widget _painel() => MaterialApp(
      theme: SivTheme.tema,
      home: Scaffold(
        body: PainelContagemGrade(
          titulo: 'Contar',
          subtitulo: 's',
          referenciaId: 1,
          referenciaNome: 'Aurora',
          corSeletor: (d) => const SizedBox(key: Key('cor_antigo')),
          tamanhoSeletor: (d) => const SizedBox(),
          fonteCores: FonteVariacao(
            carregar: () async =>
                [_sd(1, 'Vinho'), _sd(2, 'Nude'), _sd(3, 'Azul')],
            cadastrar: (n) async => _sd(9, n),
          ),
          fonteEstampas: FonteVariacao(
            carregar: () async => [_sd(7, 'Floral'), _sd(8, 'Listrada')],
          ),
          estampaSeletor: (d) => const SizedBox(key: Key('estampa_antigo')),
          carregarTamanhos: () async => const [
            TamanhoOpcao(id: 1, nome: '34'),
            TamanhoOpcao(id: 2, nome: '36'),
            TamanhoOpcao(id: 3, nome: '38'),
            TamanhoOpcao(id: 4, nome: '40'),
            TamanhoOpcao(id: 5, nome: 'P'),
            TamanhoOpcao(id: 6, nome: 'M'),
            TamanhoOpcao(id: 7, nome: 'G'),
          ],
          onSalvar: (l, i) {},
          onFechar: () {},
        ),
      ),
    );

Future<void> _mobile(WidgetTester t) async {
  t.view.physicalSize = const Size(390, 844);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  nomesCor.clear();
  nomesTamanho.clear();
  await t.pumpWidget(_painel());
}

void main() {
  testWidgets(
      'mobile: cores e tamanhos viram chips pelos seletores em tela cheia',
      (t) async {
    await _mobile(t);
    expect(find.byKey(const Key('cor_antigo')), findsNothing);
    expect(find.byKey(const Key('estampa_antigo')), findsNothing);

    await t.tap(find.byKey(const Key('add_cor')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('sel_item_1')));
    await t.tap(find.byKey(const Key('sel_item_2')));
    await t.tap(find.byKey(const Key('sel_confirmar')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('chip_cor_1')), findsOneWidget);
    expect(find.byKey(const Key('chip_cor_2')), findsOneWidget);

    await t.tap(find.byKey(const Key('add_tam')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('tam_1')));
    await t.tap(find.byKey(const Key('tam_5')));
    await t.tap(find.byKey(const Key('tam_confirmar')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('contagem_1_1')), findsOneWidget);
    expect(find.byKey(const Key('contagem_2_5')), findsOneWidget);
    expect(
        find.byKey(const Key('contagem_1_2')), findsNothing); // 36 não marcado
  });

  testWidgets('estampa: seleção única escolhe e fecha', (t) async {
    await _mobile(t);
    await t.tap(find.byKey(const Key('add_estampa')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('sel_item_7')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('chip_estampa_7')), findsOneWidget);
  });

  Future<void> faixa(WidgetTester t, List<String> toques) async {
    await _mobile(t);
    await t.tap(find.byKey(const Key('add_tam')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('tam_faixa')));
    await t.pump();
    expect(find.text('Toque no primeiro tamanho da faixa'), findsOneWidget);
    await t.tap(find.byKey(Key(toques[0])));
    await t.pump();
    expect(
        find.textContaining('Agora toque no último (início:'), findsOneWidget);
    await t.tap(find.byKey(Key(toques[1])));
    await t.pump();
    expect(find.text('MARCAR FAIXA'), findsOneWidget);
  }

  testWidgets('MARCAR FAIXA: 2 toques marcam o intervalo', (t) async {
    await faixa(t, ['tam_1', 'tam_3']); // 34..38
    expect(find.text('CONFIRMAR · 3 TAMANHOS'), findsOneWidget);
  });

  testWidgets('MARCAR FAIXA: ordem invertida e só dentro do grupo', (t) async {
    await faixa(t, ['tam_7', 'tam_5']); // G..P (letras)
    expect(find.text('CONFIRMAR · 3 TAMANHOS'), findsOneWidget);
  });
}
