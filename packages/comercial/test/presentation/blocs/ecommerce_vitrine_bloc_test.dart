import 'package:comercial/domain/data/repositories/i_ecommerce_vitrine_repository.dart';
import 'package:comercial/domain/data/repositories/i_lista_personalizada_repository.dart';
import 'package:comercial/domain/data/repositories/i_listas_grupos_repository.dart';
import 'package:comercial/domain/models/ecommerce_vitrine.dart';
import 'package:comercial/domain/models/lista_grupo.dart';
import 'package:comercial/domain/models/lista_personalizada.dart';
import 'package:comercial/domain/models/lista_personalizada_resumo.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

class _VitrineRepo implements IEcommerceVitrineRepository {
  final salvos = <(VitrineLocal, List<EcommerceVitrineItem>)>[];
  bool falhar = false;

  @override
  Future<EcommerceVitrine> recuperar(int ecommerceId) async =>
      const EcommerceVitrine(
        menu: [
          EcommerceVitrineItem(
              tipo: VitrineItemTipo.lista, itemId: 1, ordem: 0, nome: 'A'),
        ],
      );

  @override
  Future<void> salvar(
          int id, VitrineLocal local, List<EcommerceVitrineItem> itens) async =>
      falhar ? throw Exception('x') : salvos.add((local, itens));
}

class _ListasRepo implements IListaPersonalizadaRepository {
  final paginasPedidas = <int>[];

  /// Listas criadas depois que a aba já abriu (ex.: pela aba Catálogo).
  final extras = <ListaPersonalizadaResumo>[];

  ListaPersonalizadaResumo _l(int id, String nome) => ListaPersonalizadaResumo(
        id: id,
        hash: 'h$id',
        situacao: ListaPersonalizadaSituacao.ativa,
        quantidadeItens: 0,
        criadoEm: DateTime(2026),
        titulo: nome,
        tipo: ListaTipo.catalogo,
      );

  // Duas páginas: [A, B] e [C].
  @override
  Future<PaginaListasPersonalizadas> listar(
      {int page = 1, int limit = 20, ListaTipo? tipo}) async {
    paginasPedidas.add(page);
    return PaginaListasPersonalizadas(
      meta: MetaListasPersonalizadas(
        totalItems: 3,
        itemCount: page == 1 ? 2 : 1,
        itemsPerPage: 2,
        totalPages: 2,
        currentPage: page,
      ),
      items: page == 1 ? [_l(1, 'A'), _l(2, 'B')] : [_l(3, 'C'), ...extras],
    );
  }

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// Grupo 7 ("Grupo") contém a lista 1; a listagem vem sem as listas, o detalhe
/// com elas.
class _GruposRepo implements IListasGruposRepository {
  @override
  Future<PaginaListasGrupos> listar({int page = 1, int limit = 20}) async =>
      const PaginaListasGrupos(items: [ListaGrupo(id: 7, nome: 'Grupo')]);

  @override
  Future<ListaGrupo> buscarPorId(int id) async => const ListaGrupo(
        id: 7,
        nome: 'Grupo',
        listas: [ListaGrupoLista(listaId: 1, nome: 'A')],
      );

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Future<(EcommerceVitrineBloc, _VitrineRepo)> _pronto() async {
  final repo = _VitrineRepo();
  final grupos = _GruposRepo();
  final bloc = EcommerceVitrineBloc(
    RecuperarVitrineEcommerce(repository: repo),
    SalvarVitrineEcommerce(repository: repo),
    ListarListasPersonalizadas(repository: _ListasRepo()),
    ListarListasGrupos(repository: grupos),
    RecuperarListaGrupo(repository: grupos),
  );
  bloc.add(const EcommerceVitrineIniciou(ecommerceId: 9));
  await bloc.stream.firstWhere((s) => s.step == EcommerceVitrineStep.pronto);
  return (bloc, repo);
}

List<String> _nomes(EcommerceVitrineBloc b, VitrineLocal l) =>
    b.state.vitrine.doLocal(l).map((i) => '${i.ordem}:${i.nome}').toList();

Future<void> _add(
    EcommerceVitrineBloc b, VitrineLocal l, List<int> listaIds) async {
  b.add(EcommerceVitrineItensAdicionou(
    local: l,
    itens: [
      for (final id in listaIds) VitrineItemRef(VitrineItemTipo.lista, id)
    ],
  ));
  await Future<void>.delayed(Duration.zero);
}

Future<void> _mover(EcommerceVitrineBloc b, int id, int indice,
    [VitrineLocal l = VitrineLocal.menu]) async {
  b.add(EcommerceVitrineItemMoveu(
    local: l,
    tipo: VitrineItemTipo.lista,
    itemId: id,
    indice: indice,
  ));
  await Future<void>.delayed(Duration.zero);
}

void main() {
  test('carrega todas as páginas de listas', () async {
    final (bloc, _) = await _pronto();
    expect(bloc.state.listas.map((l) => l.id), [1, 2, 3]);
    await bloc.close();
  });

  test('adicionar várias de uma vez entra no fim, na ordem, sem repetir',
      () async {
    final (bloc, _) = await _pronto();
    await _add(bloc, VitrineLocal.menu, [3, 2, 1]);
    expect(_nomes(bloc, VitrineLocal.menu), ['0:A', '1:C', '2:B']);
    await bloc.close();
  });

  test('mover por índice: limites 1 e N, e fora da faixa vira o limite',
      () async {
    final (bloc, _) = await _pronto();
    await _add(bloc, VitrineLocal.menu, [2, 3]);
    expect(_nomes(bloc, VitrineLocal.menu), ['0:A', '1:B', '2:C']);

    await _mover(bloc, 3, 0); // posição 1
    expect(_nomes(bloc, VitrineLocal.menu), ['0:C', '1:A', '2:B']);

    await _mover(bloc, 3, 2); // posição N
    expect(_nomes(bloc, VitrineLocal.menu), ['0:A', '1:B', '2:C']);

    await _mover(bloc, 3, 99);
    expect(_nomes(bloc, VitrineLocal.menu), ['0:A', '1:B', '2:C']);
    await _mover(bloc, 3, -5);
    expect(_nomes(bloc, VitrineLocal.menu), ['0:C', '1:A', '2:B']);
    await bloc.close();
  });

  test('arrastar (mover para o índice do destino) renumera 0..n-1', () async {
    final (bloc, _) = await _pronto();
    await _add(bloc, VitrineLocal.menu, [2, 3]);
    await _mover(bloc, 1, 1); // A desce uma casa
    expect(_nomes(bloc, VitrineLocal.menu), ['0:B', '1:A', '2:C']);
    await bloc.close();
  });

  test('remover renumera e conta como alteração', () async {
    final (bloc, _) = await _pronto();
    await _add(bloc, VitrineLocal.menu, [2]);
    bloc.add(const EcommerceVitrineItemRemoveu(
      local: VitrineLocal.menu,
      tipo: VitrineItemTipo.lista,
      itemId: 1,
    ));
    await Future<void>.delayed(Duration.zero);
    expect(_nomes(bloc, VitrineLocal.menu), ['0:B']);
    await bloc.close();
  });

  test(
      'contador de pendentes soma posições diferentes do publicado em Menu e Home',
      () async {
    final (bloc, _) = await _pronto();
    expect(bloc.state.alteracoesPendentes, 0);

    await _add(bloc, VitrineLocal.menu, [2]);
    expect(bloc.state.alteracoesPendentes, 1);

    await _add(bloc, VitrineLocal.home, [1, 3]);
    expect(bloc.state.alteracoesPendentes, 3);

    await _mover(
        bloc, 2, 0); // menu vira [B, A]: 2 posições diferentes do publicado [A]
    expect(bloc.state.alteracoesPendentes, 4);
    await bloc.close();
  });

  test('home só aceita lista; menu aceita grupo', () async {
    final (bloc, _) = await _pronto();
    bloc.add(const EcommerceVitrineItemAdicionou(
      local: VitrineLocal.home,
      tipo: VitrineItemTipo.grupo,
      itemId: 7,
    ));
    bloc.add(const EcommerceVitrineItensAdicionou(
      local: VitrineLocal.home,
      itens: [VitrineItemRef(VitrineItemTipo.grupo, 7)],
    ));
    bloc.add(const EcommerceVitrineItemAdicionou(
      local: VitrineLocal.menu,
      tipo: VitrineItemTipo.grupo,
      itemId: 7,
    ));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.vitrine.home, isEmpty);
    expect(bloc.state.vitrine.menu.last.tipo, VitrineItemTipo.grupo);
    await bloc.close();
  });

  test('publicar chama PUT só dos locais alterados e zera pendências',
      () async {
    final (bloc, repo) = await _pronto();
    await _add(bloc, VitrineLocal.home, [3, 2]);
    await _mover(bloc, 2, 0, VitrineLocal.home);

    bloc.add(const EcommerceVitrinePublicou());
    await bloc.stream.firstWhere((s) => s.publicadoEm != null);

    expect(repo.salvos, hasLength(1));
    expect(repo.salvos.single.$1, VitrineLocal.home);
    expect(repo.salvos.single.$2.map((i) => (i.itemId, i.ordem)),
        [(2, 0), (3, 1)]);
    expect(bloc.state.alteracoesPendentes, 0);
    expect(bloc.state.publicando, isFalse);
    await bloc.close();
  });

  test('publicar com falha mantém o rascunho e as pendências', () async {
    final (bloc, repo) = await _pronto();
    repo.falhar = true;
    await _add(bloc, VitrineLocal.menu, [2]);

    bloc.add(const EcommerceVitrinePublicou());
    await bloc.stream
        .firstWhere((s) => !s.publicando && s.erro?.isNotEmpty == true);

    expect(bloc.state.alteracoesPendentes, 1);
    expect(bloc.state.publicadoEm, isNull);
    await bloc.close();
  });

  test('descartar restaura a versão publicada', () async {
    final (bloc, repo) = await _pronto();
    await _add(bloc, VitrineLocal.menu, [2, 3]);
    await _add(bloc, VitrineLocal.home, [1]);
    expect(bloc.state.alteracoesPendentes, isNonZero);

    bloc.add(const EcommerceVitrineDescartou());
    await Future<void>.delayed(Duration.zero);

    expect(_nomes(bloc, VitrineLocal.menu), ['0:A']);
    expect(bloc.state.vitrine.home, isEmpty);
    expect(bloc.state.alteracoesPendentes, 0);
    expect(repo.salvos, isEmpty);
    await bloc.close();
  });

  test('duplicidade: lista direta no menu que também está em grupo do menu',
      () async {
    final (bloc, _) = await _pronto();
    expect(bloc.state.duplicidades, isEmpty);

    bloc.add(const EcommerceVitrineItensAdicionou(
      local: VitrineLocal.menu,
      itens: [VitrineItemRef(VitrineItemTipo.grupo, 7)],
    ));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.duplicidades, {1: 'Grupo'});
    expect(bloc.state.grupoDoMenuQueContem(2), isNull);

    // Tirar o grupo do menu desfaz o alerta.
    bloc.add(const EcommerceVitrineItemRemoveu(
      local: VitrineLocal.menu,
      tipo: VitrineItemTipo.grupo,
      itemId: 7,
    ));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.duplicidades, isEmpty);
    await bloc.close();
  });

  test(
      'ondeAparece usa a versão publicada: menu direto, dentro de grupo e home',
      () async {
    final (bloc, _) = await _pronto();
    expect(bloc.state.ondeAparece(1), ['Menu · 1º']);
    expect(bloc.state.ondeAparece(2), isEmpty);
    await bloc.close();
  });

  test('lista criada depois de abrir a aba aparece ao reabrir o diálogo',
      () async {
    final repo = _VitrineRepo();
    final grupos = _GruposRepo();
    final listas = _ListasRepo();
    final bloc = EcommerceVitrineBloc(
      RecuperarVitrineEcommerce(repository: repo),
      SalvarVitrineEcommerce(repository: repo),
      ListarListasPersonalizadas(repository: listas),
      ListarListasGrupos(repository: grupos),
      RecuperarListaGrupo(repository: grupos),
    );
    bloc.add(const EcommerceVitrineIniciou(ecommerceId: 9));
    await bloc.stream.firstWhere((s) => s.step == EcommerceVitrineStep.pronto);
    expect(bloc.state.listas.map((l) => l.titulo), ['A', 'B', 'C']);

    // Rascunho pendente: recarregar o acervo não pode descartá-lo.
    bloc.add(const EcommerceVitrineItemRemoveu(
      local: VitrineLocal.menu,
      tipo: VitrineItemTipo.lista,
      itemId: 1,
    ));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.alteracoesPendentes, 1);

    listas.extras.add(listas._l(4, 'Jeans'));
    bloc.add(const EcommerceVitrineRecarregouCatalogo());
    await bloc.stream.firstWhere((s) => s.listas.length == 4);

    expect(bloc.state.listas.map((l) => l.titulo), contains('Jeans'));
    expect(bloc.state.alteracoesPendentes, 1);
    expect(bloc.state.vitrine.menu, isEmpty);
    await bloc.close();
  });
}
