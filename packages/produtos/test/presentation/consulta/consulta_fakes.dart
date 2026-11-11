export 'package:produtos/models.dart';
export 'package:produtos/presentation.dart';
import 'package:produtos/domain/data/repositorios/i_consulta_referencias_repository.dart';
import 'package:produtos/domain/data/repositorios/i_grade_da_referencia_repository.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';
import 'package:produtos/use_cases.dart';

const var1 = ConsultaVariacao(
  produtoId: 11, corId: 1, corNome: 'Azul', tamanhoId: 1, tamanhoNome: 'P',
  estampaId: null, saldo: 3, bateFiltro: true,
);
const var2 = ConsultaVariacao(
  produtoId: 12, corId: 1, corNome: 'Azul', tamanhoId: 2, tamanhoNome: 'M',
  estampaId: 7, estampaNome: 'Floral', saldo: 5, bateFiltro: true,
);

const itemA = ConsultaReferenciaItem(
  referenciaId: 100, idExterno: 'A1', nome: 'Calça Jeans', preco: 99.9,
  saldoFiltrado: 8, variacoes: [var1, var2],
);
const itemB = ConsultaReferenciaItem(
  referenciaId: 200, idExterno: 'B2', nome: 'Blusa', saldoFiltrado: 2, variacoes: [var1],
);

class FakeConsultaRepo implements IConsultaReferenciasRepository {
  final List<Map<String, Object?>> chamadas = [];
  ConsultaReferenciasPagina Function(String? busca, int page) resposta =
      (busca, page) => const ConsultaReferenciasPagina(items: [itemA, itemB]);

  @override
  Future<ConsultaReferenciasPagina> consultar({
    String? busca,
    List<int> corIds = const [],
    List<int> tamanhoIds = const [],
    List<int> estampaIds = const [],
    int? tabelaPrecoId,
    int page = 1,
    int limit = 30,
  }) async {
    chamadas.add({'busca': busca, 'corIds': corIds, 'estampaIds': estampaIds, 'page': page, 'limit': limit});
    return resposta(busca, page);
  }
}

class FakeGradeRepo implements IGradeDaReferenciaRepository {
  int chamadas = 0;

  @override
  Future<GradeDaReferencia> obterGrade({required int referenciaId, int? tabelaDePrecoId}) async {
    chamadas++;
    return GradeDaReferencia(
      referenciaId: referenciaId,
      referenciaIdExterno: 'A1',
      nome: 'Calça Jeans',
      valor: 99.9,
      totalEmEstoque: 8,
      produtos: const [
        ProdutoDaGrade(produtoId: 11, corId: 1, corNome: 'Azul', tamanhoId: 1, tamanhoNome: 'P', codigosBarras: [], saldo: 3),
        ProdutoDaGrade(produtoId: 12, corId: 1, corNome: 'Azul', tamanhoId: 2, tamanhoNome: 'M', estampaId: 7, estampaNome: 'Floral', codigosBarras: [], saldo: 5),
      ],
    );
  }
}

ConsultarProdutoBloc novoBloc(FakeConsultaRepo c, FakeGradeRepo g) => ConsultarProdutoBloc(
  consultarReferencias: ConsultarReferencias(repository: c),
  recuperarGradeDaReferencia: RecuperarGradeDaReferencia(gradeDaReferenciaRepository: g),
  debounce: const Duration(milliseconds: 10),
);

class _Estampa implements Estampa {
  _Estampa(this.id);
  @override
  final int? id;
  @override
  String get nome => 'Floral';
  @override
  bool get inativo => false;
  @override
  List<Object?> get props => [id];
  @override
  bool? get stringify => true;
}

Estampa estampaFake(int id) => _Estampa(id);
