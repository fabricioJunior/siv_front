import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/presentation/pages/pedido_entrada/componentes_entrada.dart';
import 'package:comercial/presentation/pages/pedido_entrada/painel_contagem_grade.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/variacoes_fakes.dart';

VariacoesGatewayFake _gateway() => VariacoesGatewayFake(
      coresLista: const [
        VariacaoOpcao(id: 1, nome: 'Vinho'),
        VariacaoOpcao(id: 2, nome: 'Nude'),
        VariacaoOpcao(id: 3, nome: 'Azul'),
      ],
      estampasLista: const [
        VariacaoOpcao(id: 7, nome: 'Floral'),
        VariacaoOpcao(id: 8, nome: 'Listrada'),
      ],
      tamanhosLista: const [
        TamanhoOpcao(id: 1, nome: '34'),
        TamanhoOpcao(id: 2, nome: '36'),
        TamanhoOpcao(id: 3, nome: '38'),
        TamanhoOpcao(id: 4, nome: '40'),
        TamanhoOpcao(id: 5, nome: 'P'),
        TamanhoOpcao(id: 6, nome: 'M'),
        TamanhoOpcao(id: 7, nome: 'G'),
      ],
    );

Widget _painel(VariacoesProdutoBloc bloc) => comVariacoes(
      bloc,
      MaterialApp(
        theme: SivTheme.tema,
        home: Scaffold(
          body: PainelContagemGrade(
            titulo: 'Contar',
            subtitulo: 's',
            referenciaId: 1,
            referenciaNome: 'Aurora',
            corSeletor: (d) => const SizedBox(key: Key('cor_antigo')),
            tamanhoSeletor: (d) => const SizedBox(),
            estampaSeletor: (d) => const SizedBox(key: Key('estampa_antigo')),
            onSalvar: (l, i) {},
            onFechar: () {},
          ),
        ),
      ),
    );

Future<VariacoesGatewayFake> _mobile(WidgetTester t,
    {VariacoesGatewayFake? gateway, bool preCarga = true}) async {
  final g = gateway ?? _gateway();
  t.view.physicalSize = const Size(390, 844);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  nomesCor.clear();
  nomesTamanho.clear();
  final bloc = criarVariacoesBloc(g);
  addTearDown(bloc.close);
  if (preCarga) bloc.add(const VariacoesCarregadas());
  await t.pumpWidget(_painel(bloc));
  await t.pumpAndSettle();
  return g;
}

void main() {
  testWidgets(
      'mobile: cores e tamanhos viram chips pelos seletores em tela cheia',
      (t) async {
    await _mobile(t);
    expect(find.byKey(const Key('cor_antigo')), findsNothing);
    expect(find.byKey(const Key('estampa_antigo')), findsNothing);

    await t.tap(find.byKey(const Key('add_cor')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('sel_item_1')));
    await t.tap(find.byKey(const Key('sel_item_2')));
    await t.tap(find.byKey(const Key('sel_confirmar')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('chip_cor_1')), findsOneWidget);
    expect(find.byKey(const Key('chip_cor_2')), findsOneWidget);

    await t.tap(find.byKey(const Key('add_tam')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('tam_1')));
    await t.tap(find.byKey(const Key('tam_5')));
    await t.tap(find.byKey(const Key('tam_confirmar')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('contagem_1_1')), findsOneWidget);
    expect(find.byKey(const Key('contagem_2_5')), findsOneWidget);
    expect(
        find.byKey(const Key('contagem_1_2')), findsNothing); // 36 não marcado
  });

  testWidgets('estampa: seleção única escolhe e fecha', (t) async {
    await _mobile(t);
    await t.tap(find.byKey(const Key('add_estampa')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('sel_item_7')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('chip_estampa_7')), findsOneWidget);
  });

  Future<void> faixa(WidgetTester t, List<String> toques) async {
    await _mobile(t);
    await t.tap(find.byKey(const Key('add_tam')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('tam_faixa')));
    await t.pump();
    expect(find.text('Toque no primeiro tamanho da faixa'), findsOneWidget);
    await t.tap(find.byKey(Key(toques[0])));
    await t.pump();
    expect(
        find.textContaining('Agora toque no último (início:'), findsOneWidget);
    await t.tap(find.byKey(Key(toques[1])));
    await t.pump();
    expect(find.text('MARCAR FAIXA'), findsOneWidget);
  }

  testWidgets('MARCAR FAIXA: 2 toques marcam o intervalo', (t) async {
    await faixa(t, ['tam_1', 'tam_3']); // 34..38
    expect(find.text('CONFIRMAR · 3 TAMANHOS'), findsOneWidget);
  });

  testWidgets('MARCAR FAIXA: ordem invertida e só dentro do grupo', (t) async {
    await faixa(t, ['tam_7', 'tam_5']); // G..P (letras)
    expect(find.text('CONFIRMAR · 3 TAMANHOS'), findsOneWidget);
  });

  testWidgets('tocar em + cor abre na hora, mesmo com a rede atrasada', (t) async {
    final g = _gateway()..atraso = Completer<void>();
    await _mobile(t, gateway: g);

    await t.tap(find.byKey(const Key('add_cor')));
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const Key('sel_busca')), findsOneWidget);
    expect(find.byKey(const Key('sel_carregando')), findsOneWidget);
    expect(find.byKey(const Key('sel_item_1')), findsNothing);

    g.atraso!.complete();
    await t.pumpAndSettle();
    expect(find.byKey(const Key('sel_carregando')), findsNothing);
    expect(find.byKey(const Key('sel_item_1')), findsOneWidget);
  });

  testWidgets('tocar em + tam. e + estampa também abre na hora com spinner', (t) async {
    final g = _gateway()..atraso = Completer<void>();
    await _mobile(t, gateway: g);

    await t.tap(find.byKey(const Key('add_tam')));
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const Key('tam_faixa')), findsOneWidget);
    expect(find.byKey(const Key('tam_carregando')), findsOneWidget);
    g.atraso!.complete();
    await t.pumpAndSettle();
    expect(find.byKey(const Key('tam_1')), findsOneWidget);
  });

  testWidgets('falha na carga: TENTAR DE NOVO recarrega e mostra a lista', (t) async {
    final g = _gateway()..falha = true;
    await _mobile(t, gateway: g);

    await t.tap(find.byKey(const Key('add_cor')));
    await t.pumpAndSettle();
    expect(find.text('TENTAR DE NOVO'), findsOneWidget);

    g.falha = false;
    await t.tap(find.byKey(const Key('sel_tentar_novamente')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('sel_item_1')), findsOneWidget);
  });

  testWidgets('cadastrar cor nova chega pelo estado e já fica marcada', (t) async {
    await _mobile(t);
    await t.tap(find.byKey(const Key('add_cor')));
    await t.pumpAndSettle();

    await t.enterText(find.byKey(const Key('sel_busca')), 'Rosa');
    await t.pump();
    await t.tap(find.byKey(const Key('sel_cadastrar')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('sel_confirmar')));
    await t.pumpAndSettle();

    expect(find.text('Rosa'), findsWidgets);
    expect(find.byKey(const Key('chip_cor_103')), findsOneWidget);
  });
}
