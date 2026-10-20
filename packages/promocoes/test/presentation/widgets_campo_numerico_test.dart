import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promocoes/domain/models/regra_desconto.dart';
import 'package:promocoes/presentation/widgets/regra_desconto_form_widget.dart';

void main() {
  testWidgets('campo de percentual só aceita número', (t) async {
    double? ultimo;
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: RegraDescontoFormWidget(
          tipoDesconto: TipoDesconto.percentual,
          onTipoDescontoChanged: (_) {},
          onValorPercentualChanged: (v) => ultimo = v,
          onValorDescontoMaximoChanged: (_) {},
          onValorFixoChanged: (_) {},
          onValorMinimoCompraChanged: (_) {},
          onQuantidadeMinimaChanged: (_) {},
          onPrecoFixoChanged: (_) {},
        ),
      ),
    ));
    final campo = find.byType(TextFormField).first;
    await t.enterText(campo, 'abc');
    expect(find.text('abc'), findsNothing);
    await t.enterText(campo, '1a2,5');
    expect(find.text('1a2,5'), findsNothing);
    await t.enterText(campo, '12,5');
    expect(find.text('12.5'), findsOneWidget);
    expect(ultimo, 12.5);
  });
}
