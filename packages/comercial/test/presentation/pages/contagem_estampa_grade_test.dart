import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/presentation/pages/pedido_entrada/componentes_entrada.dart';
import 'package:comercial/presentation/pages/pedido_entrada/painel_contagem_grade.dart';
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _painel(void Function(bool, List<ItemContagem>) onSalvar) => MaterialApp(
      theme: SivTheme.tema,
      home: Scaffold(
        body: PainelContagemGrade(
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
          tamanhoSeletor: (d) => TextButton(
            key: const Key('add_tam'),
            onPressed: () => d.onChanged!([SelectData(id: 1, nome: 'M', data: const {})]),
            child: const Text('tam'),
          ),
          estampaSeletor: (d) => TextButton(
            key: const Key('add_estampa'),
            onPressed: () => d.onChanged!([
              SelectData(id: 7, nome: 'Floral', data: const {}),
              SelectData(id: 8, nome: 'Listra', data: const {}),
            ]),
            child: const Text('estampa'),
          ),
          onSalvar: onSalvar,
          onFechar: () {},
        ),
      ),
    );

void main() {
  setUp(() {
    nomesCor.clear();
    nomesTamanho.clear();
  });

  testWidgets('cada estampa ganha a sua grade, além do liso', (t) async {
    List<ItemContagem>? salvo;
    await t.pumpWidget(_painel((_, i) => salvo = i));
    await t.tap(find.byKey(const Key('add_cor')));
    await t.tap(find.byKey(const Key('add_tam')));
    await t.pump();
    expect(find.byKey(const Key('contagem_1_1')), findsOneWidget);
    expect(find.text('LISO (SEM ESTAMPA)'), findsNothing); // sem estampa: grade única, sem título

    await t.tap(find.byKey(const Key('add_estampa')));
    await t.pump();

    expect(find.text('LISO (SEM ESTAMPA)'), findsOneWidget);
    expect(find.text('FLORAL'), findsOneWidget);
    expect(find.text('LISTRA'), findsOneWidget);
    await t.enterText(find.byKey(const Key('contagem_1_1')), '2');
    await t.enterText(find.byKey(const Key('contagem_1_1_e7')), '3');
    await t.enterText(find.byKey(const Key('contagem_1_1_e8')), '4');
    FocusManager.instance.primaryFocus?.unfocus(); // com foco o rodapé some (C3)
    await t.pump();

    await t.tap(find.text('SALVAR'));
    expect(
      salvo!.map((i) => (i.estampaId, i.quantidade)).toSet(),
      {(null, 2.0), (7, 3.0), (8, 4.0)},
    );
  });

  testWidgets('estampa escolhida antes de cor/tamanho avisa o que falta', (t) async {
    await t.pumpWidget(_painel((_, __) {}));
    await t.tap(find.byKey(const Key('add_estampa')));
    await t.pump();
    expect(find.byKey(const Key('contagem_estampa_sem_grade')), findsOneWidget);
  });
}
