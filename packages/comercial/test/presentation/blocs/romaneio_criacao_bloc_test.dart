import 'package:comercial/data.dart';
import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc_test.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/sessao.dart';
import 'package:financeiro/data.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

class StubCaixaRepository implements ICaixaRepository {
  @override
  Future<Caixa> abrirCaixa({
    required int idEmpresa,
    required int terminalId,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Caixa?> recuperarCaixaAberto({
    required int idEmpresa,
    required int terminalId,
  }) async =>
      null;

  @override
  Future<List<ExtratoCaixa>> buscarExtratoCaixa({required int caixaId}) async =>
      const [];

  @override
  Future<List<ExtratoCaixa>> buscarExtratoCaixaPorDocumento({
    required int caixaId,
    required String documento,
  }) async =>
      const [];
}

class StubIntegracaoFiscalRepository implements IIntegracaoFiscalRepository {
  @override
  Future<List<String>> listarProviders() async => const [];

  @override
  Future<EmpresaIntegracaoFiscal?> getConfiguracao() async => null;

  @override
  Future<EmpresaIntegracaoFiscal> salvarConfiguracao({
    required String provider,
    required bool ativo,
    Map<String, dynamic>? configuracao,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> listarDocumentos({
    int? romaneioId,
    int? pedidoId,
    String? cliente,
    String? status,
    String? formaPagamento,
    DateTime? dataInicio,
    DateTime? dataFim,
    int page = 1,
    int limit = 25,
  }) async =>
      {'items': const <DocumentoFiscal>[]};

  @override
  Future<DocumentoFiscal> reprocessar(int id) async => throw UnimplementedError();

  @override
  Future<DocumentoFiscalDetalhe> getDetalhe(int id) async =>
      throw UnimplementedError();
}

class StubCriarRomaneio implements CriarRomaneio {
  final Future<Romaneio> Function(Romaneio romaneio) onCall;

  StubCriarRomaneio(this.onCall);

  @override
  Future<Romaneio> call(Romaneio romaneio) => onCall(romaneio);
}

class StubAdicionarItemRomaneio implements AdicionarItemRomaneio {
  final Future<void> Function(
      {required int romaneioId, required RomaneioItem item}) onCall;

  StubAdicionarItemRomaneio(this.onCall);

  @override
  Future<void> call({required int romaneioId, required RomaneioItem item}) {
    return onCall(romaneioId: romaneioId, item: item);
  }
}

class StubRecuperarRomaneio implements RecuperarRomaneio {
  final Future<Romaneio> Function(int id) onCall;

  StubRecuperarRomaneio(this.onCall);

  @override
  Future<Romaneio> call(int id) => onCall(id);
}

class StubRecuperarListaDeProdutosCompartilhada
    implements RecuperarListaDeProdutosCompartilhada {
  final Future<ListaDeProdutosCompartilhada?> Function(String hash) onCall;
  final Future<List<ProdutoCompartilhado>> Function(String hashLista)
      onRecuperarProdutos;

  StubRecuperarListaDeProdutosCompartilhada({
    required this.onCall,
    required this.onRecuperarProdutos,
  });

  @override
  Future<ListaDeProdutosCompartilhada?> call(String hash) => onCall(hash);

  @override
  Future<Iterable<ListaDeProdutosCompartilhada>> recuperarListas({
    int? idLista,
    OrigemCompartilhadaTipo? origem,
  }) async {
    return const [];
  }

  @override
  Future<List<ProdutoCompartilhado>> recuperarProdutos(String hashLista) {
    return onRecuperarProdutos(hashLista);
  }
}

class StubRemoverListaDeProdutosCompartilhada
    implements RemoverListaDeProdutosCompartilhada {
  final Future<void> Function(String hash) onCall;

  StubRemoverListaDeProdutosCompartilhada(this.onCall);

  @override
  Future<void> call(String hash) => onCall(hash);
}

class StubRemoverProdutoCompartilhado implements RemoverProdutoCompartilhado {
  final Future<void> Function(String produtoHash) onCall;

  StubRemoverProdutoCompartilhado(this.onCall);

  @override
  Future<void> call(String produtoHash) => onCall(produtoHash);
}

class StubAtualizarListaCompartilhada implements AtualizarListaCompartilhada {
  final Future<void> Function(ListaDeProdutosCompartilhada lista) onCall;

  StubAtualizarListaCompartilhada(this.onCall);

  @override
  Future<void> call(ListaDeProdutosCompartilhada lista) => onCall(lista);
}

class StubReceberRomaneioNoCaixa implements ReceberRomaneioNoCaixa {
  final Future<void> Function({
    required int caixaId,
    required int romaneioId,
    required List<RomaneioPagamentoRealizado> formasDePagamentoRealizadas,
  }) onCall;

  StubReceberRomaneioNoCaixa(this.onCall);

  @override
  Future<void> call({
    required int caixaId,
    required int romaneioId,
    required List<RomaneioPagamentoRealizado> formasDePagamentoRealizadas,
    double? desconto,
    double? valorTaxaEntrega,
    List<Map<String, dynamic>> descontosItens = const [],
    bool incluirCpfNaNota = true,
    String cpfNaNota = '',
    bool pontuarFidelidade = false,
  }) {
    return onCall(
      caixaId: caixaId,
      romaneioId: romaneioId,
      formasDePagamentoRealizadas: formasDePagamentoRealizadas,
    );
  }
}

class FakeAcessoGlobalSessao implements IAcessoGlobalSessao {
  @override
  final int? caixaIdDaSessao;

  const FakeAcessoGlobalSessao({this.caixaIdDaSessao});

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

void main() {
  const hashLista = 'hash-lista';
  final agora = DateTime(2026, 4, 15);
  final listaCompartilhada = ListaDeProdutosCompartilhada(
    hash: hashLista,
    origem: OrigemCompartilhadaTipo.romenioEntradaDeProdutos,
    criadaEm: agora,
    atualizadaEm: agora,
    funcionarioId: 10,
    tabelaPrecoId: 20,
  );
  final produto = ProdutoCompartilhado(
    hash: 'produto-hash',
    produtoId: 1,
    hashLista: hashLista,
    quantidade: 2,
    valorUnitario: 10,
    nome: 'Produto teste',
    corNome: 'Azul',
    tamanhoNome: 'M',
  );
  final romaneioCriado = Romaneio.create(
    id: 123,
    funcionarioId: 10,
    tabelaPrecoId: 20,
    operacao: TipoOperacao.transferencia_entrada,
  );

  blocTest<RomaneioCriacaoBloc, RomaneioCriacaoState>(
    'informa claramente quando o romaneio foi criado, mas falhou ao receber no caixa',
    build: () => RomaneioCriacaoBloc(
      StubCriarRomaneio((_) async => romaneioCriado),
      StubAdicionarItemRomaneio(
          ({required romaneioId, required item}) async {}),
      StubRecuperarRomaneio((_) async => romaneioCriado),
      StubRecuperarListaDeProdutosCompartilhada(
        onCall: (_) async => listaCompartilhada,
        onRecuperarProdutos: (_) async => [produto],
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
          throw Exception('erro ao receber no caixa');
        },
      ),
      const FakeAcessoGlobalSessao(caixaIdDaSessao: 999),
      RecuperarCaixaAberto(repository: StubCaixaRepository()),
      ListarDocumentosFiscais(repository: StubIntegracaoFiscalRepository()),
    ),
    act: (bloc) =>
        bloc.add(
          const RomaneioCriacaoSolicitada(
            hashLista: hashLista,
            formasDePagamentoRealizadas: const [],
          ),
        ),
    expect: () => [
      isA<RomaneioCriacaoState>().having(
        (state) => state.step,
        'step',
        RomaneioCriacaoStep.processando,
      ),
      isA<RomaneioCriacaoState>()
          .having(
            (state) => state.step,
            'step',
            RomaneioCriacaoStep.processando,
          )
          .having((state) => state.totalItensProcessados, 'itens', 1),
      isA<RomaneioCriacaoState>()
          .having(
            (state) => state.step,
            'step',
            RomaneioCriacaoStep.falha,
          )
          .having(
            (state) => state.listaCompartilhada?.idLista,
            'romaneioId',
            123,
          )
          .having(
            (state) => state.erro,
            'erro',
            contains('foi criado'),
          )
          .having(
            (state) => state.erro,
            'orientacao',
            contains('conclua o processo manualmente'),
          ),
    ],
  );

  group('consignação', () {
    final listaConsignacaoSaida = ListaDeProdutosCompartilhada(
      hash: hashLista,
      origem: OrigemCompartilhadaTipo.consignacaoSaida,
      criadaEm: agora,
      atualizadaEm: agora,
      pessoaId: 5,
      funcionarioId: 10,
      tabelaPrecoId: 20,
    );

    blocTest<RomaneioCriacaoBloc, RomaneioCriacaoState>(
      'cria romaneio de consignacao_saida com consignacaoId e não tenta receber no caixa',
      build: () => RomaneioCriacaoBloc(
        StubCriarRomaneio((romaneio) async {
          expect(romaneio.operacao, TipoOperacao.consignacao_saida);
          expect(romaneio.consignacaoId, 77);
          return Romaneio.create(
            id: 456,
            funcionarioId: 10,
            tabelaPrecoId: 20,
            operacao: TipoOperacao.consignacao_saida,
            consignacaoId: 77,
          );
        }),
        StubAdicionarItemRomaneio(
            ({required romaneioId, required item}) async {}),
        StubRecuperarRomaneio((_) async => Romaneio.create(
              id: 456,
              funcionarioId: 10,
              tabelaPrecoId: 20,
              operacao: TipoOperacao.consignacao_saida,
              consignacaoId: 77,
            )),
        StubRecuperarListaDeProdutosCompartilhada(
          onCall: (_) async => listaConsignacaoSaida,
          onRecuperarProdutos: (_) async => [produto],
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
            fail('consignação não deve receber no caixa automaticamente');
          },
        ),
        const FakeAcessoGlobalSessao(caixaIdDaSessao: 999),
        RecuperarCaixaAberto(repository: StubCaixaRepository()),
        ListarDocumentosFiscais(repository: StubIntegracaoFiscalRepository()),
      ),
      act: (bloc) => bloc.add(
        const RomaneioCriacaoSolicitada(
          hashLista: hashLista,
          consignacaoId: 77,
        ),
      ),
      expect: () => [
        isA<RomaneioCriacaoState>().having(
          (state) => state.step,
          'step',
          RomaneioCriacaoStep.processando,
        ),
        isA<RomaneioCriacaoState>()
            .having(
              (state) => state.step,
              'step',
              RomaneioCriacaoStep.processando,
            )
            .having((state) => state.totalItensProcessados, 'itens', 1),
        isA<RomaneioCriacaoState>()
            .having(
              (state) => state.step,
              'step',
              RomaneioCriacaoStep.sucesso,
            )
            .having(
              (state) => state.romaneio?.operacao,
              'operacao',
              TipoOperacao.consignacao_saida,
            ),
      ],
    );
  });
}
