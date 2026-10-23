import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/presentation/pagamento/pagamento_etapa.dart';
import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/leitor.dart';
import 'package:core/permissoes/i_permissoes_controller.dart';
import 'package:core/seletores.dart';
import 'package:core/sessao.dart';
import 'package:core/tema.dart';
import 'package:financeiro/use_cases.dart' show RecuperarFormasDePagamento;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/uses_cases.dart';
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
  int? get empresaIdDaSessao => 1;

  @override
  dynamic noSuchMethod(Invocation i) => null;
}

/// Registra a ordem das chamadas que a etapa dispara no backend.
class _Repo implements IPedidosRepository {
  final log = <String>[];
  final List<PedidoPagamento> pagamentos;
  String? falharEm;
  Completer<void>? segurarPagamento;

  _Repo({this.pagamentos = const []});

  Pedido get _pedido => Pedido.create(
        id: 7,
        pessoaId: 7,
        pessoaNome: 'Maria',
        situacao: 'em_andamento',
        tipo: 'venda',
        modalidadeEntrega: 'retirada',
        desconto: 0,
        valorTaxaEntrega: 5,
      );

  void _chamou(String chave) {
    log.add(chave);
    if (falharEm != null && chave.startsWith(falharEm!)) {
      throw Exception('x');
    }
  }

  @override
  Future<Pedido> recuperarPedido(int id) async => _pedido;

  @override
  Future<List<PedidoItem>> listarItens(int id) async => [
        // Produto sem promoção: é onde o desconto geral incide.
        PedidoItem.create(
          pedidoId: 7,
          produtoId: 2,
          sequencia: 2,
          solicitado: 1,
          atendido: 1,
          valorUnitario: 20,
          valorUnitDesconto: 0,
          referenciaNome: 'Calcinha',
          corNome: 'Bege',
          tamanhoNome: 'M',
        ),
        PedidoItem.create(
          pedidoId: 7,
          produtoId: 1,
          sequencia: 1,
          solicitado: 2,
          atendido: 2,
          valorUnitario: 50,
          valorUnitDesconto: 0,
          referenciaNome: 'Sutiã Renda',
          corNome: 'Preto',
          tamanhoNome: '44',
        ),
      ];

  @override
  Future<List<PedidoPagamento>> listarPagamentos(int id) async => pagamentos;

  @override
  Future<List<PedidoEvento>> listarEventos(int id) async => const [];

  @override
  Future<Pedido> aplicarDesconto(int id, {required double desconto}) async {
    _chamou('desconto:$desconto');
    return _pedido;
  }

  @override
  Future<Pedido> aplicarDescontosPromocionais(
    int id, {
    required List<Map<String, dynamic>> descontosPromocao,
    Map<String, dynamic>? cupom,
  }) async {
    _chamou('promocoes:${descontosPromocao.map((d) => '${d['produtoId']}>${d['promocaoId']}').join(',')}'
        '${cupom == null ? '' : '+cupom:${cupom['codigo']}:${cupom['produtoIds']}'}');
    return _pedido;
  }

  @override
  Future<Pedido> salvarOpcoesFiscais(
    int id, {
    bool? incluirCpfNaNota,
    String? cpfNaNota,
    bool? enviarNotaPorEmail,
    String? emailNota,
  }) async {
    _chamou('fiscais:cpf=$incluirCpfNaNota/$cpfNaNota email=$enviarNotaPorEmail/$emailNota');
    return _pedido;
  }

  @override
  Future<PedidoPagamento> adicionarPagamento(
    int id, {
    required int formaDePagamentoId,
    required double valorEsperado,
    double? taxaAplicada,
  }) async {
    _chamou('pagamento:$formaDePagamentoId:$valorEsperado');
    await segurarPagamento?.future;
    return PedidoPagamento.create(id: 9, formaDePagamentoId: formaDePagamentoId);
  }

  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _Formas implements RecuperarFormasDePagamento {
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _Enderecos implements RecuperarEnderecosDaPessoa {
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _Pessoa implements RecuperarPessoa {
  @override
  Future<Pessoa?> call({required int idPessoa}) async => Pessoa.create(
        id: idPessoa,
        nome: 'Maria',
        tipoPessoa: TipoPessoa.fisica,
        documento: '12345678909',
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
          ItemElegibilidade(
            referenciaId: 900,
            opcoesElegiveis: [
              const OpcaoElegivel(
                tipo: 'promocao',
                id: 4,
                nome: 'Promo 10%',
                valorDesconto: 5,
                valorFinalUnitario: 45,
                overridesPorFormaPagamento: [
                  OverridePorFormaPagamento(
                    formaDePagamentoId: 2,
                    valorPercentual: 20,
                  ),
                ],
              ),
              if (codigosCupom.isNotEmpty)
                const OpcaoElegivel(
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
  _LeitorData(this.idReferencia);

  @override
  final int idReferencia;
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
      _LeitorData(produtoId == 1 ? 900 : 901);
}

Widget _grade(FormaPagamentoGradeData d) => TextButton(
      onPressed: () => d.onEscolhida(
        SelectData(id: 1, nome: 'Dinheiro', data: const {'tipo': 'Dinheiro'}),
      ),
      child: Text('GRADE ${d.tipoOperacao}'),
    );

void main() {
  late _Repo repo;

  void registrar(_Repo r) {
    repo = r;
    final sessao = _Sessao();
    sl.registerSingleton<IPermissoesController>(_Permissoes());
    sl.registerSingleton<ILeitorDataDatasource>(_Leitor());
    sl.registerSingleton<RecuperarPessoa>(_Pessoa());
    sl.registerFactory<PedidoBloc>(
      () => PedidoBloc(
        RecuperarPedido(repository: r),
        CriarPedido(repository: r),
        AtualizarPedido(repository: r),
        AplicarDescontoPedido(repository: r),
        ConferirPedido(repository: r),
        MarcarConferido(repository: r),
        FaturarPedido(repository: r),
        CancelarPedido(repository: r),
        AdicionarPagamentoPedido(repository: r),
        RemoverPagamentoPedido(repository: r),
        ListarPagamentosPedido(repository: r),
        ConfirmarPagamentoPedido(repository: r),
        AtualizarValorParaTrocoPagamentoPedido(repository: r),
        ChamarEntregadorPedido(repository: r),
        ConfirmarEntregaPedido(repository: r),
        ConfirmarRetiradaPedido(repository: r),
        ConfirmarRetiradaLotePedido(repository: r),
        CriarTaxaEntregaPedido(repository: r),
        ListarEventosPedido(repository: r),
        ListarItensPedido(repository: r),
        AdicionarItemPedido(repository: r),
        RemoverItemPedido(repository: r),
        ConferirItemPedido(repository: r),
        ConferirItemPedidoPorCodigo(repository: r),
        AssumirPedido(repository: r),
        ReenviarEmailPedido(repository: r),
        LinkCompartilhamentoPedido(repository: r),
        EmbalarPedido(repository: r),
        sessao,
        _Formas(),
        _Enderecos(),
        AplicarDescontosPromocionaisPedido(repository: r),
        SalvarOpcoesFiscaisPedido(repository: r),
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
  }

  setUp(() async => sl.reset());
  tearDown(() async => sl.reset());

  Future<void> abrir(WidgetTester t, _Repo r) async {
    registrar(r);
    t.view.physicalSize = const Size(1400, 3000);
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
        home: PedidoPage(
          idPedido: 7,
          formaPagamentoGrade: _grade,
        ),
      ),
    );
    await t.pumpAndSettle();
    await t.tap(find.text('Adicionar').last);
    await t.pumpAndSettle();
  }

  PagamentosRealizadosBloc etapa(WidgetTester t) => t
      .element(find.byType(PagamentoEtapa))
      .read<PagamentosRealizadosBloc>();

  testWidgets(
      'sem diálogo "Como será o pagamento?"; confirma na ordem desconto, promoções/cupom, nota, pagamentos',
      (t) async {
    await abrir(t, _Repo());

    expect(find.byType(SimpleDialog), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('NO ATO DA ENTREGA'), findsOneWidget);
    expect(find.text('Lançar pagamento · F9'), findsOneWidget);
    expect(find.text('na entrega'), findsNothing); // taxa existe: só leitura
    // Pedido grava o desconto padrão da promoção; a forma pode mudá-lo no faturamento.
    expect(find.text('Promoções (estimado)'), findsOneWidget);

    final bloc = etapa(t);
    bloc.add(const PagamentosRealizadosCupomInformado(codigo: 'DEZ'));
    bloc.add(const PagamentosRealizadosDescontoAlterado(
      tipo: DescontoTipo.valorBruto,
      valorTexto: '3',
    ));
    await t.pumpAndSettle();

    await t.tap(find.textContaining('GRADE'));
    await t.pumpAndSettle();
    await t.sendKeyEvent(LogicalKeyboardKey.f9);
    await t.pumpAndSettle();

    expect(repo.log.length, 4, reason: '${repo.log}');
    expect(repo.log[0], startsWith('desconto:3'));
    expect(repo.log[1], 'promocoes:1>4+cupom:DEZ:[1]');
    expect(
      repo.log[2],
      'fiscais:cpf=false/null email=true/maria@x.com',
    );
    expect(repo.log[3], startsWith('pagamento:1:'));
    // Etapa fechou ao lançar.
    expect(find.byType(PagamentoEtapa), findsNothing);
  });

  testWidgets('Online: mostra loading "Criando a forma de pagamento" enquanto gera',
      (t) async {
    final r = _Repo()..segurarPagamento = Completer<void>();
    await abrir(t, r);

    await t.tap(find.text('ONLINE · LINK / QR'));
    await t.pumpAndSettle();
    await t.tap(find.textContaining('GRADE'));
    await t.pumpAndSettle();
    expect(find.textContaining('Criando a forma de pagamento'), findsNothing);

    await t.sendKeyEvent(LogicalKeyboardKey.f9);
    await t.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('Criando a forma de pagamento: Dinheiro'),
        findsOneWidget);

    r.segurarPagamento!.complete();
    await t.pumpAndSettle();
    expect(find.textContaining('Criando a forma de pagamento'), findsNothing);
  });

  testWidgets('Online: primário vira "Gerar cobrança online", sem AlertDialog',
      (t) async {
    await abrir(t, _Repo());

    await t.tap(find.text('ONLINE · LINK / QR'));
    await t.pumpAndSettle();
    expect(find.text('Gerar cobrança online · F9'), findsOneWidget);
    expect(find.textContaining('GRADE online'), findsOneWidget);

    await t.tap(find.textContaining('GRADE'));
    await t.pumpAndSettle();
    await t.sendKeyEvent(LogicalKeyboardKey.f9);
    await t.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(repo.log.last, startsWith('pagamento:1:'));
  });

  testWidgets(
      'com pagamento lançado: descontos travados, abatimento com status, sem desconto/promoção no confirmar',
      (t) async {
    await abrir(
      t,
      _Repo(pagamentos: [
        PedidoPagamento.create(
          id: 1,
          pedidoId: 7,
          formaDePagamentoId: 3,
          tipo: 'manual',
          valorEsperado: 30,
        ),
      ]),
    );

    expect(
      find.textContaining('Remova os pagamentos lançados'),
      findsOneWidget,
    );
    expect(find.text('Pagamento · aguardando'), findsOneWidget);
    expect(find.text('Código do cupom'), findsNothing);
    final bloc = etapa(t);
    // 120 itens − 30 lançado + 5 de entrega
    expect(bloc.state.valorTotalAPagar, 95);
    expect(bloc.state.opcoesElegiveisPorItem, isEmpty);

    await t.tap(find.textContaining('GRADE'));
    await t.pumpAndSettle();
    await t.sendKeyEvent(LogicalKeyboardKey.f9);
    await t.pumpAndSettle();

    expect(repo.log.where((l) => l.startsWith('desconto')), isEmpty);
    expect(repo.log.where((l) => l.startsWith('promocoes')), isEmpty);
    expect(repo.log.first, startsWith('fiscais:'));
    expect(repo.log.last, 'pagamento:1:95.0');
  });

  testWidgets('falha ao gravar promoções: mensagem junto do botão, nada lançado',
      (t) async {
    await abrir(t, _Repo()..falharEm = 'promocoes');

    await t.tap(find.textContaining('GRADE'));
    await t.pumpAndSettle();
    await t.sendKeyEvent(LogicalKeyboardKey.f9);
    await t.pumpAndSettle();

    expect(find.text('Falha ao aplicar promoções no pedido.'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('Lançar pagamento · F9'), findsOneWidget);
    expect(repo.log.where((l) => l.startsWith('pagamento')), isEmpty);
  });

  testWidgets('Esc volta ao pedido e reabrir preserva as linhas', (t) async {
    await abrir(t, _Repo());
    await t.tap(find.textContaining('GRADE'));
    await t.pumpAndSettle();

    await t.sendKeyEvent(LogicalKeyboardKey.escape);
    await t.pumpAndSettle();
    expect(find.byType(PagamentoEtapa), findsNothing);

    await t.tap(find.text('Adicionar').last);
    await t.pumpAndSettle();
    expect(etapa(t).state.linhas.single.valorTexto, isNotEmpty);
  });
}
