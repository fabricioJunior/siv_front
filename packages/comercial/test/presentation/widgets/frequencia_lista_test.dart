import 'package:comercial/data/fake/relatorio_frequencia_clientes_repository_fake.dart';
import 'package:comercial/data/remote/dtos/relatorio_dto.dart';
import 'package:comercial/domain/models/relatorio_frequencia_clientes.dart';
import 'package:comercial/domain/models/relatorios.dart';
import 'package:comercial/domain/use_cases/get_compras_do_cliente.dart';
import 'package:comercial/domain/use_cases/get_relatorio_frequencia_clientes.dart';
import 'package:comercial/presentation/blocs/relatorio_frequencia_clientes_bloc/relatorio_frequencia_clientes_bloc.dart';
import 'package:comercial/presentation/pages/relatorio_frequencia_clientes_page.dart';
import 'package:comercial/presentation/widgets/frequencia/frequencia_cartao_mobile.dart';
import 'package:comercial/presentation/widgets/frequencia/frequencia_criterios.dart';
import 'package:comercial/presentation/widgets/frequencia/frequencia_linha_detalhe.dart';
import 'package:comercial/presentation/widgets/frequencia/frequencia_paginacao.dart';
import 'package:comercial/presentation/widgets/frequencia/frequencia_tabela.dart';
import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Sessao implements IAcessoGlobalSessao {
  @override
  int? get empresaIdDaSessao => 1;

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

class _Compras implements GetComprasDoCliente {
  int chamadas = 0;
  int? total;
  bool falha = false;
  List<int> limites = [];

  @override
  Future<RelatorioClienteCompras> call({
    required List<int> empresaIds,
    required int pessoaId,
    int limit = 10,
    String? dataInicial,
    String? dataFinal,
  }) async {
    chamadas++;
    limites.add(limit);
    if (falha) throw Exception('x');
    return RelatorioClienteComprasDto(
      totalNoPeriodo: total,
      items: const [
        RelatorioClienteCompraItemDto(
          romaneioId: 1,
          empresaId: 1,
          empresaNome: 'Loja',
          data: '2026-03-31',
          valorLiquido: 100,
        ),
      ],
    );
  }

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

late _Compras _compras;

Future<void> _registra() async {
  await sl.reset();
  addTearDown(sl.reset);
  _compras = _Compras();
  sl.registerSingleton<IAcessoGlobalSessao>(_Sessao());
  sl.registerSingleton<GetComprasDoCliente>(_compras);
  sl.registerSingleton<GetRelatorioFrequenciaClientes>(
    GetRelatorioFrequenciaClientes(FrequenciaClientesRepositoryFake()),
  );
}

/// A fonte de teste (Ahem) é mais larga que a Barlow e estoura o painel de KPIs (de P): ignora só overflow.
void _ignoraOverflow() {
  final antes = FlutterError.onError;
  FlutterError.onError = (d) {
    if (d.exceptionAsString().contains('overflowed')) return;
    antes?.call(d);
  };
  addTearDown(() => FlutterError.onError = antes);
}

Future<void> _pagina(WidgetTester t, double largura) async {
  _ignoraOverflow();
  t.view.physicalSize = Size(largura, 1600);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await _registra();
  await t.pumpWidget(MaterialApp(
    theme: SivTheme.tema,
    home: const RelatorioFrequenciaClientesPage(),
  ));
  await t.pumpAndSettle();
}

FrequenciaClienteItem _item({
  int visitas = 5,
  double? intervalo = 30,
  int dias = 20,
  bool atrasado = false,
  String? prox = '2026-05-10',
  String? cat,
  String? pag,
}) =>
    FrequenciaClienteItem(
      rank: 1,
      clienteId: 7,
      nome: 'ANA',
      telefone: '(86) 9****-1111',
      classe: 'A',
      visitas: visitas,
      primeiraCompra: '2025-10-01',
      ultimaCompra: '2026-03-31',
      diasDesdeUltima: dias,
      intervaloMedioDias: intervalo,
      valor: 1000,
      ticketMedio: 200,
      percentualAcumulado: 10,
      atrasado: atrasado,
      proximaCompraEsperada: prox,
      categoriaPreferida: cat,
      pagamentoPreferido: pag,
    );

Future<void> _tabela(WidgetTester t, FrequenciaClienteItem i, {bool aberta = true}) async {
  t.view.physicalSize = const Size(1280, 1600);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await _registra();
  final s = RelatorioFrequenciaClientesState(
    inicio: DateTime(2025, 4, 30),
    fim: DateTime(2026, 4, 30),
    status: FrequenciaStatus.sucesso,
    linhasAbertas: aberta ? {i.clienteId} : const {},
    dados: RelatorioFrequenciaClientes(items: [i]),
  );
  await t.pumpWidget(MaterialApp(
    theme: SivTheme.tema,
    home: Scaffold(
      body: SingleChildScrollView(
        child: FrequenciaTabela(state: s, onOrdenar: (_) {}, onAlternar: (_) {}),
      ),
    ),
  ));
  await t.pumpAndSettle();
}

void main() {
  group('insight', () {
    test('1 visita', () {
      expect(frequenciaInsight(_item(visitas: 1, intervalo: null, prox: null)).texto,
          'Comprou uma vez só no período.');
    });
    test('atrasado (âmbar)', () {
      final r = frequenciaInsight(_item(dias: 50, atrasado: true));
      expect(r.ambar, isTrue);
      expect(r.texto,
          'Costuma voltar a cada 30 dias. Próxima compra era esperada em 10/05/26 (há 20 dias).');
    });
    test('passou do esperado, não atrasado', () {
      final r = frequenciaInsight(_item(dias: 40));
      expect(r.ambar, isFalse);
      expect(r.texto, 'Costuma voltar a cada 30 dias. Já passou 10 dias do esperado.');
    });
    test('em dia', () {
      expect(frequenciaInsight(_item(dias: 10)).texto,
          'Costuma voltar a cada 30 dias. Próxima compra esperada por volta de 10/05/26.');
    });
  });

  test('paginação visível: 1, vizinhas, …, última', () {
    expect(frequenciaPaginasVisiveis(1, 3), [1, 2, 3]);
    expect(frequenciaPaginasVisiveis(5, 10), [1, null, 4, 5, 6, null, 10]);
  });

  testWidgets('critérios com parâmetros diferentes mudam os textos', (t) async {
    await t.pumpWidget(MaterialApp(
      theme: SivTheme.tema,
      home: const Scaffold(
        body: SingleChildScrollView(
          child: FrequenciaCriterios(
            resumo: FrequenciaClientesResumo(
              parametros: FrequenciaParametros(
                corteA: 70,
                corteB: 90,
                fatorAtraso: 1.5,
                minimoVisitasAtraso: 4,
              ),
            ),
          ),
        ),
      ),
    ));
    expect(find.textContaining('chegam a 70% do faturamento'), findsOneWidget);
    expect(find.textContaining('até 90% do faturamento'), findsOneWidget);
    expect(find.textContaining('últimos 10% do faturamento'), findsOneWidget);
    expect(find.textContaining('4+ visitas e sem comprar há mais de 1,5×'), findsOneWidget);
  });

  testWidgets('desktop (1280) tem tabela e não tem cartões', (t) async {
    await _pagina(t, 1280);
    expect(find.byType(FrequenciaTabela), findsOneWidget);
    expect(find.byType(FrequenciaCartoesMobile), findsNothing);
    expect(find.text('Só atrasados'), findsOneWidget);
    expect(find.textContaining('48 clientes · página 1 de 3'), findsOneWidget);
  });

  testWidgets('mobile (800) tem cartões e não tem tabela', (t) async {
    await _pagina(t, 800);
    expect(find.byType(FrequenciaCartoesMobile), findsOneWidget);
    expect(find.byType(FrequenciaTabela), findsNothing);
    expect(find.text('Filtros'), findsOneWidget);
  });

  for (final largura in [800.0, 1280.0]) {
    testWidgets('clicar CLASSE B filtra e mostra a tag Classe B ×; Só atrasados sincroniza ($largura)',
        (t) async {
      await _pagina(t, largura);
      expect(find.byKey(const ValueKey('frequencia-tag-classe')), findsNothing);
      await t.tap(find.text(largura < 820 ? 'Classe B' : 'CLASSE B').first);
      await t.pumpAndSettle();
      final tag = find.byKey(const ValueKey('frequencia-tag-classe'));
      expect(tag, findsOneWidget);
      expect(find.descendant(of: tag, matching: find.text('Classe B')), findsOneWidget);
      expect(find.descendant(of: tag, matching: find.byIcon(Icons.close)), findsOneWidget);
      await t.tap(tag);
      await t.pumpAndSettle();
      expect(tag, findsNothing);

      final chip = find.byKey(const ValueKey('frequencia-chip-atrasados'));
      expect(find.descendant(of: chip, matching: find.byIcon(Icons.check_box)), findsNothing);
      await t.tap(find.text('ATRASADOS').first);
      await t.pumpAndSettle();
      expect(find.descendant(of: chip, matching: find.byIcon(Icons.check_box)), findsOneWidget);
      await t.tap(chip);
      await t.pumpAndSettle();
      expect(find.descendant(of: chip, matching: find.byIcon(Icons.check_box)), findsNothing);
    });
  }

  testWidgets('filtro sem resultado mostra mensagem e Limpar filtros', (t) async {
    await _pagina(t, 1280);
    await t.enterText(find.byKey(const ValueKey('frequencia-busca')), 'zzzz');
    await t.pump(const Duration(milliseconds: 450));
    await t.pumpAndSettle();
    expect(find.text('Nenhum cliente com esse filtro.'), findsOneWidget);
    await t.tap(find.text('Limpar filtros'));
    await t.pumpAndSettle();
    expect(find.text('Nenhum cliente com esse filtro.'), findsNothing);
    expect(find.byType(FrequenciaTabela), findsOneWidget);
  });

  testWidgets('F2 carrega uma vez só; cache vale ao fechar e abrir (desktop)', (t) async {
    await _pagina(t, 1280);
    final linha = find.byKey(const ValueKey('frequencia-linha-50'));
    await t.ensureVisible(linha);
    await t.tap(find.descendant(of: linha, matching: find.text('MARCIA A. B. 1')));
    await t.pumpAndSettle();
    expect(_compras.chamadas, 1);
    expect(_compras.limites, [5]);
    expect(find.text('Abrir cadastro'), findsOneWidget);
    await t.tap(find.descendant(of: linha, matching: find.text('MARCIA A. B. 1')));
    await t.pumpAndSettle();
    expect(find.text('Abrir cadastro'), findsNothing);
    await t.tap(find.descendant(of: linha, matching: find.text('MARCIA A. B. 1')));
    await t.pumpAndSettle();
    expect(find.text('Abrir cadastro'), findsOneWidget);
    expect(_compras.chamadas, 1);
  });

  testWidgets('F2 carrega uma vez só no cartão mobile', (t) async {
    await _pagina(t, 800);
    final c = find.byKey(const ValueKey('frequencia-cartao-50'));
    await t.ensureVisible(c);
    await t.tap(find.descendant(of: c, matching: find.text('MARCIA A. B. 1')));
    await t.pumpAndSettle();
    await t.tap(find.descendant(of: c, matching: find.text('MARCIA A. B. 1')));
    await t.pumpAndSettle();
    await t.tap(find.descendant(of: c, matching: find.text('MARCIA A. B. 1')));
    await t.pumpAndSettle();
    expect(_compras.chamadas, 1);
    expect(find.text('Abrir cadastro'), findsOneWidget);
  });

  testWidgets('— quando intervalo é nulo e F2 vem sem os campos novos', (t) async {
    await _tabela(t, _item(visitas: 1, intervalo: null, prox: null));
    expect(find.text('Comprou uma vez só no período.'), findsOneWidget);
    // COMPRA A CADA + CUPOM + ITENS + PAGAMENTO
    expect(find.text('—'), findsNWidgets(4));
    expect(find.text('R\$ 100,00'), findsOneWidget);
  });

  testWidgets('mais de 5 compras mostra aviso; erro de F2 só na linha com Tentar de novo', (t) async {
    await _registra();
    _compras.total = 12;
    t.view.physicalSize = const Size(1280, 1600);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final s = RelatorioFrequenciaClientesState(
      inicio: DateTime(2025, 4, 30),
      fim: DateTime(2026, 4, 30),
      status: FrequenciaStatus.sucesso,
      linhasAbertas: const {7},
      dados: RelatorioFrequenciaClientes(items: [_item(cat: 'BLUSA', pag: 'Pix')]),
    );
    await t.pumpWidget(MaterialApp(
      theme: SivTheme.tema,
      home: Scaffold(
        body: SingleChildScrollView(
          child: FrequenciaTabela(state: s, onOrdenar: (_) {}, onAlternar: (_) {}),
        ),
      ),
    ));
    await t.pumpAndSettle();
    expect(find.text('Mostrando as 5 compras mais recentes de 12.'), findsOneWidget);
    expect(find.text('Mais compra: BLUSA · paga com Pix'), findsOneWidget);

    _compras.falha = true;
    await t.pumpWidget(const SizedBox());
    await t.pumpWidget(MaterialApp(
      theme: SivTheme.tema,
      home: Scaffold(
        body: SingleChildScrollView(
          child: FrequenciaTabela(state: s, onOrdenar: (_) {}, onAlternar: (_) {}),
        ),
      ),
    ));
    await t.pumpAndSettle();
    expect(find.text('Não foi possível carregar as compras.'), findsOneWidget);
    _compras.falha = false;
    await t.tap(find.text('Tentar de novo'));
    await t.pumpAndSettle();
    expect(find.text('Não foi possível carregar as compras.'), findsNothing);
  });
}
