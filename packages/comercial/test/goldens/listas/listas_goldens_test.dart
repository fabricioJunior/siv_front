@Tags(['golden'])
library;

import 'dart:io';
import 'dart:typed_data';

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
import 'package:core/injecoes.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_test/flutter_test.dart';

/// Dados de `mocks/dados-mock-listas-ecommerce.json` (handoff 6).
const _urlCanal = 'loja.valedoceara.com.br';

ListaPersonalizadaResumo _lista({
  required int id,
  required String titulo,
  required ListaModo modo,
  int quantidade = 0,
  ListaPersonalizadaSituacao situacao = ListaPersonalizadaSituacao.ativa,
  DateTime? inicio,
  DateTime? fim,
}) =>
    ListaPersonalizadaResumo(
      id: id,
      hash: 'h$id',
      situacao: situacao,
      quantidadeItens: quantidade,
      criadoEm: DateTime(2026, 9, 1),
      titulo: titulo,
      tipo: ListaTipo.catalogo,
      modo: modo,
      dataInicio: inicio,
      dataExpiracao: fim,
    );

ListaGrupo _grupo(int id, String nome, List<String> listas) => ListaGrupo(
      id: id,
      nome: nome,
      listas: [
        for (var i = 0; i < listas.length; i++)
          ListaGrupoLista(listaId: 1000 + id * 10 + i, nome: listas[i], ordem: i),
      ],
    );

/// Feminino contém a lista 298, que também está no menu direto: é o caso de
/// duplicidade de 3b.
final _grupos = [
  ListaGrupo(id: 7, nome: 'Feminino', listas: const [
    ListaGrupoLista(listaId: 298, nome: 'Novidades setembro', ordem: 0),
    ListaGrupoLista(listaId: 311, nome: 'Lingerie em promoção', ordem: 1),
    ListaGrupoLista(listaId: 305, nome: 'Pijamas', ordem: 2),
    ListaGrupoLista(listaId: 322, nome: 'Pijamas inverno', ordem: 3),
  ]),
  _grupo(8, 'Masculino', ['Camisas', 'Bermudas']),
  _grupo(9, 'Infantil', ['Meninas', 'Meninos']),
];

const _menu = [
  EcommerceVitrineItem(
      tipo: VitrineItemTipo.grupo, itemId: 7, ordem: 0, nome: 'Feminino'),
  EcommerceVitrineItem(
      tipo: VitrineItemTipo.grupo, itemId: 8, ordem: 1, nome: 'Masculino'),
  EcommerceVitrineItem(
      tipo: VitrineItemTipo.lista,
      itemId: 298,
      ordem: 2,
      nome: 'Novidades setembro',
      situacao: 'ativa'),
  EcommerceVitrineItem(
      tipo: VitrineItemTipo.lista,
      itemId: 315,
      ordem: 3,
      nome: 'Outlet',
      situacao: 'ativa'),
  EcommerceVitrineItem(
      tipo: VitrineItemTipo.grupo, itemId: 9, ordem: 4, nome: 'Infantil'),
];

const _home = [
  EcommerceVitrineItem(
      tipo: VitrineItemTipo.lista,
      itemId: 298,
      ordem: 0,
      nome: 'Novidades setembro',
      situacao: 'ativa'),
  EcommerceVitrineItem(
      tipo: VitrineItemTipo.lista,
      itemId: 311,
      ordem: 1,
      nome: 'Lingerie em promoção',
      situacao: 'ativa'),
  EcommerceVitrineItem(
      tipo: VitrineItemTipo.lista,
      itemId: 330,
      ordem: 2,
      nome: 'Kit presente',
      situacao: 'ativa'),
  EcommerceVitrineItem(
      tipo: VitrineItemTipo.lista,
      itemId: 322,
      ordem: 3,
      nome: 'Pijamas inverno',
      situacao: 'agendada'),
];

class _VitrineRepo implements IEcommerceVitrineRepository {
  @override
  Future<EcommerceVitrine> recuperar(int ecommerceId) async =>
      const EcommerceVitrine(menu: _menu, home: _home);

  @override
  Future<void> salvar(int id, VitrineLocal local,
      List<EcommerceVitrineItem> itens) async {}
}

class _ListasRepo implements IListaPersonalizadaRepository {
  final List<ListaPersonalizadaResumo> itens;
  final int total;

  _ListasRepo(this.itens, this.total);

  @override
  Future<PaginaListasPersonalizadas> listar(
          {int page = 1, int limit = 20, ListaTipo? tipo}) async =>
      PaginaListasPersonalizadas(
        meta: MetaListasPersonalizadas(
          totalItems: total,
          itemCount: itens.length,
          itemsPerPage: 100,
          totalPages: 1,
          currentPage: 1,
        ),
        items: tipo == ListaTipo.provador ? const [] : itens,
      );

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _GruposRepo implements IListasGruposRepository {
  @override
  Future<PaginaListasGrupos> listar({int page = 1, int limit = 20}) async =>
      PaginaListasGrupos(items: _grupos);

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _EcommerceRepo implements IEcommerceRepository {
  @override
  Future<List<Ecommerce>> recuperarEcommerces(
          {bool incluirApagados = false}) async =>
      [
        Ecommerce.create(
          id: 3,
          empresaId: 1,
          titulo: 'Loja Vale do Ceará',
          subtitulo: _urlCanal,
        ),
      ];

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// Fontes empacotadas do core (o golden precisa da tipografia certa).
Future<void> _carregarFontes() async {
  // O teste roda com a raiz do repo ou o pacote como diretório atual.
  var dir = Directory.current;
  Directory? fontes;
  for (var i = 0; i < 4 && fontes == null; i++) {
    final alvo = Directory('${dir.path}/packages/core/assets/fonts');
    if (alvo.existsSync()) fontes = alvo;
    dir = dir.parent;
  }
  if (fontes == null) throw StateError('fontes do core não encontradas');
  final raiz = fontes.path;

  Future<void> carregar(String familia, List<String> arquivos) async {
    final loader = FontLoader(familia);
    for (final a in arquivos) {
      loader.addFont(
        File('$raiz/$a')
            .readAsBytes()
            .then((b) => ByteData.sublistView(b)),
      );
    }
    await loader.load();
  }

  await carregar(sivFonteBarlow, [
    'Barlow-Regular.ttf',
    'Barlow-Medium.ttf',
    'Barlow-SemiBold.ttf',
  ]);
  await carregar(sivFonteCondensed, [
    'BarlowCondensed-Regular.ttf',
    'BarlowCondensed-SemiBold.ttf',
  ]);
  // `codigo` pede monospace, que não existe no ambiente de teste.
  await carregar('monospace', ['Barlow-Regular.ttf']);

  final lucide = FontLoader('packages/lucide_icons_flutter/Lucide')
    ..addFont(rootBundle.load('packages/lucide_icons_flutter/assets/lucide.ttf'));
  await lucide.load();
}

Future<void> _montar(
  WidgetTester tester, {
  required Size tela,
  required double dpr,
  required ListasAba aba,
  required List<ListaPersonalizadaResumo> itens,
  int total = 12,
}) async {
  tester.view.devicePixelRatio = dpr;
  tester.view.physicalSize = Size(tela.width * dpr, tela.height * dpr);
  addTearDown(tester.view.reset);

  await sl.reset();
  addTearDown(sl.reset);
  final vitrine = _VitrineRepo();
  final grupos = _GruposRepo();
  final listas = ListarListasPersonalizadas(repository: _ListasRepo(itens, total));
  final ecommerces = _EcommerceRepo();
  sl.registerFactory(() => ListasPersonalizadasBloc(listas));
  sl.registerFactory(
    () => EcommerceVitrineBloc(
      RecuperarVitrineEcommerce(repository: vitrine),
      SalvarVitrineEcommerce(repository: vitrine),
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
      debugShowCheckedModeBanner: false,
      home: ListasPersonalizadasPage(abaInicial: aba, temAcesso: (_) => true),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(_carregarFontes);

  testWidgets('3b vitrine desktop 1440x900', (tester) async {
    await _montar(
      tester,
      tela: const Size(1440, 900),
      dpr: 1,
      aba: ListasAba.vitrine,
      itens: [
        _lista(
          id: 298,
          titulo: 'Novidades setembro',
          modo: ListaModo.manual,
          quantidade: 23,
          fim: DateTime(2026, 9, 30),
        ),
        _lista(
          id: 315,
          titulo: 'Outlet',
          modo: ListaModo.filtro,
          quantidade: 64,
        ),
      ],
    );
    await expectLater(
      find.byType(ListasPersonalizadasPage),
      matchesGoldenFile('3b-vitrine-desktop.png'),
    );
  });

  testWidgets('1a listagem mobile 390x844 @2x', (tester) async {
    await _montar(
      tester,
      tela: const Size(390, 844),
      dpr: 2,
      aba: ListasAba.catalogo,
      itens: [
        _lista(
          id: 311,
          titulo: 'Lingerie em promoção',
          modo: ListaModo.filtro,
          quantidade: 142,
        ),
        _lista(
          id: 298,
          titulo: 'Novidades setembro',
          modo: ListaModo.manual,
          quantidade: 24,
          fim: DateTime(2026, 9, 30),
        ),
        _lista(
          id: 322,
          titulo: 'Pijamas inverno',
          modo: ListaModo.filtro,
          quantidade: 58,
          situacao: ListaPersonalizadaSituacao.agendada,
          inicio: DateTime(2026, 10, 1),
        ),
        _lista(
          id: 350,
          titulo: 'Dia dos pais',
          modo: ListaModo.manual,
          quantidade: 18,
          situacao: ListaPersonalizadaSituacao.expirada,
          fim: DateTime(2026, 8, 10),
        ),
      ],
    );
    await expectLater(
      find.byType(ListasPersonalizadasPage),
      matchesGoldenFile('1a-listas-mobile.png'),
    );
  });
}
