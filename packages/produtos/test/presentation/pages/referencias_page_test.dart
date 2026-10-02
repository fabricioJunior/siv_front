import 'package:core/injecoes.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';
import 'package:produtos/use_cases.dart';

import '../../doubles/servidor_referencias.dart';

ItemListaReferencia _item(
  int id,
  String nome, {
  required int categoriaId,
  required String categoria,
  String? ncm = '61091000',
  int? peso = 250,
  String? marca,
}) => ItemListaReferencia(
  referencia: fakeReferencia(
    id,
    nome,
    categoriaId: categoriaId,
    categoria: categoria,
    ncm: ncm,
    peso: peso,
  ),
  marcaNome: marca,
);

final _quatro = [
  _item(
    1,
    'Camisa Básica',
    categoriaId: 10,
    categoria: 'Camisas',
    marca: 'Vale',
  ),
  _item(2, 'Camisa Polo', categoriaId: 10, categoria: 'Camisas', ncm: null),
  _item(3, 'Calça Jeans', categoriaId: 20, categoria: 'Calças', peso: null),
  _item(
    4,
    'Vestido Longo',
    categoriaId: 30,
    categoria: 'Vestidos',
    ncm: null,
    peso: null,
  ),
];

void main() {
  late ServidorReferenciasFake servidor;

  Future<void> abrir(
    WidgetTester tester, {
    required Size tela,
    List<ItemListaReferencia>? itens,
    int tamanhoPagina = 50,
  }) async {
    tester.view.physicalSize = tela;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    servidor = ServidorReferenciasFake(
      itens ?? _quatro,
      tamanhoPagina: tamanhoPagina,
    );
    await sl.reset();
    sl.registerFactory<ReferenciasListaBloc>(
      () => ReferenciasListaBloc(BuscarReferencias(repository: servidor)),
    );

    await tester.pumpWidget(
      MaterialApp(theme: SivTheme.tema, home: const ReferenciasPage()),
    );
    await tester.pumpAndSettle();
  }

  // O app só consulta depois de 400 ms sem digitar.
  Future<void> digitar(WidgetTester tester, String texto) async {
    await tester.enterText(find.byType(TextField), texto);
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();
  }

  Finder chip(String rotulo) =>
      find.descendant(of: find.byType(Wrap), matching: find.text(rotulo));

  tearDown(() async => sl.reset());

  group('desktop (tabela)', () {
    const tela = Size(1300, 900);

    testWidgets(
      'primeira carga: uma consulta ao servidor, cabeçalho, linhas ordenadas, marca pelo nome e rodapé',
      (tester) async {
        await abrir(tester, tela: tela);

        expect(servidor.chamadas, hasLength(1));
        expect(
          (servidor.chamadas.single.orderBy, servidor.chamadas.single.page),
          ('nome', 1),
        );
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
        expect(find.text('Vale'), findsOneWidget); // marcaNome vem do servidor
        expect(find.text('1001'), findsOneWidget); // nº = ID externo
        expect(find.text('6109.10.00'), findsWidgets);
        expect(find.text('250 g'), findsWidgets);
        expect(find.text('30/09/2026 14:05'), findsWidgets);
        expect(find.text('4 referências'), findsOneWidget);
        expect(find.text('Clique na linha para editar'), findsOneWidget);
        expect(
          tester.getTopLeft(find.text('Calça Jeans')).dy,
          lessThan(tester.getTopLeft(find.text('Camisa Básica')).dy),
        );
      },
    );

    testWidgets(
      'os números dos chips vêm do resumo do servidor; a pendência vira etiqueta na linha',
      (tester) async {
        await abrir(tester, tela: tela);

        // chip + 2 linhas sem NCM (2 e 4); chip + 2 linhas sem peso (3 e 4)
        expect(find.text('Sem NCM'), findsNWidgets(3));
        expect(find.text('Sem peso'), findsNWidgets(3));
        expect(find.text('2'), findsNWidgets(2));
        expect(chip('Camisas'), findsOneWidget);
        expect(chip('Calças'), findsOneWidget);
        expect(chip('Vestidos'), findsOneWidget);
      },
    );

    testWidgets(
      'digitar só consulta o servidor depois do debounce, e a lista vem do servidor',
      (tester) async {
        await abrir(tester, tela: tela);

        await tester.enterText(find.byType(TextField), 'camisa');
        await tester.pump(const Duration(milliseconds: 100));
        expect(
          servidor.chamadas,
          hasLength(1),
          reason: 'ainda dentro do debounce',
        );

        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();

        expect(servidor.chamadas, hasLength(2));
        expect(servidor.chamadas.last.busca, 'camisa');
        expect(find.text('Camisa Básica'), findsOneWidget);
        expect(find.text('Calça Jeans'), findsNothing);
        expect(find.text('2 referências encontradas'), findsOneWidget);
      },
    );

    testWidgets('várias letras seguidas viram uma consulta só', (tester) async {
      await abrir(tester, tela: tela);

      for (final texto in ['c', 'ca', 'cam', 'cami']) {
        await tester.enterText(find.byType(TextField), texto);
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pump(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();

      expect(servidor.chamadas.map((c) => c.busca), ['', 'cami']);
    });

    testWidgets('busca pelo nº da referência', (tester) async {
      await abrir(tester, tela: tela);

      await digitar(tester, '1004');

      expect(servidor.chamadas.last.busca, '1004');
      expect(find.text('Vestido Longo'), findsOneWidget);
      expect(find.text('Camisa Polo'), findsNothing);
    });

    testWidgets(
      'chips de categoria e de pendência pedem ao servidor; sem resultado mostra o vazio e "Limpar" volta ao início',
      (tester) async {
        await abrir(tester, tela: tela);

        await tester.tap(chip('Camisas'));
        await tester.pumpAndSettle();
        expect(servidor.chamadas.last.categoriaId, 10);
        expect(find.text('Calça Jeans'), findsNothing);

        await tester.tap(find.text('Sem peso').first);
        await tester.pumpAndSettle();
        expect(
          (servidor.chamadas.last.categoriaId, servidor.chamadas.last.semPeso),
          (10, true),
        );
        expect(find.text('Nenhuma referência encontrada'), findsOneWidget);

        await tester.tap(find.text('Limpar busca e filtros'));
        await tester.pumpAndSettle();
        final ultima = servidor.chamadas.last;
        expect(
          (ultima.busca, ultima.categoriaId, ultima.semNcm, ultima.semPeso),
          ('', null, false, false),
        );
        expect(find.text('4 referências'), findsOneWidget);
      },
    );

    testWidgets('"Limpar busca e filtros" também esvazia o campo de busca', (
      tester,
    ) async {
      await abrir(tester, tela: tela);
      await digitar(tester, 'zzz');
      expect(find.text('Nenhuma referência encontrada'), findsOneWidget);

      await tester.tap(find.text('Limpar busca e filtros'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(find.text('4 referências'), findsOneWidget);
    });

    testWidgets(
      'um toque no chip não perde a busca que ainda estava no debounce',
      (tester) async {
        await abrir(tester, tela: tela);

        await tester.enterText(find.byType(TextField), 'camisa');
        await tester.tap(chip('Camisas')); // antes de 400 ms
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        final ultima = servidor.chamadas.last;
        expect((ultima.busca, ultima.categoriaId), ('camisa', 10));
      },
    );

    testWidgets('ordenar pelo menu manda campo e direção ao servidor', (
      tester,
    ) async {
      await abrir(tester, tela: tela);

      await tester.tap(find.byTooltip('Ordenar referências'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check), findsOneWidget);
      await tester.tap(find.text('Nome (Z-A)'));
      await tester.pumpAndSettle();

      expect(
        (servidor.chamadas.last.orderBy, servidor.chamadas.last.orderDir),
        ('nome', 'DESC'),
      );
      expect(
        tester.getTopLeft(find.text('Vestido Longo')).dy,
        lessThan(tester.getTopLeft(find.text('Calça Jeans')).dy),
      );
    });

    testWidgets(
      'rolagem infinita: ao chegar perto do fim pede a página 2 e o rodapé mostra quantas já carregou',
      (tester) async {
        final muitos = [
          for (var i = 1; i <= 8; i++)
            _item(
              i,
              'Ref ${i.toString().padLeft(2, '0')}',
              categoriaId: 10,
              categoria: 'Camisas',
            ),
        ];
        await abrir(
          tester,
          tela: const Size(1300, 480),
          itens: muitos,
          tamanhoPagina: 5,
        );
        expect(find.text('8 referências · mostrando 5'), findsOneWidget);

        await tester.drag(find.byType(ListView), const Offset(0, -2000));
        await tester.pumpAndSettle();

        expect(servidor.chamadas.last.page, 2);
        await tester.drag(find.byType(ListView), const Offset(0, -2000));
        await tester.pumpAndSettle();
        expect(find.text('Ref 08'), findsOneWidget);
        expect(find.text('8 referências'), findsOneWidget);
      },
    );

    testWidgets(
      'erro do servidor mostra "Tentar novamente", que consulta de novo',
      (tester) async {
        servidor = ServidorReferenciasFake(_quatro)
          ..falha = Exception('sem rede');
        tester.view.physicalSize = tela;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await sl.reset();
        sl.registerFactory<ReferenciasListaBloc>(
          () => ReferenciasListaBloc(BuscarReferencias(repository: servidor)),
        );
        await tester.pumpWidget(
          MaterialApp(theme: SivTheme.tema, home: const ReferenciasPage()),
        );
        await tester.pumpAndSettle();
        expect(find.text('Erro ao carregar referências'), findsOneWidget);

        servidor.falha = null;
        await tester.tap(find.text('Tentar novamente'));
        await tester.pumpAndSettle();

        expect(find.text('Camisa Básica'), findsOneWidget);
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
        expect(find.text('Nome A-Z'), findsOneWidget);
      },
    );

    testWidgets(
      'chip de categoria abre a folha com as contagens do servidor; escolher consulta e "Limpar" volta',
      (tester) async {
        await abrir(tester, tela: tela);

        await tester.tap(find.text('Categoria'));
        await tester.pumpAndSettle();
        expect(find.text('Calças'), findsOneWidget);
        expect(find.text('Limpar'), findsNothing);

        await tester.tap(find.text('Calças'));
        await tester.pumpAndSettle();
        expect(servidor.chamadas.last.categoriaId, 20);
        expect(find.text('Calça Jeans'), findsOneWidget);
        expect(find.text('Camisa Básica'), findsNothing);
        expect(find.text('1 referência encontrada'), findsOneWidget);

        await tester.tap(
          find.text('Calças'),
        ); // o chip agora mostra o nome da categoria
        await tester.pumpAndSettle();
        await tester.tap(find.text('Limpar'));
        await tester.pumpAndSettle();
        expect(servidor.chamadas.last.categoriaId, isNull);
        expect(find.text('4 referências'), findsOneWidget);
      },
    );

    testWidgets(
      'link de ordenação abre a folha, trocar consulta o servidor e muda o rótulo',
      (tester) async {
        await abrir(tester, tela: tela);

        await tester.tap(find.text('Nome A-Z'));
        await tester.pumpAndSettle();
        expect(find.text('Ordenar por'), findsOneWidget);

        await tester.tap(find.text('Nome (Z-A)'));
        await tester.pumpAndSettle();

        expect(find.text('Ordenar por'), findsNothing);
        expect(find.text('Nome Z-A'), findsOneWidget);
        expect(
          (servidor.chamadas.last.orderBy, servidor.chamadas.last.orderDir),
          ('nome', 'DESC'),
        );
      },
    );

    testWidgets(
      'chips de pendência e a busca também consultam o servidor no mobile',
      (tester) async {
        await abrir(tester, tela: tela);

        await tester.tap(find.text('Sem NCM').first);
        await tester.pumpAndSettle();
        expect(servidor.chamadas.last.semNcm, isTrue);
        expect(find.text('Camisa Polo'), findsOneWidget);
        expect(find.text('Camisa Básica'), findsNothing);
        expect(find.text('2 referências encontradas'), findsOneWidget);

        await digitar(tester, 'vest');
        expect(servidor.chamadas.last.busca, 'vest');
        expect(
          (servidor.chamadas.last.semNcm),
          isTrue,
          reason: 'a busca mantém o filtro de pendência',
        );
        expect(find.text('Vestido Longo'), findsOneWidget);
      },
    );
  });
}
