import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/presentation/pagamento/pagamento_etapa.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/leitor.dart';
import 'package:core/seletores.dart';
import 'package:core/sessao.dart';
import 'package:core/tema.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/use_cases.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/uses_cases.dart';
import 'package:promocoes/models.dart';
import 'package:promocoes/use_cases.dart';

class _Sessao implements IAcessoGlobalSessao {
  @override
  int? get empresaIdDaSessao => 1;

  @override
  int? get terminalIdDaSessao => 5;

  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _Caixa implements Caixa {
  @override
  int get id => 99;

  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _RecCaixa implements RecuperarCaixaAberto {
  @override
  Future<Caixa?> call({required int idEmpresa, required int idTerminal}) async =>
      _Caixa();

  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _Criar implements CriarRomaneio {
  int chamadas = 0;

  @override
  Future<Romaneio> call(Romaneio romaneio) async {
    chamadas++;
    return Romaneio.create(id: 321, operacao: TipoOperacao.consignacao_acerto);
  }
}

class _AddItem implements AdicionarItemRomaneio {
  @override
  Future<RomaneioItem> call({
    required int romaneioId,
    required RomaneioItem item,
  }) async =>
      item;
}

class _Receber implements ReceberRomaneioNoCaixa {
  final recebidos = <Map<String, dynamic>>[];
  bool falhar = false;

  @override
  Future<void> call({
    required int caixaId,
    required int romaneioId,
    required List<RomaneioPagamentoRealizado> formasDePagamentoRealizadas,
    double? desconto,
    double? valorTaxaEntrega,
    List<Map<String, dynamic>> descontosItens = const [],
    List<Map<String, dynamic>> descontosPromocao = const [],
    List<Map<String, dynamic>>? cupons,
    bool incluirCpfNaNota = true,
    String cpfNaNota = '',
    bool pontuarFidelidade = false,
    bool enviarNotaPorEmail = false,
    String emailNota = '',
  }) async {
    recebidos.add({
      'romaneioId': romaneioId,
      'desconto': desconto,
      'taxa': valorTaxaEntrega,
      'cupons': cupons,
      'email': enviarNotaPorEmail,
      'emailNota': emailNota,
      'valor': formasDePagamentoRealizadas.fold<double>(0, (s, f) => s + f.valor),
    });
    if (falhar) throw Exception('x');
  }
}

class _Pessoa implements RecuperarPessoa {
  @override
  Future<Pessoa?> call({required int idPessoa}) async => Pessoa.create(
        id: idPessoa,
        nome: 'Maria',
        tipoPessoa: TipoPessoa.fisica,
        documento: '1',
        email: 'maria@x.com',
        tipoContato: TipoContato.celular,
        contato: null,
        eCliente: true,
        eFornecedor: false,
        eFuncionario: false,
        bloqueado: false,
        generica: false,
        enviarNotaPorEmail: true,
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
  Future<bool> call({required int empresaId}) async => true;
}

class _Apurar implements ApurarElegibilidade {
  @override
  Future<ResultadoElegibilidade> call({
    int? clienteId,
    required List<ItemApuracaoElegibilidade> itens,
    List<String> codigosCupom = const [],
  }) async =>
      ResultadoElegibilidade(
        itens: [
          if (codigosCupom.isNotEmpty)
            ItemElegibilidade(
              referenciaId: 900,
              opcoesElegiveis: const [
                OpcaoElegivel(
                  tipo: 'cupom',
                  id: 3,
                  nome: 'Cupom DEZ',
                  codigo: 'DEZ',
                  valorDesconto: 10,
                  valorFinalUnitario: 40,
                ),
              ],
            ),
        ],
      );
}

class _LeitorData with LeitorData {
  @override
  int get idReferencia => 900;
  @override
  String get codigoDeBarras => '';
  @override
  String get descricao => '';
  @override
  int get quantidade => 1;
  @override
  String get tamanho => '';
  @override
  String get cor => '';
  @override
  double? get valor => null;
  @override
  int get id => 1;
  @override
  Map<String, dynamic> get dados => const {};
}

class _Leitor implements ILeitorDataDatasource {
  @override
  Future<LeitorData?> getData(String codigo, {int? tabelaDePrecoId}) async =>
      null;

  @override
  Future<LeitorData?> getDataPorProdutoId(
    int produtoId, {
    int? tabelaDePrecoId,
  }) async =>
      _LeitorData();
}

Widget _grade(FormaPagamentoGradeData d) => TextButton(
      onPressed: () => d.onEscolhida(
        SelectData(id: 1, nome: 'Dinheiro', data: const {'tipo': 'Dinheiro'}),
      ),
      child: const Text('GRADE'),
    );

void main() {
  late _Criar criar;
  late _Receber receber;

  final consignacao = Consignacao.create(
    id: 5,
    pessoaId: 7,
    nomePessoa: 'Maria',
    valorAdiantadoDisponivel: 30,
    itens: [
      ConsignacaoItem.create(
        consignacaoId: 5,
        pessoaId: 7,
        romaneioId: 1,
        sequencia: 1,
        produtoId: 1,
        referenciaNome: 'Sutiã Renda',
        corNome: 'Preto',
        tamanhoNome: '44',
        pendente: 2,
        valorPendente: 100,
      ),
    ],
  );

  setUp(() async {
    await sl.reset();
    criar = _Criar();
    receber = _Receber();
    final sessao = _Sessao();
    sl.registerSingleton<IAcessoGlobalSessao>(sessao);
    sl.registerSingleton<CriarRomaneio>(criar);
    sl.registerSingleton<AdicionarItemRomaneio>(_AddItem());
    sl.registerSingleton<ReceberRomaneioNoCaixa>(receber);
    sl.registerSingleton<RecuperarCaixaAberto>(_RecCaixa());
    sl.registerSingleton<RecuperarPessoa>(_Pessoa());
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
  });
  tearDown(() async => sl.reset());

  Future<void> abrir(WidgetTester t) async {
    t.view.physicalSize = const Size(1400, 1400);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final antigo = FlutterError.onError;
    FlutterError.onError = (d) {
      if (!d.exceptionAsString().contains('overflowed')) antigo?.call(d);
    };
    addTearDown(() => FlutterError.onError = antigo);

    await t.pumpWidget(
      MaterialApp(
        theme: SivTheme.tema,
        home: ConsignacaoAcertoPage(
          consignacao: consignacao,
          formaPagamentoGrade: _grade,
        ),
      ),
    );
    await t.pumpAndSettle();
    await t.tap(find.byType(Checkbox).first);
    await t.pumpAndSettle();
    await t.tap(find.text('Continuar'));
    await t.pumpAndSettle();
  }

  PagamentosRealizadosBloc blocPagamento(WidgetTester t) => t
      .element(find.byType(PagamentoEtapa))
      .read<PagamentosRealizadosBloc>();

  testWidgets(
      'adiantado vira linha do resumo e célula da faixa, sem snackbar; abre com e-mail e preferência da consignatária',
      (t) async {
    await abrir(t);

    expect(find.byType(SnackBar), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Adiantado na saída'), findsOneWidget);
    expect(find.text('ADIANTADO'), findsOneWidget);
    expect(find.text('Confirmar acerto · F9'), findsOneWidget);
    final bloc = blocPagamento(t);
    expect(bloc.state.abatimentoTotal, 30);
    expect(bloc.state.valorTotalProdutos, 100);
    expect(bloc.state.valorTotalAPagar, 70);
    expect(bloc.state.enviarNotaPorEmail, isTrue);
    expect(bloc.state.emailNota, 'maria@x.com');
  });

  testWidgets('cupom, taxa de entrega e e-mail chegam ao recebimento do caixa',
      (t) async {
    await abrir(t);
    final bloc = blocPagamento(t);
    bloc.add(const PagamentosRealizadosCupomInformado(codigo: 'DEZ'));
    bloc.add(const PagamentosRealizadosTaxaEntregaAlterada(valorTexto: '5'));
    await t.pumpAndSettle();
    expect(bloc.state.cuponsAplicados, ['DEZ']);

    await t.tap(find.text('GRADE'));
    await t.pumpAndSettle();
    await t.sendKeyEvent(LogicalKeyboardKey.f9);
    await t.pumpAndSettle();

    final r = receber.recebidos.single;
    expect(r['romaneioId'], 321);
    expect(r['taxa'], 5);
    expect(r['cupons'], [
      {'codigo': 'DEZ', 'produtoIds': [1]},
    ]);
    expect(r['email'], isTrue);
    expect(r['emailNota'], 'maria@x.com');
    // 100 itens − cupom − 30 adiantado + 5 taxa (taxa fora do desconto/abatimento)
    expect(r['valor'], bloc.state.valorTotalAPagar);
    expect(find.textContaining('Acerto realizado com sucesso'), findsOneWidget);
  });

  testWidgets('Esc volta à seleção sem fechar a página e reaproveita o acerto',
      (t) async {
    await abrir(t);
    expect(criar.chamadas, 1);
    await t.tap(find.text('GRADE'));
    await t.pumpAndSettle();

    await t.sendKeyEvent(LogicalKeyboardKey.escape);
    await t.pumpAndSettle();
    expect(find.text('Confirmar acerto · F9'), findsNothing);
    expect(find.text('Continuar'), findsOneWidget);

    await t.tap(find.text('Continuar'));
    await t.pumpAndSettle();
    expect(criar.chamadas, 1);
    expect(find.text('Confirmar acerto · F9'), findsOneWidget);
    expect(blocPagamento(t).state.linhas.single.valorTexto, '70,00');
  });

  testWidgets('falha ao receber: mensagem junto do botão, sem snackbar',
      (t) async {
    receber.falhar = true;
    await abrir(t);
    await t.tap(find.text('GRADE'));
    await t.pumpAndSettle();
    await t.sendKeyEvent(LogicalKeyboardKey.f9);
    await t.pumpAndSettle();

    expect(find.textContaining('Romaneio #321 criado, mas não foi possível'),
        findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('Confirmar acerto · F9'), findsOneWidget);
  });
}
