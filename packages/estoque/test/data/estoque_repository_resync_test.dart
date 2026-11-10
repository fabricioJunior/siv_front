import 'package:core/paginacao.dart';
import 'package:estoque/data/repositorios/estoque_repository.dart';
import 'package:estoque/domain/data/datasourcers/i_produtos_estoque_local_datasource.dart';
import 'package:estoque/estoque.dart';
import 'package:flutter_test/flutter_test.dart';

class _Paginacoes implements IPaginacaoDataSource {
  final mapa = <String, Paginacao>{};
  @override
  Future<Paginacao?> buscarPaginacao(String key) async => mapa[key];
  @override
  Future<void> salvarPaginacao(Paginacao p) async => mapa[p.key] = p;
  @override
  Future<void> limparTudo() async => mapa.clear();
}

class _Local implements IProdutoEstoqueLocalDataSource {
  int limpezas = 0;
  @override
  Future<void> excluirTodosProdutos() async => limpezas++;
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Remoto implements IEstoqueSaldoRemoteDataSource {
  final filtros = <FiltroProdutoDoEstoque>[];
  @override
  Future<SaldoDoEstoque> obterSaldo({required FiltroProdutoDoEstoque filtro}) async {
    filtros.add(filtro);
    return const SaldoDoEstoque(
      meta: PaginacaoDoEstoque(
        totalItems: 0,
        itemCount: 0,
        itemsPerPage: 1000,
        totalPages: 0,
        currentPage: 0,
      ),
      items: [],
    );
  }
}

void main() {
  test('cadastro local desatualizado: limpa produtos, zera cursor e sincroniza completo uma vez',
      () async {
    final pag = _Paginacoes();
    final local = _Local();
    final remoto = _Remoto();
    // sync incremental já concluída na versão antiga
    pag.mapa['estoque_sync'] = Paginacao(
      key: 'estoque_sync',
      paginaAtual: 3,
      totalPaginas: 3,
      itensPorPagina: 1000,
      totalItens: 3000,
      dataAtualizacao: DateTime.utc(2026, 11, 1),
      ended: true,
    );
    final repo = EstoqueRepository(
      estoqueSaldoRemoteDataSource: remoto,
      produtosEstoqueLocalDataSource: local,
      paginacaoDataSource: pag,
    );

    await repo.syncEstoque().toList();
    expect(local.limpezas, 1);
    expect(remoto.filtros.single.ultimaAtualizacaoInicio, isNull); // completo, não incremental
    expect(remoto.filtros.single.page, 0);
    expect(pag.mapa['estoque_cadastro_versao']?.paginaAtual, versaoCadastroLocalEstoque);

    // 2ª sync: marcador em dia, incremental, sem nova limpeza
    await repo.syncEstoque().toList();
    expect(local.limpezas, 1);
    expect(remoto.filtros.last.ultimaAtualizacaoInicio, isNotNull);
  });
}
