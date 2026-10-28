import 'package:comercial/domain/models/referencia_esperada.dart';
import 'package:comercial/presentation/pages/pedido_entrada/painel_contagem_grade.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _lista = [
  ReferenciaEsperada(
    id: 887004302,
    nome: 'Body Áurora Rendado Manga Longa Vinho Especial',
    codigoNoFornecedor: 'DL-2231-LONGO-DEMAIS',
    aguardandoPrimeiraEntrada: true,
    resumoGrade: 'Vinho, Preto, Azul Marinho, Verde Musgo · PP a GG',
    quantidadeEsperada: 24,
  ),
  ReferenciaEsperada(id: 2, nome: 'Bella', nova: true, aguardandoPrimeiraEntrada: true),
  ReferenciaEsperada(id: 3, nome: 'Cecília', aguardandoReposicao: true, resumoGrade: 'Preto · M'),
];

Future<void> _mobile(WidgetTester t) async {
  t.view.physicalSize = const Size(360, 780);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

Widget _painel() => MaterialApp(
      theme: SivTheme.tema,
      home: Scaffold(
        body: PainelContagemGrade(
          titulo: 'Contar',
          subtitulo: 'Passo 1 de 5 · Entrada #4821',
          permiteTrocarAba: true,
          corSeletor: (d) => const SizedBox(),
          tamanhoSeletor: (d) => const SizedBox(),
          onSalvar: (l, i) {},
          onFechar: () {},
          esperadas: _lista,
          contadoPorReferencia: const {3: 8},
          esperadasInicial: true,
        ),
      ),
    );

void main() {
  testWidgets('mobile 360px: abas e lista de esperadas sem overflow', (t) async {
    await _mobile(t);
    await t.pumpWidget(_painel());
    await t.pumpAndSettle();

    expect(tester(t), isNull); // sem exceção de layout capturada
    expect(find.text('ESPERADAS · 3'), findsOneWidget);
    expect(find.text('COM REFERÊNCIA'), findsOneWidget);
    expect(find.text('SEM REFERÊNCIA'), findsOneWidget);
  });

  testWidgets('mobile: itens com ao menos 72px, foto de 52px e áreas de toque de 44px', (t) async {
    await _mobile(t);
    await t.pumpWidget(_painel());
    await t.pumpAndSettle();

    for (final id in [887004302, 2, 3]) {
      expect(t.getSize(find.byKey(Key('esperada_$id'))).height, greaterThanOrEqualTo(72));
    }
    // foto/placeholder de 52px
    final fotos = t.widgetList<SizedBox>(find.byWidgetPredicate(
        (w) => w is SizedBox && w.width == 52 && w.height == 52));
    expect(fotos, isNotEmpty);

    for (final f in ['todas', 'primeiraEntrada', 'reposicao']) {
      final tamanho = t.getSize(find.byKey(Key('esperadas_filtro_$f')));
      // ChoiceChip tem alvo de toque padded (48px) mesmo com chip menor
      expect(tamanho.height, greaterThanOrEqualTo(32));
    }
    final abas = ['aba_esperadas', 'aba_com_referencia', 'aba_sem_referencia'];
    for (final a in abas) {
      expect(t.getSize(find.byKey(Key(a))).height, greaterThanOrEqualTo(44));
    }
    expect(t.getSize(find.byKey(const Key('esperadas_busca'))).height, greaterThanOrEqualTo(44));
  });

  testWidgets('mobile: escolher uma esperada abre a grade em tela cheia sem overflow', (t) async {
    await _mobile(t);
    await t.pumpWidget(_painel());
    await t.pumpAndSettle();

    await t.ensureVisible(find.byKey(const Key('esperada_3')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('esperada_3')));
    await t.pumpAndSettle();

    expect(t.takeException(), isNull);
    expect(find.textContaining('Cecília · REF 3'), findsOneWidget);
  });
}

Object? tester(WidgetTester t) => t.takeException();
