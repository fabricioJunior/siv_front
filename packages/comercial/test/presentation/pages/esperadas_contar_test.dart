import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/domain/models/referencia_esperada.dart';
import 'package:comercial/presentation/pages/pedido_entrada/lista_esperadas.dart';
import 'package:comercial/presentation/pages/pedido_entrada/painel_contagem_grade.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _aurora = ReferenciaEsperada(
  id: 1,
  nome: 'Áurora',
  codigoNoFornecedor: 'DL-2231',
  aguardandoPrimeiraEntrada: true,
  resumoGrade: 'Vinho, Preto · P a G',
  quantidadeEsperada: 24,
);
const _bella = ReferenciaEsperada(
  id: 2,
  nome: 'Bella',
  nova: true,
  aguardandoPrimeiraEntrada: true,
);
const _cecilia = ReferenciaEsperada(
  id: 3,
  nome: 'Cecília',
  aguardandoReposicao: true,
  resumoGrade: 'Preto · M',
);

Widget _app(Widget child) => MaterialApp(
      theme: SivTheme.tema,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  setUp(() {
    nomesCor.clear();
    nomesTamanho.clear();
  });

  group('ListaEsperadas', () {
    testWidgets('não contadas primeiro; contada esmaecida com contado/esperado', (t) async {
      await t.pumpWidget(_app(ListaEsperadas(
        esperadas: const [_aurora, _bella, _cecilia],
        contadoPorReferencia: const {1: 17},
        onEscolher: (_) {},
      )));

      final ordem = ['esperada_2', 'esperada_3', 'esperada_1']
          .map((k) => t.getTopLeft(find.byKey(Key(k))).dy)
          .toList();
      expect(ordem, orderedEquals([...ordem]..sort()));
      expect(find.text('17/24'), findsOneWidget); // abaixo do esperado
      expect(find.text('Cód. DL-2231 · REF 1'), findsOneWidget);
      expect(find.text('Sem variações'), findsOneWidget); // Bella
    });

    testWidgets('filtro 1ª entrada / reposição e contadores', (t) async {
      await t.pumpWidget(_app(ListaEsperadas(
        esperadas: const [_aurora, _bella, _cecilia],
        contadoPorReferencia: const {},
        onEscolher: (_) {},
      )));

      expect(find.text('Todas · 3'), findsOneWidget);
      expect(find.text('1ª entrada · 2'), findsOneWidget);
      expect(find.text('Reposição · 1'), findsOneWidget);

      await t.tap(find.byKey(const Key('esperadas_filtro_reposicao')));
      await t.pump();
      expect(find.byKey(const Key('esperada_3')), findsOneWidget);
      expect(find.byKey(const Key('esperada_1')), findsNothing);
    });

    testWidgets('busca sem acento e escolha de um item', (t) async {
      ReferenciaEsperada? escolhida;
      await t.pumpWidget(_app(ListaEsperadas(
        esperadas: const [_aurora, _bella, _cecilia],
        contadoPorReferencia: const {},
        onEscolher: (e) => escolhida = e,
      )));

      await t.enterText(find.byKey(const Key('esperadas_busca')), 'aurora');
      await t.pump();
      expect(find.byKey(const Key('esperada_2')), findsNothing);

      await t.tap(find.byKey(const Key('esperada_1')));
      expect(escolhida, _aurora);
    });

    testWidgets('sem foto mostra o espaço tracejado, sem quebrar', (t) async {
      await t.pumpWidget(_app(ListaEsperadas(
        esperadas: const [_bella],
        contadoPorReferencia: const {},
        onEscolher: (_) {},
      )));
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });
  });

  group('PainelContagemGrade com esperadas', () {
    Widget painel({bool inicial = true, Map<int, double> contado = const {}}) => MaterialApp(
          theme: SivTheme.tema,
          home: Scaffold(
            body: PainelContagemGrade(
              titulo: 'Contar',
              subtitulo: 'Passo 1 de 5',
              permiteTrocarAba: true,
              corSeletor: (d) => const SizedBox(),
              tamanhoSeletor: (d) => const SizedBox(),
              onSalvar: (l, i) {},
              onFechar: () {},
              esperadas: const [_aurora, _bella],
              contadoPorReferencia: contado,
              esperadasInicial: inicial,
              existentesDaReferencia: (id) => id == 1
                  ? const [
                      EntradaContagem(
                        produtoId: 10,
                        linhaId: null,
                        quantidade: 5,
                        referenciaId: 1,
                        corId: 1,
                        corNome: 'Vinho',
                        tamanhoId: 2,
                        tamanhoNome: 'P',
                      ),
                    ]
                  : const [],
            ),
          ),
        );

    testWidgets('abre na aba ESPERADAS quando há esperadas', (t) async {
      await t.pumpWidget(painel());
      expect(find.text('ESPERADAS · 2'), findsOneWidget);
      expect(find.byKey(const Key('esperada_1')), findsOneWidget);
      expect(find.byKey(const Key('painel_total')), findsNothing); // sem rodapé de salvar
    });

    testWidgets('sem esperadas a aba não aparece', (t) async {
      await t.pumpWidget(MaterialApp(
        theme: SivTheme.tema,
        home: Scaffold(
          body: PainelContagemGrade(
            titulo: 'Contar',
            subtitulo: 's',
            permiteTrocarAba: true,
            corSeletor: (d) => const SizedBox(),
            tamanhoSeletor: (d) => const SizedBox(),
            onSalvar: (l, i) {},
            onFechar: () {},
          ),
        ),
      ));
      expect(find.byKey(const Key('aba_esperadas')), findsNothing);
      expect(find.byKey(const Key('aba_com_referencia')), findsOneWidget);
    });

    testWidgets('escolher uma esperada abre a grade COM referência, já preenchida', (t) async {
      await t.pumpWidget(painel(contado: const {1: 5}));

      await t.tap(find.byKey(const Key('esperada_1')));
      await t.pumpAndSettle();

      expect(find.textContaining('Áurora · REF 1'), findsOneWidget);
      expect(find.byKey(const Key('esperada_x_de_y')), findsOneWidget);
      expect(find.text('5 de 24 esperadas'), findsOneWidget);
      expect(find.text('5'), findsWidgets); // célula Vinho × P pré-carregada
    });

    testWidgets('referência Nova avisa que ainda não tem variações', (t) async {
      await t.pumpWidget(painel());

      await t.tap(find.byKey(const Key('esperada_2')));
      await t.pumpAndSettle();

      expect(find.byKey(const Key('esperada_sem_variacoes')), findsOneWidget);
    });

    testWidgets('dá para voltar à lista pela aba ESPERADAS', (t) async {
      await t.pumpWidget(painel());
      await t.tap(find.byKey(const Key('esperada_1')));
      await t.pumpAndSettle();

      await t.tap(find.byKey(const Key('aba_esperadas')));
      await t.pumpAndSettle();

      expect(find.byKey(const Key('esperada_1')), findsOneWidget);
    });
  });
}
