import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:financeiro/domain/models/forma_de_pagamento.dart';
import 'package:financeiro/presentation/widgets/formas_de_pagamento_grade.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

FormaDePagamento _f(
  int id,
  String descricao,
  String tipo, {
  bool inativa = false,
  TipoOperacaoFormaPagamento op = TipoOperacaoFormaPagamento.manual,
}) =>
    FormaDePagamento.create(
      id: id,
      descricao: descricao,
      inicio: 1,
      parcelas: 1,
      tipo: tipo,
      inativa: inativa,
      tipoOperacao: op,
    );

final _formas = [
  _f(1, 'Dinheiro', 'Dinheiro'),
  _f(2, 'Pix manual', 'Pix'),
  _f(3, 'Cartão PagBank x1', 'Cartão'),
  _f(4, 'Cartão Stone x1', 'Cartão'),
  _f(5, 'Débito PagBank', 'Cartão de débito'),
  _f(6, 'Troco', 'Troco'),
  _f(7, 'Crédito de devolução', 'Crédito de devolução'),
  _f(8, 'Fatura antiga', 'Fatura', inativa: true),
  _f(9, 'Pix online', 'Pix', op: TipoOperacaoFormaPagamento.online),
];

Future<void> _pump(
  WidgetTester t, {
  required void Function(SelectData) onEscolhida,
  String? tipoOperacao,
  Set<int>? idsPermitidos,
  double saldo = 0,
  Map<int, int> uso = const {},
}) async {
  t.view.physicalSize = const Size(1200, 900);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(
      theme: SivTheme.tema,
      home: Scaffold(
        body: SingleChildScrollView(
          child: FormasDePagamentoGrade(
            carregarFormas: () async => _formas,
            carregarUso: () async => uso,
            data: FormaPagamentoGradeData(
              onEscolhida: onEscolhida,
              tipoOperacao: tipoOperacao,
              idsPermitidos: idsPermitidos,
              saldoCliente: saldo,
            ),
          ),
        ),
      ),
    ),
  );
  await t.pumpAndSettle();
}

void main() {
  _grupoFoco();
  testWidgets('tipos fixos: sem tipo vazio/inativo/Troco; Saldo só com saldo',
      (t) async {
    await _pump(t, onEscolhida: (_) {});
    expect(find.text('Dinheiro'), findsOneWidget);
    expect(find.text('Cartão crédito'), findsOneWidget);
    expect(find.text('Cartão débito'), findsOneWidget);
    expect(find.text('Fatura'), findsNothing); // só forma inativa
    expect(find.text('Outros'), findsNothing); // nenhuma forma
    expect(find.text('Troco'), findsNothing);
    expect(find.text('Saldo do cliente'), findsNothing);

    await _pump(t, onEscolhida: (_) {}, saldo: 80);
    expect(find.text('Saldo do cliente'), findsOneWidget);
  });

  testWidgets('tipo com 1 forma escolhe direto; com várias abre a linha 2',
      (t) async {
    final escolhidas = <SelectData>[];
    await _pump(t, onEscolhida: escolhidas.add);

    await t.sendKeyEvent(LogicalKeyboardKey.keyD);
    await t.pump();
    expect(escolhidas.single.id, 1);
    expect(escolhidas.single.data['tipo'], 'Dinheiro');

    await t.sendKeyEvent(LogicalKeyboardKey.keyC);
    await t.pump();
    expect(escolhidas.length, 1); // 2 formas: ainda não escolheu
    expect(find.text('Cartão PagBank x1'), findsOneWidget);
    expect(find.text('Cartão Stone x1'), findsOneWidget);

    await t.tap(find.text('Cartão Stone x1'));
    expect(escolhidas.last.id, 4);
  });

  testWidgets('ordena por uso no terminal e Enter escolhe o destacado',
      (t) async {
    final escolhidas = <SelectData>[];
    await _pump(t, onEscolhida: escolhidas.add, uso: {4: 9});

    await t.sendKeyEvent(LogicalKeyboardKey.keyC);
    await t.pump();
    await t.sendKeyEvent(LogicalKeyboardKey.enter); // Stone (mais usada) 1º
    expect(escolhidas.single.id, 4);

    await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await t.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(escolhidas.last.id, 3);
  });

  testWidgets('tipoOperacao filtra e promoção restrita bloqueia o tipo',
      (t) async {
    final escolhidas = <SelectData>[];
    await _pump(
      t,
      onEscolhida: escolhidas.add,
      tipoOperacao: 'online',
    );
    expect(find.text('Pix'), findsOneWidget);
    expect(find.text('Dinheiro'), findsNothing);

    await _pump(t, onEscolhida: escolhidas.add, idsPermitidos: {1, 2});
    await t.tap(find.text('Cartão débito')); // tipo bloqueado pela promoção
    await t.pump();
    expect(escolhidas, isEmpty);
    await t.tap(find.text('Dinheiro'));
    expect(escolhidas.single.id, 1);
  });
}

void _grupoFoco() {
  testWidgets('pede o foco ao nó da hospedeira ao carregar e a letra escolhe',
      (t) async {
    final foco = FocusNode();
    final outro = FocusNode();
    addTearDown(foco.dispose);
    addTearDown(outro.dispose);
    final escolhidas = <SelectData>[];
    await t.pumpWidget(
      MaterialApp(
        theme: SivTheme.tema,
        home: Scaffold(
          body: Focus(
            focusNode: outro,
            autofocus: true,
            child: FormasDePagamentoGrade(
              carregarFormas: () async => _formas,
              carregarUso: () async => const {},
              data: FormaPagamentoGradeData(
                onEscolhida: escolhidas.add,
                foco: foco,
              ),
            ),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(foco.hasPrimaryFocus, isTrue);

    await t.sendKeyEvent(LogicalKeyboardKey.keyD);
    await t.pumpAndSettle();
    expect(escolhidas.single.nome, 'Dinheiro');
  });
}
