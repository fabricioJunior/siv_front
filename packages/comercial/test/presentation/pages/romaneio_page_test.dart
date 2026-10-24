import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/presentation/pagamento/pagamento_etapa.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/leitor.dart';
import 'package:core/permissoes/i_permissoes_controller.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/seletores.dart';
import 'package:core/sessao.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promocoes/models.dart';
import 'package:promocoes/use_cases.dart';


class _Permissoes implements IPermissoesController {
  @override
  Future<bool> acessoPermitido({String? idComponente, int? grupoId}) async =>
      true;

  @override
  bool temAcesso({String? idComponente, int? grupoId}) => true;
}

class _Sessao implements IAcessoGlobalSessao {
  @override
  int? get caixaIdDaSessao => 999;

  @override
  int? get empresaIdDaSessao => 1;

  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _Rec implements RecuperarRomaneio {
  @override
  Future<Romaneio> call(int id) async => Romaneio.create(
        id: id,
        pessoaId: 7,
        pessoaNome: 'Cliente',
        funcionarioId: 2,
        tabelaPrecoId: 3,
        operacao: TipoOperacao.venda,
        situacao: 'em_andamento',
        valorBruto: 100,
        desconto: 10,
        valorTaxaEntrega: 5,
      );
}

class _Itens implements RecuperarItensRomaneio {
  @override
  Future<List<RomaneioItem>> call(int id) async => [
        RomaneioItem.create(
          produtoId: 1,
          quantidade: 2,
          valorUnitario: 50,
          referenciaNome: 'Sutiã Renda',
          corNome: 'Preto',
          tamanhoNome: '44',
        ),
      ];
}

class _Nada implements RecuperarItensDevolvidosRomaneio {
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _Criar implements CriarRomaneio {
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _Atualizar implements AtualizarRomaneio {
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _Obs implements AtualizarObservacaoRomaneio {
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _Vendedor implements AtualizarVendedorRomaneio {
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _Finalizar implements FinalizarRomaneio {
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _Listas implements RecuperarListaDeProdutosCompartilhada {
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _AddItem implements AdicionarItemRomaneio {
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _RemProd implements RemoverProdutoCompartilhado {
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _Docs implements ListarDocumentosFiscais {
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _Corrigir implements CorrigirFormaDePagamentoRomaneio {
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _Receber implements ReceberRomaneioNoCaixa {
  final recebidos = <Map<String, dynamic>>[];
  String? falha;

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
    Map<String, dynamic>? resgatePontos,
    bool enviarNotaPorEmail = false,
    String emailNota = '',
  }) async {
    recebidos.add({
      'desconto': desconto,
      'taxa': valorTaxaEntrega,
      'email': enviarNotaPorEmail,
      'formas': formasDePagamentoRealizadas.length,
    });
    if (falha != null) throw Exception(falha);
  }
}

class _StubOpcoesResgate implements RecuperarOpcoesResgatePontos {
  @override
  Future<OpcoesResgatePontos> call({required int pessoaId}) async =>
      throw UnimplementedError();
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
      const ResultadoElegibilidade(itens: []);
}

class _Leitor implements ILeitorDataDatasource {
  @override
  dynamic noSuchMethod(Invocation i) async => null;
}

Widget _grade(FormaPagamentoGradeData d) => TextButton(
      onPressed: () => d.onEscolhida(
        SelectData(id: 1, nome: 'Dinheiro', data: const {'tipo': 'Dinheiro'}),
      ),
      child: const Text('GRADE'),
    );

Widget _seletor(SeletorData d) => const SizedBox();

void main() {
  late _Receber receber;

  setUp(() async {
    await sl.reset();
    receber = _Receber();
    final sessao = _Sessao();
    sl.registerSingleton<IPermissoesController>(_Permissoes());
    sl.registerSingleton<ILeitorDataDatasource>(_Leitor());
    sl.registerFactory<RomaneioBloc>(
      () => RomaneioBloc(
        _Rec(),
        _Itens(),
        _Nada(),
        _Criar(),
        _Atualizar(),
        _Obs(),
        _Vendedor(),
        _Finalizar(),
        _Listas(),
        _AddItem(),
        _RemProd(),
        _Docs(),
        _Corrigir(),
        receber,
        sessao,
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
        _StubOpcoesResgate(),
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
        home: RomaneioPage(
          idRomaneio: 10,
          permitirEdicao: false,
          tableDePrecoSeletor: _seletor,
          funcionarioSeletor: _seletor,
          pessoaSeletor: _seletor,
          formaPagamentoGrade: _grade,
        ),
      ),
    );
    await t.pumpAndSettle();
    await t.ensureVisible(find.text('Ir para pagamento'));
    await t.tap(find.text('Ir para pagamento'));
    await t.pumpAndSettle();
  }

  testWidgets(
      'pagamento é etapa (sem diálogo), sem e-mail da nota, F9 manda desconto e taxa do romaneio',
      (t) async {
    await abrir(t);

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Confirmar pagamento · F9'), findsOneWidget);
    expect(find.text('Enviar nota fiscal por e-mail'), findsNothing);
    expect(find.text('Pontuar fidelidade'), findsNothing);

    await t.tap(find.text('GRADE'));
    await t.pumpAndSettle();
    await t.sendKeyEvent(LogicalKeyboardKey.f9);
    await t.pumpAndSettle();

    expect(receber.recebidos, hasLength(1));
    expect(receber.recebidos.single['desconto'], 10);
    expect(receber.recebidos.single['taxa'], 5);
    expect(receber.recebidos.single['email'], false);
    // Etapa fechou ao receber.
    expect(find.text('Confirmar pagamento · F9'), findsNothing);
  });

  testWidgets('Esc volta ao romaneio e reabrir preserva as linhas', (t) async {
    await abrir(t);
    await t.tap(find.text('GRADE'));
    await t.pumpAndSettle();

    await t.sendKeyEvent(LogicalKeyboardKey.escape);
    await t.pumpAndSettle();
    expect(find.text('Confirmar pagamento · F9'), findsNothing);
    expect(find.text('Ir para pagamento'), findsOneWidget);

    await t.ensureVisible(find.text('Ir para pagamento'));
    await t.tap(find.text('Ir para pagamento'));
    await t.pumpAndSettle();
    final bloc = t
        .element(find.byType(PagamentoEtapa).first)
        .read<PagamentosRealizadosBloc>();
    expect(bloc.state.linhas.single.valorTexto, '95,00');
  });

  testWidgets('falha no recebimento: erro junto do botão, etapa segue aberta',
      (t) async {
    receber.falha = 'Caixa fechado';
    await abrir(t);
    await t.tap(find.text('GRADE'));
    await t.pumpAndSettle();
    await t.sendKeyEvent(LogicalKeyboardKey.f9);
    await t.pumpAndSettle();

    expect(find.text('Falha ao receber o pagamento.'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('Confirmar pagamento · F9'), findsOneWidget);
  });
}
