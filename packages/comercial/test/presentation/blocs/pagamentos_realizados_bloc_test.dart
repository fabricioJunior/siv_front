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

class _StubBuscarSaldoCreditoDevolucao implements BuscarSaldoCreditoDevolucao {
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

class _StubRecuperarOpcoesResgate implements RecuperarOpcoesResgatePontos {
  @override
  Future<OpcoesResgatePontos> call({required int pessoaId}) async =>
      throw UnimplementedError();
}

class _FakeRecuperarOpcoesResgate implements RecuperarOpcoesResgatePontos {
  final OpcoesResgatePontos opcoes;

  _FakeRecuperarOpcoesResgate(this.opcoes);

  @override
  Future<OpcoesResgatePontos> call({required int pessoaId}) async => opcoes;
}

class _FakeVerificarElegibilidadeFidelidade
    implements VerificarElegibilidadeFidelidade {
  @override
  Future<bool> call({required int pessoaId}) async => true;
}

class _FakeBuscarSaldoZero implements BuscarSaldoCreditoDevolucao {
  @override
  Future<double> call({
    required int pessoaId,
    List<int>? empresaIds,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async =>
      0;
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
  final chamadas = <List<String>>[];

  _FakeApurarElegibilidade(this.resultado);

  @override
  Future<ResultadoElegibilidade> call({
    int? clienteId,
    required List<ItemApuracaoElegibilidade> itens,
    List<String> codigosCupom = const [],
  }) async {
    chamadas.add(codigosCupom);
    return resultado;
  }
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
      _StubRecuperarOpcoesResgate(),
    ),
    seed: () => const PagamentosRealizadosState(
      resumo: PagamentosRealizadosResumo(
        listaCompartilhada: null,
        produtosCompartilhados: [_produto199],
        quantidadeTotalProdutos: 1,
        valorTotalProdutos: 199,
      ),
    ),
    act: (bloc) => bloc
        .add(const PagamentosRealizadosCupomInformado(codigo: 'PRICILLA200')),
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.cupomErro, isNull);
      expect(bloc.state.cuponsAplicados, ['PRICILLA200']);
      expect(bloc.state.cuponsEscolhidosPorItem[9]?.single.ehCupom, isTrue);
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
      _StubRecuperarOpcoesResgate(),
    ),
    seed: () => const PagamentosRealizadosState(
      resumo: PagamentosRealizadosResumo(
        listaCompartilhada: null,
        produtosCompartilhados: [_produto199],
        quantidadeTotalProdutos: 1,
        valorTotalProdutos: 199,
      ),
    ),
    act: (bloc) => bloc
        .add(const PagamentosRealizadosCupomInformado(codigo: 'PRICILLA200')),
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.cupomErro, isNull);
      expect(bloc.state.cuponsEscolhidosPorItem[9]?.single.ehCupom, isTrue);
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
          itens: [
            ItemElegibilidade(referenciaId: 900, opcoesElegiveis: const [])
          ],
        ),
      ),
      _FakeLeitorDataDatasource({9: 900}),
      _StubRecuperarOpcoesResgate(),
    ),
    seed: () => const PagamentosRealizadosState(
      resumo: PagamentosRealizadosResumo(
        listaCompartilhada: null,
        produtosCompartilhados: [_produto199],
        quantidadeTotalProdutos: 1,
        valorTotalProdutos: 199,
      ),
    ),
    act: (bloc) => bloc
        .add(const PagamentosRealizadosCupomInformado(codigo: 'PRICILLA200')),
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.possuiCupomAplicado, isFalse);
      expect(
          bloc.state.cupomErro, contains('nenhum item do carrinho é elegível'));
      expect(bloc.state.valorTotalComDesconto, 199);
    },
  );

  blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
    'cupom soma com a promocao do item (nao e exclusivo)',
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
      _StubRecuperarOpcoesResgate(),
    ),
    seed: () => const PagamentosRealizadosState(
      resumo: PagamentosRealizadosResumo(
        listaCompartilhada: null,
        produtosCompartilhados: [_produto199],
        quantidadeTotalProdutos: 1,
        valorTotalProdutos: 199,
      ),
    ),
    act: (bloc) => bloc
        .add(const PagamentosRealizadosCupomInformado(codigo: 'PRICILLA200')),
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.possuiCupomAplicado, isTrue);
      expect(bloc.state.cupomErro, isNull);
      expect(bloc.state.cuponsEscolhidosPorItem[9], hasLength(1));
      // desconto total nunca passa do preco (promocao + cupom de 199)
      expect(bloc.state.valorTotalComDesconto, 0);
    },
  );

  OpcaoElegivel cupomOpcao(int id, String codigo, double desconto) =>
      OpcaoElegivel(
        tipo: 'cupom',
        id: id,
        nome: 'Cupom $codigo',
        codigo: codigo,
        valorDesconto: desconto,
        valorFinalUnitario: 199 - desconto,
      );

  const estadoCarrinho199 = PagamentosRealizadosState(
    resumo: PagamentosRealizadosResumo(
      listaCompartilhada: null,
      produtosCompartilhados: [_produto199],
      quantidadeTotalProdutos: 1,
      valorTotalProdutos: 199,
    ),
  );

  PagamentosRealizadosBloc blocComApuracao(_FakeApurarElegibilidade fake) =>
      PagamentosRealizadosBloc(
        _StubCarregarResumo(),
        _StubBuscarSaldoCreditoDevolucao(),
        _StubVerificarElegibilidadeFidelidade(),
        _StubVerificarPermiteNotaFiscalEmail(),
        _FakeAcessoGlobalSessao(),
        fake,
        _FakeLeitorDataDatasource({9: 900}),
        _StubRecuperarOpcoesResgate(),
      );

  ResultadoElegibilidade apuracaoCom(List<OpcaoElegivel> opcoes,
          {String? invalido, Map<String, String> recusados = const {}}) =>
      ResultadoElegibilidade(
        itens: [ItemElegibilidade(referenciaId: 900, opcoesElegiveis: opcoes)],
        cupomInvalido: invalido ?? recusados.values.firstOrNull,
        cuponsRecusados: recusados,
      );

  blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
    '2 cupons: soma os descontos, envia ambos na apuracao e agrupa payload por codigo',
    build: () => blocComApuracao(_FakeApurarElegibilidade(
      apuracaoCom([cupomOpcao(1, 'CUP5', 5), cupomOpcao(2, 'CUP8', 8)]),
    )),
    seed: () => estadoCarrinho199.copyWith(
      cuponsAplicados: ['CUP5'],
      cuponsEscolhidosPorItem: {
        9: [cupomOpcao(1, 'CUP5', 5)],
      },
    ),
    act: (bloc) =>
        bloc.add(const PagamentosRealizadosCupomInformado(codigo: 'cup8')),
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.cuponsAplicados, ['CUP5', 'CUP8']);
      expect(bloc.state.cuponsEscolhidosPorItem[9], hasLength(2));
      expect(bloc.state.valorDescontoPromocaoTotal, 13);
      expect(bloc.state.valorTotalComDesconto, 186);
      expect(bloc.state.cuponsParaPayload, [
        {
          'codigo': 'CUP5',
          'produtoIds': [9]
        },
        {
          'codigo': 'CUP8',
          'produtoIds': [9]
        },
      ]);
    },
  );

  blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
    'soma de cupons tem teto no preco unitario',
    build: () => blocComApuracao(_FakeApurarElegibilidade(
      apuracaoCom([cupomOpcao(1, 'A', 150), cupomOpcao(2, 'B', 150)]),
    )),
    seed: () => estadoCarrinho199,
    act: (bloc) async {
      bloc.add(const PagamentosRealizadosCupomInformado(codigo: 'A'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const PagamentosRealizadosCupomInformado(codigo: 'B'));
    },
    wait: const Duration(milliseconds: 80),
    verify: (bloc) {
      expect(bloc.state.valorDescontoPromocaoTotal, 199);
      expect(bloc.state.valorTotalComDesconto, 0);
    },
  );

  blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
    'cupom recusado nao derruba os ja aplicados e diz qual cupom e por que',
    build: () => blocComApuracao(_FakeApurarElegibilidade(
      apuracaoCom(
        [cupomOpcao(1, 'CUP5', 5)],
        recusados: {
          'X': 'não é cumulativo e não pode ser usado junto com outros cupons',
        },
      ),
    )),
    seed: () => estadoCarrinho199.copyWith(
      cuponsAplicados: ['CUP5'],
      cuponsEscolhidosPorItem: {
        9: [cupomOpcao(1, 'CUP5', 5)],
      },
    ),
    act: (bloc) =>
        bloc.add(const PagamentosRealizadosCupomInformado(codigo: 'X')),
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.cuponsAplicados, ['CUP5']);
      expect(bloc.state.cuponsEscolhidosPorItem[9], hasLength(1));
      expect(
        bloc.state.cupomErro,
        'Cupom X: não é cumulativo e não pode ser usado junto com outros cupons.',
      );
      expect(bloc.state.valorDescontoPromocaoTotal, 5);
    },
  );

  blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
    'novo cupom barrado por um ja aplicado que nao e cumulativo: nomeia o antigo',
    build: () => blocComApuracao(_FakeApurarElegibilidade(
      apuracaoCom(
        [cupomOpcao(2, 'CUP8', 8)],
        recusados: {
          'EXCL':
              'não é cumulativo e não pode ser usado junto com outros cupons',
        },
      ),
    )),
    seed: () => estadoCarrinho199.copyWith(
      cuponsAplicados: ['EXCL'],
      cuponsEscolhidosPorItem: {
        9: [cupomOpcao(1, 'EXCL', 5)],
      },
    ),
    act: (bloc) =>
        bloc.add(const PagamentosRealizadosCupomInformado(codigo: 'CUP8')),
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.cuponsAplicados, ['EXCL']);
      expect(
        bloc.state.cupomErro,
        'Cupom CUP8 não pôde ser somado: o cupom EXCL não é cumulativo e não pode ser usado junto com outros cupons.',
      );
    },
  );

  blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
    'remover um de 2 cupons reapura so com o restante',
    build: () => blocComApuracao(_FakeApurarElegibilidade(
      apuracaoCom([cupomOpcao(1, 'CUP5', 5)]),
    )),
    seed: () => estadoCarrinho199.copyWith(
      cuponsAplicados: ['CUP5', 'CUP8'],
      cuponsEscolhidosPorItem: {
        9: [cupomOpcao(1, 'CUP5', 5), cupomOpcao(2, 'CUP8', 8)],
      },
    ),
    act: (bloc) =>
        bloc.add(const PagamentosRealizadosCupomRemovido(codigo: 'CUP8')),
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.cuponsAplicados, ['CUP5']);
      expect(bloc.state.cuponsEscolhidosPorItem[9]?.map((o) => o.codigo),
          ['CUP5']);
      expect(bloc.state.valorDescontoPromocaoTotal, 5);
    },
  );

  blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
    'remover o unico cupom limpa tudo (comportamento antigo)',
    build: () => blocComApuracao(
        _FakeApurarElegibilidade(const ResultadoElegibilidade(itens: []))),
    seed: () => estadoCarrinho199.copyWith(
      cuponsAplicados: ['CUP5'],
      cuponsEscolhidosPorItem: {
        9: [cupomOpcao(1, 'CUP5', 5)],
      },
    ),
    act: (bloc) =>
        bloc.add(const PagamentosRealizadosCupomRemovido(codigo: 'CUP5')),
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.possuiCupomAplicado, isFalse);
      expect(bloc.state.cuponsEscolhidosPorItem, isEmpty);
      expect(bloc.state.valorTotalComDesconto, 199);
    },
  );

  blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
    'cupom ja aplicado ou alem de 5 e barrado sem chamar a apuracao',
    build: () => blocComApuracao(
        _FakeApurarElegibilidade(const ResultadoElegibilidade(itens: []))),
    seed: () => estadoCarrinho199.copyWith(
      cuponsAplicados: ['A', 'B', 'C', 'D', 'E'],
    ),
    act: (bloc) async {
      bloc.add(const PagamentosRealizadosCupomInformado(codigo: 'e'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      bloc.add(const PagamentosRealizadosCupomInformado(codigo: 'F'));
    },
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.cuponsAplicados, hasLength(5));
      expect(bloc.state.cupomErro, contains('Máximo de 5'));
    },
  );

  blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
    'cupom soma com a promocao do mesmo item',
    build: () => blocComApuracao(_FakeApurarElegibilidade(
      apuracaoCom(
          [_opcao(77), cupomOpcao(1, 'CUP5', 5), cupomOpcao(2, 'CUP8', 8)]),
    )),
    seed: () => estadoCarrinho199,
    act: (bloc) =>
        bloc.add(const PagamentosRealizadosCupomInformado(codigo: 'CUP5')),
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.cuponsAplicados, ['CUP5']);
      expect(bloc.state.cuponsEscolhidosPorItem[9], hasLength(1));
      expect(bloc.state.cupomErro, isNull);
    },
  );

  blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
    'cupom soma com o desconto manual do item, com teto no preco',
    build: () => blocComApuracao(_FakeApurarElegibilidade(
      apuracaoCom([cupomOpcao(1, 'CUP5', 5)]),
    )),
    seed: () => estadoCarrinho199.copyWith(
      descontosItensAplicado: {9: 197},
    ),
    act: (bloc) =>
        bloc.add(const PagamentosRealizadosCupomInformado(codigo: 'CUP5')),
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.cuponsAplicados, ['CUP5']);
      expect(bloc.state.cupomErro, isNull);
      // 199 - 197 manual = 2 restantes; cupom de 5 e limitado a 2
      expect(bloc.state.valorTotalComDesconto, 0);
      expect(bloc.state.valorDescontoPromocaoTotal, 2);
    },
  );

  blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
    'escolher promocao no item mantem os cupons dele',
    build: () => blocComApuracao(
        _FakeApurarElegibilidade(const ResultadoElegibilidade(itens: []))),
    seed: () => estadoCarrinho199.copyWith(
      cuponsAplicados: ['CUP5'],
      cuponsEscolhidosPorItem: {
        9: [cupomOpcao(1, 'CUP5', 5)],
      },
    ),
    act: (bloc) => bloc.add(
      PagamentosRealizadosPromocaoEscolhida(produtoId: 9, opcao: _opcao(77)),
    ),
    verify: (bloc) {
      expect(bloc.state.cuponsEscolhidosPorItem[9], hasLength(1));
      expect(bloc.state.promocaoEscolhidaPorItem[9]?.id, 77);
    },
  );

  blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
    'venda zerada por 2 cupons fecha com pagamento de valor 0',
    build: () => blocComApuracao(
        _FakeApurarElegibilidade(const ResultadoElegibilidade(itens: []))),
    seed: () => estadoCarrinho199.copyWith(
      cuponsAplicados: ['A', 'B'],
      cuponsEscolhidosPorItem: {
        9: [cupomOpcao(1, 'A', 100), cupomOpcao(2, 'B', 99)],
      },
      linhas: [
        PagamentoRealizadoLinha(
          id: 'l1',
          formaDePagamento: SelectData(
            id: 1,
            nome: 'Dinheiro',
            data: const {'tipo': 'dinheiro'},
          ),
          valorTexto: '',
          parcelasTexto: '1',
        ),
      ],
    ),
    act: (bloc) => bloc.add(const PagamentosRealizadosFinalizacaoSolicitada()),
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.erro, isNull);
      expect(bloc.state.step, PagamentosRealizadosStep.concluido);
      expect(bloc.state.resultado.single['valor'], 0);
    },
  );

  test('payload agrupa produtoIds por codigo em varios produtos', () {
    final estado = estadoCarrinho199.copyWith(
      cuponsEscolhidosPorItem: {
        1: [cupomOpcao(1, 'A', 5)],
        2: [cupomOpcao(1, 'A', 5), cupomOpcao(2, 'B', 8)],
      },
    );
    expect(estado.cuponsParaPayload, [
      {
        'codigo': 'A',
        'produtoIds': [1, 2]
      },
      {
        'codigo': 'B',
        'produtoIds': [2]
      },
    ]);
  });

  PagamentosRealizadosState estadoVendaDe199(
          {required bool comCupom, String valorTexto = ''}) =>
      PagamentosRealizadosState(
        resumo: const PagamentosRealizadosResumo(
          listaCompartilhada: null,
          produtosCompartilhados: [_produto199],
          quantidadeTotalProdutos: 1,
          valorTotalProdutos: 199,
        ),
        cuponsEscolhidosPorItem: comCupom
            ? {
                9: [
                  const OpcaoElegivel(
                    tipo: 'cupom',
                    id: 3,
                    nome: 'Cupom PRICILLA200',
                    codigo: 'PRICILLA200',
                    valorDesconto: 199,
                    valorFinalUnitario: 0,
                  ),
                ],
              }
            : const {},
        cuponsAplicados: comCupom ? ['PRICILLA200'] : const [],
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
        _StubRecuperarOpcoesResgate(),
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

  group('acerto coberto pelo adiantado (abatimento)', () {
    Future<PagamentosRealizadosBloc> abrirComAdiantado({
      required bool permiteZero,
    }) async {
      final bloc = blocDeFechamento();
      addTearDown(bloc.close);
      bloc.add(PagamentosRealizadosIniciado(
        hashLista: 'h',
        resumoInicial: const PagamentosRealizadosResumo(
          listaCompartilhada: null,
          produtosCompartilhados: [_produto199],
          quantidadeTotalProdutos: 1,
          valorTotalProdutos: 199,
        ),
        abatimentoTotal: 199,
        abatimentoPermiteZero: permiteZero,
      ));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      bloc.add(PagamentosRealizadosFormaAlterada(
        linhaId: bloc.state.linhas.single.id,
        formaDePagamento: SelectData(
          id: 1,
          nome: 'Dinheiro',
          data: const {'tipo': 'dinheiro'},
        ),
      ));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      bloc.add(const PagamentosRealizadosFinalizacaoSolicitada());
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return bloc;
    }

    test('consignação: adiantado cobre tudo fecha com pagamento de valor 0',
        () async {
      final bloc = await abrirComAdiantado(permiteZero: true);
      expect(bloc.state.valorTotalAPagar, 0);
      expect(bloc.state.erro, isNull);
      expect(bloc.state.step, PagamentosRealizadosStep.concluido);
      expect(bloc.state.resultado.single['valor'], 0);
    });

    test('pedido: pagamentos já lançados cobrindo tudo não aceita linha zero',
        () async {
      final bloc = await abrirComAdiantado(permiteZero: false);
      expect(bloc.state.step, isNot(PagamentosRealizadosStep.concluido));
      expect(bloc.state.erro, 'Informe um valor válido em todas as linhas.');
    });
  });

  group('crédito de devolução na tela de pagamento', () {
    PagamentosRealizadosBloc blocCom(_SaldoCreditoFake saldo) =>
        PagamentosRealizadosBloc(
          _StubCarregarResumo(),
          saldo,
          _StubVerificarElegibilidadeFidelidade(),
          _StubVerificarPermiteNotaFiscalEmail(),
          _FakeAcessoGlobalSessao(),
          _FakeApurarElegibilidade(const ResultadoElegibilidade(itens: [])),
          _FakeLeitorDataDatasource(const {}),
          _StubRecuperarOpcoesResgate(),
        );

    PagamentosRealizadosIniciado iniciadoCom({required bool generico}) =>
        PagamentosRealizadosIniciado(
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

    test(
        'cliente genérico ("Cliente não cadastrado") não consulta nem mostra o saldo da pessoa compartilhada',
        () async {
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
            ItemElegibilidade(
                referenciaId: 100, opcoesElegiveis: [_opcao(501)]),
            ItemElegibilidade(
                referenciaId: 200, opcoesElegiveis: [_opcao(502)]),
            ItemElegibilidade(
              referenciaId: 300,
              opcoesElegiveis: [_opcao(601), _opcao(602)],
            ),
          ],
        ),
      ),
      _FakeLeitorDataDatasource({1: 100, 2: 200, 3: 300}),
      _StubRecuperarOpcoesResgate(),
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

  group('resgate de pontos de fidelidade', () {
    const resumo199 = PagamentosRealizadosResumo(
      listaCompartilhada: null,
      produtosCompartilhados: [_produto199],
      quantidadeTotalProdutos: 1,
      valorTotalProdutos: 199,
    );
    const opcoes = OpcoesResgatePontos(
      saldo: 100,
      valorPorPonto: 0.1,
      cumulativoValorPorPonto: false,
      faixas: [
        FaixaResgate(
          id: 1,
          pontos: 50,
          tipo: 'valor',
          valor: 10,
          cumulativo: true,
          disponivel: true,
        ),
        FaixaResgate(
          id: 2,
          pontos: 80,
          tipo: 'percentual',
          valor: 10,
          cumulativo: false,
          disponivel: true,
        ),
        FaixaResgate(
          id: 3,
          pontos: 500,
          tipo: 'valor',
          valor: 100,
          cumulativo: true,
          disponivel: false,
        ),
      ],
    );

    PagamentosRealizadosBloc novoBloc() => PagamentosRealizadosBloc(
          _StubCarregarResumo(),
          _FakeBuscarSaldoZero(),
          _FakeVerificarElegibilidadeFidelidade(),
          _StubVerificarPermiteNotaFiscalEmail(),
          _FakeAcessoGlobalSessao(),
          _FakeApurarElegibilidade(ResultadoElegibilidade(itens: const [])),
          _FakeLeitorDataDatasource({}),
          _FakeRecuperarOpcoesResgate(opcoes),
        );

    const comOpcoes = PagamentosRealizadosState(
      step: PagamentosRealizadosStep.editando,
      resumo: resumo199,
      clienteElegivelFidelidade: true,
      opcoesResgate: opcoes,
    );

    blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
      'carrega as opcoes de resgate junto da elegibilidade',
      build: novoBloc,
      act: (bloc) => bloc.add(
        const PagamentosRealizadosIniciado(
          hashLista: 'hash',
          resumoInicial: resumo199,
          pessoaId: 7,
        ),
      ),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.clienteElegivelFidelidade, isTrue);
        expect(bloc.state.opcoesResgate, opcoes);
        expect(bloc.state.possuiResgate, isFalse);
      },
    );

    blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
      'aplica faixa de valor fixo: desconta do total e envia so faixaId',
      build: novoBloc,
      seed: () => comOpcoes,
      act: (bloc) =>
          bloc.add(const PagamentosRealizadosResgateEscolhido(faixaId: 1)),
      verify: (bloc) {
        expect(bloc.state.valorDescontoResgate, 10);
        expect(bloc.state.valorTotalAPagar, 189);
        expect(bloc.state.valorDescontoAplicado, 0);
        expect(bloc.state.resgatePayload, {'faixaId': 1});
      },
    );

    blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
      'faixa nao cumulativa com desconto por item: bloqueada',
      build: novoBloc,
      seed: () => comOpcoes.copyWith(descontosItensAplicado: {9: 99}),
      act: (bloc) =>
          bloc.add(const PagamentosRealizadosResgateEscolhido(faixaId: 2)),
      verify: (bloc) {
        expect(bloc.state.resgateFaixaId, isNull);
        expect(bloc.state.erro, contains('Não cumulativo'));
      },
    );

    blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
      'faixa percentual sem outros descontos: 10% de 199',
      build: novoBloc,
      seed: () => comOpcoes,
      act: (bloc) =>
          bloc.add(const PagamentosRealizadosResgateEscolhido(faixaId: 2)),
      verify: (bloc) {
        expect(bloc.state.valorDescontoResgate, 19.9);
        expect(bloc.state.valorTotalAPagar, closeTo(179.1, 0.001));
      },
    );

    blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
      'aplica pontos livres: pontos x valorPorPonto, envia so pontos',
      build: novoBloc,
      seed: () => comOpcoes,
      act: (bloc) =>
          bloc.add(const PagamentosRealizadosResgateEscolhido(pontos: 30)),
      verify: (bloc) {
        expect(bloc.state.valorDescontoResgate, 3);
        expect(bloc.state.resgatePayload, {'pontos': 30});
        expect(bloc.state.resgateFaixaId, isNull);
      },
    );

    blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
      'rejeita pontos acima do saldo e faixa indisponivel',
      build: novoBloc,
      seed: () => comOpcoes,
      act: (bloc) async {
        bloc.add(const PagamentosRealizadosResgateEscolhido(pontos: 101));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const PagamentosRealizadosResgateEscolhido(faixaId: 3));
      },
      verify: (bloc) {
        expect(bloc.state.possuiResgate, isFalse);
        expect(bloc.state.erro, contains('Faltam 400 pontos'));
      },
    );

    blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
      'nao cumulativo com outro desconto presente: bloqueia o resgate',
      build: novoBloc,
      seed: () => comOpcoes.copyWith(valorDescontoAplicado: 5),
      act: (bloc) =>
          bloc.add(const PagamentosRealizadosResgateEscolhido(pontos: 30)),
      verify: (bloc) {
        expect(bloc.state.possuiResgate, isFalse);
        expect(bloc.state.erro, contains('Não cumulativo'));
      },
    );

    blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
      'resgate nao cumulativo ativo bloqueia desconto manual e cupom',
      build: novoBloc,
      seed: () => comOpcoes.copyWith(resgatePontos: 30),
      act: (bloc) async {
        bloc.add(
          const PagamentosRealizadosDescontoAlterado(
            tipo: DescontoTipo.valorBruto,
            valorTexto: '10',
          ),
        );
        await Future<void>.delayed(Duration.zero);
        bloc.add(const PagamentosRealizadosCupomInformado(codigo: 'X'));
      },
      verify: (bloc) {
        expect(bloc.state.valorDescontoAplicado, 0);
        expect(bloc.state.resgatePontos, 30);
        expect(bloc.state.cupomErro, contains('não pode ser somado'));
      },
    );

    blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
      'resgate cumulativo convive com desconto manual',
      build: novoBloc,
      seed: () => comOpcoes.copyWith(resgateFaixaId: 1),
      act: (bloc) => bloc.add(
        const PagamentosRealizadosDescontoAlterado(
          tipo: DescontoTipo.valorBruto,
          valorTexto: '10',
        ),
      ),
      verify: (bloc) {
        expect(bloc.state.valorDescontoAplicado, 10);
        expect(bloc.state.valorTotalAPagar, 179);
      },
    );

    blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
      'remove o resgate',
      build: novoBloc,
      seed: () => comOpcoes.copyWith(resgateFaixaId: 1),
      act: (bloc) => bloc.add(const PagamentosRealizadosResgateEscolhido()),
      verify: (bloc) {
        expect(bloc.state.possuiResgate, isFalse);
        expect(bloc.state.resgatePayload, isNull);
        expect(bloc.state.valorTotalAPagar, 199);
      },
    );
  });
}
