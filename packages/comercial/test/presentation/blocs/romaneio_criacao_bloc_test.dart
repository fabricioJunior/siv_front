import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc_test.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/sessao.dart';
import 'package:flutter_test/flutter_test.dart';

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
  final Future<void> Function({required int caixaId, required int romaneioId})
      onCall;

  StubReceberRomaneioNoCaixa(this.onCall);

  @override
  Future<void> call({required int caixaId, required int romaneioId}) {
    return onCall(caixaId: caixaId, romaneioId: romaneioId);
  }
}

class FakeAcessoGlobalSessao implements IAcessoGlobalSessao {
  @override
  final int? caixaIdDaSessao;

  const FakeAcessoGlobalSessao({this.caixaIdDaSessao});

  @override
  int? get empresaIdDaSessao => null;

  @override
  int? get terminalIdDaSessao => null;

  @override
  String? get terminalNomeDaSessao => null;

  @override
  int? get usuarioIdDaSessao => null;

  @override
  void atualizarCaixaIdDaSessao({required int terminalId, int? caixaId}) {}
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
        ({required caixaId, required romaneioId}) async {
          throw Exception('erro ao receber no caixa');
        },
      ),
      const FakeAcessoGlobalSessao(caixaIdDaSessao: 999),
    ),
    act: (bloc) =>
        bloc.add(const RomaneioCriacaoSolicitada(hashLista: hashLista)),
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
            contains('pendentes'),
          ),
    ],
  );
}
