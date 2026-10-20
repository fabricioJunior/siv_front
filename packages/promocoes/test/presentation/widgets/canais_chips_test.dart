import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promocoes/domain/models/promocao.dart';
import 'package:promocoes/presentation/widgets/canais_chips.dart';

void main() {
  Future<List<PromocaoCanal>> monta(WidgetTester t, PromocaoCanal inicial) async {
    final emitidos = <PromocaoCanal>[];
    var canal = inicial;
    await t.pumpWidget(MaterialApp(
      theme: SivTheme.tema,
      home: Scaffold(
        body: StatefulBuilder(
          builder: (_, set) => CanaisChips(
            canal: canal,
            onChanged: (c) => set(() {
              canal = c;
              emitidos.add(c);
            }),
          ),
        ),
      ),
    ));
    return emitidos;
  }

  Future<void> toca(WidgetTester t, String s) async {
    await t.tap(find.text(s));
    await t.pump();
  }

  testWidgets('ambos: desmarcar um deixa o outro', (t) async {
    final e = await monta(t, PromocaoCanal.ambos);
    await toca(t, 'Loja');
    await toca(t, 'Loja'); // religa -> ambos
    await toca(t, 'E-commerce');
    expect(e, [PromocaoCanal.ecommerce, PromocaoCanal.ambos, PromocaoCanal.loja]);
  });

  testWidgets('nao deixa desmarcar o ultimo chip', (t) async {
    final e = await monta(t, PromocaoCanal.loja);
    await toca(t, 'Loja');
    expect(e, isEmpty);
    expect(t.widget<FilterChip>(find.widgetWithText(FilterChip, 'Loja')).selected, isTrue);
  });

  testWidgets('loja + ecommerce = ambos', (t) async {
    final e = await monta(t, PromocaoCanal.loja);
    await toca(t, 'E-commerce');
    expect(e, [PromocaoCanal.ambos]);
  });

  testWidgets('ecommerce + loja = ambos', (t) async {
    final e = await monta(t, PromocaoCanal.ecommerce);
    await toca(t, 'Loja');
    expect(e, [PromocaoCanal.ambos]);
  });
}
