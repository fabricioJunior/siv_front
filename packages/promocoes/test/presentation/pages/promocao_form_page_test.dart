import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promocoes/presentation.dart';
import 'package:core/presentation.dart';

import 'form_harness.dart';

Future<(dynamic, List<bool?>)> abrirPromo(WidgetTester t, Size s) async {
  tela(t, s);
  final r = registrar();
  final res = <bool?>[];
  await t.pumpWidget(app(rota: '/promocao', pagina: (_) => const PromocaoFormPage(), resultado: res));
  await abrir(t);
  return (r, res);
}

void main() {
  for (final (nome, tam, modal) in [('mobile', mobile, false), ('desktop', desktop, true)]) {
    group('PromocaoFormPage $nome', () {
      testWidgets('formato certo, sem FAB, sem Leve e pague no tipo', (t) async {
        await abrirPromo(t, tam);
        expect(find.byType(SivModal), modal ? findsOneWidget : findsNothing);
        expect(find.byIcon(Icons.arrow_back), modal ? findsNothing : findsOneWidget);
        expect(find.byType(FloatingActionButton), findsNothing);
        expect(find.text('Nova promoção'), findsOneWidget);
        expect(find.text('Leve e pague'), findsOneWidget); // so no escopo
      });

      testWidgets('campos mudam com tipo e escopo', (t) async {
        await abrirPromo(t, tam);
        expect(find.text('Teto de desconto (opcional)'), findsOneWidget);
        await t.tap(find.text('Valor fixo'));
        await t.pumpAndSettle();
        expect(find.text('Pedido mínimo (opcional)'), findsOneWidget);
        expect(find.text('Teto de desconto (opcional)'), findsNothing);

        expect(find.text('Itens do combo'), findsNothing);
        await t.ensureVisible(find.text('Combo/Kit'));
        await t.tap(find.text('Combo/Kit'));
        await t.pumpAndSettle();
        expect(find.text('Itens do combo'), findsOneWidget);

        // "Mais opções" fechado esconde os campos; abrir mostra
        expect(find.text('Descrição (opcional)'), findsNothing);
        await t.ensureVisible(find.text('Mais opções'));
        await t.tap(find.text('Mais opções'));
        await t.pumpAndSettle();
        expect(find.text('Descrição (opcional)'), findsOneWidget);
        expect(find.text('Período do limite'), findsNothing);
      });

      testWidgets('Salvar dispara PromocaoSalvou e fecha com true', (t) async {
        final (r, res) = await abrirPromo(t, tam);
        r.promocaoBloc.add(PromocaoCampoAlterado(
          dataInicio: DateTime(2026, 1, 1),
          dataFim: DateTime(2026, 1, 31),
          valorPercentual: 10,
        ));
        await t.pumpAndSettle();
        await t.enterText(find.byType(TextFormField).first, 'Promo teste');
        await t.tap(find.text('Salvar promoção'));
        await t.pumpAndSettle();
        expect(r.promocao.salva?.nome, 'Promo teste');
        expect(res, [true]);
        expect(find.byType(PromocaoFormPage), findsNothing);
      });

      testWidgets('Salvar sem nome nao salva nem fecha', (t) async {
        final (r, res) = await abrirPromo(t, tam);
        await t.tap(find.text('Salvar promoção'));
        await t.pumpAndSettle();
        expect(r.promocao.salva, isNull);
        expect(res, isEmpty);
        expect(find.text('Informe o nome'), findsOneWidget);
      });
    });
  }

  testWidgets('mobile: Salvar visivel com teclado aberto', (t) async {
    await abrirPromo(t, mobile);
    t.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(t.view.resetViewInsets);
    await t.pumpAndSettle();
    final r = t.getRect(find.widgetWithText(ElevatedButton, 'Salvar promoção'));
    expect(r.bottom, lessThanOrEqualTo(500));
    expect(r.top, greaterThanOrEqualTo(0));
  });

  testWidgets('mobile: alvos >= 44px (segmentos, Salvar, voltar, chips)', (t) async {
    await abrirPromo(t, mobile);
    for (final txt in ['Percentual', 'Todo o catálogo', 'Combo/Kit']) {
      final alvo = find.ancestor(of: find.text(txt).first, matching: find.byType(InkWell)).first;
      expect(t.getSize(alvo).height, greaterThanOrEqualTo(44), reason: txt);
    }
    expect(t.getSize(find.widgetWithText(ElevatedButton, 'Salvar promoção')).height, greaterThanOrEqualTo(44));
    expect(t.getSize(find.byType(IconButton).first).height, greaterThanOrEqualTo(44));
    await t.ensureVisible(find.text('Loja'));
    expect(t.getSize(find.widgetWithText(FilterChip, 'Loja')).height, greaterThanOrEqualTo(44));
  });
}
