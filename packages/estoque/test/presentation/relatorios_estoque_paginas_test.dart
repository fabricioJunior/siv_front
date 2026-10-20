import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/sessao.dart';
import 'package:core/tema.dart';
import 'package:estoque/data/remote/dtos/relatorio_produtos_defasados_dto.dart';
import 'package:estoque/domain/data/repositorios/i_relatorio_estoque_repository.dart';
import 'package:estoque/domain/models/relatorio_posicao_estoque.dart';
import 'package:estoque/domain/models/relatorio_produtos_defasados.dart';
import 'package:estoque/domain/usecases/get_relatorio_posicao_estoque.dart';
import 'package:estoque/domain/usecases/get_relatorio_produtos_defasados.dart';
import 'package:estoque/presentation/blocs/relatorio_posicao_estoque_bloc/relatorio_posicao_estoque_bloc.dart';
import 'package:estoque/presentation/blocs/relatorio_produtos_defasados_bloc/relatorio_produtos_defasados_bloc.dart';
import 'package:estoque/presentation/pages/relatorio_estoque_page.dart';
import 'package:estoque/presentation/pages/relatorio_produtos_defasados_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Sessao implements IAcessoGlobalSessao {
  @override
  int? get empresaIdDaSessao => 1;

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

class _Repo implements IRelatorioEstoqueRepository {
  bool falha = false;
  bool vazio = false;
  final chamadas = <Map<String, Object?>>[];

  @override
  Future<RelatorioPosicaoEstoque> posicaoEstoque({
    required List<int> empresaIds,
    String? dataReferencia,
    List<int>? categoriaIds,
    List<int>? corIds,
    List<int>? tamanhoIds,
    String? situacao,
    String ordenarPor = 'valor',
    String ordem = 'desc',
  }) async {
    chamadas.add({
      'cat': categoriaIds,
      'cor': corIds,
      'tam': tamanhoIds,
      'sit': situacao,
    });
    if (falha) throw Exception('x');
    return RelatorioPosicaoEstoque(
      baseValor: 'venda',
      resumo: const PosicaoEstoqueResumo(
          valorEstoque: 5000, pecas: 50, skusAtivos: 9, emRuptura: 2),
      items: vazio
          ? const []
          : const [
              PosicaoEstoqueCategoria(
                  categoriaNome: 'Calça', pecas: 30, valor: 3000, percentual: 60),
            ],
    );
  }

  @override
  Future<RelatorioProdutosDefasados> produtosDefasados({
    required List<int> empresaIds,
    int dias = 90,
    String tipoMovimentacao = 'ambas',
    String visualizacao = 'produto',
    String? dataReferencia,
    List<int>? produtoIds,
    List<int>? referenciaIds,
    List<int>? categoriaIds,
    List<int>? corIds,
    List<int>? tamanhoIds,
    ModoAgrupamentoReferencia modoAgrupamentoReferencia =
        ModoAgrupamentoReferencia.todos,
    String? busca,
    int page = 1,
    int limit = 100,
  }) async {
    if (falha) throw Exception('x');
    return RelatorioProdutosDefasadosDto(
      items: vazio
          ? const []
          : const [
              RelatorioProdutoDefasadoItemDto(
                produtoId: 1,
                produtoIdExterno: 'P1',
                referenciaId: 2,
                referenciaIdExterno: '2001',
                referenciaNome: 'VESTIDO LONGO',
                corId: 3,
                corNome: 'AZUL',
                tamanhoId: 4,
                tamanhoNome: 'M',
                quantidadeProdutos: 1,
                saldo: 5,
                valorUnitario: 100,
                valorTotal: 500,
                diasSemMovimentacao: 120,
              ),
            ],
      meta: const RelatorioProdutosDefasadosMetaDto(
          totalItems: 1, itemCount: 1, itemsPerPage: 100, currentPage: 1, totalPages: 1),
      resumo: const RelatorioProdutosDefasadosResumoDto(
          quantidadeDefasados: 1,
          totalEmEstoque: 10,
          percentualDefasado: 10,
          valorTotalDefasado: 500),
    );
  }

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

late _Repo _repo;

Future<void> _abre(WidgetTester t, double largura, Widget pagina,
    {void Function(_Repo)? config}) async {
  final antes = FlutterError.onError;
  FlutterError.onError = (d) {
    if (d.exceptionAsString().contains('overflowed')) return;
    antes?.call(d);
  };
  addTearDown(() => FlutterError.onError = antes);
  t.view.physicalSize = Size(largura, 1600);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await sl.reset();
  addTearDown(sl.reset);
  _repo = _Repo();
  config?.call(_repo);
  sl.registerSingleton<IAcessoGlobalSessao>(_Sessao());
  sl.registerSingleton(GetRelatorioPosicaoEstoque(repository: _repo));
  sl.registerFactory(() => RelatorioProdutosDefasadosBloc(
      GetRelatorioProdutosDefasados(repository: _repo)));
  await t.pumpWidget(const SizedBox());
  await t.pumpWidget(MaterialApp(theme: SivTheme.tema, home: pagina));
  await t.pumpAndSettle();
}

const _vazioTxt = 'Nenhum resultado para o filtro selecionado.';

void main() {
  for (final w in [800.0, 1280.0]) {
    final desktop = w >= 820;
    group('largura $w', () {
      testWidgets('R6 estoque: KPIs, tabela/cartões', (t) async {
        await _abre(t, w, const RelatorioEstoquePage());
        expect(find.text('VALOR EM ESTOQUE'), findsOneWidget);
        expect(find.text('EM RUPTURA'), findsOneWidget);
        expect(find.text('CATEGORIA'), desktop ? findsOneWidget : findsNothing);
        expect(find.byType(RelatorioItemMobile), desktop ? findsNothing : findsOneWidget);
        expect(find.text('Valor calculado pelo preço de venda.'), findsOneWidget);
      });

      testWidgets('R6 estoque: vazio e erro', (t) async {
        await _abre(t, w, const RelatorioEstoquePage(), config: (r) => r.vazio = true);
        expect(find.text(_vazioTxt), findsOneWidget);
        await _abre(t, w, const RelatorioEstoquePage(), config: (r) => r.falha = true);
        expect(find.text('Tentar de novo'), findsOneWidget);
      });

      testWidgets('R5 produtos defasados: KPIs, tabela/cartões', (t) async {
        await _abre(t, w, const RelatorioProdutosDefasadosPage());
        expect(find.text('ITENS DEFASADOS'), findsOneWidget);
        expect(find.text('PRODUTO'), desktop ? findsOneWidget : findsNothing);
        expect(find.byType(RelatorioItemMobile), desktop ? findsNothing : findsOneWidget);
      });

      testWidgets('R5 produtos defasados: vazio e erro', (t) async {
        await _abre(t, w, const RelatorioProdutosDefasadosPage(),
            config: (r) => r.vazio = true);
        expect(find.text(_vazioTxt), findsOneWidget);
        await _abre(t, w, const RelatorioProdutosDefasadosPage(),
            config: (r) => r.falha = true);
        expect(find.text('Tentar de novo'), findsOneWidget);
      });
    });
  }

  testWidgets('R6: chip "Em ruptura" chama o use case com situacao=ruptura', (t) async {
    // largura extra: o cabeçalho desktop não quebra linha e o chip sairia da tela
    await _abre(t, 2400, const RelatorioEstoquePage());
    expect(_repo.chamadas.single['sit'], isNull);
    await t.tap(find.textContaining('Em ruptura'));
    await t.pumpAndSettle();
    expect(_repo.chamadas.last['sit'], 'ruptura');
  });

  test('R6: filtros de categoria/cor/tamanho/situação chegam ao use case', () async {
    await sl.reset();
    addTearDown(sl.reset);
    sl.registerSingleton<IAcessoGlobalSessao>(_Sessao());
    _repo = _Repo();
    final bloc = RelatorioPosicaoEstoqueBloc(GetRelatorioPosicaoEstoque(repository: _repo));
    addTearDown(bloc.close);
    bloc.add(const PosicaoEstoqueFiltrosAlterados(
      categoriaIds: [1, 2],
      corIds: [3],
      tamanhoIds: [4],
      situacao: 'normal',
    ));
    await bloc.stream.firstWhere((s) => s.step == PosicaoEstoqueStep.sucesso);
    expect(_repo.chamadas.single, {
      'cat': [1, 2],
      'cor': [3],
      'tam': [4],
      'sit': 'normal',
    });
  });
}
