import 'package:comercial/domain/data/repositories/i_ecommerce_repository.dart';
import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/injecoes.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _RepositorioFake implements IEcommerceRepository {
  final List<EcommerceReferencia> referencias;

  _RepositorioFake(this.referencias);

  @override
  Future<EcommerceReferenciasPagina> recuperarReferencias(
    int ecommerceId, {
    String? busca,
    List<int>? categoriaIds,
    bool? rascunho,
    bool? publicavel,
    int page = 1,
    int limit = 50,
  }) async =>
      EcommerceReferenciasPagina(
        itens: referencias,
        total: referencias.length,
        totalPublicados: referencias.where((r) => !r.rascunho).length,
        totalRascunho: referencias.where((r) => r.rascunho).length,
        totalNaoPublicaveis: 0,
      );

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  setUp(() {
    sl.reset();
  });

  Future<void> montarPagina(
    WidgetTester tester, {
    required List<EcommerceReferencia> referencias,
    Size viewport = const Size(400, 800),
  }) async {
    final repo = _RepositorioFake(referencias);
    sl.registerFactory<EcommerceReferenciasBloc>(
      () => EcommerceReferenciasBloc(
        RecuperarReferenciasEcommerce(repository: repo),
        AdicionarReferenciaEcommerce(repository: repo),
        AtualizarReferenciaEcommerce(repository: repo),
        PublicarReferenciasEmLoteEcommerce(repository: repo),
      ),
    );

    // Tela de celular -- overflow reportado não aparece num viewport largo.
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: SivTheme.tema,
        home: Scaffold(
          body: EcommerceReferenciasPage(ecommerceId: 9),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lista de referências renderiza sem overflow', (tester) async {
    final referencias = List.generate(
      15,
      (i) => EcommerceReferencia.create(
        id: i,
        ecommerceId: 9,
        referenciaId: i,
        rascunho: i.isEven,
        referenciaNome: 'Produto $i',
        valor: 59.9,
      ),
    );

    await montarPagina(tester, referencias: referencias);

    expect(tester.takeException(), isNull);
    expect(find.byType(EcommerceReferenciasPage), findsOneWidget);
  });

  testWidgets('lista vazia renderiza sem overflow', (tester) async {
    await montarPagina(tester, referencias: const []);

    expect(tester.takeException(), isNull);
  });

  testWidgets('botão "Publicar aptas" conta só rascunho + publicável',
      (tester) async {
    final referencias = [
      EcommerceReferencia.create(
        id: 1,
        ecommerceId: 9,
        referenciaId: 1,
        rascunho: true,
        publicavel: true,
        referenciaNome: 'Apta',
        valor: 10,
      ),
      EcommerceReferencia.create(
        id: 2,
        ecommerceId: 9,
        referenciaId: 2,
        rascunho: true,
        publicavel: false,
        referenciaNome: 'Bloqueada',
        valor: 10,
      ),
      EcommerceReferencia.create(
        id: 3,
        ecommerceId: 9,
        referenciaId: 3,
        rascunho: false,
        publicavel: true,
        referenciaNome: 'Já publicada',
        valor: 10,
      ),
    ];

    await montarPagina(
      tester,
      referencias: referencias,
      viewport: const Size(1200, 800),
    );

    expect(find.text('Publicar aptas (1)'), findsOneWidget);
    await tester.tap(find.text('Publicar aptas (1)'));
    await tester.pumpAndSettle();

    expect(find.text('Publicar todas as aptas'), findsOneWidget);
  });
}
