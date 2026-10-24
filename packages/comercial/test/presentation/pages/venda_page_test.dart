import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/presentation/pagamento/pagamento_etapa.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/leitor.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/seletores.dart';
import 'package:core/sessao.dart';
import 'package:core/tema.dart';
import 'package:financeiro/use_cases.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promocoes/models.dart';
import 'package:promocoes/use_cases.dart';

import '../../support/venda_fakes.dart';
import '../blocs/romaneio_criacao_bloc_test.dart';

class _Produto with LeitorData {
  @override
  final String codigoDeBarras;
  _Produto(this.codigoDeBarras);
  @override
  String get descricao => 'Produto $codigoDeBarras';
  @override
  int get quantidade => 100;
  @override
  int get idReferencia => 1;
  @override
  String get tamanho => 'M';
  @override
  String get cor => 'Preto';
  @override
  double? get valor => 10;
  @override
  int get id => 1;
  @override
  Map<String, dynamic> get dados => const {};
}

class _Leitor implements ILeitorDataDatasource {
  @override
  Future<LeitorData?> getData(String codigo, {int? tabelaDePrecoId}) async =>
      _Produto(codigo);

  @override
  Future<LeitorData?> getDataPorProdutoId(
    int produtoId, {
    int? tabelaDePrecoId,
  }) async =>
      null;
}

class _Busca implements ILeitorBuscaDataDatasource {
  @override
  Future<List<LeitorData>> buscarPorTexto(
    String texto, {
    String? tamanho,
    String? cor,
    int? tabelaDePrecoId,
    Set<int>? somenteProdutoIds,
  }) async =>
      texto.isEmpty ? const [] : [_Produto('555')];
}

class _Sessao implements IAcessoGlobalSessao {
  @override
  int? get caixaIdDaSessao => 999;

  @override
  int? get empresaIdDaSessao => null;

  @override
  dynamic noSuchMethod(Invocation i) {
    if (i.memberName == #dadosSincronizados) return true;
    if (i.memberName == #sincronizandoDados) return const Stream<bool>.empty();
    return null;
  }
}

class _Orcamento implements CarregarOrcamento {
  @override
  Future<OrcamentoLocal?> call(String hash) async => OrcamentoLocal.criar(
        hash: hash,
        clienteId: 1,
        clienteNome: 'Cliente Teste',
        funcionarioId: 2,
        funcionarioNome: 'Ana',
        tabelaPrecoId: 3,
        tabelaPrecoNome: 'Atacado',
        itens: const [],
      );
}

class _Resumo implements CarregarResumoPagamentosRealizados {
  @override
  Future<PagamentosRealizadosResumo> call(String hashLista) async =>
      throw UnimplementedError();
}

class _Saldo implements BuscarSaldoCreditoDevolucao {
  @override
  Future<double> call({
    required int pessoaId,
    List<int>? empresaIds,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async =>
      0;
}

class _Fidelidade implements VerificarElegibilidadeFidelidade {
  @override
  Future<bool> call({required int pessoaId}) async => false;
}

class _PermiteEmail implements VerificarPermiteNotaFiscalEmail {
  @override
  Future<bool> call({required int empresaId}) async => false;
}

class _Apurar implements ApurarElegibilidade {
  @override
  Future<ResultadoElegibilidade> call({
    int? clienteId,
    required List<ItemApuracaoElegibilidade> itens,
    List<String> codigosCupom = const [],
  }) async =>
      const ResultadoElegibilidade(itens: []);
}

Widget _grade(FormaPagamentoGradeData d) => TextButton(
      onPressed: () => d.onEscolhida(
        SelectData(id: 1, nome: 'Dinheiro', data: const {'tipo': 'Dinheiro'}),
      ),
      child: const Text('GRADE'),
    );

Widget _seletor(SeletorData d) => const SizedBox();

void main() {
  const hashLista = 'hash';
  final agora = DateTime(2026, 10, 22);
  late int tentativasVendaCompleta;
  late bool falharPrimeira;
  late int? romaneioRetomado;
  late int recebimentosFalhos;
  late List<int> recebidos;

  setUp(() async {
    await sl.reset();
    tentativasVendaCompleta = 0;
    falharPrimeira = false;
    romaneioRetomado = null;
    recebimentosFalhos = 0;
    recebidos = [];
    final sessao = _Sessao();
    sl.registerSingleton<IAcessoGlobalSessao>(sessao);
    sl.registerSingleton<ILeitorDataDatasource>(_Leitor());
    sl.registerSingleton<ILeitorBuscaDataDatasource>(_Busca());
    sl.registerFactory<VendaBloc>(
      () => VendaBloc(
        FakeSalvar(),
        FakePedido(),
        FakeItemPedido(),
        FakeSalvarOrcamento(),
        _Orcamento(),
        FakeExcluirOrcamento(),
        FakeCaixa(),
        FakeBalanco(),
        sessao,
        FakeNaoCadastrado(),
        VerificarExigeClienteNaVenda(FakeExigeCliente()),
        RecuperarDescontoMaximoVendedor(FakeLimite(0)),
        FakeReenviar(),
        FakeReprocessar(),
      ),
    );
    sl.registerFactory<PagamentosRealizadosBloc>(
      () => PagamentosRealizadosBloc(
        _Resumo(),
        _Saldo(),
        _Fidelidade(),
        _PermiteEmail(),
        sessao,
        _Apurar(),
        _Leitor(),
      ),
    );
    sl.registerFactory<RomaneioCriacaoBloc>(
      () => RomaneioCriacaoBloc(
        StubCriarRomaneio((_) async => throw UnimplementedError()),
        StubAdicionarItemRomaneio(({required romaneioId, required item}) async {}),
        StubRecuperarRomaneio((_) async => Romaneio.create(
              id: 123,
              funcionarioId: 2,
              tabelaPrecoId: 3,
              operacao: TipoOperacao.venda,
            )),
        StubAtualizarObservacaoRomaneio((_, __) async => Romaneio.create(
              id: 123,
              funcionarioId: 2,
              tabelaPrecoId: 3,
              operacao: TipoOperacao.venda,
            )),
        StubRecuperarListaDeProdutosCompartilhada(
          onCall: (_) async => ListaDeProdutosCompartilhada(
            hash: hashLista,
            origem: OrigemCompartilhadaTipo.venda,
            criadaEm: agora,
            atualizadaEm: agora,
            pessoaId: 1,
            funcionarioId: 2,
            tabelaPrecoId: 3,
            idLista: romaneioRetomado,
          ),
          onRecuperarProdutos: (_) async => const [
            ProdutoCompartilhado(
              hash: 'p',
              produtoId: 1,
              hashLista: hashLista,
              quantidade: 1,
              valorUnitario: 10,
              nome: 'Produto',
              corNome: 'Preto',
              tamanhoNome: 'M',
            ),
          ],
        ),
        StubRemoverListaDeProdutosCompartilhada((_) async {}),
        StubRemoverProdutoCompartilhado((_) async {}),
        StubAtualizarListaCompartilhada((_) async {}),
        StubReceberRomaneioNoCaixa(
          ({
            required caixaId,
            required romaneioId,
            required formasDePagamentoRealizadas,
          }) async {
            recebidos.add(romaneioId);
            if (recebimentosFalhos-- > 0) throw Exception('estoque');
          },
        ),
        StubCriarVendaCompleta(() async {
          tentativasVendaCompleta++;
          if (falharPrimeira && tentativasVendaCompleta == 1) {
            throw Exception('caixa fechado');
          }
          return Romaneio.create(
            id: 48213,
            funcionarioId: 2,
            tabelaPrecoId: 3,
            operacao: TipoOperacao.venda,
          );
        }),
        sessao,
        RecuperarCaixaAberto(repository: StubCaixaRepository()),
        ListarDocumentosFiscais(repository: StubIntegracaoFiscalRepository()),
      ),
    );
  });
  tearDown(() async => sl.reset());

  Future<void> abrir(WidgetTester t) async {
    t.view.physicalSize = const Size(1400, 900);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final antigo = FlutterError.onError;
    FlutterError.onError = (d) {
      // overflow: fonte Ahem (markNeedsBuild no build NÃO é filtrado).
      if (!d.exceptionAsString().contains('overflowed')) antigo?.call(d);
    };
    addTearDown(() => FlutterError.onError = antigo);

    await t.pumpWidget(
      MaterialApp(
        theme: SivTheme.tema,
        home: Scaffold(
          body: VendaPage(
            pessoaSeletor: _seletor,
            vendedoresSeletor: _seletor,
            tabelasDePrecoSeletor: _seletor,
            formaPagamentoGrade: _grade,
          ),
        ),
      ),
    );
    await t.pump();
    // Entra na leitura sem passar pela checagem de caixa.
    final bloc = t.element(find.text('Iniciar venda')).read<VendaBloc>();
    bloc.add(const VendaOrcamentoCarregarSolicitado(hash: 'o'));
    await t.pumpAndSettle();
  }

  Future<void> bipar(WidgetTester t, String codigo) async {
    await t.enterText(find.byType(TextField).first, codigo);
    await t.testTextInput.receiveAction(TextInputAction.done);
    await t.pumpAndSettle();
  }

  Future<void> tecla(WidgetTester t, LogicalKeyboardKey k) async {
    await t.sendKeyEvent(k);
    await t.pumpAndSettle();
  }

  testWidgets(
      'leitura → F9 → forma → F9 conclui sem modal, troco e romaneio ficam até Nova venda',
      (t) async {
    await abrir(t);
    await bipar(t, '789');
    expect(find.text('Ir para pagamento · F9'), findsOneWidget);

    await tecla(t, LogicalKeyboardKey.f9);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Confirmar e emitir · F9'), findsOneWidget);

    await t.tap(find.text('GRADE'));
    await t.pumpAndSettle();
    await tecla(t, LogicalKeyboardKey.f9);

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('VENDA CONCLUÍDA'), findsOneWidget);
    expect(find.textContaining('Romaneio #48213'), findsOneWidget);
    expect(find.text('SEM TROCO'), findsOneWidget);
    expect(tentativasVendaCompleta, 1);

    await tecla(t, LogicalKeyboardKey.enter);
    expect(find.text('Ir para pagamento · F9'), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget, reason: 'mantém o vendedor');
    expect(find.text('Produto 789'), findsNothing, reason: 'itens zerados');
  });

  testWidgets('pagamento: F4 abre o desconto da etapa e o foco fica nela',
      (t) async {
    await abrir(t);
    await bipar(t, '789');
    await tecla(t, LogicalKeyboardKey.f9);
    expect(find.text('Confirmar e emitir · F9'), findsOneWidget);

    await tecla(t, LogicalKeyboardKey.f4);
    expect(find.text('Percentual (0 a 100)'), findsOneWidget);
  });

  testWidgets('Esc no pagamento volta aos itens e o pagamento recomeça do zero',
      (t) async {
    await abrir(t);
    await bipar(t, '789');
    await tecla(t, LogicalKeyboardKey.f9);
    await t.tap(find.text('GRADE'));
    await t.pumpAndSettle();

    await tecla(t, LogicalKeyboardKey.escape);
    expect(find.text('Ir para pagamento · F9'), findsOneWidget);
    expect(find.text('Produto 789'), findsWidgets, reason: 'itens preservados');

    await tecla(t, LogicalKeyboardKey.f9);
    expect(find.text('Confirmar e emitir · F9'), findsOneWidget);
    final bloc = t.element(find.byType(PagamentoEtapa))
        .read<PagamentosRealizadosBloc>();
    expect(bloc.state.linhas.single.formaDePagamento, isNull);
  });

  testWidgets('falha total fica no pagamento com a mensagem e F9 tenta de novo',
      (t) async {
    falharPrimeira = true;
    await abrir(t);
    await bipar(t, '789');
    await tecla(t, LogicalKeyboardKey.f9);
    await t.tap(find.text('GRADE'));
    await t.pumpAndSettle();
    await tecla(t, LogicalKeyboardKey.f9);

    expect(find.text('VENDA CONCLUÍDA'), findsNothing);
    expect(find.text('Confirmar e emitir · F9'), findsOneWidget);
    expect(find.textContaining('Falha ao criar o romaneio'), findsOneWidget);

    await tecla(t, LogicalKeyboardKey.f9);
    expect(find.text('VENDA CONCLUÍDA'), findsOneWidget);
    expect(tentativasVendaCompleta, 2);
  });

  testWidgets(
      'parcial vira pendência com o romaneio e "tentar receber de novo" conclui sem criar outro',
      (t) async {
    romaneioRetomado = 123;
    recebimentosFalhos = 1;
    await abrir(t);
    await bipar(t, '789');
    await tecla(t, LogicalKeyboardKey.f9);
    await t.tap(find.text('GRADE'));
    await t.pumpAndSettle();
    await tecla(t, LogicalKeyboardKey.f9);

    expect(find.textContaining('ROMANEIO #123 CRIADO'), findsOneWidget);
    expect(find.textContaining('nada foi cobrado'), findsOneWidget);
    expect(find.text('Confirmar e emitir · F9'), findsNothing);

    await tecla(t, LogicalKeyboardKey.enter);
    expect(find.text('VENDA CONCLUÍDA'), findsOneWidget);
    expect(recebidos, [123, 123]);
    expect(tentativasVendaCompleta, 0, reason: 'não cria romaneio novo');
  });

  testWidgets('busca manual abre com foco no campo; após adicionar, F2/F9 seguem valendo',
      (t) async {
    await abrir(t);

    await tecla(t, LogicalKeyboardKey.f2);
    expect(find.text('Busca manual de produto'), findsOneWidget);
    expect(
        FocusManager.instance.primaryFocus!.context!
            .findAncestorWidgetOfExactType<EditableText>(),
        isNotNull,
        reason: 'foco no campo de busca');

    await t.enterText(find.byType(TextField).last, 'cam');
    await t.pump(const Duration(milliseconds: 500));
    await t.pumpAndSettle();
    await t.tap(find.text('Produto 555'));
    await t.pumpAndSettle();
    await t.tap(find.text('Adicionar'));
    await t.pumpAndSettle();
    expect(find.text('Busca manual de produto'), findsNothing);
    expect(
        FocusManager.instance.primaryFocus!.context!
            .findAncestorWidgetOfExactType<EditableText>(),
        isNotNull,
        reason: 'foco volta ao campo de código');

    await tecla(t, LogicalKeyboardKey.f2);
    expect(find.text('Busca manual de produto'), findsOneWidget,
        reason: 'F2 ainda funciona depois do primeiro item');
    await tecla(t, LogicalKeyboardKey.escape);
    await tecla(t, LogicalKeyboardKey.f9);
    expect(find.text('Confirmar e emitir · F9'), findsOneWidget);
  });

  testWidgets('leitura: sem atalho nem linha de desconto; só um Trocar',
      (t) async {
    await abrir(t);
    await bipar(t, '789');
    expect(find.text('Trocar'), findsOneWidget);
    expect(find.textContaining('F4'), findsNothing);

    await tecla(t, LogicalKeyboardKey.f4);
    expect(find.textContaining('Desconto'), findsNothing);
    expect(find.byType(TextField), findsOneWidget, reason: 'só o código');
  });
}
