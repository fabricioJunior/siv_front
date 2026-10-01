import 'dart:convert';

import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc_test.dart';
import 'package:core/leitor.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/seletores.dart';
import 'package:core/sessao.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promocoes/models.dart';
import 'package:promocoes/use_cases.dart';

class _StubCarregarResumo implements CarregarResumoPagamentosRealizados {
  @override
  Future<PagamentosRealizadosResumo> call(String hashLista) async =>
      throw UnimplementedError();
}

class _StubBuscarSaldoCreditoDevolucao
    implements BuscarSaldoCreditoDevolucao {
  @override
  Future<double> call({
    required int pessoaId,
    List<int>? empresaIds,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async =>
      throw UnimplementedError();
}

class _SaldoCreditoFake implements BuscarSaldoCreditoDevolucao {
  final consultados = <int>[];

  @override
  Future<double> call({
    required int pessoaId,
    List<int>? empresaIds,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    consultados.add(pessoaId);
    return 79;
  }
}

class _StubVerificarElegibilidadeFidelidade
    implements VerificarElegibilidadeFidelidade {
  @override
  Future<bool> call({required int pessoaId}) async =>
      throw UnimplementedError();
}

class _StubVerificarPermiteNotaFiscalEmail
    implements VerificarPermiteNotaFiscalEmail {
  @override
  Future<bool> call({required int empresaId}) async =>
      throw UnimplementedError();
}

class _FakeAcessoGlobalSessao implements IAcessoGlobalSessao {
  @override
  int? get caixaIdDaSessao => null;

  @override
  int? get empresaIdDaSessao => null;

  @override
  String? get empresaNomeDaSessao => null;

  @override
  int? get terminalIdDaSessao => null;

  @override
  String? get terminalNomeDaSessao => null;

  @override
  int? get usuarioIdDaSessao => null;

  @override
  void atualizarCaixaIdDaSessao({required int terminalId, int? caixaId}) {}

  @override
  bool get dadosSincronizados => true;

  @override
  Stream<bool> get sincronizandoDados => const Stream.empty();
}

class _FakeApurarElegibilidade implements ApurarElegibilidade {
  final ResultadoElegibilidade resultado;

  _FakeApurarElegibilidade(this.resultado);

  @override
  Future<ResultadoElegibilidade> call({
    int? clienteId,
    required List<ItemApuracaoElegibilidade> itens,
    String? codigoCupom,
  }) async =>
      resultado;
}

class _FakeLeitorData with LeitorData {
  @override
  final int idReferencia;

  _FakeLeitorData(this.idReferencia);

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
  int get id => idReferencia;
  @override
  Map<String, dynamic> get dados => const {};
}

class _FakeLeitorDataDatasource implements ILeitorDataDatasource {
  final Map<int, int> referenciaIdPorProdutoId;

  _FakeLeitorDataDatasource(this.referenciaIdPorProdutoId);

  @override
  Future<LeitorData?> getData(String codigo, {int? tabelaDePrecoId}) async =>
      null;

  @override
  Future<LeitorData?> getDataPorProdutoId(
    int produtoId, {
    int? tabelaDePrecoId,
  }) async {
    final referenciaId = referenciaIdPorProdutoId[produtoId];
    if (referenciaId == null) return null;
    return _FakeLeitorData(referenciaId);
  }
}

OpcaoElegivel _opcao(int id, {String tipo = 'promocao'}) => OpcaoElegivel(
      tipo: tipo,
      id: id,
      nome: 'Promoção $id',
      valorDesconto: 5,
      valorFinalUnitario: 15,
    );

const _produtoSemConflitoA = ProdutoCompartilhado(
  hash: 'p1',
  produtoId: 1,
  hashLista: 'hash',
  quantidade: 1,
  valorUnitario: 20,
  nome: 'Produto 1',
  corNome: 'Azul',
  tamanhoNome: 'M',
);

const _produtoSemConflitoB = ProdutoCompartilhado(
  hash: 'p2',
  produtoId: 2,
  hashLista: 'hash',
  quantidade: 1,
  valorUnitario: 20,
  nome: 'Produto 2',
  corNome: 'Azul',
  tamanhoNome: 'M',
);

const _produtoComConflito = ProdutoCompartilhado(
  hash: 'p3',
  produtoId: 3,
  hashLista: 'hash',
  quantidade: 1,
  valorUnitario: 20,
  nome: 'Produto 3',
  corNome: 'Azul',
  tamanhoNome: 'M',
);

const _produto199 = ProdutoCompartilhado(
  hash: 'p199',
  produtoId: 9,
  hashLista: 'hash',
  quantidade: 1,
  valorUnitario: 199,
  nome: 'Produto 199',
  corNome: 'Azul',
  tamanhoNome: 'M',
);

void main() {
  blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
    'cupom valor_fixo 200 em produto de 199: aplica o desconto e zera o total',
    build: () => PagamentosRealizadosBloc(
      _StubCarregarResumo(),
      _StubBuscarSaldoCreditoDevolucao(),
      _StubVerificarElegibilidadeFidelidade(),
      _StubVerificarPermiteNotaFiscalEmail(),
      _FakeAcessoGlobalSessao(),
      _FakeApurarElegibilidade(
        ResultadoElegibilidade(
          itens: [
            ItemElegibilidade(
              referenciaId: 900,
              opcoesElegiveis: [
                const OpcaoElegivel(
                  tipo: 'cupom',
                  id: 3,
                  nome: 'Cupom PRICILLA200',
                  valorDesconto: 199,
                  valorFinalUnitario: 0,
                ),
              ],
            ),
          ],
        ),
      ),
      _FakeLeitorDataDatasource({9: 900}),
    ),
    seed: () => const PagamentosRealizadosState(
      resumo: PagamentosRealizadosResumo(
        listaCompartilhada: null,
        produtosCompartilhados: [_produto199],
        quantidadeTotalProdutos: 1,
        valorTotalProdutos: 199,
      ),
    ),
    act: (bloc) =>
        bloc.add(const PagamentosRealizadosCupomInformado(codigo: 'PRICILLA200')),
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.cupomErro, isNull);
      expect(bloc.state.cupomCodigoAplicado, 'PRICILLA200');
      expect(bloc.state.promocaoEscolhidaPorItem[9]?.ehCupom, isTrue);
      expect(bloc.state.valorDescontoPromocaoTotal, 199);
      expect(bloc.state.valorTotalComDesconto, 0);
    },
  );


  blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
    'cupom: resposta REAL da apuracao em producao (JSON) zera produto de 199',
    build: () => PagamentosRealizadosBloc(
      _StubCarregarResumo(),
      _StubBuscarSaldoCreditoDevolucao(),
      _StubVerificarElegibilidadeFidelidade(),
      _StubVerificarPermiteNotaFiscalEmail(),
      _FakeAcessoGlobalSessao(),
      _FakeApurarElegibilidade(
        ResultadoElegibilidade.fromJson(
          jsonDecode(
            '{"itens":[{"referenciaId":66700001,"opcoesElegiveis":[{"tipo":"cupom","id":3,'
            '"nome":"Cupom PRICILLA200","valorDesconto":199,"valorFinalUnitario":0}]}]}',
          ) as Map<String, dynamic>,
        ),
      ),
      _FakeLeitorDataDatasource({9: 66700001}),
    ),
    seed: () => const PagamentosRealizadosState(
      resumo: PagamentosRealizadosResumo(
        listaCompartilhada: null,
        produtosCompartilhados: [_produto199],
        quantidadeTotalProdutos: 1,
        valorTotalProdutos: 199,
      ),
    ),
    act: (bloc) =>
        bloc.add(const PagamentosRealizadosCupomInformado(codigo: 'PRICILLA200')),
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.cupomErro, isNull);
      expect(bloc.state.promocaoEscolhidaPorItem[9]?.ehCupom, isTrue);
      expect(bloc.state.valorTotalComDesconto, 0);
    },
  );


  blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
    'cupom valido mas sem nenhum item elegivel: nao mostra "aplicado" e explica o motivo',
    build: () => PagamentosRealizadosBloc(
      _StubCarregarResumo(),
      _StubBuscarSaldoCreditoDevolucao(),
      _StubVerificarElegibilidadeFidelidade(),
      _StubVerificarPermiteNotaFiscalEmail(),
      _FakeAcessoGlobalSessao(),
      _FakeApurarElegibilidade(
        ResultadoElegibilidade(
          itens: [ItemElegibilidade(referenciaId: 900, opcoesElegiveis: const [])],
        ),
      ),
      _FakeLeitorDataDatasource({9: 900}),
    ),
    seed: () => const PagamentosRealizadosState(
      resumo: PagamentosRealizadosResumo(
        listaCompartilhada: null,
        produtosCompartilhados: [_produto199],
        quantidadeTotalProdutos: 1,
        valorTotalProdutos: 199,
      ),
    ),
    act: (bloc) =>
        bloc.add(const PagamentosRealizadosCupomInformado(codigo: 'PRICILLA200')),
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.cupomCodigoAplicado, isNull);
      expect(bloc.state.possuiCupomAplicado, isFalse);
      expect(bloc.state.cupomErro, contains('nenhum item do carrinho é elegível'));
      expect(bloc.state.valorTotalComDesconto, 199);
    },
  );

  blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
    'cupom perde para promocao ja escolhida no item: avisa que nao e acumulavel',
    build: () => PagamentosRealizadosBloc(
      _StubCarregarResumo(),
      _StubBuscarSaldoCreditoDevolucao(),
      _StubVerificarElegibilidadeFidelidade(),
      _StubVerificarPermiteNotaFiscalEmail(),
      _FakeAcessoGlobalSessao(),
      _FakeApurarElegibilidade(
        ResultadoElegibilidade(
          itens: [
            ItemElegibilidade(
              referenciaId: 900,
              opcoesElegiveis: [
                _opcao(77),
                const OpcaoElegivel(
                  tipo: 'cupom',
                  id: 3,
                  nome: 'Cupom PRICILLA200',
                  valorDesconto: 199,
                  valorFinalUnitario: 0,
                ),
              ],
            ),
          ],
        ),
      ),
      _FakeLeitorDataDatasource({9: 900}),
    ),
    seed: () => const PagamentosRealizadosState(
      resumo: PagamentosRealizadosResumo(
        listaCompartilhada: null,
        produtosCompartilhados: [_produto199],
        quantidadeTotalProdutos: 1,
        valorTotalProdutos: 199,
      ),
    ),
    act: (bloc) =>
        bloc.add(const PagamentosRealizadosCupomInformado(codigo: 'PRICILLA200')),
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.possuiCupomAplicado, isFalse);
      expect(bloc.state.cupomErro, contains('não é acumulável'));
    },
  );


  PagamentosRealizadosState estadoVendaDe199({required bool comCupom, String valorTexto = ''}) =>
      PagamentosRealizadosState(
        resumo: const PagamentosRealizadosResumo(
          listaCompartilhada: null,
          produtosCompartilhados: [_produto199],
          quantidadeTotalProdutos: 1,
          valorTotalProdutos: 199,
        ),
        promocaoEscolhidaPorItem: comCupom
            ? {
                9: const OpcaoElegivel(
                  tipo: 'cupom',
                  id: 3,
                  nome: 'Cupom PRICILLA200',
                  valorDesconto: 199,
                  valorFinalUnitario: 0,
                ),
              }
            : const {},
        cupomCodigoAplicado: comCupom ? 'PRICILLA200' : null,
        linhas: [
          PagamentoRealizadoLinha(
            id: 'l1',
            formaDePagamento: SelectData(
              id: 1,
              nome: 'Dinheiro',
              data: const {'tipo': 'dinheiro'},
            ),
            valorTexto: valorTexto,
            parcelasTexto: '1',
          ),
        ],
      );

  PagamentosRealizadosBloc blocDeFechamento() => PagamentosRealizadosBloc(
        _StubCarregarResumo(),
        _StubBuscarSaldoCreditoDevolucao(),
        _StubVerificarElegibilidadeFidelidade(),
        _StubVerificarPermiteNotaFiscalEmail(),
        _FakeAcessoGlobalSessao(),
        _FakeApurarElegibilidade(const ResultadoElegibilidade(itens: [])),
        _FakeLeitorDataDatasource({9: 900}),
      );

  blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
    'fecha venda zerada por cupom com pagamento de valor 0 (valor em branco)',
    build: blocDeFechamento,
    seed: () => estadoVendaDe199(comCupom: true),
    act: (bloc) => bloc.add(const PagamentosRealizadosFinalizacaoSolicitada()),
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.erro, isNull);
      expect(bloc.state.step, PagamentosRealizadosStep.concluido);
      expect(bloc.state.resultado, hasLength(1));
      expect(bloc.state.resultado.first['valor'], 0);
    },
  );

  blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
    'sem cupom, total a pagar > 0 continua exigindo valor maior que zero',
    build: blocDeFechamento,
    seed: () => estadoVendaDe199(comCupom: false, valorTexto: '0'),
    act: (bloc) => bloc.add(const PagamentosRealizadosFinalizacaoSolicitada()),
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.erro, 'Informe um valor válido em todas as linhas.');
      expect(bloc.state.step, isNot(PagamentosRealizadosStep.concluido));
    },
  );

  group('crédito de devolução na tela de pagamento', () {
    PagamentosRealizadosBloc blocCom(_SaldoCreditoFake saldo) => PagamentosRealizadosBloc(
          _StubCarregarResumo(),
          saldo,
          _StubVerificarElegibilidadeFidelidade(),
          _StubVerificarPermiteNotaFiscalEmail(),
          _FakeAcessoGlobalSessao(),
          _FakeApurarElegibilidade(const ResultadoElegibilidade(itens: [])),
          _FakeLeitorDataDatasource(const {}),
        );

    PagamentosRealizadosIniciado iniciadoCom({required bool generico}) => PagamentosRealizadosIniciado(
          hashLista: 'hash',
          pessoaId: 2208,
          clienteGenerico: generico,
          resumoInicial: const PagamentosRealizadosResumo(
            listaCompartilhada: null,
            produtosCompartilhados: [_produto199],
            quantidadeTotalProdutos: 1,
            valorTotalProdutos: 199,
          ),
        );

    test('cliente genérico ("Cliente não cadastrado") não consulta nem mostra o saldo da pessoa compartilhada', () async {
      final saldo = _SaldoCreditoFake();
      final bloc = blocCom(saldo)..add(iniciadoCom(generico: true));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(saldo.consultados, isEmpty);
      expect(bloc.state.saldoCreditoDevolucao, 0);
      expect(bloc.state.carregandoSaldoCreditoDevolucao, isFalse);
      await bloc.close();
    });

    test('cliente identificado continua consultando o próprio saldo', () async {
      final saldo = _SaldoCreditoFake();
      final bloc = blocCom(saldo)..add(iniciadoCom(generico: false));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(saldo.consultados, [2208]);
      expect(bloc.state.saldoCreditoDevolucao, 79);
      await bloc.close();
    });
  });

  blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
    'auto-aplica promocao por produto, mesmo com multiplas promocoes '
    'distintas no carrinho, e nao auto-aplica em produto com conflito',
    build: () => PagamentosRealizadosBloc(
      _StubCarregarResumo(),
      _StubBuscarSaldoCreditoDevolucao(),
      _StubVerificarElegibilidadeFidelidade(),
      _StubVerificarPermiteNotaFiscalEmail(),
      _FakeAcessoGlobalSessao(),
      _FakeApurarElegibilidade(
        ResultadoElegibilidade(
          itens: [
            ItemElegibilidade(referenciaId: 100, opcoesElegiveis: [_opcao(501)]),
            ItemElegibilidade(referenciaId: 200, opcoesElegiveis: [_opcao(502)]),
            ItemElegibilidade(
              referenciaId: 300,
              opcoesElegiveis: [_opcao(601), _opcao(602)],
            ),
          ],
        ),
      ),
      _FakeLeitorDataDatasource({1: 100, 2: 200, 3: 300}),
    ),
    act: (bloc) => bloc.add(
      const PagamentosRealizadosIniciado(
        hashLista: 'hash',
        resumoInicial: PagamentosRealizadosResumo(
          listaCompartilhada: null,
          produtosCompartilhados: [
            _produtoSemConflitoA,
            _produtoSemConflitoB,
            _produtoComConflito,
          ],
          quantidadeTotalProdutos: 3,
          valorTotalProdutos: 60,
        ),
      ),
    ),
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      final promocoes = bloc.state.promocaoEscolhidaPorItem;
      expect(promocoes[1]?.id, 501);
      expect(promocoes[2]?.id, 502);
      expect(promocoes.containsKey(3), isFalse);
    },
  );
}
