import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siv_front/presentation/widgets/assinatura_siv.dart';

void main() {
  testWidgets('a assinatura da marca carrega do asset declarado no pubspec', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: AssinaturaSiv())),
      ),
    );
    await tester.runAsync(() async {
      final imagem = tester.widget<Image>(find.byType(Image));
      await precacheImage(imagem.image, tester.element(find.byType(Image)));
    });
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(find.bySemanticsLabel('SIV, Vale do Ceará'), findsOneWidget);
  });

  testWidgets('largura é respeitada', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: AssinaturaSiv(largura: 120))),
      ),
    );

    expect(tester.getSize(find.byType(Image)).width, 120);
  });
}
