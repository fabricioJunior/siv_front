import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';
import 'package:estoque/domain/data/repositorios/i_relatorio_estoque_repository.dart';
import 'package:estoque/domain/models/relatorio_giro_estoque.dart';
import 'package:estoque/domain/usecases/get_relatorio_giro_estoque.dart';
import 'package:estoque/domain/usecases/get_resumo_giro_estoque.dart';
import 'package:estoque/domain/usecases/get_variacoes_giro_estoque.dart';
import 'package:estoque/presentation/blocs/relatorio_giro_estoque_bloc/relatorio_giro_estoque_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _Sessao implements IAcessoGlobalSessao {
  @override
  int? get empresaIdDaSessao => 1;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Repositório fake que só registra as chamadas do giro.
class _Repo implements IRelatorioEstoqueRepository {
  final listas = <({AbaGiro aba, int page, String ordenarPor, String ordem})>[];
  int resumos = 0;
  final variacoes = <int>[];

  @override
  Future<PaginaGiroEstoque> giro({
    required List<int> empresaIds,
    required FiltroGiroEstoque filtro,
    required AbaGiro aba,
    required String ordenarPor,
    required String ordem,
    int page = 1,
    int limit = 20,
  }) async {
    listas.add((aba: aba, page: page, ordenarPor: ordenarPor, ordem: ordem));
    return const PaginaGiroEstoque(items: [], meta: GiroEstoqueMeta(totalItems: 0));
  }

  @override
  Future<GiroEstoqueResumo> giroResumo({
    required List<int> empresaIds,
    required FiltroGiroEstoque filtro,
  }) async {
    resumos++;
    return const GiroEstoqueResumo();
  }

  @override
  Future<GiroEstoqueVariacoes> giroVariacoes({
    required int referenciaId,
    required List<int> empresaIds,
    required FiltroGiroEstoque filtro,
  }) async {
    variacoes.add(referenciaId);
    return const GiroEstoqueVariacoes(items: []);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  late _Repo repo;
  late RelatorioGiroEstoqueBloc bloc;

  Future<void> iniciar() async {
    bloc.add(GiroEstoqueIniciou());
    await pumpEventQueue();
    repo.listas.clear();
    repo.resumos = 0;
  }

  setUp(() {
    if (sl.isRegistered<IAcessoGlobalSessao>()) sl.unregister<IAcessoGlobalSessao>();
    sl.registerSingleton<IAcessoGlobalSessao>(_Sessao());
    repo = _Repo();
    bloc = RelatorioGiroEstoqueBloc(
      GetRelatorioGiroEstoque(repository: repo),
      GetResumoGiroEstoque(repository: repo),
      GetVariacoesGiroEstoque(repository: repo),
    );
  });

  tearDown(() => bloc.close());

  test('iniciou carrega resumo e página 1 uma vez cada', () async {
    bloc.add(GiroEstoqueIniciou());
    await pumpEventQueue();
    expect(repo.listas.map((c) => c.page), [1]);
    expect(repo.resumos, 1);
    expect(bloc.state.listaStep, GiroSecaoStep.sucesso);
    expect(bloc.state.resumoStep, GiroSecaoStep.sucesso);
  });

  test('paginar recarrega só a lista', () async {
    await iniciar();
    bloc.add(GiroPaginaAlterada(2));
    await pumpEventQueue();
    expect(repo.listas.map((c) => c.page), [2]);
    expect(repo.resumos, 0);
  });

  test('ordenar alterna asc/desc; trocar de aba restaura a ordem padrão sem resumo', () async {
    await iniciar();
    bloc.add(GiroOrdenacaoAlterada('vendido'));
    await pumpEventQueue();
    expect((bloc.state.ordenarPor, bloc.state.ordem), ('vendido', 'desc'));
    bloc.add(GiroOrdenacaoAlterada('vendido'));
    await pumpEventQueue();
    expect(bloc.state.ordem, 'asc');

    bloc.add(GiroAbaAlterada(AbaGiro.reposicao));
    await pumpEventQueue();
    expect((bloc.state.ordenarPor, bloc.state.ordem), ('diasParaEsgotar', 'asc'));
    expect(repo.listas.last.aba, AbaGiro.reposicao);
    expect(repo.resumos, 0);
  });

  test('filtro e período recarregam resumo + página 1', () async {
    await iniciar();
    bloc.add(GiroPaginaAlterada(3));
    await pumpEventQueue();
    repo.listas.clear();

    bloc.add(GiroFiltroAlterado(const FiltroGiroEstoque(busca: 'sutiã')));
    await pumpEventQueue();
    expect(repo.listas.map((c) => c.page), [1]);
    expect(repo.resumos, 1);

    bloc.add(GiroPeriodoAlterado(PeriodoGiro.noventa));
    await pumpEventQueue();
    expect(repo.resumos, 2);
    expect(bloc.state.filtro.periodo, PeriodoGiro.noventa);
  });

  test('classificação do painel filtra só a lista, na aba ranking', () async {
    await iniciar();
    bloc.add(GiroAbaAlterada(AbaGiro.parado));
    await pumpEventQueue();
    repo.listas.clear();

    bloc.add(GiroClassificacaoSelecionada(ClassificacaoGiro.lento));
    await pumpEventQueue();
    expect(bloc.state.aba, AbaGiro.ranking);
    expect(bloc.state.filtro.classificacoes, {ClassificacaoGiro.lento});
    expect(repo.listas.map((c) => c.aba), [AbaGiro.ranking]);
    expect(repo.resumos, 0);

    bloc.add(GiroClassificacaoSelecionada(ClassificacaoGiro.lento));
    await pumpEventQueue();
    expect(bloc.state.filtro.classificacoes, isEmpty);
  });

  test('variações são buscadas uma vez por referência (cache)', () async {
    await iniciar();
    bloc.add(GiroLinhaExpandida(7));
    await pumpEventQueue();
    expect(bloc.state.abertos, {7});
    bloc.add(GiroLinhaExpandida(7)); // fecha
    await pumpEventQueue();
    bloc.add(GiroLinhaExpandida(7)); // abre de novo
    await pumpEventQueue();
    expect(repo.variacoes, [7]);
    expect(bloc.state.variacoes.containsKey(7), isTrue);
  });

  test('mudar o filtro limpa o cache de variações', () async {
    await iniciar();
    bloc.add(GiroLinhaExpandida(7));
    await pumpEventQueue();
    bloc.add(GiroFiltroAlterado(const FiltroGiroEstoque(busca: 'x')));
    await pumpEventQueue();
    expect(bloc.state.variacoes, isEmpty);
    expect(bloc.state.abertos, isEmpty);
  });
}
