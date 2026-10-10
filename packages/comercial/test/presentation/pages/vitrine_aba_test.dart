import 'package:comercial/domain/data/repositories/i_ecommerce_repository.dart';
import 'package:comercial/domain/data/repositories/i_ecommerce_vitrine_repository.dart';
import 'package:comercial/domain/data/repositories/i_lista_personalizada_repository.dart';
import 'package:comercial/domain/data/repositories/i_listas_grupos_repository.dart';
import 'package:comercial/domain/models/ecommerce.dart';
import 'package:comercial/domain/models/ecommerce_vitrine.dart';
import 'package:comercial/domain/models/lista_grupo.dart';
import 'package:comercial/domain/models/lista_personalizada.dart';
import 'package:comercial/domain/models/lista_personalizada_resumo.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _VitrineRepo implements IEcommerceVitrineRepository {
  final salvos = <VitrineLocal>[];

  @override
  Future<EcommerceVitrine> recuperar(int ecommerceId) async =>
      const EcommerceVitrine(
        menu: [
          EcommerceVitrineItem(
              tipo: VitrineItemTipo.lista, itemId: 1, ordem: 0, nome: 'A'),
          EcommerceVitrineItem(
              tipo: VitrineItemTipo.lista, itemId: 2, ordem: 1, nome: 'B'),
          EcommerceVitrineItem(
              tipo: VitrineItemTipo.lista, itemId: 3, ordem: 2, nome: 'C'),
        ],
      );

  @override
  Future<void> salvar(
          int id, VitrineLocal local, List<EcommerceVitrineItem> itens) async =>
      salvos.add(local);
}

class _ListasRepo implements IListaPersonalizadaRepository {
  @override
  Future<PaginaListasPersonalizadas> listar(
          {int page = 1, int limit = 20, ListaTipo? tipo}) async =>
      PaginaListasPersonalizadas(
        meta: const MetaListasPersonalizadas(
          totalItems: 3,
          itemCount: 3,
          itemsPerPage: 100,
          totalPages: 1,
          currentPage: 1,
        ),
        items: [
          for (final (id, nome) in [(1, 'A'), (2, 'B'), (3, 'C'), (4, 'D')])
            ListaPersonalizadaResumo(
              id: id,
              hash: 'h$id',
              situacao: ListaPersonalizadaSituacao.ativa,
              quantidadeItens: 5,
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

Future<(EcommerceVitrineBloc, _VitrineRepo)> _montar(
    WidgetTester tester, Size tela) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = tela;
  addTearDown(tester.view.reset);

  final repo = _VitrineRepo();
  final grupos = _GruposRepo();
  final bloc = EcommerceVitrineBloc(
    RecuperarVitrineEcommerce(repository: repo),
    SalvarVitrineEcommerce(repository: repo),
    ListarListasPersonalizadas(repository: _ListasRepo()),
    ListarListasGrupos(repository: grupos),
    RecuperarListaGrupo(repository: grupos),
  )..add(const EcommerceVitrineIniciou(ecommerceId: 9));
  addTearDown(bloc.close);

  await tester.pumpWidget(
    MaterialApp(
      theme: SivTheme.tema,
      home: BlocProvider<EcommerceVitrineBloc>.value(
        value: bloc,
        child: Scaffold(
          body: VitrineAba(
            canais: [Ecommerce.create(id: 9, empresaId: 1, titulo: 'Loja')],
            canalId: 9,
            onCanalChanged: (_) {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (bloc, repo);
}

class _EcommerceRepo implements IEcommerceRepository {
  @override
  Future<List<Ecommerce>> recuperarEcommerces(
          {bool incluirApagados = false}) async =>
      [Ecommerce.create(id: 9, empresaId: 1, titulo: 'Loja')];

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Future<void> _montarPagina(
  WidgetTester tester, {
  required bool vitrine,
  ListasAba aba = ListasAba.catalogo,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);
  await sl.reset();
  addTearDown(sl.reset);
  final repo = _VitrineRepo();
  final grupos = _GruposRepo();
  final listas = ListarListasPersonalizadas(repository: _ListasRepo());
  final ecommerces = _EcommerceRepo();
  sl.registerFactory(() => ListasPersonalizadasBloc(listas));
  sl.registerFactory(
    () => EcommerceVitrineBloc(
      RecuperarVitrineEcommerce(repository: repo),
      SalvarVitrineEcommerce(repository: repo),
      listas,
      ListarListasGrupos(repository: grupos),
      RecuperarListaGrupo(repository: grupos),
    ),
  );
  sl.registerFactory(
    () => EcommercesBloc(
      RecuperarEcommerces(repository: ecommerces),
      ExcluirEcommerce(repository: ecommerces),
      RestaurarEcommerce(repository: ecommerces),
    ),
  );
  await tester.pumpWidget(
    MaterialApp(
      theme: SivTheme.tema,
      home: ListasPersonalizadasPage(
        abaInicial: aba,
        temAcesso: (c) => c == 'ECOFM004' || (vitrine && c == 'ECOFM001'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('abas: sem ECOFM001 a Vitrine do site some', (tester) async {
    await _montarPagina(tester, vitrine: false);
    for (final t in ['Catálogo', 'Provador', 'Grupos']) {
      expect(find.text(t), findsOneWidget);
    }
    expect(find.text('Vitrine do site'), findsNothing);
  });

  testWidgets(
      'card: onde aparece e alerta "Não está no site" para catálogo fora da vitrine',
      (tester) async {
    await _montarPagina(tester, vitrine: true);
    expect(find.text('Menu · 1º'), findsOneWidget);
    expect(find.byKey(const Key('lista-fora-do-site-1')), findsNothing);
    expect(find.byKey(const Key('lista-fora-do-site-4')), findsOneWidget);
    expect(find.text('Não está no site'), findsOneWidget);
    expect(find.text('Por regras'), findsNothing);
    expect(find.text('Avulsa · 5 produtos'), findsWidgets);

    await tester.tap(find.byKey(const Key('lista-fora-do-site-4')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('vitrine-publicar')), findsOneWidget);
  });

  testWidgets('deep link abre a aba Vitrine com o canal', (tester) async {
    await _montarPagina(tester, vitrine: true, aba: ListasAba.vitrine);
    expect(find.byKey(const Key('vitrine-publicar')), findsOneWidget);
    // Com 1 canal o nome aparece como texto (sem dropdown), uma vez só.
    expect(find.byKey(const Key('vitrine-canal')), findsOneWidget);
  });

  testWidgets(
      'mobile: alvos de toque >= 44px e publicar fixo no rodapé com 52px',
      (tester) async {
    await _montar(tester, const Size(390, 844));

    final pos =
        tester.getSize(find.byKey(const Key('vitrine-posicao-menu-lista-1')));
    expect(pos.width, greaterThanOrEqualTo(44));
    expect(pos.height, greaterThanOrEqualTo(44));
    expect(find.byKey(const Key('vitrine-indice-menu-lista-1')), findsNothing);

    for (final f in [
      find.byTooltip('Remover').first,
      find.byKey(const Key('vitrine-adicionar-menu')),
      find.byKey(const Key('vitrine-descartar')),
    ]) {
      final s = tester.getSize(f);
      expect(s.height, greaterThanOrEqualTo(44), reason: '$f');
    }
    final publicar = find.byKey(const Key('vitrine-publicar'));
    expect(tester.getSize(publicar).height, greaterThanOrEqualTo(52));
    expect(tester.widget<FilledButton>(publicar).onPressed, isNull);
    expect(find.text('Tudo publicado. O site está igual a esta tela.'),
        findsOneWidget);
    expect(find.text('Menu · 3'), findsOneWidget);
    expect(find.text('Home · 0'), findsOneWidget);
  });

  testWidgets(
      'mobile: sheet de posição move para o fim, publica só o menu e descarta',
      (tester) async {
    final (_, repo) = await _montar(tester, const Size(390, 844));

    await tester.tap(find.byKey(const Key('vitrine-posicao-menu-lista-1')));
    await tester.pumpAndSettle();
    expect(find.text('Mover "A"'), findsOneWidget);
    await tester.tap(find.text('Mandar para o fim'));
    await tester.pumpAndSettle();

    expect(find.text('3 alterações não publicadas'), findsOneWidget);

    await tester.tap(find.byKey(const Key('vitrine-descartar')));
    await tester.pumpAndSettle();
    expect(find.text('Tudo publicado. O site está igual a esta tela.'),
        findsOneWidget);

    await tester.tap(find.byKey(const Key('vitrine-posicao-menu-lista-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tirar do menu'));
    await tester.pumpAndSettle();
    expect(find.text('3 alterações não publicadas'), findsOneWidget);

    await tester.tap(find.byKey(const Key('vitrine-publicar')));
    await tester.pumpAndSettle();
    expect(repo.salvos, [VitrineLocal.menu]);
    expect(find.textContaining('Publicado no site às'), findsOneWidget);
  });

  testWidgets('desktop: campo de índice 1-based move a linha e mostra a prévia',
      (tester) async {
    await _montar(tester, const Size(1280, 800));

    expect(find.byKey(const Key('vitrine-previa')), findsOneWidget);
    await tester.enterText(
        find.byKey(const Key('vitrine-indice-menu-lista-3')), '1');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final c = tester.getTopLeft(find.byKey(const ValueKey('menu-lista-3'))).dy;
    final a = tester.getTopLeft(find.byKey(const ValueKey('menu-lista-1'))).dy;
    expect(c, lessThan(a));
    expect(find.text('3 alterações não publicadas'), findsOneWidget);
  });

  testWidgets(
      'diálogo adicionar: multi-seleção, oculta já presentes, Grupos desabilitada na Home',
      (tester) async {
    final (bloc, _) = await _montar(tester, const Size(390, 844));

    await tester.tap(find.byKey(const Key('vitrine-adicionar-menu')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('vitrine-add-lista-1')), findsNothing);
    expect(find.byKey(const Key('vitrine-add-lista-4')), findsOneWidget);
    await tester.tap(find.byKey(const Key('vitrine-add-lista-4')));
    await tester.pump();
    expect(find.text('Entra no fim do menu (posição 4)'), findsOneWidget);
    await tester.tap(find.byKey(const Key('vitrine-add-confirmar')));
    await tester.pumpAndSettle();
    expect(bloc.state.vitrine.menu.map((i) => i.itemId), [1, 2, 3, 4]);

    await tester.tap(find.text('Home · 0'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('vitrine-adicionar-home')));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Grupos ·'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('vitrine-add-grupo-7')), findsNothing);
    expect(find.text('Grupos só entram no Menu.'), findsOneWidget);
  });

  testWidgets('confirmação ao sair com pendências', (tester) async {
    bool? resultado;
    await tester.pumpWidget(
      MaterialApp(
        theme: SivTheme.tema,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async =>
                resultado = await confirmarSairSemPublicar(context, 2),
            child: const Text('sair'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('sair'));
    await tester.pumpAndSettle();
    expect(find.text('2 alterações não publicadas serão perdidas.'),
        findsOneWidget);
    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();
    expect(resultado, isFalse);

    await tester.tap(find.text('sair'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();
    expect(resultado, isTrue);
  });
}
