import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc_test.dart';
import 'package:core/leitor.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/sessao.dart';
import 'package:empresas/models.dart';
import 'package:empresas/use_cases.dart';
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

class _StubVerificarElegibilidadeFidelidade
    implements VerificarElegibilidadeFidelidade {
  @override
  Future<bool> call({required int pessoaId}) async =>
      throw UnimplementedError();
}

class _StubRecuperarConfiguracaoNotaFiscalEmail
    implements RecuperarConfiguracaoNotaFiscalEmail {
  @override
  Future<EmpresaNotaFiscalEmail> call(int empresaId) async =>
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

void main() {
  blocTest<PagamentosRealizadosBloc, PagamentosRealizadosState>(
    'auto-aplica promocao por produto, mesmo com multiplas promocoes '
    'distintas no carrinho, e nao auto-aplica em produto com conflito',
    build: () => PagamentosRealizadosBloc(
      _StubCarregarResumo(),
      _StubBuscarSaldoCreditoDevolucao(),
      _StubVerificarElegibilidadeFidelidade(),
      _StubRecuperarConfiguracaoNotaFiscalEmail(),
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
