import 'package:comercial/domain/data/remote/i_pedido_entrada_remote_data_source.dart';
import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/domain/use_cases/pedido_entrada/pedido_entrada_use_cases.dart';
import 'package:comercial/presentation/blocs/pedido_entrada_bloc/pedido_entrada_bloc.dart';
import 'package:comercial/presentation/pages/pedido_entrada_page.dart';
import 'package:comercial/domain/use_cases/conferir_pedido.dart';
import 'package:comercial/domain/use_cases/faturar_pedido.dart';
import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _json({bool contado = false}) => {
      'pedidoId': 9,
      'origemEntrada': 'NFE',
      'nfe': {
        'chaveAcesso': '3526' * 11,
        'numero': '123',
        'serie': '1',
        'emitenteNome': 'Fornecedor Ltda',
        'emitenteDocumento': '12345678000199',
        'valorTotal': '100.00',
      },
      'linhas': [
        {
          'id': 1,
          'sequencia': 1,
          'codigoFornecedor': 'A1',
          'descricao': 'Calça Wide Leg',
          'quantidadeNfe': '10',
          'valorUnitario': '10',
          'valorTotal': '100',
          'status': 'mapeado',
          'produtoId': 11,
          'quantidadeContada': contado ? 9 : null,
          'diferenca': contado ? -1 : null,
          'divergente': contado,
        },
        {
          'id': 2,
          'sequencia': 2,
          'descricao': 'Vestido Luna',
          'quantidadeNfe': '24',
          'valorUnitario': '60',
          'valorTotal': '1440',
          'status': 'nao_cadastrado',
        },
      ],
      'contagens': [],
      'totais': {'nfe': 34, 'contado': contado ? 9 : 0},
      'pendencias': [
        'Item 1 (Calça Wide Leg): falta a contagem',
        'Item 2 (Vestido Luna): ainda sem produto',
      ],
    };

Map<String, dynamic> _jsonContagem({
  bool comContagem = false,
  bool comLivre = false,
  Map<String, dynamic> extra = const {},
}) =>
    {
      'pedidoId': 9,
      'origemEntrada': 'CONTAGEM',
      'nfe': null,
      'linhas': [],
      'contagens': comContagem
          ? [
              {
                'produtoId': 5,
                'quantidade': '3',
                'referenciaId': 77,
                'referenciaNome': 'Vestido Luna',
                'corId': 1,
                'corNome': 'Preto',
                'tamanhoId': 2,
                'tamanhoNome': 'M',
              },
            ]
          : [],
      'contagensLivres': comLivre
          ? [
              {
                'id': 1,
                'descricao': 'Vestido Luna',
                'corId': 1,
                'tamanhoId': 2,
                'quantidade': '3',
              },
            ]
          : [],
      'totais': {'nfe': 0, 'contado': comContagem ? 3 : 0},
      'pendencias': [],
      ...extra,
    };

class _Sessao implements IAcessoGlobalSessao {
  @override
  int? get caixaIdDaSessao => 1;
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _Conferir implements ConferirPedido {
  @override
  Future<void> call(int id, {bool processarComDivergencia = false}) async {}
}

class _Faturar implements FaturarPedido {
  @override
  Future<void> call(int id, {required int caixaId}) async {}
}

class _Remoto implements IPedidoEntradaRemoteDataSource {
  List<ItemContagem>? contagemEnviada;
  List<ItemContagem>? livreEnviada;
  List<int>? associados;
  int? associadoRef;
  int? associadoCategoria;
  bool semNfe = false;
  bool comLivre = false;
  Map<String, dynamic> extra = const {};

  @override
  Future<EntradaResumo> obter(int pedidoId) async => EntradaResumo.fromJson(
        semNfe ? _jsonContagem(comLivre: comLivre, extra: extra) : _json(),
      );

  @override
  Future<EntradaResumo> registrarContagem(
    int pedidoId,
    List<ItemContagem> itens, {
    String? origem,
    String? motivo,
  }) async {
    contagemEnviada = itens;
    return EntradaResumo.fromJson(
      semNfe
          ? _jsonContagem(comContagem: true, extra: extra)
          : _json(contado: true),
    );
  }

  @override
  Future<EntradaResumo> registrarContagemLivre(
    int pedidoId,
    List<ItemContagem> itens,
  ) async {
    livreEnviada = itens;
    return EntradaResumo.fromJson(_jsonContagem(comLivre: true));
  }

  @override
  Future<EntradaResumo> associarContagemLivre(
    int pedidoId,
    List<int> ids, {
    int? referenciaId,
    int? categoriaId,
    String? nome,
  }) async {
    associados = ids;
    associadoRef = referenciaId;
    associadoCategoria = categoriaId;
    return EntradaResumo.fromJson(_jsonContagem(comContagem: true));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

void main() {
  late _Remoto remoto;

  Future<void> abrir(WidgetTester tester, {Size tamanho = const Size(420, 1400)}) async {
    tester.view.physicalSize = tamanho;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await sl.reset();
    sl.registerFactory<PedidoEntradaBloc>(
      () => PedidoEntradaBloc(
        ImportarNfeEntrada(remoto),
        CriarEntradaPorContagem(remoto),
        ObterPedidoEntrada(remoto),
        VincularLinhaEntrada(remoto),
        PreCadastrarLinhaEntrada(remoto),
        IgnorarLinhaEntrada(remoto),
        ResolverDivergenciaEntrada(remoto),
        RegistrarContagemEntrada(remoto),
        RegistrarContagemLivreEntrada(remoto),
        AssociarContagemLivreEntrada(remoto),
        CorrigirContagemEntrada(remoto),
        DecidirDivergenciaEntrada(remoto),
        RegistrarEtiquetasEntrada(remoto),
        FaturarEntrada(_Conferir(), _Faturar()),
        _Sessao(),
      ),
    );
    Widget falso(String n) => Text('seletor $n');
    SeletorWidget escolhe(String nome, int id) => (data) => TextButton(
          key: Key('escolher_$nome'),
          onPressed: () => data.onChanged?.call([
            SelectData(id: id, nome: nome, data: const {}),
          ]),
          child: Text('escolher $nome'),
        );
    await tester.pumpWidget(
      MaterialApp(
        home: PedidoEntradaPage(
          pedidoId: 9,
          categoriaSeletor: (_) => falso('categoria'),
          referenciaSeletor: (_) => falso('referencia'),
          referenciaContagemSeletor: escolhe('referencia', 77),
          corSeletor: escolhe('cor', 1),
          tamanhoSeletor: escolhe('tamanho', 2),
          buscarReferenciasParecidas: (nome) async => [
            const ReferenciaParecida(id: 41390, nome: 'Body Renda Floral'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() => remoto = _Remoto());
  tearDown(() async => sl.reset());

  testWidgets('NF-e: cartões de linha dentro do passo Contar', (tester) async {
    await abrir(tester);

    expect(find.text('Passo 1 de 5 · Contar'), findsOneWidget);
    expect(find.textContaining('NF-e 123/1 · Fornecedor Ltda'), findsOneWidget);
    expect(find.text('Pendências antes de conferir'), findsOneWidget);
    expect(find.text('1. Calça Wide Leg'), findsOneWidget);
    expect(find.text('Pré-cadastrar'), findsOneWidget);
    expect(find.text('Vincular a referência'), findsOneWidget);
    expect(find.byKey(const Key('entrada_contar_1')), findsOneWidget);
    expect(find.byKey(const Key('entrada_contar_2')), findsNothing);
  });

  testWidgets('NF-e: contar um SKU manda a contagem e mostra a diferença', (
    tester,
  ) async {
    await abrir(tester);

    await tester.tap(find.byKey(const Key('entrada_contar_1')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('contagem_quantidade')), '9');
    await tester.pump();
    await tester.tap(find.text('SALVAR'));
    await tester.pumpAndSettle();

    expect(remoto.contagemEnviada!.single.produtoId, 11);
    expect(remoto.contagemEnviada!.single.linhaId, 1);
    expect(remoto.contagemEnviada!.single.quantidade, 9);
    expect(find.textContaining('Diferença: -1'), findsOneWidget);
    expect(find.text('Resolver divergência'), findsOneWidget);
  });

  testWidgets('mobile: contar referência × cor × tamanho na tela cheia', (
    tester,
  ) async {
    remoto.semNfe = true;
    await abrir(tester);

    expect(find.text('Nenhum produto contado ainda'), findsOneWidget);
    expect(find.byKey(const Key('trilha_segmentos')), findsOneWidget);

    await tester.tap(find.byKey(const Key('entrada_vazio_contar_ref')));
    await tester.pumpAndSettle();
    expect(find.text('COM REFERÊNCIA'), findsOneWidget);
    expect(find.text('SEM REFERÊNCIA'), findsOneWidget);
    // sem nada preenchido não há o que salvar
    expect(
      tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'SALVAR')).onPressed,
      isNull,
    );

    await tester.tap(find.byKey(const Key('escolher_referencia')));
    await tester.tap(find.byKey(const Key('escolher_cor')));
    await tester.tap(find.byKey(const Key('escolher_tamanho')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('contagem_1_2')), '3');
    await tester.pump();
    await tester.tap(find.text('SALVAR'));
    await tester.pumpAndSettle();

    final item = remoto.contagemEnviada!.single;
    expect(item.linhaId, isNull);
    expect(item.referenciaId, 77);
    expect(item.corId, 1);
    expect(item.tamanhoId, 2);
    expect(item.quantidade, 3);
    expect(find.text('Vestido Luna'), findsOneWidget);
    expect(find.text('TERMINEI · ETIQUETAS'), findsOneWidget);
  });

  testWidgets('mobile: aba SEM REFERÊNCIA com sugestão "Contar nesta"', (
    tester,
  ) async {
    remoto.semNfe = true;
    await abrir(tester);
    await tester.tap(find.byKey(const Key('entrada_vazio_contar_ref')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('aba_sem_referencia')));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('contagem_descricao')), 'Body rendado vinho');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('Já existe? Referências parecidas'), findsOneWidget);
    expect(find.text('Body Renda Floral · REF 41390'), findsOneWidget);

    // sem cor/tamanho/quantidade o botão fica desabilitado
    expect(
      tester
          .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Salvar sem referência'))
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const Key('escolher_cor')));
    await tester.tap(find.byKey(const Key('escolher_tamanho')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('contagem_1_2')), '5');
    await tester.pump();
    await tester.tap(find.text('Salvar sem referência'));
    await tester.pumpAndSettle();

    final item = remoto.livreEnviada!.single;
    expect(item.descricao, 'Body rendado vinho');
    expect(item.referenciaId, isNull);
    expect(item.corId, 1);
    expect(item.tamanhoId, 2);
  });

  testWidgets('mobile: barra −1/+1 fica acima do teclado e o rodapé continua visível',
      (tester) async {
    remoto.semNfe = true;
    await abrir(tester);
    await tester.tap(find.byKey(const Key('entrada_vazio_contar_ref')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('escolher_referencia')));
    await tester.tap(find.byKey(const Key('escolher_cor')));
    await tester.tap(find.byKey(const Key('escolher_tamanho')));
    await tester.pumpAndSettle();

    tester.view.viewInsets = const FakeViewPadding(bottom: 400);
    await tester.tap(find.byKey(const Key('contagem_1_2')));
    await tester.pumpAndSettle();

    final barra = find.byKey(const Key('barra_teclado'));
    expect(barra, findsOneWidget);
    expect(tester.getBottomLeft(barra).dy, lessThanOrEqualTo(1400 - 400));
    final rodape = find.byKey(const Key('rodape_acao_entrada'));
    expect(rodape, findsOneWidget);
    expect(tester.getBottomLeft(rodape).dy, lessThanOrEqualTo(1400 - 400));
    // a barra vem acima do rodapé
    expect(tester.getBottomLeft(barra).dy,
        lessThanOrEqualTo(tester.getTopLeft(rodape).dy + 0.5));

    await tester.tap(find.byKey(const Key('barra_mais')));
    await tester.tap(find.byKey(const Key('barra_mais')));
    await tester.tap(find.byKey(const Key('barra_menos')));
    await tester.pump();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('contagem_1_2')))
          .controller!
          .text,
      '1',
    );
    expect(find.text('1 peças'), findsOneWidget);
    await tester.tap(find.byKey(const Key('barra_limpar')));
    await tester.pump();
    expect(find.text('0 peças'), findsOneWidget);
  });

  testWidgets('mobile: entrada vazia mostra os dois caminhos de contagem', (
    tester,
  ) async {
    remoto.semNfe = true;
    await abrir(tester, tamanho: const Size(390, 844));

    expect(find.byKey(const Key('entrada_estado_vazio')), findsOneWidget);
    expect(find.text('CONTAR COM REFERÊNCIA'), findsOneWidget);
    expect(find.text('CONTAR SEM REFERÊNCIA'), findsOneWidget);
    for (final k in ['entrada_vazio_contar_ref', 'entrada_vazio_contar_livre']) {
      expect(tester.getSize(find.byKey(Key(k))).height, greaterThanOrEqualTo(44),
          reason: k);
    }

    // "sem referência" abre o painel já na aba sem referência
    await tester.tap(find.byKey(const Key('entrada_vazio_contar_livre')));
    await tester.pumpAndSettle();
    expect(find.text('Salvar sem referência'), findsOneWidget);
  });

  testWidgets('mobile: alvos de toque >= 44px e ação principal de 50-52px',
      (tester) async {
    remoto.semNfe = true;
    await abrir(tester);

    final seg = tester.getSize(find.byKey(const Key('trilha_segmentos')));
    expect(seg.height, greaterThanOrEqualTo(44));
    final fab = tester.getSize(find.byKey(const Key('entrada_vazio_contar_ref')));
    expect(fab.height, greaterThanOrEqualTo(44));
    final principal =
        tester.getSize(find.byKey(const Key('entrada_terminei_contar')));
    expect(principal.height, inInclusiveRange(50, 52));

    await tester.tap(find.byKey(const Key('entrada_vazio_contar_ref')));
    await tester.pumpAndSettle();
    for (final k in ['painel_fechar', 'aba_com_referencia', 'aba_sem_referencia']) {
      expect(tester.getSize(find.byKey(Key(k))).height, greaterThanOrEqualTo(44),
          reason: k);
    }
    // cabeçalho do painel: 52px
    expect(tester.getSize(find.byKey(const Key('painel_fechar'))).width,
        greaterThanOrEqualTo(44));
  });

  testWidgets('contado nunca abaixo do lido: aviso e salvar desabilitado',
      (tester) async {
    remoto.semNfe = true;
    remoto.extra = {
      'etapa': 'contando',
      'contagens': [
        {
          'produtoId': 5,
          'quantidade': '3',
          'referenciaId': 77,
          'referenciaNome': 'Vestido Luna',
          'corId': 1,
          'corNome': 'Preto',
          'tamanhoId': 2,
          'tamanhoNome': 'M',
        },
      ],
      'totais': {'nfe': 0, 'contado': 3},
      'conferencia': {
        'totalContado': 3,
        'totalLido': 2,
        'itens': [
          {'produtoId': 5, 'contado': 3, 'lido': 2, 'situacao': 'parcial'},
        ],
      },
    };
    await abrir(tester);
    await tester.tap(find.byKey(const Key('entrada_grupo_77')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('contagem_1_2')), '1');
    await tester.pump();
    expect(find.byKey(const Key('painel_aviso_lido')), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'SALVAR')).onPressed,
      isNull,
    );
    await tester.enterText(find.byKey(const Key('contagem_1_2')), '2');
    await tester.pump();
    expect(find.byKey(const Key('painel_aviso_lido')), findsNothing);
    expect(
      tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'SALVAR')).onPressed,
      isNotNull,
    );
  });

  testWidgets('contagem sem referência: abre em Associar e bloqueia Etiquetas',
      (tester) async {
    remoto
      ..semNfe = true
      ..comLivre = true;
    await abrir(tester);

    expect(find.text('Passo 2 de 5 · Associar'), findsOneWidget);
    expect(find.textContaining('As etiquetas liberam quando todos'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.descendant(
            of: find.byKey(const Key('associar_imprimir_etiquetas')),
            matching: find.byType(FilledButton),
          ))
          .onPressed,
      isNull,
    );

    // trilha completa -> Etiquetas: continua bloqueada
    await tester.tap(find.byKey(const Key('trilha_segmentos')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('trilha_passo_2')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('etiquetas_bloqueio')), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.descendant(
            of: find.byKey(const Key('etiquetas_imprimir')),
            matching: find.byType(FilledButton),
          ))
          .onPressed,
      isNull,
    );
  });

  testWidgets('associar a uma referência existente', (tester) async {
    remoto
      ..semNfe = true
      ..comLivre = true;
    await abrir(tester);

    await tester.tap(find.byKey(const Key('escolher_referencia')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('entrada_associar_Vestido Luna')));
    await tester.pumpAndSettle();

    expect(remoto.associados, [1]);
    expect(remoto.associadoRef, 77);
    // associou tudo -> segue para Etiquetas
    expect(find.text('Passo 3 de 5 · Etiquetas'), findsOneWidget);
  });

  testWidgets('editar após etiquetas: painel mostra só a diferença a imprimir',
      (tester) async {
    remoto.semNfe = true;
    remoto.extra = {
      'etapa': 'contando',
      'contagens': [
        {'produtoId': 5, 'quantidade': '3', 'referenciaId': 77, 'referenciaNome': 'Vestido Luna', 'corId': 1, 'corNome': 'Preto', 'tamanhoId': 2, 'tamanhoNome': 'M'},
      ],
      'totais': {'nfe': 0, 'contado': 3},
      'etiquetas': {'impressasEm': '2026-10-08T09:31:00-03:00', 'impressasPorProduto': {'5': 3}},
    };
    await abrir(tester);
    await tester.tap(find.byKey(const Key('entrada_grupo_77')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('painel_aviso_etiquetas')), findsOneWidget);
    expect(find.text('SALVAR · IMPRIMIR 0'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('contagem_1_2')), '5');
    await tester.pump();
    expect(find.text('SALVAR · IMPRIMIR 2'), findsOneWidget);
    await tester.tap(find.text('SALVAR · IMPRIMIR 2'));
    await tester.pumpAndSettle();
    expect(remoto.contagemEnviada!.single.quantidade, 5);
  });

  Map<String, dynamic> variacoes() => {
        'etapa': 'associando',
        'contagensLivres': [
          {'id': 10, 'descricao': 'Vestido Luna', 'corId': 5, 'tamanhoId': 6, 'quantidade': '2', 'referenciaId': 77, 'referenciaNome': 'Vestido Luna'},
          {'id': 11, 'descricao': 'Vestido Luna', 'corId': 5, 'tamanhoId': 7, 'quantidade': '1', 'referenciaId': 77, 'referenciaNome': 'Vestido Luna'},
          {'id': 12, 'descricao': 'Body Aurora', 'corId': 5, 'tamanhoId': 6, 'quantidade': '4', 'referenciaId': 88, 'referenciaNome': 'Body Aurora'},
          {'id': 13, 'descricao': 'Peça sem ref', 'corId': 1, 'tamanhoId': 2, 'quantidade': '3'},
        ],
      };

  testWidgets('Associar: variações novas por referência, botão manda só os ids',
      (tester) async {
    remoto
      ..semNfe = true
      ..extra = variacoes();
    await abrir(tester);

    expect(find.text('VARIAÇÕES NOVAS · cadastrar'), findsOneWidget);
    expect(find.text('Esta cor/tamanho ainda não existe para a referência.'),
        findsNWidgets(2));
    expect(find.text('CADASTRAR 2 VARIAÇÕES'), findsOneWidget);
    expect(find.text('CADASTRAR VARIAÇÃO'), findsOneWidget);
    expect(find.byKey(const Key('cadastrar_todas_variacoes')), findsOneWidget);
    // sem referência continua como antes
    expect(find.byKey(const Key('grupo_associar_Peça sem ref')), findsOneWidget);
    expect(tester.getSize(find.byKey(const Key('cadastrar_variacao_77'))).height,
        inInclusiveRange(50, 52));

    await tester.tap(find.byKey(const Key('cadastrar_variacao_77')));
    await tester.pumpAndSettle();
    expect(remoto.associados, [10, 11]);
    expect(remoto.associadoRef, isNull);
    expect(remoto.associadoCategoria, isNull);
  });

  testWidgets('Associar: CADASTRAR TODAS manda os ids de todas as variações',
      (tester) async {
    remoto
      ..semNfe = true
      ..extra = variacoes();
    await abrir(tester);
    await tester.ensureVisible(find.byKey(const Key('cadastrar_todas_variacoes')));
    await tester.tap(find.byKey(const Key('cadastrar_todas_variacoes')));
    await tester.pumpAndSettle();
    expect(remoto.associados, [10, 11, 12]);
  });

  testWidgets('Contar separa variação nova de sem referência', (tester) async {
    remoto
      ..semNfe = true
      ..extra = {...variacoes(), 'etapa': 'contando'};
    await abrir(tester);

    expect(find.text('VARIAÇÃO NOVA · cadastrar no passo 2'), findsOneWidget);
    expect(find.byKey(const Key('entrada_variacao_77')), findsOneWidget);
    expect(find.byKey(const Key('entrada_variacao_88')), findsOneWidget);
    expect(find.byKey(const Key('entrada_sem_ref_Peça sem ref')), findsOneWidget);
    expect(find.byKey(const Key('entrada_sem_ref_Vestido Luna')), findsNothing);
    expect(find.text('1 sem referência'), findsOneWidget);
    expect(find.text('3 variações a cadastrar'), findsOneWidget);
    expect(find.text('TERMINEI · ASSOCIAR 4'), findsOneWidget);

    // tocar reabre o painel COM referência dessa referência
    await tester.tap(find.byKey(const Key('entrada_variacao_77')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('painel_fechar')), findsOneWidget);
    expect(find.byKey(const Key('contagem_5_6')), findsOneWidget);
    expect(find.byKey(const Key('contagem_5_7')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('contagem_5_6')), '5');
    await tester.pump();
    await tester.tap(find.text('SALVAR'));
    await tester.pumpAndSettle();
    expect(remoto.contagemEnviada!.map((e) => (e.referenciaId, e.corId, e.tamanhoId, e.quantidade)),
        containsAll([(77, 5, 6, 5.0), (77, 5, 7, 1.0)]));
  });

  testWidgets('desktop: trilha em linha e painel inline', (tester) async {
    remoto.semNfe = true;
    await abrir(tester, tamanho: const Size(1200, 900));

    expect(find.byKey(const Key('trilha_segmentos')), findsNothing);
    expect(find.byKey(const Key('trilha_passo_3')), findsOneWidget);
    await tester.tap(find.byKey(const Key('entrada_vazio_contar_ref')));
    await tester.pumpAndSettle();
    // inline: a lista segue visível ao lado do painel
    expect(find.byKey(const Key('painel_fechar')), findsOneWidget);
    expect(find.text('TERMINEI DE CONTAR · ETIQUETAS'), findsOneWidget);
  });
}
