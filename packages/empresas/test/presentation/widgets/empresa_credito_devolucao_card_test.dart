import 'package:core/injecoes.dart';
import 'package:core/tema.dart';
import 'package:empresas/models.dart';
import 'package:empresas/presentation/blocs/config_credito_devolucao_bloc/config_credito_devolucao_bloc.dart';
import 'package:empresas/presentation/widgets/empresa_credito_devolucao_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../blocs/config_credito_devolucao_bloc_test.dart';

Future<FakeSalvarConfig> _pump(WidgetTester t, {double largura = 1280}) async {
  t.view.physicalSize = Size(largura, 900);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await sl.reset();
  addTearDown(sl.reset);
  final salvar = FakeSalvarConfig();
  sl.registerFactory(
      () => ConfigCreditoDevolucaoBloc(FakeRecuperarConfig(), salvar));
  await t.pumpWidget(MaterialApp(
    theme: SivTheme.tema,
    home: const Scaffold(
      body: SingleChildScrollView(child: EmpresaCreditoDevolucaoCard(idEmpresa: 4)),
    ),
  ));
  await t.pumpAndSettle();
  return salvar;
}

void main() {
  for (final w in [800.0, 1280.0]) {
    testWidgets('salva validade e aviso escolhidos ($w px)', (t) async {
      final salvar = await _pump(t, largura: w);
      expect(find.text('Crédito de devolução'), findsOneWidget);
      await t.tap(find.text('Sem validade'));
      await t.pump();
      await t.enterText(find.byType(TextField), '5');
      await t.tap(find.text('Salvar'));
      await t.pumpAndSettle();
      expect(salvar.chamada,
          (4, const ConfigCreditoDevolucao(validadeDiasPadrao: null, avisoDiasAntes: 5)));
      expect(find.text('Configuração salva.'), findsOneWidget);
    });
  }

  testWidgets('aviso vazio vira 0 dias', (t) async {
    final salvar = await _pump(t);
    await t.enterText(find.byType(TextField), '');
    await t.tap(find.text('Salvar'));
    await t.pumpAndSettle();
    expect(salvar.chamada!.$2.avisoDiasAntes, 0);
  });
}
