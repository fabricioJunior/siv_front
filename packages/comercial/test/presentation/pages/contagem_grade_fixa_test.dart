import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/presentation/pages/pedido_entrada/componentes_entrada.dart';
import 'package:comercial/presentation/pages/pedido_entrada/painel_contagem_grade.dart';
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contagem de [nc] cores × [nt] tamanhos já salva, cada célula com 1 peça.
List<EntradaContagem> _existentes(int nc, int nt) => [
      for (var c = 1; c <= nc; c++)
        for (var t = 1; t <= nt; t++)
          EntradaContagem(
            produtoId: c * 100 + t,
            linhaId: null,
            quantidade: 1,
            referenciaId: 1,
            corId: c,
            corNome: 'C$c',
            tamanhoId: t,
            tamanhoNome: '$t',
          ),
    ];

Widget _painel(
  int nc,
  int nt, {
  void Function(bool, List<ItemContagem>)? onSalvar,
  bool abas = false,
}) =>
    MaterialApp(
      theme: SivTheme.tema,
      home: Scaffold(
        body: PainelContagemGrade(
          titulo: 'Contar',
          subtitulo: 's',
          permiteTrocarAba: abas,
          referenciaId: 1,
          referenciaNome: 'Aurora',
          existentes: _existentes(nc, nt),
          corSeletor: (d) => const SizedBox(),
          tamanhoSeletor: (d) => const SizedBox(),
          fonteCores: FonteVariacao(carregar: () async => const []),
          carregarTamanhos: () async => const [],
          onSalvar: onSalvar ?? (l, i) {},
          onFechar: () {},
        ),
      ),
    );

Future<void> _mobile(WidgetTester t, Widget w) async {
  t.view.physicalSize = const Size(390, 844);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  nomesCor.clear();
  nomesTamanho.clear();
  await t.pumpWidget(const SizedBox()); // estado novo a cada chamada
  await t.pumpWidget(w);
  await t.pumpAndSettle();
}

Future<void> _naGrade(WidgetTester t) async {
  await t.tap(find.text('GRADE'));
  await t.pumpAndSettle();
}

Key _c(int c, int tam) => Key('contagem_${c}_$tam');
String _txt(WidgetTester t, Key k) =>
    t.widget<TextField>(find.byKey(k)).controller!.text;

void main() {
  testWidgets(
      'cabeçalho e coluna de cores seguem visíveis ao rolar nos dois eixos',
      (t) async {
    await _mobile(t, _painel(10, 10));
    await _naGrade(t);

    final cab = find.descendant(
        of: find.byKey(const Key('grade_cabecalho')), matching: find.text('1'));
    final nome = find.descendant(
        of: find.byKey(const Key('grade_coluna_cores')),
        matching: find.text('C1'));
    final cel = find.byKey(_c(1, 1));
    final h0 = t.getTopLeft(cab),
        n0 = t.getTopLeft(nome),
        c0 = t.getTopLeft(cel);

    await t.drag(cel, const Offset(-200, 0),
        warnIfMissed: false); // começa numa célula
    await t.pumpAndSettle();
    var h = t.getTopLeft(cab), c = t.getTopLeft(cel);
    expect(c.dx, lessThan(c0.dx - 100), reason: 'o corpo rolou na horizontal');
    expect(h.dx - c.dx, closeTo(h0.dx - c0.dx, 0.5),
        reason: 'cabeçalho acompanha');
    expect(h.dy, h0.dy, reason: 'cabeçalho fica no lugar');
    expect(t.getTopLeft(nome), n0, reason: 'coluna de cores fica no lugar');

    final outra = find.byKey(_c(1, 5)); // a (1,1) já rolou para fora
    await t.drag(outra, const Offset(0, -100), warnIfMissed: false);
    await t.pumpAndSettle();
    h = t.getTopLeft(cab);
    c = t.getTopLeft(outra);
    final n = t.getTopLeft(nome);
    expect(c.dy, lessThan(c0.dy - 50), reason: 'o corpo rolou na vertical');
    expect(n.dy - c.dy, closeTo(n0.dy - c0.dy, 0.5),
        reason: 'cores acompanham');
    expect(n.dx, n0.dx);
    expect(h.dy, h0.dy, reason: 'cabeçalho continua visível');
  });

  testWidgets('destaque em cruz e mapa 3×3 movem o foco; bordas ficam vazias',
      (t) async {
    await _mobile(t, _painel(4, 6));
    await _naGrade(t);

    await t.tap(find.byKey(_c(1, 1)), warnIfMissed: false);
    await t.pumpAndSettle();
    expect(find.text('C1 · 1'), findsOneWidget);
    expect(find.text('linha 1 de 4 · coluna 1 de 6'), findsOneWidget);
    // canto superior-esquerdo: sem vizinhas acima nem à esquerda
    expect(find.byKey(const Key('mapa_0_0')), findsNothing);
    expect(find.byKey(const Key('mapa_0_1')), findsNothing);
    expect(find.byKey(const Key('mapa_1_0')), findsNothing);
    expect(find.byKey(const Key('mapa_2_2')), findsOneWidget);

    await t.tap(find.byKey(const Key('mapa_2_2'))); // abaixo-direita
    await t.pumpAndSettle();
    expect(find.text('C2 · 2'), findsOneWidget);
    expect(find.text('linha 2 de 4 · coluna 2 de 6'), findsOneWidget);
    expect(find.byKey(const Key('mapa_0_0')), findsOneWidget);

    await t.tap(find.byKey(const Key('mapa_1_2'))); // à direita
    await t.pumpAndSettle();
    expect(find.text('C2 · 3'), findsOneWidget);

    // mapa respeita a borda inferior
    await t.ensureVisible(find.byKey(_c(4, 6)));
    await t.pumpAndSettle();
    await t.tap(find.byKey(_c(4, 6)), warnIfMissed: false);
    await t.pumpAndSettle();
    expect(find.text('C4 · 6'), findsOneWidget);
    expect(find.byKey(const Key('mapa_2_1')), findsNothing);
    expect(find.byKey(const Key('mapa_1_2')), findsNothing);
    expect(find.byKey(const Key('mapa_0_0')), findsOneWidget);
  });

  testWidgets('Por cor e Grade mostram os mesmos valores', (t) async {
    await _mobile(t, _painel(3, 6));
    // mobile com mais de 4 tamanhos abre em Por cor
    expect(find.byKey(const Key('por_cor')), findsOneWidget);
    expect(find.text('6 peças nesta cor'), findsOneWidget);

    await t.enterText(find.byKey(const Key('pc_1_1')), '5');
    await t.pump();
    expect(find.text('10 peças nesta cor'), findsOneWidget);
    await t.tap(find.byKey(const Key('pc_mais_1_2')));
    await t.pump();
    expect(find.text('11 peças nesta cor'), findsOneWidget);
    _desfocar();
    await _naGrade(t);
    expect(_txt(t, _c(1, 1)), '5');
    expect(_txt(t, _c(1, 2)), '2');

    await t.enterText(find.byKey(_c(2, 3)), '9');
    _desfocar();
    await t.tap(find.text('POR COR'));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('pc_chip_2')));
    await t.pumpAndSettle();
    expect(_txt(t, const Key('pc_2_3')), '9');
    expect(find.text('14 peças nesta cor'), findsOneWidget);
  });

  testWidgets('salvar envia o mesmo payload nos dois modos', (t) async {
    Future<Set<(int, int, double)>> salvar(bool porCor) async {
      List<ItemContagem>? itens;
      await _mobile(t, _painel(3, 6, onSalvar: (_, i) => itens = i));
      if (porCor) {
        await t.enterText(find.byKey(const Key('pc_1_1')), '5');
        await t.tap(find.byKey(const Key('pc_chip_2')));
        await t.pumpAndSettle();
        await t.enterText(find.byKey(const Key('pc_2_3')), '9');
      } else {
        await _naGrade(t);
        await t.enterText(find.byKey(_c(1, 1)), '5');
        await t.enterText(find.byKey(_c(2, 3)), '9');
      }
      _desfocar();
      await t.pump();
      await t.tap(find.textContaining('SALVAR'));
      await t.pumpAndSettle();
      return {for (final i in itens!) (i.corId!, i.tamanhoId!, i.quantidade)};
    }

    final grade = await salvar(false);
    final porCor = await salvar(true);
    expect(grade.length, 18);
    expect(grade, contains((1, 1, 5.0)));
    expect(grade, contains((2, 3, 9.0)));
    expect(porCor, grade);
  });
}

void _desfocar() => FocusManager.instance.primaryFocus?.unfocus();
