import 'package:comercial/domain/data/remote/i_pedido_entrada_remote_data_source.dart';
import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/domain/use_cases/pedido_entrada/pedido_entrada_use_cases.dart';
import 'package:comercial/presentation/blocs/pedido_entrada_bloc/pedido_entrada_bloc.dart';
import 'package:comercial/presentation/pages/pedido_entrada_page.dart';
import 'package:core/injecoes.dart';
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
    };

class _Remoto implements IPedidoEntradaRemoteDataSource {
  List<ItemContagem>? contagemEnviada;
  bool semNfe = false;
  bool comLivre = false;

  @override
  Future<EntradaResumo> obter(int pedidoId) async => EntradaResumo.fromJson(
        semNfe ? _jsonContagem(comLivre: comLivre) : _json(),
      );

  @override
  Future<EntradaResumo> criarPorContagem({
    required int pessoaId,
    required int tabelaPrecoId,
    String? observacao,
  }) =>
      throw UnimplementedError();

  @override
  Future<EntradaResumo> registrarContagem(
    int pedidoId,
    List<ItemContagem> itens,
  ) async {
    contagemEnviada = itens;
    return EntradaResumo.fromJson(
      semNfe ? _jsonContagem(comContagem: true) : _json(contado: true),
    );
  }

  @override
  Future<EntradaResumo> registrarContagemLivre(
    int pedidoId,
    List<ItemContagem> itens,
  ) =>
      throw UnimplementedError();

  @override
  Future<EntradaResumo> associarContagemLivre(
    int pedidoId,
    List<int> ids, {
    int? referenciaId,
    int? categoriaId,
    String? nome,
  }) =>
      throw UnimplementedError();

  @override
  Future<EntradaResumo> importarNfe({
    required String filePath,
    required int tabelaPrecoId,
  }) =>
      throw UnimplementedError();

  @override
  Future<EntradaResumo> vincularReferencia(int p, int l, int r) =>
      throw UnimplementedError();

  @override
  Future<EntradaResumo> preCadastrar(
    int p,
    int l, {
    required int categoriaId,
    String? nome,
  }) =>
      throw UnimplementedError();

  @override
  Future<EntradaResumo> ignorar(int p, int l, bool i) =>
      throw UnimplementedError();

  @override
  Future<EntradaResumo> resolverDivergencia(int p, int l, String? o) =>
      throw UnimplementedError();
}

void main() {
  late _Remoto remoto;

  Future<void> abrir(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 1800);
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
      ),
    );
    Widget falso(String n) => Text('seletor $n');
    // Seletor que "escolhe" um item ao toque (os reais abrem busca).
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
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() => remoto = _Remoto());
  tearDown(() async => sl.reset());

  testWidgets('mostra a NF-e, as pendências e NF-e × contado por linha', (
    tester,
  ) async {
    await abrir(tester);

    expect(find.textContaining('NF-e 123/1 · Fornecedor Ltda'), findsOneWidget);
    expect(find.text('Pendências antes de conferir'), findsOneWidget);
    expect(find.text('1. Calça Wide Leg'), findsOneWidget);
    expect(find.text('Identificado'), findsOneWidget);
    expect(find.text('Produto não cadastrado'), findsOneWidget);
    // sem produto: pré-cadastrar / vincular; com SKU: contar
    expect(find.text('Pré-cadastrar'), findsOneWidget);
    expect(find.text('Vincular a referência'), findsOneWidget);
    expect(find.byKey(const Key('entrada_contar_1')), findsOneWidget);
    expect(find.byKey(const Key('entrada_contar_2')), findsNothing);
  });

  testWidgets(
      'contar um SKU identificado manda a contagem e mostra a diferença', (
    tester,
  ) async {
    await abrir(tester);

    await tester.tap(find.byKey(const Key('entrada_contar_1')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('contagem_quantidade')), '9');
    await tester.tap(find.byKey(const Key('contagem_salvar')));
    await tester.pumpAndSettle();

    expect(remoto.contagemEnviada, hasLength(1));
    expect(remoto.contagemEnviada!.single.produtoId, 11);
    expect(remoto.contagemEnviada!.single.linhaId, 1);
    expect(remoto.contagemEnviada!.single.quantidade, 9);
    expect(find.textContaining('Diferença: -1'), findsOneWidget);
    expect(find.text('Resolver divergência'), findsOneWidget);
  });

  testWidgets(
      'entrada por contagem: conta referência + cor + tamanho sem linha de NF-e',
      (
    tester,
  ) async {
    remoto.semNfe = true;
    await abrir(tester);

    expect(find.text('Contagem por referência'), findsOneWidget);
    expect(find.textContaining('Nenhuma contagem ainda'), findsOneWidget);
    expect(find.text('Calça Wide Leg'), findsNothing);

    await tester.tap(find.byKey(const Key('entrada_contar_referencia')));
    await tester.pumpAndSettle();
    // sem referência escolhida não há o que enviar
    await tester.tap(find.byKey(const Key('contagem_salvar')));
    await tester.pumpAndSettle();
    expect(remoto.contagemEnviada, isNull);

    await tester.tap(find.byKey(const Key('entrada_contar_referencia')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('escolher_referencia')));
    await tester.tap(find.byKey(const Key('escolher_cor')));
    await tester.tap(find.byKey(const Key('escolher_tamanho')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('contagem_1_2')), '3');
    await tester.tap(find.byKey(const Key('contagem_salvar')));
    await tester.pumpAndSettle();

    final item = remoto.contagemEnviada!.single;
    expect(item.linhaId, isNull); // sem NF-e
    expect(item.referenciaId, 77);
    expect(item.corId, 1);
    expect(item.tamanhoId, 2);
    expect(item.quantidade, 3);
    expect(find.text('Vestido Luna'), findsOneWidget);
    expect(find.textContaining('Preto M: 3'), findsOneWidget);
  });

  testWidgets(
      'etiquetas e conferência ficam desabilitadas com contagem sem referência',
      (
    tester,
  ) async {
    remoto
      ..semNfe = true
      ..comLivre = true;
    await abrir(tester);

    FilledButton conferir() => tester.widget<FilledButton>(
          find.byKey(const Key('pedido_entrada_conferir_codigo_button')),
        );
    expect(conferir().onPressed, isNull);
    expect(find.textContaining('Associe uma referência'), findsWidgets);
    expect(find.byKey(const Key('pedido_entrada_conferir_button')),
        findsOneWidget);
  });

  testWidgets('sem pendências as ações de etiqueta e conferência ficam ativas',
      (
    tester,
  ) async {
    remoto.semNfe = true;
    await abrir(tester);

    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const Key('pedido_entrada_conferir_codigo_button')),
          )
          .onPressed,
      isNotNull,
    );
  });
}
