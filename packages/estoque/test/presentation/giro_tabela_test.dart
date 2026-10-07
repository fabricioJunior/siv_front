import 'package:core/tema.dart';
import 'package:estoque/domain/models/parametros_giro.dart';
import 'package:estoque/domain/models/relatorio_giro_estoque.dart';
import 'package:estoque/presentation/pages/giro_estoque/giro_tabela.dart';
import 'package:estoque/presentation/pages/giro_estoque/giro_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Tema sem fontes remotas (GoogleFonts tenta baixar em teste).
final _tema = ThemeData(extensions: const [
  SivTextStyles(
    display: TextStyle(),
    titulo: TextStyle(),
    secao: TextStyle(),
    valor: TextStyle(),
    corpo: TextStyle(),
    apoio: TextStyle(),
    rotulo: TextStyle(),
    codigo: TextStyle(),
  ),
]);

GiroEstoqueLinha _linha(int id, String nome, {bool variacoes = true}) =>
    GiroEstoqueLinha(
      referenciaId: id,
      nome: nome,
      ref: '30$id',
      categoria: 'Lingerie',
      fornecedor: 'Forn',
      inicial: 30,
      vendido: 29,
      estoque: 1,
      pctVendido: 96.67,
      diasGiro: 3,
      velocidade: 9.67,
      diasParaEsgotar: 1,
      classificacao: ClassificacaoGiro.excepcional,
      rank: id,
      temVariacoes: variacoes,
    );

Widget _app(Widget child) => MaterialApp(
      theme: _tema,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

GiroTabela _tabela({
  Set<int> abertos = const {},
  Map<int, GiroEstoqueVariacoes> variacoes = const {},
  ValueChanged<String>? onOrdenar,
  ValueChanged<int>? onExpandir,
}) =>
    GiroTabela(
      aba: AbaGiro.ranking,
      visaoVariacao: false,
      pagina: PaginaGiroEstoque(
        items: [_linha(1, 'Sutiã Renda'), _linha(2, 'Calcinha Fio')],
        meta: const GiroEstoqueMeta(totalItems: 2, totalPages: 1),
      ),
      ordenarPor: 'score',
      ordem: 'desc',
      variacoes: variacoes,
      abertos: abertos,
      carregandoVariacoes: const {},
      parametros: const ParametrosGiro(),
      onOrdenar: onOrdenar ?? (_) {},
      onExpandir: onExpandir ?? (_) {},
      onPagina: (_) {},
    );

void main() {
  setUp(() {});

  testWidgets('clicar na linha pede a expansão da referência', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    int? expandida;
    await tester.pumpWidget(_app(_tabela(onExpandir: (id) => expandida = id)));
    await tester.tap(find.text('Calcinha Fio'));
    expect(expandida, 2);
  });

  testWidgets('linha aberta mostra melhor/pior e as variações', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(_tabela(
      abertos: {1},
      variacoes: {
        1: GiroEstoqueVariacoes(
          items: [
            const GiroEstoqueLinha(
              referenciaId: 1,
              produtoId: 11,
              nome: 'Sutiã Renda',
              variacaoLabel: '40 Preto',
              classificacao: ClassificacaoGiro.rapido,
              inicial: 6,
              vendido: 6,
              pctVendido: 100,
            ),
          ],
          melhor: const GiroVariacaoDestaque(
              variacaoLabel: '40 Preto', pctVendido: 100, diasGiro: 2),
        ),
      },
    )));
    expect(find.textContaining('Melhor: 40 Preto · 100% em 2 dias'), findsOneWidget);
    expect(find.text('40 Preto'), findsOneWidget);
  });

  testWidgets('clicar no cabeçalho pede ordenação pela coluna', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    String? coluna;
    await tester.pumpWidget(_app(_tabela(onOrdenar: (c) => coluna = c)));
    await tester.tap(find.text('VENDIDO'));
    expect(coluna, 'vendido');
  });

  testWidgets('chip de classificação mostra a faixa e remove ao tocar', (tester) async {
    var removido = false;
    await tester.pumpWidget(_app(GiroChipClassificacao(
      classificacao: ClassificacaoGiro.lento,
      onRemover: () => removido = true,
    )));
    expect(find.text('Classificação: Lento'), findsOneWidget);
    await tester.tap(find.byType(GiroChipClassificacao));
    expect(removido, isTrue);
  });
}
