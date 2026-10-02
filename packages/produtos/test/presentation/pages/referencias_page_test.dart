import 'package:core/injecoes.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:produtos/data/remote/dtos/categoria_dto.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';
import 'package:produtos/repositorios.dart';
import 'package:produtos/use_cases.dart';

class _RepoReferencias implements IReferenciasRepository {
  final List<Referencia> itens;
  _RepoReferencias(this.itens);

  @override
  Future<List<Referencia>> obterReferencias({
    String? nome,
    bool? inativo,
  }) async => [...itens];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RepoMarcas implements IMarcasRepository {
  @override
  Future<List<Marca>> obterMarcas({String? nome, bool? inativa}) async => [
    Marca.create(id: 7, nome: 'Vale', inativa: false),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Referencia _ref(
  int id,
  String nome, {
  required int categoriaId,
  required String categoria,
  String? ncm = '61091000',
  int? peso = 250,
  int? marcaId,
}) => Referencia.create(
  id: id,
  nome: nome,
  idExterno: '${1000 + id}',
  categoriaId: categoriaId,
  categoria: CategoriaDto(id: categoriaId, nome: categoria, inativa: false),
  marcaId: marcaId,
  ncm: ncm,
  pesoGramas: peso,
  atualizadoEm: DateTime(2026, 9, 30, 14, 5),
);

void main() {
  final referencias = [
    _ref(1, 'Camisa Básica', categoriaId: 10, categoria: 'Camisas', marcaId: 7),
    _ref(2, 'Camisa Polo', categoriaId: 10, categoria: 'Camisas', ncm: null),
    _ref(3, 'Calça Jeans', categoriaId: 20, categoria: 'Calças', peso: null),
    _ref(
      4,
      'Vestido Longo',
      categoriaId: 30,
      categoria: 'Vestidos',
      ncm: null,
      peso: null,
    ),
  ];

  Future<void> abrir(WidgetTester tester, {required Size tela}) async {
    tester.view.physicalSize = tela;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await sl.reset();
    sl.registerFactory<ReferenciasBloc>(
      () => ReferenciasBloc(
        RecuperarReferencias(
          referenciasRepository: _RepoReferencias(referencias),
        ),
      ),
    );
    sl.registerFactory<RecuperarMarcas>(
      () => RecuperarMarcas(marcasRepository: _RepoMarcas()),
    );

    await tester.pumpWidget(
      MaterialApp(theme: SivTheme.tema, home: const ReferenciasPage()),
    );
    await tester.pumpAndSettle();
  }

  tearDown(() async => sl.reset());

  group('desktop (tabela)', () {
    const tela = Size(1300, 900);

    testWidgets(
      'mostra o cabeçalho, as 4 linhas, a marca pelo nome e o rodapé',
      (tester) async {
        await abrir(tester, tela: tela);

        for (final coluna in [
          'Nº',
          'NOME',
          'MARCA',
          'NCM',
          'PESO',
          'ATUALIZADO EM',
        ]) {
          expect(find.text(coluna), findsOneWidget, reason: coluna);
        }
        for (final nome in [
          'Camisa Básica',
          'Camisa Polo',
          'Calça Jeans',
          'Vestido Longo',
        ]) {
          expect(find.text(nome), findsOneWidget, reason: nome);
        }
        expect(find.text('Vale'), findsOneWidget); // marcaId 7 resolvido
        expect(find.text('1001'), findsOneWidget); // nº = ID externo
        expect(find.text('6109.10.00'), findsWidgets); // NCM formatado
        expect(find.text('250 g'), findsWidgets);
        expect(find.text('30/09/2026 14:05'), findsWidgets);
        expect(find.text('4 referências'), findsOneWidget);
        expect(find.text('Clique na linha para editar'), findsOneWidget);
      },
    );

    testWidgets(
      'pendência vira etiqueta no lugar do valor e o chip mostra a contagem',
      (tester) async {
        await abrir(tester, tela: tela);

        // chip + 2 linhas sem NCM (2 e 4); chip + 2 linhas sem peso (3 e 4)
        expect(find.text('Sem NCM'), findsNWidgets(3));
        expect(find.text('Sem peso'), findsNWidgets(3));
        expect(find.text('2'), findsNWidgets(2)); // contagem dos dois chips
      },
    );

    testWidgets(
      'busca por nome (sem acento) filtra e o rodapé mostra "N de M"',
      (tester) async {
        await abrir(tester, tela: tela);

        await tester.enterText(find.byType(TextField), 'calca');
        await tester.pumpAndSettle();

        expect(find.text('Calça Jeans'), findsOneWidget);
        expect(find.text('Camisa Básica'), findsNothing);
        expect(find.text('1 de 4 referências'), findsOneWidget);
      },
    );

    testWidgets('busca pelo nº da referência', (tester) async {
      await abrir(tester, tela: tela);

      await tester.enterText(find.byType(TextField), '1004');
      await tester.pumpAndSettle();

      expect(find.text('Vestido Longo'), findsOneWidget);
      expect(find.text('Camisa Polo'), findsNothing);
    });

    testWidgets(
      'chip de categoria e de pendência combinam; sem resultado mostra o vazio e "Limpar" restaura',
      (tester) async {
        await abrir(tester, tela: tela);

        await tester.tap(
          find.descendant(
            of: find.byType(Wrap),
            matching: find.text('Camisas'),
          ),
        ); // o chip, não o subtítulo das linhas
        await tester.pumpAndSettle();
        expect(find.text('Calça Jeans'), findsNothing);

        await tester.tap(find.text('Sem peso').first);
        await tester.pumpAndSettle();
        expect(find.text('Nenhuma referência encontrada'), findsOneWidget);

        await tester.tap(find.text('Limpar busca e filtros'));
        await tester.pumpAndSettle();
        expect(find.text('Nenhuma referência encontrada'), findsNothing);
        expect(find.text('4 referências'), findsOneWidget);
      },
    );

    testWidgets(
      'botão de ordenar abre o menu com as 6 opções e a atual marcada',
      (tester) async {
        await abrir(tester, tela: tela);

        await tester.tap(find.byTooltip('Ordenar referências'));
        await tester.pumpAndSettle();

        expect(find.text('Nome (Z-A)'), findsOneWidget);
        expect(find.text('Atualizado em (mais recente)'), findsOneWidget);
        expect(find.byIcon(Icons.check), findsOneWidget);
      },
    );
  });

  group('mobile (folhas inferiores)', () {
    const tela = Size(390, 844);

    testWidgets(
      'sem cabeçalho de colunas; linha com "categoria · marca" e "Nº"; botão "Nova referência"',
      (tester) async {
        await abrir(tester, tela: tela);

        expect(find.text('NOME'), findsNothing);
        expect(find.text('Nova referência'), findsOneWidget);
        expect(find.text('Camisas · Vale'), findsOneWidget);
        expect(find.text('Nº 1001'), findsOneWidget);
        expect(find.text('4 referências'), findsOneWidget);
        expect(find.text('Nome A-Z'), findsOneWidget); // link de ordenação
      },
    );

    testWidgets(
      'chip de categoria abre a folha com contagens; escolher filtra e "Limpar" volta',
      (tester) async {
        await abrir(tester, tela: tela);

        await tester.tap(find.text('Categoria'));
        await tester.pumpAndSettle();
        expect(find.text('Calças'), findsOneWidget);
        expect(
          find.text('Limpar'),
          findsNothing,
        ); // ainda sem categoria escolhida

        await tester.tap(find.text('Calças'));
        await tester.pumpAndSettle();
        expect(find.text('Calça Jeans'), findsOneWidget);
        expect(find.text('Camisa Básica'), findsNothing);
        expect(find.text('1 de 4 referências'), findsOneWidget);

        await tester.tap(
          find.text('Calças'),
        ); // o chip agora mostra o nome da categoria
        await tester.pumpAndSettle();
        await tester.tap(find.text('Limpar'));
        await tester.pumpAndSettle();
        expect(find.text('4 referências'), findsOneWidget);
      },
    );

    testWidgets(
      'link de ordenação abre a folha "Ordenar por" e trocar muda o rótulo',
      (tester) async {
        await abrir(tester, tela: tela);

        await tester.tap(find.text('Nome A-Z'));
        await tester.pumpAndSettle();
        expect(find.text('Ordenar por'), findsOneWidget);

        await tester.tap(find.text('Nome (Z-A)'));
        await tester.pumpAndSettle();

        expect(find.text('Ordenar por'), findsNothing);
        expect(find.text('Nome Z-A'), findsOneWidget);
      },
    );

    testWidgets('chips de pendência filtram também no mobile', (tester) async {
      await abrir(tester, tela: tela);

      await tester.tap(find.text('Sem NCM').first);
      await tester.pumpAndSettle();

      expect(find.text('Camisa Polo'), findsOneWidget);
      expect(find.text('Vestido Longo'), findsOneWidget);
      expect(find.text('Camisa Básica'), findsNothing);
      expect(find.text('2 de 4 referências'), findsOneWidget);
    });
  });
}
