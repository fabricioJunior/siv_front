import 'package:comercial/domain/data/remote/i_pedido_entrada_remote_data_source.dart';
import 'package:comercial/domain/models/contagem_em_andamento.dart';
import 'package:comercial/domain/use_cases/pedido_entrada/pedido_entrada_use_cases.dart';
import 'package:comercial/presentation/blocs/contagens_em_andamento_cubit/contagens_em_andamento_cubit.dart';
import 'package:comercial/presentation/pages/contagens_em_andamento_page.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Chamada {
  final String? busca;
  final int? funcionarioId;
  final bool minhas;
  final int pagina;
  _Chamada(this.busca, this.funcionarioId, this.minhas, this.pagina);
}

class _Remote extends Fake implements IPedidoEntradaRemoteDataSource {
  final chamadas = <_Chamada>[];
  ContagensEmAndamentoPagina Function(_Chamada) resposta;
  bool falha = false;

  _Remote(this.resposta);

  @override
  Future<ContagensEmAndamentoPagina> contagensEmAndamento({
    String? busca,
    int? funcionarioId,
    bool minhas = false,
    int pagina = 1,
    int tamanho = 30,
  }) async {
    final c = _Chamada(busca, funcionarioId, minhas, pagina);
    chamadas.add(c);
    if (falha) throw Exception('falhou');
    return resposta(c);
  }
}

ContagemEmAndamento _c(
  int id, {
  List<ItemContagemEmAndamento> itens = const [],
  int? total,
  String? contador = 'Ana Paula',
  String etapa = 'contando',
}) =>
    ContagemEmAndamento(
      pedidoId: id,
      fornecedor: 'Duloren $id',
      contador: contador,
      etapa: etapa,
      criadoEm: DateTime(2026, 10, 28, 9, 2),
      itens: itens,
      totalItens: total ?? itens.length,
    );

const _ref = ItemContagemEmAndamento(nome: 'Sutiã Renda Liz');
const _livre = ItemContagemEmAndamento(
  nome: 'Body rendado vinho',
  semReferencia: true,
);

ContagensEmAndamentoCubit _cubit(_Remote r, {int? funcionarioId}) =>
    ContagensEmAndamentoCubit(
      ObterContagensEmAndamento(r),
      funcionarioId: funcionarioId,
    );

Widget _app(ContagensEmAndamentoCubit cubit, {List<String>? rotas}) =>
    MaterialApp(
      theme: SivTheme.tema,
      onGenerateRoute: (s) {
        rotas?.add('${s.name} ${s.arguments}');
        return MaterialPageRoute<dynamic>(
          builder: (_) => s.name == '/'
              ? ContagensEmAndamentoPage(cubit: cubit)
              : const Scaffold(body: Text('destino')),
        );
      },
    );

Future<void> _tela(WidgetTester t, Size tamanho) async {
  t.view.physicalSize = tamanho;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

void main() {
  group('formatarCriadoEm', () {
    final agora = DateTime(2026, 10, 28, 12);
    test('mobile: hoje, ontem e data curta', () {
      expect(
        formatarCriadoEm(DateTime(2026, 10, 28, 9, 2),
            mobile: true, agora: agora),
        'hoje, 09:02',
      );
      expect(
        formatarCriadoEm(DateTime(2026, 10, 27, 16, 40),
            mobile: true, agora: agora),
        'ontem, 16:40',
      );
      expect(
        formatarCriadoEm(DateTime(2026, 10, 25, 14, 8),
            mobile: true, agora: agora),
        '25/10, 14:08',
      );
    });
    test('desktop: dd/MM/aaaa HH:mm', () {
      expect(
        formatarCriadoEm(DateTime(2026, 10, 5, 9, 2), mobile: false),
        '05/10/2026 09:02',
      );
    });
  });

  group('cubit', () {
    test('carrega, filtra "Minhas", busca e pagina', () async {
      final r = _Remote(
        (c) => ContagensEmAndamentoPagina(
          total: 31,
          totalDoFuncionario: 1,
          itens: [
            for (var i = 0; i < (c.minhas ? 1 : 30); i++) _c(c.pagina * 100 + i)
          ],
        ),
      );
      final cubit = _cubit(r, funcionarioId: 7);

      await cubit.carregar();
      expect(cubit.state.itens.length, 30);
      expect(cubit.state.temMais, isTrue);
      expect(r.chamadas.last.minhas, isFalse);
      expect(
          r.chamadas.last.funcionarioId, 7); // o contador "Minhas" sempre vem

      await cubit.maisItens();
      expect(r.chamadas.last.pagina, 2);
      expect(cubit.state.itens.length, 60);

      await cubit.filtrar(minhas: true);
      expect(r.chamadas.last.minhas, isTrue);
      expect(r.chamadas.last.pagina, 1);
      expect(cubit.state.itens.length, 1);
      expect(cubit.state.temMais, isFalse);

      await cubit.buscar('  duloren ');
      expect(r.chamadas.last.busca, 'duloren');
      expect(cubit.state.busca, 'duloren');
    });

    test('erro vira estado e "tentar de novo" recarrega', () async {
      final r = _Remote((_) => ContagensEmAndamentoPagina(itens: [_c(1)]))
        ..falha = true;
      final cubit = _cubit(r);
      await cubit.carregar();
      expect(cubit.state.erro, isNotNull);
      r.falha = false;
      await cubit.carregar();
      expect(cubit.state.erro, isNull);
      expect(cubit.state.itens.length, 1);
    });
  });

  group('página', () {
    testWidgets(
        'mobile: linha com fornecedor, itens, descrição em âmbar, +N e toque abre a contagem',
        (t) async {
      await _tela(t, const Size(360, 780));
      final r = _Remote(
        (_) => ContagensEmAndamentoPagina(
          total: 3,
          totalDoFuncionario: 1,
          itens: [
            _c(4821,
                itens: const [_ref, _livre], total: 6, etapa: 'associando'),
            _c(4817, contador: null),
          ],
        ),
      );
      final rotas = <String>[];
      await t.pumpWidget(_app(_cubit(r, funcionarioId: 7), rotas: rotas));
      await t.pumpAndSettle();

      expect(t.takeException(), isNull);
      expect(find.text('Duloren 4821'), findsOneWidget);
      expect(find.text('#4821'), findsOneWidget);
      expect(find.textContaining('+4', findRichText: true), findsOneWidget);
      expect(find.text('Nenhum item contado'), findsOneWidget);
      // etapa da trilha em cada linha
      expect(
          find.byKey(const Key('contagem_etapa_associando')), findsOneWidget);
      expect(find.text('Associar'), findsOneWidget);
      expect(find.byKey(const Key('contagem_etapa_contando')), findsOneWidget);
      expect(find.text('Todas · 3'), findsOneWidget);
      expect(find.text('Minhas · 1'), findsOneWidget);
      expect(find.byKey(const Key('contagens_nova')), findsOneWidget);

      // descrição livre em âmbar (cor diferente da referência)
      final rich = t
          .widgetList<RichText>(
            find.descendant(
              of: find.byKey(const Key('contagem_4821')),
              matching: find.byType(RichText),
            ),
          )
          .firstWhere((w) => w.text.toPlainText().contains('Body rendado'));
      final spans = <TextSpan>[];
      rich.text.visitChildren((s) {
        if (s is TextSpan && s.text != null) spans.add(s);
        return true;
      });
      final cores = SivColors.padrao;
      expect(
          spans.firstWhere((s) => s.text == 'Body rendado vinho').style?.color,
          cores.parcialTexto);
      expect(spans.firstWhere((s) => s.text == 'Sutiã Renda Liz').style?.color,
          isNull);

      await t.tap(find.byKey(const Key('contagem_4821')));
      await t.pumpAndSettle();
      expect(rotas.last, '/pedido_entrada {pedidoId: 4821}');
    });

    testWidgets('"Minhas" desabilitado sem funcionário e novo contagem navega',
        (t) async {
      await _tela(t, const Size(360, 780));
      final r = _Remote((_) => const ContagensEmAndamentoPagina());
      final rotas = <String>[];
      await t.pumpWidget(_app(_cubit(r), rotas: rotas));
      await t.pumpAndSettle();

      final minhas = t
          .widget<TextButton>(find.byKey(const Key('contagens_filtro_minhas')));
      expect(minhas.onPressed, isNull);
      expect(find.byKey(const Key('contagens_vazio')), findsOneWidget);
      expect(find.text('Nenhuma contagem em andamento'), findsOneWidget);

      await t.tap(find.byKey(const Key('contagens_nova')));
      await t.pumpAndSettle();
      expect(rotas.last, startsWith('/entrada_contagem/nova'));
    });

    testWidgets('busca sem resultado e erro com "Tentar de novo"', (t) async {
      await _tela(t, const Size(360, 780));
      final r = _Remote((_) => const ContagensEmAndamentoPagina());
      await t.pumpWidget(_app(_cubit(r)));
      await t.pumpAndSettle();

      await t.enterText(find.byKey(const Key('contagens_busca')), 'xyz');
      await t.pump(const Duration(milliseconds: 350));
      await t.pumpAndSettle();
      expect(r.chamadas.last.busca, 'xyz');
      expect(find.text('Nenhuma contagem para “xyz”'), findsOneWidget);

      r.falha = true;
      await t.enterText(find.byKey(const Key('contagens_busca')), 'abc');
      await t.pump(const Duration(milliseconds: 350));
      await t.pumpAndSettle();
      expect(find.byKey(const Key('contagens_erro')), findsOneWidget);
      r.falha = false;
      await t.tap(find.byKey(const Key('contagens_tentar_de_novo')));
      await t.pumpAndSettle();
      expect(find.byKey(const Key('contagens_erro')), findsNothing);
    });

    testWidgets(
        'desktop: tabela com data completa e botão Nova contagem no cabeçalho',
        (t) async {
      await _tela(t, const Size(1280, 800));
      final r = _Remote(
        (_) => ContagensEmAndamentoPagina(
          total: 1,
          itens: [
            _c(4821, itens: const [_ref, _livre])
          ],
        ),
      );
      await t.pumpWidget(_app(_cubit(r, funcionarioId: 7)));
      await t.pumpAndSettle();

      expect(t.takeException(), isNull);
      expect(find.text('28/10/2026 09:02'), findsOneWidget);
      expect(find.text('Ana Paula'), findsOneWidget);
      expect(find.text('Nova contagem'), findsOneWidget);
    });
  });
}
