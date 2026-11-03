import 'dart:io';

import 'package:comercial/domain/data/gateways/i_filtros_pedidos_contagem_gateway.dart';
import 'package:comercial/domain/data/remote/i_relatorio_pedidos_contagem_remote_data_source.dart';
import 'package:comercial/domain/models/relatorio_pedidos_contagem.dart';
import 'package:comercial/domain/use_cases/relatorio_pedidos_contagem_use_cases.dart';
import 'package:comercial/presentation/blocs/relatorio_pedidos_contagem_cubit/relatorio_pedidos_contagem_cubit.dart';
import 'package:comercial/presentation/pages/relatorio_pedidos_contagem_page.dart';
import 'package:comercial/presentation/widgets/pedidos_contagem/pedidos_contagem_formato.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _hoje = DateTime(2026, 11, 2);

class _Remote implements IRelatorioPedidosContagemRemoteDataSource {
  bool falha = false;
  List<PedidoContagemLinha> linhas = [];
  ResumoPedidosContagem resumo = const ResumoPedidosContagem();
  final filtros = <FiltroPedidosContagem>[];
  final tabelasItens = <int?>[];

  @override
  Future<RelatorioPedidosContagem> relatorio(
    FiltroPedidosContagem filtro, {
    int pagina = 1,
    int tamanho = 30,
  }) async {
    filtros.add(filtro);
    if (falha) throw Exception('x');
    return RelatorioPedidosContagem(
      resumo: resumo,
      itens: linhas,
      totalItems: linhas.length,
    );
  }

  @override
  Future<List<ItemPedidoContagem>> itens(
    int pedidoId, {
    int? categoriaId,
    int? referenciaId,
    int? produtoId,
    int? tabelaPrecoId,
  }) async {
    tabelasItens.add(tabelaPrecoId);
    return const [];
  }
}

class _Gateway implements IFiltrosPedidosContagemGateway {
  @override
  Future<List<OpcaoFiltro>> categorias() async => const [];

  @override
  Future<List<OpcaoFiltro>> referencias({
    int? categoriaId,
    required String busca,
  }) async =>
      const [];

  @override
  Future<List<OpcaoFiltro>> produtos(int referenciaId) async => const [];
}

PedidoContagemLinha _linha(
  int id, {
  String etapa = 'contando',
  int diasAberto = 5,
  double semCusto = 0,
  double custo = 100,
  double valor = 300,
  double semValor = 0,
}) =>
    PedidoContagemLinha(
      pedidoId: id,
      fornecedor: 'FORN $id',
      etapa: etapa,
      abertoEm: DateTime.now().subtract(Duration(days: diasAberto)),
      faturadoEm: etapa == 'faturado' ? DateTime.now() : null,
      pecas: 10,
      custo: custo,
      pecasSemCusto: semCusto,
      custoPedido: 999,
      valor: valor,
      valorPedido: 888,
      pecasSemValor: semValor,
      quantidadeReferencias: 1,
    );

RelatorioPedidosContagemCubit _cubit(_Remote r) => RelatorioPedidosContagemCubit(
      ObterRelatorioPedidosContagem(r),
      ObterItensPedidoContagem(r),
      ListarCategoriasFiltroContagem(_Gateway()),
      BuscarReferenciasFiltroContagem(_Gateway()),
      ListarProdutosFiltroContagem(_Gateway()),
      agora: () => _hoje,
    );

late RelatorioPedidosContagemCubit _paginaCubit;

Future<_Remote> _abre(
  WidgetTester t,
  double largura, {
  void Function(_Remote)? config,
}) async {
  final antes = FlutterError.onError;
  // Fonte de teste (Ahem) é mais larga que a Barlow: ignora só overflow.
  FlutterError.onError = (d) {
    if (d.exceptionAsString().contains('overflowed')) return;
    antes?.call(d);
  };
  addTearDown(() => FlutterError.onError = antes);
  t.view.physicalSize = Size(largura, 1600);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final r = _Remote()
    ..linhas = [_linha(1), _linha(2, etapa: 'associando')]
    ..resumo = const ResumoPedidosContagem(pedidos: 2, pecas: 20, custo: 200);
  config?.call(r);
  await sl.reset();
  addTearDown(sl.reset);
  sl.registerFactory(() => _paginaCubit = _cubit(r));
  await t.pumpWidget(const SizedBox());
  await t.pumpWidget(
    MaterialApp(
      theme: SivTheme.tema,
      home: RelatorioPedidosContagemPage(
        fornecedorSeletor: (_) => const SizedBox(),
        tabelaPrecoSeletor: (d) => TextButton(
          key: const Key('tabela_fake'),
          onPressed: () => d.onChanged?.call(
            [SelectData(id: 7, nome: 'ATACADO', data: const {})],
          ),
          child: const Text('fake tabela'),
        ),
      ),
    ),
  );
  await t.pumpAndSettle();
  return r;
}

Color? _corDoTexto(WidgetTester t, Finder f) =>
    t.widget<Text>(f.first).style?.color;

void main() {
  for (final largura in [800.0, 1280.0]) {
    final mobile = largura < 820;
    group('página a ${largura.toInt()}px', () {
      testWidgets('lista: ${mobile ? 'cartões' : 'tabela'}', (t) async {
        await _abre(t, largura);
        expect(find.text('Pedido #1'), mobile ? findsOneWidget : findsNothing);
        expect(find.text('#1'), mobile ? findsNothing : findsOneWidget);
        expect(find.text('STATUS DA CONTAGEM'),
            mobile ? findsNothing : findsOneWidget);
      });

      testWidgets('estado vazio', (t) async {
        await _abre(t, largura, config: (r) {
          r.linhas = [];
          r.resumo = const ResumoPedidosContagem();
        });
        expect(find.text('Nenhum pedido por contagem nesse filtro.'),
            findsOneWidget);
        expect(find.text('Limpar filtros'), findsNothing);
      });

      testWidgets('estado de erro', (t) async {
        await _abre(t, largura, config: (r) => r.falha = true);
        expect(find.text('Falha ao carregar o relatório.'), findsOneWidget);
        expect(find.text('Tentar de novo'), findsOneWidget);
      });

      testWidgets('situação muda KPI, coluna de data e base do período',
          (t) async {
        await _abre(t, largura);
        // desktop: nota dos filtros; mobile: base do KPI
        expect(find.textContaining('data de abertura'), findsOneWidget);
        expect(find.text('CUSTO EM ABERTO'), findsOneWidget);
        if (!mobile) expect(find.text('ABERTO EM'), findsOneWidget);

        await t.tap(find.text('Faturados'));
        await t.pumpAndSettle();
        expect(find.textContaining('data de faturamento'), findsOneWidget);
        expect(find.textContaining('data de abertura'), findsNothing);
        expect(find.text('CUSTO FATURADO NO PERÍODO'), findsOneWidget);
        if (!mobile) {
          expect(find.text('FATURADO'), findsOneWidget);
          expect(find.text('ABERTURA'), findsOneWidget);
          expect(find.text('ABERTO EM'), findsNothing);
        }

        await t.tap(find.text('Todos'));
        await t.pumpAndSettle();
        expect(find.text('CUSTO NO PERÍODO'), findsOneWidget);
      });

      testWidgets('filtro de item mostra "de R\$ … no pedido"', (t) async {
        await _abre(t, largura);
        expect(find.textContaining('no pedido'), findsNothing);
        await _paginaCubit.alterarCategoria(const OpcaoFiltro(1, 'CALCA'));
        await t.pumpAndSettle();
        expect(find.textContaining('R\$ 999,00 no pedido'), findsNWidgets(2));
      });

      testWidgets('KPI valor de venda; coluna valor e "de R\$ … no pedido"',
          (t) async {
        await _abre(t, largura, config: (r) {
          r.resumo = const ResumoPedidosContagem(
              pedidos: 2, pecas: 20, custo: 200, valor: 600);
        });
        if (mobile) {
          expect(find.textContaining('Valor de venda R\$'), findsWidgets);
        } else {
          expect(find.text('VALOR DE VENDA'), findsOneWidget);
          expect(find.text('VALOR'), findsOneWidget);
        }
        await _paginaCubit.alterarCategoria(const OpcaoFiltro(1, 'CALCA'));
        await t.pumpAndSettle();
        expect(find.textContaining('R\$ 888,00 no pedido'), findsNWidgets(2));
      });

      testWidgets('escolher tabela envia tabelaPrecoId, mostra nome; limpar zera',
          (t) async {
        final r = await _abre(t, largura);
        // mobile: chips em ListView lazy, fora da tela não existem
        if (mobile) {
          await _paginaCubit.alterarTabelaPreco(7, 'ATACADO');
        } else {
          await t.tap(find.byKey(const Key('tabela_fake')));
        }
        await t.pumpAndSettle();
        expect(r.filtros.last.tabelaPrecoId, 7);
        expect(find.textContaining('simulado com ATACADO'), findsOneWidget);
        if (mobile) {
          await _paginaCubit.limparFiltros();
        } else {
          await t.tap(find.byKey(const Key('contagem_limpar')));
        }
        await t.pumpAndSettle();
        expect(r.filtros.last.tabelaPrecoId, isNull);
        expect(find.textContaining('simulado com'), findsNothing);
      });
    });
  }

  group('âmbar com peças sem custo', () {
    testWidgets('KPI e linha usam a cor atencao do tema', (t) async {
      await _abre(t, 1280, config: (r) {
        r.linhas = [_linha(1, semCusto: 3)];
        r.resumo = const ResumoPedidosContagem(
            pedidos: 1, pecas: 10, custo: 100, pecasSemCusto: 3);
      });
      final atencao = SivTheme.tema.extension<SivColors>()!.atencao;
      expect(_corDoTexto(t, find.text('PEÇAS SEM CUSTO')), atencao);
      expect(find.text('falta associar referência'), findsOneWidget);
      expect(_corDoTexto(t, find.text('+ 3 pç sem custo')), atencao);
    });

    testWidgets('sem peças sem custo, nada âmbar', (t) async {
      await _abre(t, 1280);
      final atencao = SivTheme.tema.extension<SivColors>()!.atencao;
      expect(_corDoTexto(t, find.text('PEÇAS SEM CUSTO')), isNot(atencao));
      expect(find.text('falta associar referência'), findsNothing);
    });

    testWidgets('mobile: linha do cartão em âmbar', (t) async {
      await _abre(t, 800, config: (r) {
        r.linhas = [_linha(1, semCusto: 3)];
        r.resumo = const ResumoPedidosContagem(
            pedidos: 1, pecas: 10, custo: 100, pecasSemCusto: 3);
      });
      final atencao = SivTheme.tema.extension<SivColors>()!.atencao;
      expect(
        _corDoTexto(t, find.text('+ 3 pç sem custo (falta associar)')),
        atencao,
      );
    });
  });

  group('âmbar com peças sem preço', () {
    testWidgets('KPI e linha usam a cor atencao do tema', (t) async {
      await _abre(t, 1280, config: (r) {
        r.linhas = [_linha(1, semValor: 4)];
        r.resumo = const ResumoPedidosContagem(
            pedidos: 1, pecas: 10, custo: 100, valor: 300, pecasSemValor: 4);
      });
      final atencao = SivTheme.tema.extension<SivColors>()!.atencao;
      expect(find.text('4 pç sem preço'), findsOneWidget);
      expect(_corDoTexto(t, find.text('+ 4 pç sem preço')), atencao);
    });
  });

  group('cubit', () {
    late _Remote r;
    late RelatorioPedidosContagemCubit c;
    setUp(() {
      r = _Remote()..linhas = [_linha(1)];
      c = _cubit(r);
    });
    tearDown(() => c.close());

    test('filtro inicial: últimos 90 dias', () async {
      await c.iniciar();
      expect(c.state.filtro.ate, DateTime(2026, 11, 2));
      expect(c.state.filtro.de, DateTime(2026, 8, 5));
    });

    test('etapa: tocar na escolhida limpa; faturados descarta', () async {
      await c.alternarEtapa('associando');
      expect(c.state.filtro.etapa, 'associando');
      expect(r.filtros.last.etapa, 'associando');
      await c.alternarEtapa('contando');
      expect(c.state.filtro.etapa, 'contando');
      await c.alternarEtapa('contando');
      expect(c.state.filtro.etapa, isNull);
      await c.alternarEtapa('associando');
      await c.alterarSituacao(SituacaoContagem.faturado);
      expect(c.state.filtro.etapa, isNull);
    });

    test('ordenar: nova coluna desc, repetir alterna', () async {
      await c.ordenar('custo');
      expect((c.state.filtro.ordenarPor, c.state.filtro.ordem), ('custo', 'desc'));
      await c.ordenar('custo');
      expect(c.state.filtro.ordem, 'asc');
      await c.ordenar('custo');
      expect(c.state.filtro.ordem, 'desc');
      await c.ordenar('pecas');
      expect((c.state.filtro.ordenarPor, c.state.filtro.ordem), ('pecas', 'desc'));
    });

    test('ordenar por valor e tabela de preço no filtro e nos itens', () async {
      await c.ordenar('valor');
      expect(r.filtros.last.toQuery()['ordenarPor'], 'valor');
      await c.alterarTabelaPreco(7, 'ATACADO');
      expect(r.filtros.last.toQuery()['tabelaPrecoId'], '7');
      await c.carregarItens(1);
      expect(r.tabelasItens.last, 7);
      await c.alterarTabelaPreco(null, null);
      expect(c.state.tabelaPrecoNome, isNull);
      expect(r.filtros.last.toQuery().containsKey('tabelaPrecoId'), isFalse);
    });

    test('em aberto há > 30 dias alerta; faturado nunca', () {
      PedidoContagemLinha l(int dias, {String etapa = 'contando'}) =>
          PedidoContagemLinha(
            pedidoId: 1,
            fornecedor: 'F',
            etapa: etapa,
            abertoEm: _hoje.subtract(Duration(days: dias)),
          );
      expect(pcAlerta(l(30), _hoje), isFalse);
      expect(pcAlerta(l(31), _hoje), isTrue);
      expect(pcAlerta(l(90, etapa: 'faturado'), _hoje), isFalse);
      expect(pcEmAbertoHa(l(0).abertoEm!, _hoje), 'hoje');
      expect(pcEmAbertoHa(l(1).abertoEm!, _hoje), '1 dia');
      expect(pcEmAbertoHa(l(45).abertoEm!, _hoje), '45 dias');
    });

    test('cascata: trocar categoria limpa referência e produto de outra categoria',
        () async {
      await c.alterarCategoria(const OpcaoFiltro(1, 'CALCA'));
      await c.alterarReferencia(const OpcaoFiltro(10, 'REF', categoriaId: 1));
      await c.alterarProduto(const OpcaoFiltro(100, 'PROD'));
      expect(c.state.filtro.produtoId, 100);

      // mesma categoria: mantém
      await c.alterarCategoria(const OpcaoFiltro(1, 'CALCA'));
      expect(c.state.filtro.referenciaId, 10);
      expect(c.state.filtro.produtoId, 100);

      await c.alterarCategoria(const OpcaoFiltro(2, 'BLUSA'));
      expect(c.state.referencia, isNull);
      expect(c.state.produto, isNull);
      expect(c.state.filtro.categoriaId, 2);
      expect(c.state.filtro.referenciaId, isNull);
      expect(c.state.filtro.produtoId, isNull);
    });

    test('cascata: trocar referência limpa produto; limpar categoria mantém',
        () async {
      await c.alterarReferencia(const OpcaoFiltro(10, 'REF'));
      await c.alterarProduto(const OpcaoFiltro(100, 'PROD'));
      await c.alterarReferencia(const OpcaoFiltro(11, 'REF2'));
      expect(c.state.filtro.referenciaId, 11);
      expect(c.state.filtro.produtoId, isNull);
      expect(c.state.produto, isNull);

      await c.alterarCategoria(null);
      expect(c.state.filtro.referenciaId, 11);
    });

    test('limparFiltros zera item, fornecedor, busca e etapa', () async {
      await c.alterarCategoria(const OpcaoFiltro(1, 'C'));
      await c.alterarFornecedor(7);
      await c.buscar(' abc ');
      expect(c.state.filtro.busca, 'abc');
      expect(c.state.temFiltro, isTrue);
      await c.limparFiltros();
      expect(c.state.temFiltro, isFalse);
      expect(c.state.filtro.categoriaId, isNull);
      expect(c.state.limpezas, 1);
    });
  });

  test('widgets novos sem Colors. nem 0xFF', () {
    final arquivos = [
      'lib/presentation/pages/relatorio_pedidos_contagem_page.dart',
      'lib/presentation/blocs/relatorio_pedidos_contagem_cubit/relatorio_pedidos_contagem_cubit.dart',
      'lib/domain/models/relatorio_pedidos_contagem.dart',
      'lib/domain/use_cases/relatorio_pedidos_contagem_use_cases.dart',
      ...Directory('lib/presentation/widgets/pedidos_contagem')
          .listSync()
          .whereType<File>()
          .map((f) => f.path),
    ];
    expect(arquivos.length, greaterThan(8));
    final proibido = RegExp(r'(?<![A-Za-z])Colors\.|0xFF');
    for (final a in arquivos) {
      expect(proibido.hasMatch(File(a).readAsStringSync()), isFalse, reason: a);
    }
  });
}
