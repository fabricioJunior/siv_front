import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promocoes/presentation.dart';
import 'package:core/presentation.dart';

import 'form_harness.dart';

Future<(dynamic, List<bool?>)> abrirCupom(WidgetTester t, Size s) async {
  tela(t, s);
  final r = registrar();
  final res = <bool?>[];
  await t.pumpWidget(app(rota: '/cupom', pagina: (_) => const CupomFormPage(), resultado: res));
  await abrir(t);
  return (r, res);
}

void main() {
  group('gerarCodigoCupom', () {
    test('8 chars, sem 0/O/1/I, alterna consoante/vogal', () {
      final r = Random(1);
      for (var i = 0; i < 500; i++) {
        final c = gerarCodigoCupom(r);
        expect(c.length, 8);
        expect(c, isNot(matches('[01OI]')));
        for (var j = 0; j < 8; j++) {
          expect('AEU'.contains(c[j]), j.isOdd, reason: c);
        }
      }
      expect(gerarCodigoCupom(), hasLength(8));
    });
  });

  for (final (nome, tam, modal) in [('mobile', mobile, false), ('desktop', desktop, true)]) {
    group('CupomFormPage $nome', () {
      testWidgets('formato certo, sem FAB, sem Leve e pague no tipo', (t) async {
        await abrirCupom(t, tam);
        expect(find.byType(SivModal), modal ? findsOneWidget : findsNothing);
        expect(find.byIcon(Icons.arrow_back), modal ? findsNothing : findsOneWidget);
        expect(find.byType(FloatingActionButton), findsNothing);
        expect(find.text('Novo cupom'), findsOneWidget);
        // 'Leve e pague' so existe no segmento de Escopo (1x), nunca no de tipo
        expect(find.text('Leve e pague'), findsOneWidget);
        expect(find.text('Percentual'), findsOneWidget);
        expect(find.text('Preço fixo'), findsOneWidget);
      });

      testWidgets('campos mudam com tipo e escopo', (t) async {
        await abrirCupom(t, tam);
        expect(find.text('Teto de desconto (opcional)'), findsOneWidget);
        expect(find.text('Pedido mínimo (opcional)'), findsNothing);
        await t.tap(find.text('Valor fixo'));
        await t.pumpAndSettle();
        expect(find.text('Pedido mínimo (opcional)'), findsOneWidget);
        expect(find.text('Quantidade mínima (opcional)'), findsOneWidget);
        expect(find.text('Teto de desconto (opcional)'), findsNothing);
        await t.tap(find.text('Preço fixo'));
        await t.pumpAndSettle();
        expect(find.text('Pedido mínimo (opcional)'), findsNothing);
        expect(find.text('Preço fixo'), findsNWidgets(2)); // segmento + rotulo do campo

        expect(find.text('Itens do combo'), findsNothing);
        await t.ensureVisible(find.text('Combo/Kit'));
        await t.tap(find.text('Combo/Kit'));
        await t.pumpAndSettle();
        expect(find.text('Itens do combo'), findsOneWidget);
      });

      testWidgets('Salvar dispara CupomSalvou e fecha com true', (t) async {
        final (r, res) = await abrirCupom(t, tam);
        r.cupomBloc.add(CupomCampoAlterado(
          codigo: 'BAFEKUDO',
          dataInicio: DateTime(2026, 1, 1),
          dataFim: DateTime(2026, 1, 31),
          valorPercentual: 10,
        ));
        await t.pumpAndSettle();
        await t.tap(find.text('Salvar cupom'));
        await t.pumpAndSettle();
        expect(r.cupom.salvo?.codigo, 'BAFEKUDO');
        expect(res, [true]);
        expect(find.byType(CupomFormPage), findsNothing);
      });

      testWidgets('Gerar código preenche 8 chars', (t) async {
        await abrirCupom(t, tam);
        await t.tap(find.text('Gerar código'));
        await t.pumpAndSettle();
        final f = t.widget<TextFormField>(find.byType(TextFormField).first);
        expect(f.controller!.text, hasLength(8));
      });
    });
  }

  group('mobile: toque e teclado', () {
    testWidgets('controles principais >= 44px', (t) async {
      await abrirCupom(t, mobile);
      for (final txt in ['Percentual', 'Valor fixo', 'Preço fixo', 'Geral', 'Combo/Kit']) {
        final alvo = find.ancestor(of: find.text(txt).first, matching: find.byType(InkWell)).first;
        expect(t.getSize(alvo).height, greaterThanOrEqualTo(44), reason: txt);
      }
      expect(t.getSize(find.widgetWithText(OutlinedButton, 'Gerar código')).height, greaterThanOrEqualTo(44));
      expect(t.getSize(find.widgetWithText(ElevatedButton, 'Salvar cupom')).height, greaterThanOrEqualTo(44));
      expect(t.getSize(find.byType(IconButton).first).height, greaterThanOrEqualTo(44));
    });

    testWidgets('Salvar visivel com teclado aberto', (t) async {
      await abrirCupom(t, mobile);
      t.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(t.view.resetViewInsets);
      await t.pumpAndSettle();
      final r = t.getRect(find.widgetWithText(ElevatedButton, 'Salvar cupom'));
      expect(r.bottom, lessThanOrEqualTo(800 - 300));
      expect(r.top, greaterThanOrEqualTo(0));
    });
  });
}
