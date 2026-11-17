import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/presentation/pagamento/pagamento_etapa.dart';
import 'package:comercial/presentation/pages/pedido/etapa_retirada.dart';
import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/leitor.dart';
import 'package:core/permissoes/i_permissoes_controller.dart';
import 'package:core/remote_data_sourcers.dart' show HttpException;
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
  int? get caixaIdDaSessao => 1;

  @override
  bool get dadosSincronizados => true;

  @override
  Stream<bool> get sincronizandoDados => const Stream<bool>.empty();

  @override
  dynamic noSuchMethod(Invocation i) => null;
}

/// Registra a ordem das chamadas que a etapa dispara no backend.
class _Repo implements IPedidosRepository {
  final log = <String>[];
  List<PedidoPagamento> pagamentos;
  String? falharEm;
  Completer<void>? segurarPagamento;

  Pedido? pedidoBase;
  List<PedidoItem>? itensBase;
  List<Pedido> pendentes;
  String? codigoCerto;

  _Repo({
    List<PedidoPagamento> pagamentos = const [],
    this.pedidoBase,
    this.itensBase,
    this.pendentes = const [],
    this.codigoCerto,
  }) : pagamentos = List.of(pagamentos);

  Pedido get _pedido =>
      pedidoBase ??
      Pedido.create(
        id: 7,
        pessoaId: 7,
        pessoaNome: 'Maria',
        situacao: 'em_andamento',
        tipo: 'venda',
        modalidadeEntrega: 'retirada',
        desconto: 0,
        valorTaxaEntrega: 5,
        valorTotal: 125,
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
  Future<List<PedidoItem>> listarItens(int id) async => itensBase ?? [
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

  void _somar(int produtoId, double q) {
    final i = itensBase!.indexWhere((x) => x.produtoId == produtoId);
    final o = itensBase![i];
    itensBase![i] = PedidoItem.create(
      pedidoId: o.pedidoId,
      produtoId: o.produtoId,
      sequencia: o.sequencia,
      solicitado: o.solicitado,
      atendido: (o.atendido ?? 0) + q,
      valorUnitario: o.valorUnitario,
      valorUnitDesconto: o.valorUnitDesconto,
      referenciaNome: o.referenciaNome,
    );
  }

  @override
  Future<void> conferirItemPorCodigo(int id,
      {required String codigoBarras, required double quantidade}) async {
    _chamou('lerCodigo:$codigoBarras');
    final produtoId = {'7891': 1, '7892': 2}[codigoBarras];
    if (produtoId == null) {
      throw HttpException('x', statusCode: 400, apiMessage: 'Produto não pertence ao pedido.');
    }
    _somar(produtoId, quantidade);
  }

  @override
  Future<void> conferirItem(int id,
      {required int produtoId, required int sequencia, required double quantidade}) async {
    _chamou('contar:$produtoId');
    _somar(produtoId, quantidade);
  }

  @override
  Future<void> conferirPedido(int id, {bool processarComDivergencia = false}) async {
    _chamou('conferir');
    pedidoBase = _copiaConferido(_pedido);
  }

  @override
  Future<void> marcarConferido(int id) async {
    _chamou('marcarConferido');
    pedidoBase = _copiaConferido(_pedido);
  }

  @override
  Future<void> embalarPedido(int id) async {
    _chamou('embalar');
    pedidoBase = _copia(_pedido, ent: 'embalado');
  }

  @override
  Future<void> chamarEntregador(int id) async {
    _chamou('chamar');
    pedidoBase = _copia(_pedido, ent: 'chamado');
  }

  @override
  Future<void> confirmarEntrega(int id) async {
    _chamou('entrega');
    pedidoBase = _copia(_pedido, ent: 'entregue');
  }

  @override
  Future<void> faturarPedido(int id, {required int caixaId}) async {
    _chamou('faturar');
    pedidoBase = _copia(_pedido, sit: 'encerrado');
  }

  @override
  Future<PedidoPagamento> confirmarPagamento(
    int id,
    int pagamentoId, {
    required double valorConfirmado,
  }) async {
    _chamou('confirmar:$pagamentoId:$valorConfirmado');
    final i = pagamentos.indexWhere((p) => p.id == pagamentoId);
    final o = pagamentos[i];
    pagamentos[i] = PedidoPagamento.create(
      id: o.id,
      tipo: o.tipo,
      formaDePagamentoId: o.formaDePagamentoId,
      valorEsperado: o.valorEsperado,
      valorParaTroco: o.valorParaTroco,
      valorConfirmado: valorConfirmado,
      confirmadoEm: DateTime(2026),
    );
    if (pagamentos.every((p) => p.confirmadoEm != null)) {
      pedidoBase = _copia(_pedido, pag: 'pago');
    }
    return pagamentos[i];
  }

  @override
  Future<void> removerPagamento(int id, int pagamentoId) async {
    _chamou('remover:$pagamentoId');
    pagamentos.removeWhere((p) => p.id == pagamentoId);
  }

  @override
  Future<Pedido> atualizarPedido(Pedido pedido) async {
    _chamou('atualizar:naEntrega=${pedido.pagamentoNaEntrega}');
    pedidoBase = _copia(_pedido, naEntrega: pedido.pagamentoNaEntrega);
    return _pedido;
  }

  @override
  Future<List<Pedido>> listarRetiradaPendentes(int id) async => pendentes;

  @override
  Future<List<Pedido>> confirmarRetiradaLote(List<int> ids) async {
    _chamou('lote:${ids.join(',')}');
    return [];
  }

  @override
  Future<(Pedido, List<Pedido>)> confirmarRetirada(int id, String codigo) async {
    _chamou('retirada:$codigo');
    if (codigoCerto != null && codigo != codigoCerto) {
      throw HttpException('x', statusCode: 400, apiMessage: 'Código de retirada inválido.');
    }
    pedidoBase = _copia(_pedido, retirado: DateTime(2026));
    return (_pedido, <Pedido>[]);
  }

  @override
  dynamic noSuchMethod(Invocation i) => null;
}

Pedido _copiaConferido(Pedido p) => Pedido.create(
      id: p.id,
      pessoaNome: p.pessoaNome,
      situacao: p.situacao,
      tipo: p.tipo,
      origem: p.origem,
      modalidadeEntrega: p.modalidadeEntrega,
      situacaoEntrega: p.situacaoEntrega,
      situacaoPagamento: p.situacaoPagamento,
      funcionarioId: p.funcionarioId,
      valorTotal: p.valorTotal,
      desconto: p.desconto,
      conferidoEm: DateTime(2026),
    );

Pedido _copia(Pedido p,
        {String? sit, String? ent, String? pag, bool? naEntrega, DateTime? retirado}) =>
    Pedido.create(
      id: p.id,
      pessoaId: p.pessoaId,
      pessoaNome: p.pessoaNome,
      situacao: sit ?? p.situacao,
      tipo: p.tipo,
      origem: p.origem,
      modalidadeEntrega: p.modalidadeEntrega,
      situacaoEntrega: ent ?? p.situacaoEntrega,
      situacaoPagamento: pag ?? p.situacaoPagamento,
      funcionarioId: p.funcionarioId,
      valorTotal: p.valorTotal,
      desconto: p.desconto,
      conferidoEm: p.conferidoEm,
      retiradoEm: retirado ?? p.retiradoEm,
      exigeCodigoRetirada: p.exigeCodigoRetirada,
      pagamentoNaEntrega: naEntrega ?? p.pagamentoNaEntrega,
    );

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
  _LeitorData(this.idReferencia, [this._cod = '']);

  final String _cod;
  @override
  final int idReferencia;
  @override
  String get codigoDeBarras => _cod;
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

class _Busca implements ILeitorBuscaDataDatasource {
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _Leitor implements ILeitorDataDatasource {
  @override
  Future<LeitorData?> getData(String codigo, {int? tabelaDePrecoId}) async =>
      codigo.startsWith('789') ? _LeitorData(900, codigo) : null;

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
    sl.registerSingleton<ILeitorBuscaDataDatasource>(_Busca());
    sl.registerSingleton<IAcessoGlobalSessao>(sessao);
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
        ListarRetiradaPendentesPedido(repository: r),
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
  }

  setUp(() async => sl.reset());
  tearDown(() async => sl.reset());

  Future<void> abrir(WidgetTester t, _Repo r, {bool pagar = true, Size? tamanho}) async {
    registrar(r);
    t.view.physicalSize = tamanho ?? const Size(1400, 3000);
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
        routes: {'/pedido_entrada': (_) => const Text('TELA ENTRADA')},
        home: PedidoPage(
          idPedido: 7,
          formaPagamentoGrade: _grade,
        ),
      ),
    );
    await t.pumpAndSettle();
    if (!pagar) return;
    await t.tap(find.byKey(const Key('pedido_acao_principal')));
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

    await t.tap(find.byKey(const Key('pedido_acao_principal')));
    await t.pumpAndSettle();
    expect(etapa(t).state.linhas.single.valorTexto, isNotEmpty);
  });

  // ---- Shell FP1 ----
  Pedido ped({
    String tipo = 'venda',
    String mod = 'retirada',
    String sit = 'em_andamento',
    String? ent,
    String? origem,
    int? func = 1,
    bool exigeCodigo = true,
    bool naEntrega = false,
    String? pag,
  }) =>
      Pedido.create(
        id: 7,
        situacaoPagamento: pag,
        pessoaId: 7,
        pessoaNome: 'Maria',
        situacao: sit,
        tipo: tipo,
        origem: origem,
        modalidadeEntrega: mod,
        situacaoEntrega: ent,
        funcionarioId: func,
        valorTotal: 100,
        desconto: 0,
        exigeCodigoRetirada: exigeCodigo,
        pagamentoNaEntrega: naEntrega,
      );

  final pagOk = [
    PedidoPagamento.create(
        id: 1, valorEsperado: 100, valorConfirmado: 100, confirmadoEm: DateTime(2026)),
  ];

  testWidgets('etapa Itens: só F9 "Ir para pagamento" + Mais ações; sem botões soltos',
      (t) async {
    await abrir(t, _Repo(pedidoBase: ped()), pagar: false);
    expect(find.byKey(const Key('pedido_acao_principal')), findsOneWidget);
    expect(find.byKey(const Key('pedido_mais_acoes')), findsOneWidget);
    expect(find.text('Ir para pagamento'), findsOneWidget);
    for (final x in ['Faturar', 'Conferir', 'Cancelar', 'Marcar embalado', 'Converter em entrega']) {
      expect(find.text(x), findsNothing, reason: x);
    }
    expect(find.textContaining('Situação atual'), findsNothing);
    expect(find.text('Pedido #7'), findsOneWidget);
  });

  testWidgets('F9 dispara a ação da etapa (Itens -> abre pagamento)', (t) async {
    await abrir(t, _Repo(pedidoBase: ped()), pagar: false);
    await t.sendKeyEvent(LogicalKeyboardKey.f9);
    await t.pumpAndSettle();
    expect(find.byType(PagamentoEtapa), findsOneWidget);
  });

  testWidgets('Embalar: F9 chama marcarEmbalado', (t) async {
    final r = _Repo(
      pedidoBase: ped(mod: 'entrega', sit: 'encerrado', ent: 'aguardando_chamada'),
      pagamentos: pagOk,
    );
    await abrir(t, r, pagar: false);
    expect(find.text('Marcar embalado'), findsOneWidget);
    expect(find.text('Chamar entregador'), findsNothing);
    await t.sendKeyEvent(LogicalKeyboardKey.f9);
    await t.pumpAndSettle();
    expect(r.log, contains('embalar'));
  });

  testWidgets('Embalado -> só "Chamar entregador" e dispara', (t) async {
    final r = _Repo(
      pedidoBase: ped(mod: 'entrega', sit: 'encerrado', ent: 'embalado'),
      pagamentos: pagOk,
    );
    await abrir(t, r, pagar: false);
    expect(find.text('Marcar embalado'), findsNothing);
    await t.tap(find.text('Chamar entregador'));
    await t.pumpAndSettle();
    expect(r.log, contains('chamar'));
  });

  testWidgets('Retirada sem código: F9 confirma direto, sem diálogo', (t) async {
    final r = _Repo(
      pedidoBase: ped(sit: 'encerrado', ent: 'nao_aplicavel', exigeCodigo: false),
      pagamentos: pagOk,
    );
    await abrir(t, r, pagar: false);
    expect(find.text('Confirmar retirada'), findsOneWidget);
    await t.sendKeyEvent(LogicalKeyboardKey.f9);
    await t.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(r.log, contains('retirada:'));
  });

  testWidgets('E-commerce sem vendedor: só "Assumir pedido"', (t) async {
    await abrir(t, _Repo(pedidoBase: ped(origem: 'ecommerce', func: null)), pagar: false);
    expect(find.text('Assumir pedido'), findsOneWidget);
    expect(find.text('Concluir conferência'), findsNothing);
  });

  testWidgets('F10 abre Mais ações com letras e Cancelar no fim; Esc fecha', (t) async {
    await abrir(t, _Repo(pedidoBase: ped()), pagar: false);
    await t.sendKeyEvent(LogicalKeyboardKey.f10);
    await t.pumpAndSettle();
    expect(find.text('Imprimir nota de conferência'), findsOneWidget);
    expect(find.text('Copiar link do pedido'), findsOneWidget);
    expect(find.text('Observação'), findsWidgets);
    expect(find.text('Histórico'), findsWidgets);
    expect(find.text('Cancelar pedido'), findsOneWidget);
    expect(find.text('Imprimir nota de entrega'), findsNothing); // retirada
    await t.sendKeyEvent(LogicalKeyboardKey.escape);
    await t.pumpAndSettle();
    expect(find.text('Cancelar pedido'), findsNothing);
  });

  testWidgets('Mais ações: letra O abre a observação', (t) async {
    await abrir(t, _Repo(pedidoBase: ped()), pagar: false);
    await t.sendKeyEvent(LogicalKeyboardKey.f10);
    await t.pumpAndSettle();
    await t.sendKeyEvent(LogicalKeyboardKey.keyO);
    await t.pumpAndSettle();
    expect(find.text('Observação do pedido'), findsOneWidget);
  });

  testWidgets('Converter em entrega só aparece p/ retirada encerrada', (t) async {
    await abrir(
      t,
      _Repo(pedidoBase: ped(sit: 'encerrado', ent: 'nao_aplicavel'), pagamentos: pagOk),
      pagar: false,
    );
    await t.sendKeyEvent(LogicalKeyboardKey.f10);
    await t.pumpAndSettle();
    expect(find.text('Converter em entrega'), findsOneWidget);
  });

  testWidgets('Pedido de entrada redireciona para /pedido_entrada', (t) async {
    await abrir(t, _Repo(pedidoBase: ped(tipo: 'compra')), pagar: false);
    expect(find.text('TELA ENTRADA'), findsOneWidget);
  });

  testWidgets('Mobile: trilha, F9 sem tecla e lateral recolhível', (t) async {
    await abrir(t, _Repo(pedidoBase: ped()), pagar: false, tamanho: const Size(400, 900));
    expect(find.byKey(const Key('trilha_etapa_itens')), findsOneWidget);
    expect(find.text('Ir para pagamento'), findsOneWidget);
    expect(find.text('· F9'), findsNothing);
    expect(find.text('Detalhes do pedido', skipOffstage: false), findsOneWidget);
  });

  // ---- FP2 ----
  PedidoPagamento pg(int id,
          {bool ok = false, bool online = false, double v = 120, double? troco, bool link = false}) =>
      PedidoPagamento.create(
        id: id,
        tipo: online ? 'controlado' : 'manual',
        formaDePagamentoId: 1,
        valorEsperado: v,
        valorParaTroco: troco,
        valorConfirmado: ok ? v : null,
        confirmadoEm: ok ? DateTime(2026) : null,
        cobranca: link
            ? PedidoPagamentoCobranca.create(urlDePagamento: 'https://pague.me/abc')
            : null,
      );

  FilledButton f9(WidgetTester t) =>
      t.widget<FilledButton>(find.byKey(const Key('pedido_acao_principal')));

  Future<void> digitar(WidgetTester t, String codigo) async {
    for (var i = 0; i < codigo.length; i++) {
      await t.enterText(find.byKey(Key('retirada_digito_$i')), codigo[i]);
      await t.pump();
    }
    await t.pumpAndSettle();
  }

  _Repo retiradaRepo({bool exige = true, List<Pedido> pendentes = const []}) => _Repo(
        pedidoBase: ped(sit: 'encerrado', ent: 'embalado', pag: 'pago', exigeCodigo: exige),
        pagamentos: [pg(1, ok: true)],
        pendentes: pendentes,
        codigoCerto: exige ? '1234' : null,
      );

  testWidgets('T3 Retirada: 4º dígito confirma; erro limpa as casas e mostra a mensagem',
      (t) async {
    final r = retiradaRepo();
    await abrir(t, r, pagar: false);
    expect(f9(t).onPressed, isNull); // falta o código
    await digitar(t, '9999');
    expect(r.log, contains('retirada:9999'));
    expect(
      find.descendant(
          of: find.byType(EtapaRetirada), matching: find.text('Código de retirada inválido.')),
      findsOneWidget,
    );
    for (var i = 0; i < 4; i++) {
      expect(
        t.widget<TextField>(find.byKey(Key('retirada_digito_$i'))).controller!.text,
        isEmpty,
      );
    }
    await digitar(t, '1234');
    expect(r.log, contains('retirada:1234'));
    expect(r.log.where((l) => l.startsWith('lote')), isEmpty);
    expect(find.text('Pedido concluído.'), findsOneWidget);
  });

  testWidgets('T3 Retirar junto: marcados saem depois da principal, no mesmo gesto', (t) async {
    final r = retiradaRepo(pendentes: [Pedido.create(id: 9, valorTotal: 50)]);
    await abrir(t, r, pagar: false);
    expect(find.text('Pedido #9'), findsOneWidget);
    await t.tap(find.byKey(const Key('retirar_junto_9')));
    await t.pump();
    await digitar(t, '1234');
    expect(r.log.where((l) => l.startsWith('retirada') || l.startsWith('lote')).toList(),
        ['retirada:1234', 'lote:9']);
  });

  testWidgets('Retirada sem código: só F9, retirar junto vai no mesmo F9', (t) async {
    final r = retiradaRepo(exige: false, pendentes: [Pedido.create(id: 9, valorTotal: 50)]);
    await abrir(t, r, pagar: false);
    expect(find.byKey(const Key('retirada_digito_0')), findsNothing);
    await t.tap(find.byKey(const Key('retirar_junto_9')));
    await t.pump();
    await t.sendKeyEvent(LogicalKeyboardKey.f9);
    await t.pumpAndSettle();
    expect(r.log.where((l) => l.startsWith('retirada') || l.startsWith('lote')).toList(),
        ['retirada:', 'lote:9']);
  });

  testWidgets('T4 online: sem botão de confirmar; webhook confirma e avança sozinho', (t) async {
    final r = _Repo(
      pedidoBase: ped(mod: 'entrega', ent: 'aguardando_chamada', pag: 'pendente'),
      pagamentos: [pg(1, online: true, link: true)],
    );
    await abrir(t, r, pagar: false);
    expect(find.text('Aguardando cliente · R\$ 120,00'), findsOneWidget);
    expect(find.textContaining('Confirmar · Enter'), findsNothing);
    expect(find.text('Trocar forma'), findsOneWidget);
    expect(find.textContaining('Copiar link'), findsOneWidget);
    expect(f9(t).onPressed, isNull);

    // webhook: backend confirma; o polling (15 s) traz a mudança.
    r.pagamentos = [pg(1, online: true, ok: true)];
    r.pedidoBase = _copia(r.pedidoBase!, pag: 'pago');
    await t.pump(const Duration(seconds: 15));
    await t.pumpAndSettle();
    expect(find.text('Marcar embalado'), findsOneWidget);
    expect(r.log, isNot(contains('faturar'))); // entrega: backend só fatura depois de entregar
  });

  testWidgets('T4 online: Trocar forma remove o pagamento (com confirmação)', (t) async {
    final r = _Repo(
      pedidoBase: ped(mod: 'entrega', ent: 'aguardando_chamada', pag: 'pendente'),
      pagamentos: [pg(1, online: true, link: true)],
    );
    await abrir(t, r, pagar: false);
    await t.tap(find.byKey(const Key('trocar_forma_1')));
    await t.pumpAndSettle();
    await t.tap(find.text('Remover'));
    await t.pumpAndSettle();
    expect(r.log, contains('remover:1'));
    expect(find.text('Ir para pagamento'), findsOneWidget); // volta ao pagamento
  });

  testWidgets('T3 Confirmação: Enter confirma a linha manual e fatura sozinho', (t) async {
    final r = _Repo(
      pedidoBase: ped(ent: 'aguardando_chamada', pag: 'pendente'),
      pagamentos: [pg(1)],
    );
    await abrir(t, r, pagar: false);
    expect(find.text('CONFIRMADO'), findsOneWidget);
    expect(find.text('Confirmar · Enter'), findsOneWidget);
    await t.sendKeyEvent(LogicalKeyboardKey.enter);
    await t.pumpAndSettle();
    expect(r.log.where((l) => l == 'faturar' || l.startsWith('confirmar')).toList(),
        ['confirmar:1:120.0', 'faturar']);
    expect(find.text('Marcar embalado'), findsOneWidget);
  });

  testWidgets('T5 Acerto: F9 só libera com tudo recebido; confirma, entrega e fatura', (t) async {
    final r = _Repo(
      pedidoBase: ped(mod: 'entrega', naEntrega: true, ent: 'chamado', pag: 'pendente'),
      pagamentos: [pg(1, v: 70), pg(2, v: 50, troco: 100)],
    );
    await abrir(t, r, pagar: false);
    expect(find.text('FALTA'), findsOneWidget);
    expect(f9(t).onPressed, isNull);
    expect(find.text('Faltam R\$ 120,00 a receber.'), findsOneWidget);
    await t.sendKeyEvent(LogicalKeyboardKey.space); // marca a linha selecionada
    await t.pump();
    expect(f9(t).onPressed, isNull);
    await t.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await t.sendKeyEvent(LogicalKeyboardKey.space);
    await t.pump();
    expect(f9(t).onPressed, isNotNull);
    await t.sendKeyEvent(LogicalKeyboardKey.f9);
    await t.pumpAndSettle();
    expect(r.log.where((l) => l != 'x').toList(), [
      'confirmar:1:70.0',
      'confirmar:2:50.0',
      'entrega',
      'faturar',
    ]);
    expect(r.pedidoBase!.situacao, 'encerrado');
    expect(r.pedidoBase!.situacaoEntrega, 'entregue');
    expect(find.text('Pedido concluído.'), findsOneWidget);
  });

  testWidgets('T5 Chamar entregador: mostra o troco a levar e a nota de entrega', (t) async {
    final r = _Repo(
      pedidoBase: ped(mod: 'entrega', naEntrega: true, ent: 'embalado', pag: 'pendente'),
      pagamentos: [pg(1, v: 120, troco: 150)],
    );
    await abrir(t, r, pagar: false);
    expect(find.textContaining('Troco para R\$ 150,00 → leve R\$ 30,00'), findsOneWidget);
    expect(find.text('Imprimir nota de entrega · Ctrl+P'), findsOneWidget);
    expect(find.text('FORMA PREVISTA'), findsOneWidget); // título da trilha T5
  });

  testWidgets('F4 abre o pagamento com o desconto aberto', (t) async {
    await abrir(t, _Repo(pedidoBase: ped()), pagar: false);
    await t.sendKeyEvent(LogicalKeyboardKey.f4);
    await t.pumpAndSettle();
    expect(t.widget<PagamentoEtapa>(find.byType(PagamentoEtapa)).abrirDesconto, isTrue);
  });

  testWidgets('Pagamento: segmentado "No ato da entrega" grava pagamentoNaEntrega no pedido',
      (t) async {
    final r = _Repo(pedidoBase: ped(mod: 'entrega'));
    await abrir(t, r);
    await t.tap(find.textContaining('GRADE'));
    await t.pumpAndSettle();
    await t.sendKeyEvent(LogicalKeyboardKey.f9);
    await t.pumpAndSettle();
    expect(r.log, contains('atualizar:naEntrega=true'));
    expect(r.log.indexOf('atualizar:naEntrega=true'),
        lessThan(r.log.indexWhere((l) => l.startsWith('pagamento'))));
  });

  // ---- FP3 (e-commerce) ----
  PedidoItem it(int prod, double sol, double atend) => PedidoItem.create(
        pedidoId: 7,
        produtoId: prod,
        sequencia: prod,
        solicitado: sol,
        atendido: atend,
        valorUnitario: 10,
        valorUnitDesconto: 0,
        referenciaNome: 'Peça $prod',
      );

  _Repo ecom({String sit = 'em_andamento', List<PedidoItem>? itens}) => _Repo(
        pedidoBase: ped(origem: 'ecommerce', sit: sit, ent: 'nao_aplicavel', pag: 'pago'),
        itensBase: itens ?? [it(1, 2, 0), it(2, 1, 0)],
      );

  Future<void> ler(WidgetTester t, String codigo) async {
    await t.enterText(find.byType(TextField).first, codigo);
    await t.testTextInput.receiveAction(TextInputAction.done);
    await t.pumpAndSettle();
  }

  testWidgets('T1 Conferir: F9 só com todas as peças lidas; em andamento chama conferir',
      (t) async {
    final r = ecom();
    await abrir(t, r, pagar: false);
    expect(find.text('CONFERIR'), findsWidgets);
    expect(find.textContaining('Conferir por leitura'), findsNothing);
    expect(f9(t).onPressed, isNull);
    expect(find.text('Faltam 3 peça(s).'), findsOneWidget);
    await ler(t, '7891');
    await ler(t, '7891');
    expect(f9(t).onPressed, isNull);
    await ler(t, '7892');
    expect(r.log.where((l) => l.startsWith('lerCodigo')).length, 3);
    expect(f9(t).onPressed, isNotNull);
    // F9 funciona com o foco no campo do leitor.
    await t.sendKeyEvent(LogicalKeyboardKey.f9);
    await t.pumpAndSettle();
    expect(r.log, contains('conferir'));
    expect(r.log, isNot(contains('marcarConferido')));
    expect(find.text('Marcar embalado'), findsOneWidget);
  });

  testWidgets('T1 Conferir: encerrado e não conferido chama marcarConferido', (t) async {
    final r = ecom(sit: 'encerrado', itens: [it(1, 1, 1)]);
    await abrir(t, r, pagar: false);
    expect(f9(t).onPressed, isNotNull);
    await t.sendKeyEvent(LogicalKeyboardKey.f9);
    await t.pumpAndSettle();
    expect(r.log, contains('marcarConferido'));
    expect(r.log, isNot(contains('conferir')));
  });

  testWidgets('Conferir: peça fora do pedido é recusada e não soma', (t) async {
    final r = ecom();
    await abrir(t, r, pagar: false);
    await ler(t, '7899');
    expect(r.itensBase!.every((i) => (i.atendido ?? 0) == 0), isTrue);
    expect(f9(t).onPressed, isNull);
  });

  testWidgets('Conferir: ↑↓ escolhem a linha e + conta uma peça nela; conferidos descem',
      (t) async {
    final r = ecom();
    await abrir(t, r, pagar: false);
    await t.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await t.sendKeyEvent(LogicalKeyboardKey.numpadAdd);
    await t.pumpAndSettle();
    expect(r.log, contains('contar:2'));
    // produto 2 completo: vai para o fim da lista, esmaecido.
    final y1 = t.getTopLeft(find.byKey(const Key('conferir_linha_1_1'))).dy;
    final y2 = t.getTopLeft(find.byKey(const Key('conferir_linha_2_2'))).dy;
    expect(y2, greaterThan(y1));
  });

  testWidgets('Assumir: tela só leitura com um único botão', (t) async {
    await abrir(t, _Repo(pedidoBase: ped(origem: 'ecommerce', func: null)), pagar: false);
    expect(find.byKey(const Key('pedido_mais_acoes')), findsNothing);
    await t.sendKeyEvent(LogicalKeyboardKey.f10);
    await t.pumpAndSettle();
    expect(find.text('Cancelar pedido'), findsNothing);
    expect(find.text('Gerenciar produtos'), findsOneWidget);
    expect(
      t.widget<TextButton>(find.widgetWithText(TextButton, 'Gerenciar produtos')).onPressed,
      isNull,
    );
  });

  testWidgets('T2 e-commerce entrega: Embalar -> Chamar -> Entregue (um F9 por etapa)',
      (t) async {
    final r = _Repo(
      pedidoBase: _copiaConferido(
          ped(origem: 'ecommerce', mod: 'entrega', sit: 'encerrado', ent: 'aguardando_chamada', pag: 'pago')),
      pagamentos: [pg(1, ok: true)],
    );
    await abrir(t, r, pagar: false);
    for (final acao in ['Marcar embalado', 'Chamar entregador', 'Confirmar entrega']) {
      expect(find.text(acao), findsOneWidget);
      await t.sendKeyEvent(LogicalKeyboardKey.f9);
      await t.pumpAndSettle();
    }
    expect(r.log.where((l) => ['embalar', 'chamar', 'entrega'].contains(l)).toList(),
        ['embalar', 'chamar', 'entrega']);
  });
}
