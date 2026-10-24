import 'package:comercial/domain/models/opcoes_resgate_pontos.dart';
import 'package:comercial/domain/models/pagamentos_realizados_resumo.dart';
import 'package:comercial/presentation/blocs/pagamentos_realizados_bloc/pagamentos_realizados_bloc.dart';
import 'package:comercial/presentation/pagamento/pagamento_contexto.dart';
import 'package:comercial/presentation/pagamento/pagamento_etapa.dart';
import 'package:comercial/presentation/pagamento/pagamento_resumo.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/leitor.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/seletores.dart';
import 'package:core/sessao.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promocoes/models.dart';
import 'package:promocoes/use_cases.dart';

int _saldoDePontos = 100;

class _StubOpcoesResgate implements RecuperarOpcoesResgatePontos {
  @override
  Future<OpcoesResgatePontos> call({required int pessoaId}) async =>
      OpcoesResgatePontos(
        saldo: _saldoDePontos,
        valorPorPonto: 0.1,
        faixas: const [
          FaixaResgate(
            id: 1,
            pontos: 50,
            tipo: 'valor',
            valor: 5,
            cumulativo: true,
            disponivel: true,
          ),
        ],
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
      80;
}

class _Fidelidade implements VerificarElegibilidadeFidelidade {
  @override
  Future<bool> call({required int pessoaId}) async => true;
}

class _PermiteEmail implements VerificarPermiteNotaFiscalEmail {
  @override
  Future<bool> call({required int empresaId}) async => true;
}

class _Sessao implements IAcessoGlobalSessao {
  @override
  int? get empresaIdDaSessao => 1;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
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
  Future<LeitorData?> getData(String codigo, {int? tabelaDePrecoId}) async =>
      null;

  @override
  Future<LeitorData?> getDataPorProdutoId(
    int produtoId, {
    int? tabelaDePrecoId,
  }) async =>
      null;
}

const _produto = ProdutoCompartilhado(
  hash: 'p1',
  produtoId: 1,
  hashLista: 'h',
  quantidade: 2,
  valorUnitario: 50,
  nome: 'Sutiã Renda',
  corNome: 'Preto',
  tamanhoNome: '44',
);

const _resumo = PagamentosRealizadosResumo(
  listaCompartilhada: null,
  produtosCompartilhados: [_produto],
  quantidadeTotalProdutos: 2,
  valorTotalProdutos: 100,
);

PagamentosRealizadosBloc _bloc(PagamentoContexto c) => PagamentosRealizadosBloc(
      _Resumo(),
      _Saldo(),
      _Fidelidade(),
      _PermiteEmail(),
      _Sessao(),
      _Apurar(),
      _Leitor(),
      _StubOpcoesResgate(),
    )..add(c.eventoInicial);

PagamentoContexto _ctx(PagamentoOrigem origem) {
  const base = (hash: 'h', pessoa: 7);
  switch (origem) {
    case PagamentoOrigem.venda:
      return PagamentoContexto.venda(
        hashLista: base.hash,
        resumo: _resumo,
        pessoaId: base.pessoa,
      );
    case PagamentoOrigem.romaneio:
      return PagamentoContexto.romaneio(
        hashLista: base.hash,
        resumo: _resumo,
        pessoaId: base.pessoa,
        taxaEntregaInicial: 0,
      );
    case PagamentoOrigem.pedido:
      return PagamentoContexto.pedido(
        hashLista: base.hash,
        resumo: _resumo,
        titulo: 'Pedido #1 · pagamento',
        pessoaId: base.pessoa,
        abatimentos: const [
          PagamentoAbatimento(rotulo: 'Já lançado', valor: 20),
        ],
        descontosTravados: true,
      );
    case PagamentoOrigem.consignacaoAcerto:
      return PagamentoContexto.consignacaoAcerto(
        hashLista: base.hash,
        resumo: _resumo,
        titulo: 'Consignação #5 · acerto',
        pessoaId: base.pessoa,
        abatimentos: const [
          PagamentoAbatimento(rotulo: 'Adiantado na saída', valor: 30),
        ],
      );
  }
}

Widget _grade(FormaPagamentoGradeData d) => TextButton(
      onPressed: () => d.onEscolhida(
        SelectData(id: 1, nome: 'Dinheiro', data: const {'tipo': 'Dinheiro'}),
      ),
      child: Text('GRADE tipoOp=${d.tipoOperacao} saldo=${d.saldoCliente}'),
    );

var _gradePediuFoco = false;

/// Imita a grade real: o teclado só chega a ela com o foco no `foco` dela.
Widget _gradeComTeclas(FormaPagamentoGradeData d) => Focus(
      focusNode: d.foco,
      autofocus: true,
      onKeyEvent: (_, e) {
        if (e is KeyDownEvent && e.logicalKey == LogicalKeyboardKey.keyD) {
          d.onEscolhida(SelectData(
              id: 1, nome: 'Dinheiro', data: const {'tipo': 'Dinheiro'}));
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Builder(builder: (context) {
        // Como a grade real: pede o foco para si só ao montar (1 vez).
        if (!_gradePediuFoco) {
          _gradePediuFoco = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) d.foco?.requestFocus();
          });
        }
        return const Text('GRADE-TECLAS');
      }),
    );

Future<void> _pump(
  WidgetTester t,
  PagamentosRealizadosBloc bloc,
  PagamentoContexto c, {
  void Function(Map<String, dynamic>)? onConfirmado,
  VoidCallback? onVoltar,
  double largura = 1400,
  FormaPagamentoGradeWidget grade = _grade,
}) async {
  _gradePediuFoco = false;
  t.view.physicalSize = Size(largura, 900);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  // Fonte Ahem (larga) estoura Rows; overflow não é o alvo destes testes.
  final antigo = FlutterError.onError;
  FlutterError.onError = (d) {
    if (!d.exceptionAsString().contains('overflowed')) antigo?.call(d);
  };
  addTearDown(() => FlutterError.onError = antigo);

  await t.pumpWidget(
    MaterialApp(
      theme: SivTheme.tema,
      home: BlocProvider.value(
        value: bloc,
        child: Scaffold(
          body: PagamentoEtapa(
            contexto: c,
            formaPagamentoGrade: grade,
            onConfirmado: onConfirmado ?? (_) {},
            onVoltar: onVoltar ?? () {},
          ),
        ),
      ),
    ),
  );
  await t.pumpAndSettle();
}

void main() {
  const fidelidade = 'Pontuar fidelidade';
  const cpf = 'Incluir CPF do cliente na nota fiscal';
  const email = 'Enviar nota fiscal por e-mail';

  testWidgets('venda: todos os recursos, inclusive fidelidade e e-mail',
      (t) async {
    final c = _ctx(PagamentoOrigem.venda);
    await _pump(t, _bloc(c), c);

    expect(find.text(fidelidade), findsOneWidget);
    expect(find.text(cpf), findsOneWidget);
    expect(find.text(email), findsOneWidget);
    expect(find.text('Código do cupom'), findsOneWidget);
    expect(find.text('editar · F4'), findsOneWidget);
    expect(find.text('adicionar'), findsOneWidget); // entrega
    expect(find.text('Confirmar e emitir · F9'), findsOneWidget);
    expect(find.textContaining('estoque baixado'), findsOneWidget);
    expect(find.textContaining('saldo=80.0'), findsOneWidget);
  });

  testWidgets('romaneio: sem fidelidade e sem e-mail (pendente)', (t) async {
    final c = _ctx(PagamentoOrigem.romaneio);
    await _pump(t, _bloc(c), c);

    expect(find.text(fidelidade), findsNothing);
    expect(find.text(email), findsNothing);
    expect(find.text(cpf), findsOneWidget);
    expect(find.text('Código do cupom'), findsOneWidget);
    expect(find.text('adicionar'), findsOneWidget);
  });

  testWidgets('pedido: entrega só leitura, segmentado, abatimento e travado',
      (t) async {
    final c = _ctx(PagamentoOrigem.pedido);
    await _pump(t, _bloc(c), c);

    expect(find.text(fidelidade), findsNothing);
    expect(find.text(email), findsOneWidget);
    expect(find.text('na entrega'), findsOneWidget);
    expect(find.text('adicionar'), findsNothing);
    expect(find.text('NO ATO DA ENTREGA'), findsOneWidget);
    expect(find.text('ONLINE · LINK / QR'), findsOneWidget);
    expect(find.text('Já lançado'), findsOneWidget);
    expect(
        find.textContaining('Remova os pagamentos lançados'), findsOneWidget);
    // Descontos travados: sem cupom, sem F4, sem painel de item.
    expect(find.text('Código do cupom'), findsNothing);
    expect(find.text('editar · F4'), findsNothing);
    expect(find.byTooltip('Desconto do item'), findsNothing);
    // (100 itens − 20 já lançado)
    expect(find.text('R\$ 80,00'), findsWidgets);
    expect(find.text('Lançar pagamento · F9'), findsOneWidget);
    expect(find.textContaining('tipoOp=manual'), findsOneWidget);

    await t.tap(find.text('ONLINE · LINK / QR'));
    await t.pump();
    expect(find.textContaining('tipoOp=online'), findsOneWidget);
  });

  testWidgets('consignação: adiantado na faixa e no resumo, com taxa e e-mail',
      (t) async {
    final c = _ctx(PagamentoOrigem.consignacaoAcerto);
    await _pump(t, _bloc(c), c);

    expect(find.text('ADIANTADO'), findsOneWidget);
    expect(find.text('Adiantado na saída'), findsOneWidget);
    expect(find.text(fidelidade), findsNothing);
    expect(find.text(email), findsOneWidget);
    expect(find.text('adicionar'), findsOneWidget);
    expect(find.text('Confirmar acerto · F9'), findsOneWidget);
  });

  testWidgets('forma escolhida vem com o valor que falta e F9 confirma',
      (t) async {
    final c = _ctx(PagamentoOrigem.romaneio);
    final bloc = _bloc(c);
    Map<String, dynamic>? resultado;
    await _pump(t, bloc, c, onConfirmado: (r) => resultado = r);

    await t.tap(find.textContaining('GRADE'));
    await t.pumpAndSettle();
    expect(bloc.state.linhas.single.valorTexto, '100,00');

    await t.sendKeyEvent(LogicalKeyboardKey.f9);
    await t.pumpAndSettle();

    expect(resultado, isNotNull);
    expect(
        resultado!.keys,
        containsAll([
          'formasDePagamentoRealizadas',
          'desconto',
          'descontosItens',
          'descontosPromocao',
          'cupons',
          'valorTaxaEntrega',
          'resumoFormasDePagamento',
          'valorTotalRecebido',
          'valorTroco',
          'incluirCpfNaNota',
          'cpfNaNota',
          'pontuarFidelidade',
          'enviarNotaPorEmail',
          'emailNota',
        ]));
    final linha = (resultado!['formasDePagamentoRealizadas'] as List).single;
    expect(linha['parcela'], 1);
    expect(linha['formaDePagamentoId'], 1);
    expect(resultado!['valorTotalRecebido'], 100);
  });

  testWidgets('dividir em outra forma mesmo com a 1ª linha já cobrindo tudo',
      (t) async {
    final c = _ctx(PagamentoOrigem.romaneio);
    final bloc = _bloc(c);
    await _pump(t, bloc, c);

    await t.tap(find.textContaining('GRADE'));
    await t.pumpAndSettle();
    expect(bloc.state.valorRestante, 0);

    await t.tap(find.text('+ Dividir em outra forma'));
    await t.pumpAndSettle();
    expect(bloc.state.linhas.length, 2);

    bloc.add(PagamentosRealizadosValorAlterado(
      linhaId: bloc.state.linhas.first.id,
      valorTexto: '40,00',
    ));
    await t.pumpAndSettle();
    await t.tap(find.textContaining('GRADE'));
    await t.pumpAndSettle();

    expect(bloc.state.linhas.last.valorTexto, '60,00');
    expect(bloc.state.valorRestante, 0);
  });

  testWidgets('desconto geral abre em % e a ordem é %, R\$, Total', (t) async {
    final c = _ctx(PagamentoOrigem.romaneio);
    final bloc = _bloc(c);
    await _pump(t, bloc, c);

    await t.sendKeyEvent(LogicalKeyboardKey.f4);
    await t.pumpAndSettle();

    expect(find.text('Percentual (0 a 100)'), findsOneWidget);
    double x(String r) => t.getTopLeft(find.text(r)).dx;
    expect(x('%'), lessThan(x('R\$')));
    expect(x('R\$'), lessThan(x('Total')));
  });

  testWidgets('desconto do item abre em % mesmo com o bloc semeando R\$',
      (t) async {
    final c = _ctx(PagamentoOrigem.romaneio);
    final bloc = _bloc(c);
    await _pump(t, bloc, c);

    await t.tap(find.byTooltip('Desconto do item'));
    await t.pumpAndSettle();

    expect(find.text('Percentual (0 a 100)'), findsOneWidget);
    expect(t.getTopLeft(find.text('%')).dx,
        lessThan(t.getTopLeft(find.text('R\$')).dx));
  });

  testWidgets('letras chegam à grade, F2 alterna valor/formas, F4 abre desconto',
      (t) async {
    final c = _ctx(PagamentoOrigem.romaneio);
    final bloc = _bloc(c);
    await _pump(t, bloc, c, grade: _gradeComTeclas);

    await t.sendKeyEvent(LogicalKeyboardKey.keyD);
    await t.pumpAndSettle();
    expect(bloc.state.linhas.single.formaDePagamento?.id, 1);

    // Depois de escolher, o foco segue na grade: a letra vale de novo.
    await t.sendKeyEvent(LogicalKeyboardKey.f2);
    await t.pumpAndSettle();
    expect(find.byType(EditableText), findsWidgets);
    await t.sendKeyEvent(LogicalKeyboardKey.f2);
    await t.pumpAndSettle();

    await t.sendKeyEvent(LogicalKeyboardKey.f4);
    await t.pumpAndSettle();
    expect(find.text('Percentual (0 a 100)'), findsOneWidget);
  });

  testWidgets('F4 leva o foco ao campo do desconto e aplicar devolve à grade',
      (t) async {
    final c = _ctx(PagamentoOrigem.romaneio);
    final bloc = _bloc(c);
    await _pump(t, bloc, c, grade: _gradeComTeclas);

    await t.sendKeyEvent(LogicalKeyboardKey.f4);
    await t.pumpAndSettle();
    final foco = FocusManager.instance.primaryFocus!;
    expect(foco.context!.findAncestorWidgetOfExactType<EditableText>(),
        isNotNull);

    await t.enterText(
        find.descendant(
            of: find.byKey(const ValueKey('painel-desconto-geral')),
            matching: find.byType(TextField)),
        '10');
    await t.testTextInput.receiveAction(TextInputAction.done);
    await t.pumpAndSettle();
    expect(find.text('Percentual (0 a 100)'), findsNothing);

    await t.sendKeyEvent(LogicalKeyboardKey.keyD);
    await t.pumpAndSettle();
    expect(bloc.state.linhas.single.formaDePagamento?.id, 1);
  });

  testWidgets('desconto escolhido por clique (tipo + Aplicar): letras voltam',
      (t) async {
    final c = _ctx(PagamentoOrigem.romaneio);
    final bloc = _bloc(c);
    await _pump(t, bloc, c, grade: _gradeComTeclas);

    await t.sendKeyEvent(LogicalKeyboardKey.f4);
    await t.pumpAndSettle();
    await t.tap(find.text('R\$').first);
    await t.pumpAndSettle();
    await t.enterText(
        find.descendant(
            of: find.byKey(const ValueKey('painel-desconto-geral')),
            matching: find.byType(TextField)),
        '5');
    final painel = find.byKey(const ValueKey('painel-desconto-geral'));
    await t.tap(find.descendant(of: painel, matching: find.text('Aplicar')));
    await t.pumpAndSettle();
    expect(painel, findsNothing);

    await t.sendKeyEvent(LogicalKeyboardKey.keyD);
    await t.pumpAndSettle();
    expect(bloc.state.linhas.single.formaDePagamento?.id, 1);
  });

  testWidgets('Esc volta e o estado (linhas e desconto) sobrevive no bloc',
      (t) async {
    final c = _ctx(PagamentoOrigem.venda);
    final bloc = _bloc(c);
    var voltou = 0;
    await _pump(t, bloc, c, onVoltar: () => voltou++);

    await t.tap(find.textContaining('GRADE'));
    await t.pumpAndSettle();
    bloc.add(const PagamentosRealizadosDescontoAlterado(
      tipo: DescontoTipo.valorBruto,
      valorTexto: '10',
    ));
    await t.pumpAndSettle();
    expect(find.text('−R\$ 10,00'), findsOneWidget);

    await t.sendKeyEvent(LogicalKeyboardKey.escape);
    expect(voltou, 1);

    // Origem desmonta a etapa e depois monta de novo com o mesmo bloc.
    await t.pumpWidget(const SizedBox());
    await _pump(t, bloc, c);

    expect(find.text('−R\$ 10,00'), findsOneWidget);
    expect(bloc.state.linhas.single.valorTexto, '100,00');
    expect(bloc.state.valorDescontoAplicado, 10);
  });

  test('resultado não carrega recurso desligado', () {
    const state = PagamentosRealizadosState(
      enviarNotaPorEmail: true,
      emailNota: 'a@b.com',
      pontuarFidelidade: true,
      clienteElegivelFidelidade: true,
      incluirCpfNaNota: true,
      cpfNaNota: '123',
    );
    final r = PagamentoEtapa.resultado(state, PagamentoRecursos.romaneio);
    expect(r['enviarNotaPorEmail'], false);
    expect(r['emailNota'], '');
    expect(r['pontuarFidelidade'], false);
    expect(r['incluirCpfNaNota'], true);

    final v = PagamentoEtapa.resultado(state, PagamentoRecursos.venda);
    expect(v['pontuarFidelidade'], true);
    expect(v['enviarNotaPorEmail'], true);
  });

  testWidgets('mobile: itens e nota viram bottom sheets', (t) async {
    final c = _ctx(PagamentoOrigem.venda);
    await _pump(t, _bloc(c), c, largura: 420);

    expect(find.text(cpf), findsNothing);
    expect(find.text('Sutiã Renda'), findsNothing);

    await t.tap(find.text('Nota'));
    await t.pumpAndSettle();
    expect(find.text(cpf), findsOneWidget);
  });

  testWidgets(
      'falha total: reabre com a mensagem junto do botão, linhas preservadas, F9 tenta de novo',
      (t) async {
    final c = _ctx(PagamentoOrigem.venda);
    final bloc = _bloc(c);
    var confirmacoes = 0;
    await _pump(t, bloc, c, onConfirmado: (_) => confirmacoes++);

    await t.tap(find.textContaining('GRADE'));
    await t.pumpAndSettle();
    await t.sendKeyEvent(LogicalKeyboardKey.f9);
    await t.pumpAndSettle();
    expect(confirmacoes, 1);
    expect(bloc.state.step, PagamentosRealizadosStep.concluido);

    bloc.add(const PagamentosRealizadosReaberto(erro: 'Saldo insuficiente'));
    await t.pumpAndSettle();

    expect(find.text('Saldo insuficiente'), findsOneWidget);
    expect(find.text('Confirmar e emitir · F9'), findsOneWidget);
    expect(bloc.state.linhas.single.valorTexto, '100,00');

    await t.sendKeyEvent(LogicalKeyboardKey.f9);
    await t.pumpAndSettle();
    expect(confirmacoes, 2);
  });

  testWidgets('pontos: botão só na venda', (t) async {
    for (final o in PagamentoOrigem.values) {
      final c = _ctx(o);
      await _pump(t, _bloc(c), c);
      expect(find.text('Pontos (saldo 100)'),
          o == PagamentoOrigem.venda ? findsOneWidget : findsNothing,
          reason: o.name);
    }
  });

  testWidgets('saldo de crédito de devolução do cliente aparece no resumo',
      (t) async {
    final c = _ctx(PagamentoOrigem.venda);
    await _pump(t, _bloc(c), c);

    expect(find.text('Crédito de devolução'), findsOneWidget);
    expect(find.text(pagamentoMoeda(80)), findsOneWidget);
  });

  testWidgets('pontos: saldo zero aparece, sem ação de resgatar', (t) async {
    _saldoDePontos = 0;
    addTearDown(() => _saldoDePontos = 100);
    final c = _ctx(PagamentoOrigem.venda);
    await _pump(t, _bloc(c), c);

    expect(find.text('Pontos (saldo 0)'), findsOneWidget);
    expect(find.text('resgatar'), findsNothing);
  });

  testWidgets('pontos: faixa reduz o A PAGAR e sai no Map', (t) async {
    final c = _ctx(PagamentoOrigem.venda);
    final bloc = _bloc(c);
    Map<String, dynamic>? resultado;
    await _pump(t, bloc, c, onConfirmado: (r) => resultado = r);

    await t.tap(find.text('resgatar'));
    await t.pumpAndSettle();
    await t.tap(find.textContaining('50 pts'));
    await t.pumpAndSettle();

    expect(bloc.state.valorTotalAPagar, 95);
    expect(find.text('−R\$ 5,00'), findsOneWidget);

    await t.tap(find.textContaining('GRADE'));
    await t.pumpAndSettle();
    await t.sendKeyEvent(LogicalKeyboardKey.f9);
    await t.pumpAndSettle();

    expect(resultado!['resgatePontos'], {'faixaId': 1});
    expect(resultado!['valorTotalRecebido'], 95);
  });

  testWidgets('pontos livres: valor digitado vai no Map', (t) async {
    final c = _ctx(PagamentoOrigem.venda);
    final bloc = _bloc(c);
    await _pump(t, bloc, c);

    await t.tap(find.text('resgatar'));
    await t.pumpAndSettle();
    await t.enterText(
      find.byWidgetPredicate((w) =>
          w is TextField &&
          (w.decoration?.hintText?.startsWith('Usar pontos') ?? false)),
      '20',
    );
    await t.pumpAndSettle();
    await t.tap(find.widgetWithText(FilledButton, 'Aplicar'));
    await t.pumpAndSettle();

    expect(bloc.state.valorTotalAPagar, 98);
    expect(PagamentoEtapa.resultado(bloc.state, c.recursos)['resgatePontos'],
        {'pontos': 20});
  });
}
