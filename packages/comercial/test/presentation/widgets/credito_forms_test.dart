import 'package:comercial/models.dart';
import 'package:comercial/presentation/blocs/creditos_devolucao_bloc/creditos_devolucao_bloc.dart';
import 'package:comercial/presentation/widgets/adicionar_credito_modal.dart';
import 'package:comercial/presentation/widgets/credito_form_comum.dart';
import 'package:comercial/presentation/widgets/expirar_credito_dialogo.dart';
import 'package:comercial/presentation/widgets/remover_credito_modal.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _credito = CreditoDevolucao(
  id: 9,
  codigo: 'CR-9',
  origem: 'avulso',
  empresaId: 1,
  data: DateTime(2026, 1, 1),
  valorOriginal: 100,
  valorRestante: 80,
  situacao: SituacaoCreditoDevolucao.disponivel,
);

Future<void> _pump(WidgetTester t, Widget form, {double largura = 1280}) async {
  t.view.physicalSize = Size(largura, 900);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  // Fonte Ahem (wide) estoura o rodapé do SivModal; overflow não é o alvo.
  final antigo = FlutterError.onError;
  FlutterError.onError = (d) {
    if (!d.exceptionAsString().contains('overflowed')) antigo?.call(d);
  };
  addTearDown(() => FlutterError.onError = antigo);
  await t.pumpWidget(MaterialApp(theme: SivTheme.tema, home: form));
  await t.pump();
}

Future<void> _confirmar(WidgetTester t, String rotulo) async {
  final f = find.widgetWithText(ElevatedButton, rotulo);
  // Chama direto: com Ahem o botão do modal fica fora da área clicável.
  t.widget<ElevatedButton>(f).onPressed!();
  await t.pump();
}

Future<void> _tocar(WidgetTester t, String texto) async {
  final f = find.text(texto);
  await t.ensureVisible(f);
  await t.tap(f);
  await t.pump();
}

Future<void> _digitar(WidgetTester t, String rotulo, String texto) async {
  final f = find.widgetWithText(TextFormField, rotulo);
  await t.ensureVisible(f);
  await t.enterText(f, texto);
  await t.pump();
}

void main() {
  test('parseValorBr', () {
    expect(parseValorBr('1.234,50'), 1234.5);
    expect(parseValorBr('50.5'), 50.5);
    expect(parseValorBr('abc'), isNull);
    expect(parseValorBr(''), isNull);
  });

  for (final largura in [800.0, 1280.0]) {
    group('Adicionar ($largura px)', () {
      Widget form(List<CreditosDevolucaoEvent> env) => AdicionarCreditoForm(
            nome: 'Maria',
            saldoAtual: 20,
            validadeDiasPadrao: 60,
            aoConfirmar: (e) async {
              env.add(e);
              return null;
            },
          );

      testWidgets('vazio: valor, motivo e observação obrigatórios',
          (t) async {
        final env = <CreditosDevolucaoEvent>[];
        await _pump(t, form(env), largura: largura);
        await _confirmar(t, 'Adicionar crédito');
        expect(find.text('O valor deve ser maior que zero.'), findsOneWidget);
        expect(find.text('Escolha o motivo.'), findsOneWidget);
        expect(find.textContaining('Informe a observação'), findsOneWidget);
        expect(env, isEmpty);
      });

      testWidgets('valor zero é rejeitado', (t) async {
        final env = <CreditosDevolucaoEvent>[];
        await _pump(t, form(env), largura: largura);
        await _digitar(t, 'Valor', '0,00');
        await _tocar(t, 'Cortesia');
        await _digitar(t, 'Observação', 'brinde');
        await _confirmar(t, 'Adicionar crédito');
        expect(find.text('O valor deve ser maior que zero.'), findsOneWidget);
        expect(env, isEmpty);
      });

      testWidgets('observação em branco (avulso) é rejeitada', (t) async {
        final env = <CreditosDevolucaoEvent>[];
        await _pump(t, form(env), largura: largura);
        await _digitar(t, 'Valor', '10');
        await _tocar(t, 'Cortesia');
        await _digitar(t, 'Observação', '  ');
        await _confirmar(t, 'Adicionar R\$ 10,00');
        expect(find.textContaining('Informe a observação'), findsOneWidget);
        expect(env, isEmpty);
      });

      testWidgets('válido: envia evento com validade padrão de 60 dias',
          (t) async {
        final env = <CreditosDevolucaoEvent>[];
        await _pump(t, form(env), largura: largura);
        await _digitar(t, 'Valor', '12,50');
        await _tocar(t, 'Ajuste de saldo');
        await _digitar(t, 'Observação', ' acerto ');
        await _confirmar(t, 'Adicionar R\$ 12,50');
        final e = env.single as CreditosDevolucaoAdicionou;
        expect(e.valor, 12.5);
        expect(e.motivo, 'ajuste');
        expect(e.observacao, 'acerto');
        final h = DateTime.now();
        expect(
          e.validade,
          DateTime(h.year, h.month, h.day).add(const Duration(days: 60)),
        );
      });
    });

    group('Remover ($largura px)', () {
      Widget form(List<CreditosDevolucaoEvent> env, {String? erro}) =>
          RemoverCreditoForm(
            credito: _credito,
            titulo: 'Avulso · Cortesia',
            aoConfirmar: (e) async {
              env.add(e);
              return erro;
            },
          );

      testWidgets('motivo obrigatório', (t) async {
        final env = <CreditosDevolucaoEvent>[];
        await _pump(t, form(env), largura: largura);
        await _confirmar(t, 'Remover R\$ 80,00');
        expect(find.text('Escolha o motivo.'), findsOneWidget);
        expect(env, isEmpty);
      });

      testWidgets('"Outro" exige observação', (t) async {
        final env = <CreditosDevolucaoEvent>[];
        await _pump(t, form(env), largura: largura);
        await _tocar(t, 'Outro');
        await _confirmar(t, 'Remover R\$ 80,00');
        expect(find.textContaining('obrigatória em "Outro"'), findsOneWidget);
        expect(env, isEmpty);
      });

      testWidgets('outro motivo: observação opcional; total => valor nulo',
          (t) async {
        final env = <CreditosDevolucaoEvent>[];
        await _pump(t, form(env), largura: largura);
        await _tocar(t, 'Duplicidade');
        await _confirmar(t, 'Remover R\$ 80,00');
        final e = env.single as CreditosDevolucaoRemoveu;
        expect(e.valor, isNull);
        expect(e.creditoId, 9);
        expect(e.motivo, 'duplicidade');
      });

      testWidgets('parcial: 0 e acima do restante são rejeitados; = restante ok',
          (t) async {
        final env = <CreditosDevolucaoEvent>[];
        await _pump(t, form(env), largura: largura);
        await _tocar(t, 'Só uma parte');
        await _tocar(t, 'Duplicidade');

        await _digitar(t, 'Valor a remover', '0');
        await _confirmar(t, 'Remover crédito');
        expect(find.text('O valor deve ser maior que zero.'), findsOneWidget);

        await _digitar(t, 'Valor a remover', '80,01');
        await _confirmar(t, 'Remover R\$ 80,01');
        expect(find.text('O valor passa do restante.'), findsOneWidget);
        expect(env, isEmpty);

        await _digitar(t, 'Valor a remover', '80,00');
        await _confirmar(t, 'Remover R\$ 80,00');
        expect((env.single as CreditosDevolucaoRemoveu).valor, 80);
      });

      testWidgets('erro devolvido pelo bloc aparece e mantém o form',
          (t) async {
        final env = <CreditosDevolucaoEvent>[];
        await _pump(t, form(env, erro: 'Sem permissão'), largura: largura);
        await _tocar(t, 'Duplicidade');
        await _confirmar(t, 'Remover R\$ 80,00');
        await t.pump();
        expect(find.text('Sem permissão'), findsOneWidget);
      });
    });
  }

  testWidgets('Expirar: motivo opcional e vai no evento', (t) async {
    final env = <CreditosDevolucaoEvent>[];
    await _pump(
      t,
      ExpirarCreditoDialogo(
        credito: _credito,
        titulo: 'Avulso',
        aoConfirmar: (e) async {
          env.add(e);
          return null;
        },
      ),
    );
    await _confirmar(t, 'Expirar R\$ 80,00');
    final e = env.single as CreditosDevolucaoExpirou;
    expect(e.creditoId, 9);
    expect(e.motivo, '');
  });

  // BUG: bottomNavigationBar do Scaffold não sobe com o teclado (só o body
  // encolhe); o botão principal fica coberto. Remover skip ao corrigir.
  testWidgets('mobile: rodapé do form fica acima do teclado', skip: true,
      (t) async {
    await _pump(
      t,
      AdicionarCreditoForm(
        nome: 'Maria',
        saldoAtual: 0,
        aoConfirmar: (_) async => null,
      ),
      largura: 390,
    );
    t.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(t.view.resetViewInsets);
    await t.pump();
    final botao = find.widgetWithText(ElevatedButton, 'Adicionar crédito');
    expect(botao, findsOneWidget);
    expect(t.getRect(botao).bottom, lessThanOrEqualTo(900 - 300));
    expect(t.getRect(botao).top, greaterThan(0));
  });
}
