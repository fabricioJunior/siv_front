import 'package:core/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:produtos/domain/data/repositorios/i_grade_da_referencia_repository.dart';
import 'package:produtos/domain/data/repositorios/i_produtos_repository.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';
import 'package:produtos/use_cases.dart';

class _DummyGradeRepo implements IGradeDaReferenciaRepository {
  @override
  Future<GradeDaReferencia> obterGrade({
    required int referenciaId,
    int? tabelaDePrecoId,
  }) => throw UnimplementedError();
}

class _FakeRecuperarGradeDaReferencia extends RecuperarGradeDaReferencia {
  final List<GradeDaReferencia> respostas;
  int indice = 0;

  _FakeRecuperarGradeDaReferencia(this.respostas)
    : super(gradeDaReferenciaRepository: _DummyGradeRepo());

  @override
  Future<GradeDaReferencia> call({
    required int referenciaId,
    int? tabelaDePrecoId,
  }) async {
    final resposta = respostas[indice.clamp(0, respostas.length - 1)];
    indice++;
    return resposta;
  }
}

class _DummyProdutosRepo implements IProdutosRepository {
  @override
  Future<Produto> criarProduto({
    required int referenciaId,
    String? idExterno,
    required int corId,
    required int tamanhoId,
    int? estampaId,
  }) => throw UnimplementedError();

  @override
  Future<List<Produto>> criarProdutos(List<NovoProdutoCombinacao> itens) =>
      throw UnimplementedError();

  @override
  Future<Produto> atualizarProduto({
    required int id,
    required int referenciaId,
    required String idExterno,
    required int corId,
    required int tamanhoId,
    int? estampaId,
  }) => throw UnimplementedError();

  @override
  Future<void> excluirProduto(int id) => throw UnimplementedError();

  @override
  Future<ExclusaoProdutosEmLoteResultado> excluirProdutosEmLote(
    List<int> ids,
  ) => throw UnimplementedError();

  @override
  Future<List<Produto>> obterProdutos({
    String? idExterno,
    int? referenciaId,
    int idCor = 0,
    int idTamanho = 0,
    int? idEstampa,
  }) => throw UnimplementedError();
}

class _FakeCriarProdutosEmLote extends CriarProdutosEmLote {
  List<NovoProdutoCombinacao>? ultimaChamada;

  _FakeCriarProdutosEmLote() : super(produtosRepository: _DummyProdutosRepo());

  @override
  Future<List<Produto>> call(List<NovoProdutoCombinacao> itens) async {
    ultimaChamada = itens;
    return itens
        .map(
          (item) => Produto.create(
            referenciaId: item.referenciaId,
            idExterno: '',
            corId: item.corId,
            tamanhoId: item.tamanhoId,
            estampaId: item.estampaId,
          ),
        )
        .toList();
  }
}

ProdutoDaGrade _produtoDaGrade({
  required int produtoId,
  required int corId,
  required String corNome,
  required int tamanhoId,
  required String tamanhoNome,
  int? estampaId,
  String? estampaNome,
}) {
  return ProdutoDaGrade(
    produtoId: produtoId,
    corId: corId,
    corNome: corNome,
    tamanhoId: tamanhoId,
    tamanhoNome: tamanhoNome,
    estampaId: estampaId,
    estampaNome: estampaNome,
    codigosBarras: ['123456789012$produtoId'],
    saldo: 0,
  );
}

GradeDaReferencia _grade(List<ProdutoDaGrade> produtos) {
  return GradeDaReferencia(
    referenciaId: 1,
    nome: 'Referência teste',
    totalEmEstoque: 0,
    produtos: produtos,
  );
}

void main() {
  group('ProdutosDaReferenciaBloc -', () {
    // Preto/P, Azul/P e Azul/M existem; Preto/M é o único faltante.
    final gradeInicial = _grade([
      _produtoDaGrade(
        produtoId: 1,
        corId: 1,
        corNome: 'Preto',
        tamanhoId: 1,
        tamanhoNome: 'P',
      ),
      _produtoDaGrade(
        produtoId: 2,
        corId: 2,
        corNome: 'Azul',
        tamanhoId: 1,
        tamanhoNome: 'P',
      ),
      _produtoDaGrade(
        produtoId: 3,
        corId: 2,
        corNome: 'Azul',
        tamanhoId: 2,
        tamanhoNome: 'M',
      ),
    ]);

    blocTest<ProdutosDaReferenciaBloc, ProdutosDaReferenciaState>(
      'calcula faltantes e contadores da grade ao carregar',
      build: () => ProdutosDaReferenciaBloc(
        _FakeRecuperarGradeDaReferencia([gradeInicial]),
        _FakeCriarProdutosEmLote(),
        CriarCodigoDeBarras(),
      ),
      act: (bloc) => bloc.add(ProdutosDaReferenciaIniciou(referenciaId: 1)),
      verify: (bloc) {
        final state = bloc.state;
        expect(state.step, ProdutosDaReferenciaStep.sucesso);
        expect(state.totalCombinacoesDaGrade, 4); // 2 cores x 2 tamanhos
        expect(state.totalCombinacoesComProduto, 3);
        expect(state.todosOsFaltantes, [
          const ComboDeGrade(corId: 1, tamanhoId: 2, estampaId: null),
        ]);
      },
    );

    blocTest<ProdutosDaReferenciaBloc, ProdutosDaReferenciaState>(
      'cria combinações faltantes e recarrega a grade sem precisar de reload manual',
      build: () {
        final gradeAtualizada = _grade([
          ...gradeInicial.produtos,
          _produtoDaGrade(
            produtoId: 4,
            corId: 1,
            corNome: 'Preto',
            tamanhoId: 2,
            tamanhoNome: 'M',
          ),
        ]);
        return ProdutosDaReferenciaBloc(
          _FakeRecuperarGradeDaReferencia([gradeInicial, gradeAtualizada]),
          _FakeCriarProdutosEmLote(),
          CriarCodigoDeBarras(),
        );
      },
      act: (bloc) async {
        bloc.add(ProdutosDaReferenciaIniciou(referenciaId: 1));
        await Future<void>.delayed(Duration.zero);
        bloc.add(
          ProdutosDaReferenciaCriouCombinacoes(
            combinacoes: const [
              ComboDeGrade(corId: 1, tamanhoId: 2, estampaId: null),
            ],
          ),
        );
      },
      wait: const Duration(milliseconds: 10),
      verify: (bloc) {
        expect(bloc.state.step, ProdutosDaReferenciaStep.sucesso);
        expect(bloc.state.totalCombinacoesComProduto, 4);
        expect(bloc.state.todosOsFaltantes, isEmpty);
      },
    );
  });
}
