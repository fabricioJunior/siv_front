import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/presentation/pages/pedido_entrada/componentes_entrada.dart';
import 'package:comercial/presentation/pages/pedido_entrada/painel_contagem_grade.dart';
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _painel({List<EntradaContagem> existentes = const []}) => MaterialApp(
      theme: SivTheme.tema,
      home: Scaffold(
        body: PainelContagemGrade(
          titulo: 'Contar',
          subtitulo: 's',
          permiteTrocarAba: true,
          referenciaId: 1,
          referenciaNome: 'Aurora',
          existentes: existentes,
          corSeletor: (d) => TextButton(
            key: const Key('add_cor'),
            onPressed: () => d.onChanged!([SelectData(id: 1, nome: 'Vinho', data: const {})]),
            child: const Text('cor'),
          ),
          tamanhoSeletor: (d) => const SizedBox(),
          carregarTamanhos: () async => const [
            TamanhoOpcao(id: 1, nome: '36'),
            TamanhoOpcao(id: 2, nome: '38'),
            TamanhoOpcao(id: 3, nome: 'P'),
            TamanhoOpcao(id: 4, nome: 'M'),
          ],
          onSalvar: (l, i) {},
          onFechar: () {},
        ),
      ),
    );

Future<void> _ate(WidgetTester t, String tipo) async {
  await t.tap(find.text(tipo));
  await t.pumpAndSettle();
}

void main() {
  setUp(() {
    nomesCor.clear();
    nomesTamanho.clear();
  });

  testWidgets('sem quantidade digitada, trocar para LETRAS tira os numéricos sem perguntar', (t) async {
    await t.pumpWidget(_painel());
    await t.tap(find.byKey(const Key('add_cor')));
    await t.pump();
    await _ate(t, 'NUMÉRICO');
    expect(find.text('36'), findsWidgets);

    await _ate(t, 'LETRAS');

    expect(find.text('Trocar o tipo de tamanho?'), findsNothing);
    expect(find.text('P'), findsWidgets);
    expect(find.text('36'), findsNothing);
  });

  testWidgets('com quantidade digitada, pergunta; CANCELAR mantém tudo como estava', (t) async {
    await t.pumpWidget(_painel());
    await t.tap(find.byKey(const Key('add_cor')));
    await t.pump();
    await _ate(t, 'NUMÉRICO');
    await t.enterText(find.byType(TextField).first, '3');
    await t.pump();

    await _ate(t, 'LETRAS');
    expect(find.text('Trocar o tipo de tamanho?'), findsOneWidget);
    await t.tap(find.byKey(const Key('trocar_tipo_cancelar')));
    await t.pumpAndSettle();

    expect(find.text('36'), findsWidgets);
    expect(find.text('P'), findsNothing);
    expect(find.text('3'), findsWidgets); // quantidade preservada
  });

  testWidgets('com quantidade digitada, TROCAR descarta as colunas do outro tipo', (t) async {
    await t.pumpWidget(_painel());
    await t.tap(find.byKey(const Key('add_cor')));
    await t.pump();
    await _ate(t, 'NUMÉRICO');
    await t.enterText(find.byType(TextField).first, '3');
    await t.pump();

    await _ate(t, 'LETRAS');
    await t.tap(find.byKey(const Key('trocar_tipo_confirmar')));
    await t.pumpAndSettle();

    expect(find.text('36'), findsNothing);
    expect(find.text('38'), findsNothing);
    expect(find.text('P'), findsWidgets);
  });

  testWidgets('tamanho de contagem já salva não é descartado pela troca de tipo', (t) async {
    await t.pumpWidget(_painel(existentes: const [
      EntradaContagem(
        produtoId: 10,
        linhaId: null,
        quantidade: 5,
        referenciaId: 1,
        corId: 1,
        corNome: 'Vinho',
        tamanhoId: 1,
        tamanhoNome: '36',
      ),
    ]));

    await _ate(t, 'LETRAS');

    expect(find.text('Trocar o tipo de tamanho?'), findsNothing);
    expect(find.text('36'), findsWidgets); // salvo: continua
    expect(find.text('P'), findsWidgets);
  });

  test('compararTamanhos: números pelo valor, depois letras na ordem usual, depois o resto', () {
    final nomes = ['XG', '44', 'M', '34', 'GG', 'P', '10', '38', 'PP', 'G', '40,5', 'UN', 'Zeta', 'G1'];
    nomes.sort(compararTamanhos);
    expect(nomes, ['10', '34', '38', '40,5', '44', 'PP', 'P', 'M', 'G', 'GG', 'XG', 'G1', 'UN', 'Zeta']);
  });

  testWidgets('colunas de tamanho saem em ordem: 34 vem antes do 36 mesmo cadastrado depois', (t) async {
    await t.pumpWidget(MaterialApp(
      theme: SivTheme.tema,
      home: Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 900,
            height: 700,
            child: PainelContagemGrade(
              titulo: 'Contar',
              subtitulo: 's',
              permiteTrocarAba: true,
              referenciaId: 1,
              referenciaNome: 'Aurora',
              corSeletor: (d) => TextButton(
                key: const Key('add_cor'),
                onPressed: () => d.onChanged!([SelectData(id: 1, nome: 'Vinho', data: const {})]),
                child: const Text('cor'),
              ),
              tamanhoSeletor: (d) => const SizedBox(),
              carregarTamanhos: () async => const [
                TamanhoOpcao(id: 4, nome: '36'),
                TamanhoOpcao(id: 5, nome: '38'),
                TamanhoOpcao(id: 6, nome: '40'),
                TamanhoOpcao(id: 11, nome: '34'),
              ],
              onSalvar: (l, i) {},
              onFechar: () {},
            ),
          ),
        ),
      ),
    ));
    await t.tap(find.byKey(const Key('add_cor')));
    await t.pump();
    await t.tap(find.text('NUMÉRICO'));
    await t.pumpAndSettle();

    final xs = ['34', '36', '38', '40'].map((n) => t.getTopLeft(find.text(n).first).dx).toList();
    expect(xs, orderedEquals([...xs]..sort()));
  });
}
