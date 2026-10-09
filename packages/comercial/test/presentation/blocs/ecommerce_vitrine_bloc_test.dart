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

  @override
  Future<EcommerceVitrine> recuperar(int ecommerceId) async => const EcommerceVitrine(
        menu: [
          EcommerceVitrineItem(tipo: VitrineItemTipo.lista, itemId: 1, ordem: 0, nome: 'A'),
        ],
      );

  @override
  Future<void> salvar(int id, VitrineLocal local, List<EcommerceVitrineItem> itens) async =>
      salvos.add((local, itens));
}

class _ListasRepo implements IListaPersonalizadaRepository {
  @override
  Future<PaginaListasPersonalizadas> listar({int page = 1, int limit = 20, ListaTipo? tipo}) async =>
      PaginaListasPersonalizadas(
        meta: const MetaListasPersonalizadas(
          totalItems: 3,
          itemCount: 3,
          itemsPerPage: 100,
          totalPages: 1,
          currentPage: 1,
        ),
        items: [
          for (final (id, nome) in [(1, 'A'), (2, 'B'), (3, 'C')])
            ListaPersonalizadaResumo(
              id: id,
              hash: 'h$id',
              situacao: ListaPersonalizadaSituacao.ativa,
              quantidadeItens: 0,
              criadoEm: DateTime(2026),
              titulo: nome,
              tipo: ListaTipo.catalogo,
            ),
        ],
      );

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _GruposRepo implements IListasGruposRepository {
  @override
  Future<PaginaListasGrupos> listar({int page = 1, int limit = 20}) async =>
      const PaginaListasGrupos(items: [ListaGrupo(id: 7, nome: 'Grupo')]);

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Future<(EcommerceVitrineBloc, _VitrineRepo)> _pronto() async {
  final repo = _VitrineRepo();
  final bloc = EcommerceVitrineBloc(
    RecuperarVitrineEcommerce(repository: repo),
    SalvarVitrineEcommerce(repository: repo),
    ListarListasPersonalizadas(repository: _ListasRepo()),
    ListarListasGrupos(repository: _GruposRepo()),
  );
  bloc.add(const EcommerceVitrineIniciou(ecommerceId: 9));
  await bloc.stream.firstWhere((s) => s.step == EcommerceVitrineStep.pronto);
  return (bloc, repo);
}

List<String> _nomes(EcommerceVitrineBloc b, VitrineLocal l) =>
    b.state.vitrine.doLocal(l).map((i) => '${i.ordem}:${i.nome}').toList();

void main() {
  test('ordem por índice: mover para a posição renumera 0..n-1', () async {
    final (bloc, _) = await _pronto();
    for (final id in [2, 3]) {
      bloc.add(EcommerceVitrineItemAdicionou(
        local: VitrineLocal.menu,
        tipo: VitrineItemTipo.lista,
        itemId: id,
      ));
    }
    await Future<void>.delayed(Duration.zero);
    expect(_nomes(bloc, VitrineLocal.menu), ['0:A', '1:B', '2:C']);

    bloc.add(const EcommerceVitrineItemMoveu(
      local: VitrineLocal.menu,
      tipo: VitrineItemTipo.lista,
      itemId: 3,
      indice: 0,
    ));
    await Future<void>.delayed(Duration.zero);
    expect(_nomes(bloc, VitrineLocal.menu), ['0:C', '1:A', '2:B']);

    bloc.add(const EcommerceVitrineItemMoveu(
      local: VitrineLocal.menu,
      tipo: VitrineItemTipo.lista,
      itemId: 3,
      indice: 99,
    ));
    await Future<void>.delayed(Duration.zero);
    expect(_nomes(bloc, VitrineLocal.menu), ['0:A', '1:B', '2:C']);
    await bloc.close();
  });

  test('home só aceita lista; menu aceita grupo', () async {
    final (bloc, _) = await _pronto();
    bloc.add(const EcommerceVitrineItemAdicionou(
      local: VitrineLocal.home,
      tipo: VitrineItemTipo.grupo,
      itemId: 7,
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

  test('salvar chama PUT só do local pedido, com a ordem atual; remover renumera', () async {
    final (bloc, repo) = await _pronto();
    bloc.add(const EcommerceVitrineItemAdicionou(
      local: VitrineLocal.home,
      tipo: VitrineItemTipo.lista,
      itemId: 2,
    ));
    bloc.add(const EcommerceVitrineItemAdicionou(
      local: VitrineLocal.home,
      tipo: VitrineItemTipo.lista,
      itemId: 3,
    ));
    bloc.add(const EcommerceVitrineItemRemoveu(
      local: VitrineLocal.home,
      tipo: VitrineItemTipo.lista,
      itemId: 2,
    ));
    bloc.add(const EcommerceVitrineSalvou(local: VitrineLocal.home));
    await bloc.stream.firstWhere((s) => s.ultimoSalvo == VitrineLocal.home);

    expect(repo.salvos, hasLength(1));
    expect(repo.salvos.single.$1, VitrineLocal.home);
    expect(repo.salvos.single.$2.map((i) => (i.itemId, i.ordem)), [(3, 0)]);
    await bloc.close();
  });
}
