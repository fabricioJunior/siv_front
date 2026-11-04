import 'package:core/presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('interpretar: válida, incompleta e inexistente', () {
    expect(DateInput.interpretar('05/03/2024'), DateTime(2024, 3, 5));
    expect(DateInput.interpretar('05/03/202'), isNull);
    expect(DateInput.interpretar('31/02/2024'), isNull);
    expect(DateInput.interpretar('ab/cd/efgh'), isNull);
  });

  testWidgets('letras e texto longo não lançam; data completa chama onComplete', (tester) async {
    DateTime? ultima;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: DateInput(onComplete: (d) => ultima = d))));
    await tester.enterText(find.byType(TextField), 'ab/cd/efghij');
    expect(tester.takeException(), isNull);
    expect(ultima, isNull);
    await tester.enterText(find.byType(TextField), '05032024');
    expect(find.text('05/03/2024'), findsOneWidget);
    expect(ultima, DateTime(2024, 3, 5));
  });
}
