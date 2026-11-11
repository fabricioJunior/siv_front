import 'package:core/bloc.dart';
import 'package:core/tema.dart';
import 'package:empresas/domain/entities/integracao_infinity_pay.dart';
import 'package:empresas/presentation/blocs/integracao_infinity_pay_bloc/integracao_infinity_pay_bloc.dart';
import 'package:empresas/presentation/pages/integracoes_pagamento_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../doubles/infinity_pay_fakes.dart';

Future<ServidorParametros> _pump(
  WidgetTester t, {
  double largura = 1280,
  Map<String, String> over = const {},
}) async {
  t.view.physicalSize = Size(largura, 1000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final srv = ServidorParametros({...parametrosBase(), ...over});
  final bloc = IntegracaoInfinityPayBloc(
    FakeRecuperarParametros(srv),
    FakeAtualizarParametros(srv),
    'https://api.loja.com',
  )..add(IntegracaoInfinityPayIniciou(1));
  addTearDown(bloc.close);
  await t.pumpWidget(
    MaterialApp(
      theme: SivTheme.tema,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider.value(
                    value: bloc,
                    child: const IntegracoesPagamentoView(),
                  ),
                ),
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    ),
  );
  await t.tap(find.text('abrir'));
  await t.pumpAndSettle();
  return srv;
}

Finder _campo(CampoInfinityPay c) => find.byKey(Key('campo_${c.name}'));

FilledButton _salvar(WidgetTester t) =>
    t.widget<FilledButton>(find.widgetWithText(FilledButton, 'SALVAR'));

Future<void> _digitar(WidgetTester t, CampoInfinityPay c, String v) async {
  await t.ensureVisible(_campo(c));
  await t.enterText(_campo(c), v);
  await t.pump();
}

void main() {
  group('desktop', () {
    testWidgets('selo nos 3 estados', (t) async {
      await _pump(t);
      expect(find.text('DESLIGADA'), findsWidgets);
      expect(find.text('ATIVA'), findsOneWidget); // só Mercado Pago

      await t.tap(find.byKey(const Key('switch_habilitada')));
      await t.pump();
      expect(find.text('INCOMPLETA'), findsNWidgets(2)); // gateway + form

      await _digitar(t, CampoInfinityPay.handle, r'$vale doceara');
      expect(find.text('ATIVA'), findsNWidgets(3));
      expect(
        t.widget<TextField>(_campo(CampoInfinityPay.handle)).controller!.text,
        'valedoceara',
      );
    });

    testWidgets('checklist reflete o estado', (t) async {
      await _pump(t);
      Finder icone(String k, IconData i) => find.descendant(
        of: find.byKey(Key('check_$k')),
        matching: find.byIcon(i),
      );
      expect(icone('ligada', Icons.radio_button_unchecked), findsOneWidget);
      expect(icone('email', Icons.error_outline), findsOneWidget);

      await t.tap(find.byKey(const Key('switch_habilitada')));
      await t.pump();
      expect(icone('ligada', Icons.check_circle), findsOneWidget);
      expect(icone('handle', Icons.error_outline), findsOneWidget);
      expect(icone('webhook', Icons.error_outline), findsOneWidget);

      await _digitar(t, CampoInfinityPay.handle, 'vale');
      await t.ensureVisible(find.text('Usar endereço padrão desta API'));
      await t.tap(find.text('Usar endereço padrão desta API'));
      await t.pump();
      await _digitar(t, CampoInfinityPay.emailEstorno, 'a@b.com');
      for (final k in ['ligada', 'handle', 'webhook', 'email']) {
        expect(icone(k, Icons.check_circle), findsOneWidget, reason: k);
      }
      expect(
        find.text('✓ Endereço padrão desta API para esta empresa.'),
        findsOneWidget,
      );
    });

    testWidgets('SALVAR desabilitado sem alteração e com erro', (t) async {
      final srv = await _pump(t);
      expect(_salvar(t).onPressed, isNull);
      expect(find.text('Tudo salvo'), findsOneWidget);

      await t.tap(find.byKey(const Key('switch_habilitada')));
      await t.pump();
      expect(find.text('1 campo precisa de ajuste'), findsOneWidget);
      expect(_salvar(t).onPressed, isNull);

      await _digitar(t, CampoInfinityPay.handle, 'vale');
      expect(find.text('2 alterações não salvas'), findsOneWidget);
      expect(_salvar(t).onPressed, isNotNull);

      await t.tap(find.text('SALVAR'));
      await t.pumpAndSettle();
      expect(find.text('✓ Configuração salva'), findsOneWidget);
      expect(srv.valores['INTEGRACAO_INFINITY_PAY_API_HANDLE'], 'vale');
    });

    testWidgets('parcelas e Pix exigem API Key', (t) async {
      await _pump(t);
      await t.ensureVisible(_campo(CampoInfinityPay.parcelasSemJuros));
      expect(
        t.widget<TextField>(_campo(CampoInfinityPay.parcelasSemJuros)).enabled,
        isFalse,
      );
      expect(find.text('Exige a API Key'), findsWidgets);
      await _digitar(t, CampoInfinityPay.apiKey, 'inchk_abc');
      expect(
        t.widget<TextField>(_campo(CampoInfinityPay.parcelasSemJuros)).enabled,
        isTrue,
      );
    });

    testWidgets('Mercado Pago mostra status real e snackbar', (t) async {
      await _pump(t);
      await t.tap(find.byKey(const Key('gateway_Mercado Pago')));
      await t.pump();
      expect(
        find.text('Em breve nesta tela. Use Parâmetros da empresa.'),
        findsOneWidget,
      );
    });

    testWidgets('PopScope com alterações pendentes', (t) async {
      await _pump(t);
      await _digitar(t, CampoInfinityPay.emailEstorno, 'a@b.com');

      final nav = t.state<NavigatorState>(find.byType(Navigator));
      nav.maybePop();
      await t.pumpAndSettle();
      expect(find.text('Descartar alterações?'), findsOneWidget);

      await t.tap(find.text('CONTINUAR EDITANDO'));
      await t.pumpAndSettle();
      expect(find.byType(IntegracoesPagamentoView), findsOneWidget);

      nav.maybePop();
      await t.pumpAndSettle();
      await t.tap(find.text('DESCARTAR'));
      await t.pumpAndSettle();
      expect(find.byType(IntegracoesPagamentoView), findsNothing);
    });

    testWidgets('sem alterações sai direto', (t) async {
      await _pump(t);
      t.state<NavigatorState>(find.byType(Navigator)).maybePop();
      await t.pumpAndSettle();
      expect(find.byType(IntegracoesPagamentoView), findsNothing);
    });
  });

  group('mobile', () {
    testWidgets('lista resume o estado e abre o formulário', (t) async {
      await _pump(
        t,
        largura: 400,
        over: {
          'INTEGRACAO_INFINITY_PAY_HABILITADA': 'S',
          'INTEGRACAO_INFINITY_PAY_API_HANDLE': 'valedoceara',
        },
      );
      expect(find.text(r'$valedoceara · sem webhook'), findsOneWidget);
      expect(
        find.text('ATIVA'),
        findsNWidgets(2),
      ); // InfinityPay + Mercado Pago
      final linha = t.getSize(find.byKey(const Key('gateway_InfinityPay')));
      expect(linha.height, greaterThanOrEqualTo(64));

      await t.tap(find.byKey(const Key('gateway_InfinityPay')));
      await t.pumpAndSettle();
      expect(find.text('SALVAR'), findsOneWidget);
      expect(find.text('Descartar'), findsOneWidget);
    });

    testWidgets('alvos de toque >= 44px', (t) async {
      await _pump(t, largura: 400);
      await t.tap(find.byKey(const Key('gateway_InfinityPay')));
      await t.pumpAndSettle();
      for (final tipo in [
        FilledButton,
        OutlinedButton,
        TextButton,
        IconButton,
      ]) {
        for (final e in find.byType(tipo).evaluate()) {
          final r = t.getRect(find.byWidget(e.widget));
          expect(r.height, greaterThanOrEqualTo(44), reason: '$tipo');
          expect(r.width, greaterThanOrEqualTo(44), reason: '$tipo');
        }
      }
      for (final k in ['switch_habilitada', 'switch_pix']) {
        await t.ensureVisible(find.byKey(Key(k)));
        expect(t.getSize(find.byKey(Key(k))).height, greaterThanOrEqualTo(56));
      }
    });
  });
}
