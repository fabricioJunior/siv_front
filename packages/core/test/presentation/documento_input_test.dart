import 'package:core/presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<GlobalKey<FormState>> abrir(
    WidgetTester tester, {
    required bool juridica,
    required TextEditingController controller,
  }) async {
    final form = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: form,
            child: DocumentoInput(juridica: juridica, controller: controller),
          ),
        ),
      ),
    );
    return form;
  }

  testWidgets('CPF: rótulo, máscara e validação', (tester) async {
    final c = TextEditingController();
    final form = await abrir(tester, juridica: false, controller: c);

    expect(find.text('CPF *'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '52998224725');
    expect(c.text, '529.982.247-25');
    expect(form.currentState!.validate(), isTrue);

    await tester.enterText(find.byType(TextFormField), '11111111111');
    expect(form.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('CPF inválido, verifique os números digitados'), findsOneWidget);
  });

  testWidgets('CNPJ: rótulo, máscara e validação', (tester) async {
    final c = TextEditingController();
    final form = await abrir(tester, juridica: true, controller: c);

    expect(find.text('CNPJ *'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '11222333000181');
    expect(c.text, '11.222.333/0001-81');
    expect(form.currentState!.validate(), isTrue);

    await tester.enterText(find.byType(TextFormField), '11222333000180');
    expect(form.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('CNPJ inválido, verifique os números digitados'), findsOneWidget);
  });

  testWidgets('um CPF não passa como CNPJ e vice-versa', (tester) async {
    final c = TextEditingController();
    final form = await abrir(tester, juridica: true, controller: c);
    await tester.enterText(find.byType(TextFormField), '52998224725');
    expect(form.currentState!.validate(), isFalse);

    c.clear();
    final c2 = TextEditingController();
    final form2 = await abrir(tester, juridica: false, controller: c2);
    await tester.enterText(find.byType(TextFormField), '11222333000181');
    // a máscara de CPF corta em 11 dígitos: 112.223.330-00 (inválido)
    expect(form2.currentState!.validate(), isFalse);
  });

  testWidgets('vazio: documento obrigatório pede o CNPJ', (tester) async {
    final c = TextEditingController();
    final form = await abrir(tester, juridica: true, controller: c);
    expect(form.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Informe o CNPJ'), findsOneWidget);
  });
}
