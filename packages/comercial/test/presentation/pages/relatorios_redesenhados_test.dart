import 'package:comercial/data/remote/dtos/relatorio_dto.dart';
import 'package:comercial/domain/data/repositories/i_relatorio_repository.dart';
import 'package:comercial/domain/models/relatorio_movimentacoes.dart';
import 'package:comercial/domain/models/relatorios.dart';
import 'package:comercial/domain/use_cases/get_compras_do_cliente.dart';
import 'package:comercial/domain/use_cases/get_relatorio_clientes_ativos.dart';
import 'package:comercial/domain/use_cases/get_relatorio_curva_abc.dart';
import 'package:comercial/domain/use_cases/get_relatorio_faturamento.dart';
import 'package:comercial/domain/use_cases/get_relatorio_faturamento_comparativo.dart';
import 'package:comercial/domain/use_cases/get_relatorio_movimentacoes.dart';
import 'package:comercial/domain/use_cases/get_relatorio_vendas_por_funcionario.dart';
import 'package:comercial/presentation/blocs/compras_do_cliente_bloc/compras_do_cliente_bloc.dart';
import 'package:comercial/presentation/blocs/relatorio_clientes_bloc/relatorio_clientes_bloc.dart';
import 'package:comercial/presentation/blocs/relatorio_curva_abc_bloc/relatorio_curva_abc_bloc.dart';
import 'package:comercial/presentation/blocs/relatorio_faturamento_bloc/relatorio_faturamento_bloc.dart';
import 'package:comercial/presentation/blocs/relatorio_vendas_por_funcionario_bloc/relatorio_vendas_por_funcionario_bloc.dart';
import 'package:comercial/presentation/pages/relatorio_clientes_ativos_page.dart';
import 'package:comercial/presentation/pages/relatorio_curva_abc_page.dart';
import 'package:comercial/presentation/pages/relatorio_faturamento_page.dart';
import 'package:comercial/presentation/pages/relatorio_movimentacoes_page.dart';
import 'package:comercial/presentation/pages/relatorio_vendas_por_funcionario_page.dart';
import 'package:comercial/presentation/widgets/cliente_compras_aba.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/seletores.dart';
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

RelatorioFaturamentoDto _fat(double total, int vendas, int pecas) =>
    RelatorioFaturamentoDto(
      total: total,
      valorBrutoVendas: total,
      valorDevolucoes: 0,
      quantidadeProdutosVendidos: pecas,
      quantidadeVendas: vendas,
      ticketMedio: vendas == 0 ? 0 : total / vendas,
      empresas: vendas == 0
          ? const []
          : [
              RelatorioFaturamentoEmpresaDto(
                empresaId: 1,
                empresaNome: 'LOJA CENTRO',
                total: total,
                valorBrutoVendas: total,
                valorDevolucoes: 0,
                quantidadeProdutosVendidos: pecas,
                quantidadeVendas: vendas,
                ticketMedio: total / vendas,
                vendedores: [
                  RelatorioFaturamentoVendedorDto(
                    funcionarioId: 3,
                    funcionarioNome: 'Maria',
                    total: total,
                    valorBrutoVendas: total,
                    valorDevolucoes: 0,
                    quantidadeProdutosVendidos: pecas,
                    quantidadeVendas: vendas,
                    ticketMedio: total / vendas,
                  ),
                ],
                produtos: const [],
              ),
            ],
    );

const _metaAbc = RelatorioCurvaAbcMetaDto(
    totalItems: 2, itemCount: 2, itemsPerPage: 100, totalPages: 1, currentPage: 1);

RelatorioCurvaAbcItemDto _itemAbc(String nome, String classe) =>
    RelatorioCurvaAbcItemDto(
      referenciaNome: nome,
      quantidadeVendida: 4,
      valorTotalVendido: 400,
      percentualParticipacao: 40,
      percentualAcumulado: 40,
      classeAbc: classe,
    );

class _Repo implements IRelatorioRepository {
  bool falha = false;
  bool vazio = false;
  bool semResumo = false;
  bool anteriorIgual = true;
  List<RelatorioFaturamentoComparativoPontoDto>? pontosComparativo;
  final periodosFat = <(String, String)>[];
  final chamadasMov = <Map<String, Object?>>[];

  @override
  Future<RelatorioFaturamento> faturamento({
    required List<int> empresaIds,
    required String dataInicial,
    required String dataFinal,
  }) async {
    periodosFat.add((dataInicial, dataFinal));
    if (falha) throw Exception('x');
    if (vazio) return _fat(0, 0, 0);
    if (periodosFat.length == 1) return _fat(1000, 10, 20);
    return anteriorIgual ? _fat(1002, 10, 20) : _fat(500, 4, 5);
  }

  @override
  Future<RelatorioFaturamentoComparativo> faturamentoComparativo({
    required List<int> empresaIds,
    required String dataInicial,
    required String dataFinal,
    required String agruparPor,
  }) async =>
      RelatorioFaturamentoComparativoDto(
          pontos: pontosComparativo ??
              const [
                RelatorioFaturamentoComparativoPontoDto(
                    periodo: '2026-10-01', faturamento: 100, quantidadeVendas: 1),
              ]);

  @override
  Future<RelatorioCurvaAbc> curvaAbc({
    required List<int> empresaIds,
    required String dataInicial,
    required String dataFinal,
    String? busca,
    int page = 1,
    int limit = 100,
    String agruparPor = 'produto',
    List<int>? referenciaIds,
    List<int>? categoriaIds,
  }) async {
    if (falha) throw Exception('x');
    return RelatorioCurvaAbcDto(
      items: vazio ? const [] : [_itemAbc('CALCA JEANS', 'A'), _itemAbc('BLUSA', 'B')],
      meta: _metaAbc,
      resumo: semResumo
          ? null
          : const RelatorioCurvaAbcResumoDto(valorTotal: 800, quantidadeItens: 2, classes: [
              RelatorioCurvaAbcClasseDto(
                  classe: 'A',
                  quantidadeItens: 1,
                  percentualItens: 50,
                  valorTotal: 400,
                  percentualFaturamento: 50),
              RelatorioCurvaAbcClasseDto(
                  classe: 'B',
                  quantidadeItens: 1,
                  percentualItens: 50,
                  valorTotal: 400,
                  percentualFaturamento: 50),
            ]),
    );
  }

  @override
  Future<RelatorioClientesAtivos> clientesAtivos({
    required List<int> empresaIds,
    required int dias,
    String? dataReferencia,
    int page = 1,
    int limit = 100,
  }) async {
    if (falha) throw Exception('x');
    return RelatorioClientesAtivosDto(
      items: vazio
          ? const []
          : const [
              RelatorioClienteAtivoItemDto(
                empresaId: 1,
                empresaNome: 'Loja',
                clienteId: 7,
                clienteNome: 'ANA PAULA',
                clienteDocumento: '1',
                clienteMunicipio: 'Teresina',
                clienteUf: 'PI',
                dataUltimaCompra: '2020-01-02',
                quantidadeCompras: 3,
                valorTotalComprado: 300,
              ),
            ],
      meta: const RelatorioClienteAtivoMetaDto(
          totalItems: 42, itemCount: 1, itemsPerPage: 100, totalPages: 1, currentPage: 1),
      resumo: semResumo
          ? null
          : const RelatorioClientesAtivosResumoDto(
              quantidadeClientes: 1,
              valorTotalComprado: 300,
              quantidadeCompras: 3,
              ticketMedio: 100,
              comprasPorCliente: 3,
            ),
    );
  }

  @override
  Future<List<RelatorioVendasPorFuncionarioItem>> vendasPorFuncionario({
    required List<int> empresaIds,
    required List<int> funcionarioIds,
    required String dataInicial,
    required String dataFinal,
  }) async {
    if (falha) throw Exception('x');
    return vazio
        ? const []
        : const [
            RelatorioVendasPorFuncionarioItemDto(
              funcionarioId: 3,
              funcionarioNome: 'Maria Souza',
              total: 900,
              valorBrutoVendas: 900,
              valorDevolucoes: 0,
              quantidadeProdutosVendidos: 9,
              quantidadeVendas: 3,
              ticketMedio: 300,
            ),
          ];
  }

  @override
  Future<RelatorioMovimentacoes> movimentacoes({
    required List<int> empresaIds,
    required String dataInicial,
    required String dataFinal,
    List<String>? tipos,
    String? busca,
    int page = 1,
    int limit = 50,
  }) async {
    chamadasMov.add({'tipos': tipos, 'busca': busca});
    if (falha) throw Exception('x');
    return RelatorioMovimentacoes(
      items: vazio
          ? const []
          : [
              MovimentacaoItem(
                id: '1',
                tipo: 'venda',
                dataHora: DateTime(2026, 10, 1, 9, 30),
                produtoNome: 'CALCA',
                quantidade: 2,
                responsavelNome: 'Maria',
              ),
            ],
      contagemPorTipo: const {'venda': 1},
    );
  }

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

late _Repo _repo;

Future<void> _registra() async {
  await sl.reset();
  addTearDown(sl.reset);
  _repo = _Repo();
  sl.registerSingleton<IAcessoGlobalSessao>(_Sessao());
  sl.registerFactory(() => RelatorioFaturamentoBloc(
      GetRelatorioFaturamento(_repo), GetRelatorioFaturamentoComparativo(_repo)));
  sl.registerFactory(() => RelatorioCurvaAbcBloc(GetRelatorioCurvaAbc(_repo)));
  sl.registerFactory(() => RelatorioClientesBloc(GetRelatorioClientesAtivos(_repo)));
  sl.registerFactory(() =>
      RelatorioVendasPorFuncionarioBloc(GetRelatorioVendasPorFuncionario(_repo)));
  sl.registerSingleton<GetRelatorioMovimentacoes>(GetRelatorioMovimentacoes(_repo));
}

/// Fonte de teste (Ahem) é mais larga que a Barlow: ignora só overflow.
void _ignoraOverflow() {
  final antes = FlutterError.onError;
  FlutterError.onError = (d) {
    if (d.exceptionAsString().contains('overflowed')) return;
    antes?.call(d);
  };
  addTearDown(() => FlutterError.onError = antes);
}

Future<void> _abre(WidgetTester t, double largura, Widget pagina,
    {void Function(_Repo)? config}) async {
  _ignoraOverflow();
  t.view.physicalSize = Size(largura, 1600);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await _registra();
  config?.call(_repo);
  await t.pumpWidget(const SizedBox());
  await t.pumpWidget(MaterialApp(theme: SivTheme.tema, home: pagina));
  await t.pumpAndSettle();
}

Future<void> _r3(WidgetTester t, double largura,
    {void Function(_Repo)? config, bool consulta = true}) async {
  _ignoraOverflow();
  t.view.physicalSize = Size(largura, 1600);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await _registra();
  config?.call(_repo);
  final bloc = RelatorioVendasPorFuncionarioBloc(GetRelatorioVendasPorFuncionario(_repo));
  sl.unregister<RelatorioVendasPorFuncionarioBloc>();
  sl.registerFactory(() => bloc);
  await t.pumpWidget(const SizedBox());
  await t.pumpWidget(MaterialApp(
    theme: SivTheme.tema,
    home: Scaffold(
      body: RelatorioVendasPorFuncionarioPage(funcionariosSeletor: (_) => const SizedBox()),
    ),
  ));
  if (consulta) {
    bloc.add(RelatorioVendasPorFuncionarioCarregar(
      funcionariosSelecionados: [SelectData(id: 3, nome: 'Maria Souza', data: const {})],
      dataInicial: '2026-10-01',
      dataFinal: '2026-10-31',
    ));
  }
  await t.pumpAndSettle();
}

const _vazioTxt = 'Nenhum resultado para o filtro selecionado.';

void main() {
  group('R1 faturamento', () {
    test('2ª chamada usa os 30 dias anteriores ao período', () async {
      await _registra();
      final bloc = RelatorioFaturamentoBloc(
          GetRelatorioFaturamento(_repo), GetRelatorioFaturamentoComparativo(_repo));
      addTearDown(bloc.close);
      bloc.add(RelatorioFaturamentoCarregar(
          dataInicial: '2026-09-01', dataFinal: '2026-09-30'));
      await bloc.stream.firstWhere((s) => s.anteriorDados != null);
      expect(_repo.periodosFat, [
        ('2026-09-01', '2026-09-30'),
        ('2026-08-02', '2026-08-31'),
      ]);
    });

    test('período de 1 dia compara com o dia anterior; falha da 2ª é ignorada', () async {
      await _registra();
      final bloc = RelatorioFaturamentoBloc(
          GetRelatorioFaturamento(_repo), GetRelatorioFaturamentoComparativo(_repo));
      addTearDown(bloc.close);
      bloc.add(RelatorioFaturamentoCarregar(
          dataInicial: '2026-03-01', dataFinal: '2026-03-01'));
      await bloc.stream.firstWhere((s) => s.anteriorDados != null);
      expect(_repo.periodosFat.last, ('2026-02-28', '2026-02-28'));
    });

    test('gráfico por dia traz os dias sem venda com faturamento 0', () async {
      await _registra();
      _repo.pontosComparativo = const [
        RelatorioFaturamentoComparativoPontoDto(periodo: '2026-10-01', faturamento: 100, quantidadeVendas: 1),
        RelatorioFaturamentoComparativoPontoDto(periodo: '2026-10-04', faturamento: 50, quantidadeVendas: 2),
      ];
      final bloc = RelatorioFaturamentoBloc(
          GetRelatorioFaturamento(_repo), GetRelatorioFaturamentoComparativo(_repo));
      addTearDown(bloc.close);
      bloc.add(RelatorioFaturamentoComparativoCarregar(
          dataInicial: '2026-10-01', dataFinal: '2026-10-05', agruparPor: 'dia'));
      final s = await bloc.stream.firstWhere(
          (s) => s.comparativoStep == RelatorioFaturamentoComparativoStep.sucesso);
      final pontos = s.comparativoDados!.pontos;
      expect(pontos.map((p) => p.periodo),
          ['2026-10-01', '2026-10-02', '2026-10-03', '2026-10-04', '2026-10-05']);
      expect(pontos.map((p) => p.faturamento), [100, 0, 0, 50, 0]);
    });

    test('gráfico por mês traz os meses sem venda com faturamento 0', () async {
      await _registra();
      _repo.pontosComparativo = const [
        RelatorioFaturamentoComparativoPontoDto(periodo: '2026-08', faturamento: 10, quantidadeVendas: 1),
        RelatorioFaturamentoComparativoPontoDto(periodo: '2026-10', faturamento: 30, quantidadeVendas: 3),
      ];
      final bloc = RelatorioFaturamentoBloc(
          GetRelatorioFaturamento(_repo), GetRelatorioFaturamentoComparativo(_repo));
      addTearDown(bloc.close);
      bloc.add(RelatorioFaturamentoComparativoCarregar(
          dataInicial: '2026-08-15', dataFinal: '2026-10-20', agruparPor: 'mes'));
      final s = await bloc.stream.firstWhere(
          (s) => s.comparativoStep == RelatorioFaturamentoComparativoStep.sucesso);
      final pontos = s.comparativoDados!.pontos;
      expect(pontos.map((p) => p.periodo), ['2026-08', '2026-09', '2026-10']);
      expect(pontos.map((p) => p.faturamento), [10, 0, 30]);
    });

    for (final w in [800.0, 1280.0]) {
      testWidgets('estável com variação < 0,5% ($w)', (t) async {
        await _abre(t, w, const RelatorioFaturamentoPage());
        expect(find.text('estável'), findsNWidgets(4));
      });

      testWidgets('variação grande: sem "estável" ($w)', (t) async {
        await _abre(t, w, const RelatorioFaturamentoPage(),
            config: (r) => r.anteriorIgual = false);
        expect(find.text('estável'), findsNothing);
      });

      testWidgets('tabela no desktop, cartões no mobile ($w)', (t) async {
        await _abre(t, w, const RelatorioFaturamentoPage());
        expect(find.text('LOJA / VENDEDOR'), w >= 820 ? findsOneWidget : findsNothing);
        expect(find.byType(RelatorioItemMobile), w >= 820 ? findsNothing : findsWidgets);
      });

      testWidgets('vazio e erro ($w)', (t) async {
        await _abre(t, w, const RelatorioFaturamentoPage(),
            config: (r) => r.vazio = true);
        expect(find.text(_vazioTxt), findsOneWidget);
        await _abre(t, w, const RelatorioFaturamentoPage(),
            config: (r) => r.falha = true);
        expect(find.text('Tentar de novo'), findsOneWidget);
        expect(find.text('Falha ao carregar relatório de faturamento.'), findsOneWidget);
      });
    }
  });

  for (final w in [800.0, 1280.0]) {
    final desktop = w >= 820;
    group('largura $w', () {
      testWidgets('R2 curva ABC: tabela/cartões e cartões de classe', (t) async {
        await _abre(t, w, const RelatorioCurvaAbcPage());
        expect(find.text('PRODUTO'), desktop ? findsOneWidget : findsNothing);
        expect(find.byType(RelatorioItemMobile), desktop ? findsNothing : findsNWidgets(2));
        expect(find.textContaining('CLASSE A'), findsOneWidget);
        expect(find.textContaining('CLASSE B'), findsOneWidget);
      });

      testWidgets('R2 resumo null: cartões de classe somem', (t) async {
        await _abre(t, w, const RelatorioCurvaAbcPage(),
            config: (r) => r.semResumo = true);
        expect(find.textContaining('CLASSE A'), findsNothing);
        expect(find.textContaining('CLASSE B'), findsNothing);
        expect(find.textContaining('CALCA JEANS'), findsOneWidget);
      });

      testWidgets('R2 vazio e erro', (t) async {
        await _abre(t, w, const RelatorioCurvaAbcPage(), config: (r) => r.vazio = true);
        expect(find.text(_vazioTxt), findsOneWidget);
        await _abre(t, w, const RelatorioCurvaAbcPage(), config: (r) => r.falha = true);
        expect(find.text('Tentar de novo'), findsOneWidget);
      });

      testWidgets('R3 vendas por funcionário: barras, vazio e erro', (t) async {
        await _r3(t, w, consulta: false);
        expect(find.text('Selecione o funcionário para consultar.'), findsOneWidget);
        await _r3(t, w);
        expect(find.text('Maria Souza'), findsOneWidget);
        expect(find.text('1 funcionários com venda no período'), findsOneWidget);
        await _r3(t, w, config: (r) => r.vazio = true);
        expect(find.text(_vazioTxt), findsOneWidget);
        await _r3(t, w, config: (r) => r.falha = true);
        expect(find.text('Tentar de novo'), findsOneWidget);
      });

      testWidgets('R4 clientes ativos: tabela/cartões e KPIs', (t) async {
        await _abre(t, w, const RelatorioClientesAtivosPage());
        expect(find.text('CLIENTE'), desktop ? findsOneWidget : findsNothing);
        expect(find.byType(RelatorioItemMobile), desktop ? findsNothing : findsOneWidget);
        expect(find.text('CLIENTES ATIVOS'), findsOneWidget);
        expect(find.text('TICKET MÉDIO'), findsOneWidget);
      });

      testWidgets('R4 resumo null: só CLIENTES ATIVOS com meta.totalItems', (t) async {
        await _abre(t, w, const RelatorioClientesAtivosPage(),
            config: (r) => r.semResumo = true);
        expect(find.text('CLIENTES ATIVOS'), findsOneWidget);
        expect(find.text('42'), findsOneWidget);
        expect(find.text('TICKET MÉDIO'), findsNothing);
        expect(find.text('COMPRAS/CLIENTE'), findsNothing);
      });

      testWidgets('R4 vazio e erro', (t) async {
        await _abre(t, w, const RelatorioClientesAtivosPage(),
            config: (r) => r.vazio = true);
        expect(find.text(_vazioTxt), findsOneWidget);
        await _abre(t, w, const RelatorioClientesAtivosPage(),
            config: (r) => r.falha = true);
        expect(find.text('Tentar de novo'), findsOneWidget);
      });

      testWidgets('R7 movimentações: tabela/cartões, vazio e erro', (t) async {
        await _abre(t, w, const RelatorioMovimentacoesPage());
        expect(find.text('DATA/HORA'), desktop ? findsOneWidget : findsNothing);
        expect(find.byType(RelatorioItemMobile), desktop ? findsNothing : findsOneWidget);
        await _abre(t, w, const RelatorioMovimentacoesPage(),
            config: (r) => r.vazio = true);
        expect(find.text(_vazioTxt), findsOneWidget);
        await _abre(t, w, const RelatorioMovimentacoesPage(),
            config: (r) => r.falha = true);
        expect(find.text('Tentar de novo'), findsOneWidget);
      });
    });
  }

  group('regressão: aba Compras do cliente', () {
    test('parse sem os campos novos (F2 opcionais)', () {
      final r = RelatorioClienteComprasDto.fromJson({
        'items': [
          {
            'romaneioId': 5,
            'empresaId': 1,
            'empresaNome': 'Loja',
            'data': '2026-01-02',
            'valorLiquido': 10,
          }
        ],
      });
      expect(r.totalNoPeriodo, isNull);
      final i = r.items.single;
      expect(i.numeroCupom, isNull);
      expect(i.quantidadeItens, isNull);
      expect(i.formaPagamento, isNull);
      expect(i.valorLiquido, 10.0);
    });

    testWidgets('aba renderiza a tabela de compras', (t) async {
      t.view.physicalSize = const Size(1280, 900);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await sl.reset();
      addTearDown(sl.reset);
      sl.registerSingleton<IAcessoGlobalSessao>(_Sessao());
      sl.registerFactory(() => ComprasDoClienteBloc(_Compras()));
      await t.pumpWidget(MaterialApp(
        theme: SivTheme.tema,
        home: const Scaffold(body: ClienteComprasAba(pessoaId: 7)),
      ));
      await t.pumpAndSettle();
      expect(find.text('ROMANEIO'), findsOneWidget);
      expect(find.text('#5'), findsOneWidget);
      expect(find.text('02/01/2026'), findsOneWidget);
      expect(find.text('1 compra(s)'), findsOneWidget);
    });
  });
}

class _Compras implements GetComprasDoCliente {
  @override
  Future<RelatorioClienteCompras> call({
    required List<int> empresaIds,
    required int pessoaId,
    int limit = 10,
    String? dataInicial,
    String? dataFinal,
  }) async =>
      RelatorioClienteComprasDto.fromJson({
        'items': [
          {
            'romaneioId': 5,
            'empresaId': 1,
            'empresaNome': 'Loja',
            'data': '2026-01-02',
            'valorLiquido': 10,
          }
        ],
      });

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}
