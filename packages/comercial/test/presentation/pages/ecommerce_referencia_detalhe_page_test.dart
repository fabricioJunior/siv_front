import 'package:comercial/domain/data/repositories/i_ecommerce_repository.dart';
import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/injecoes.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _RepositorioFake implements IEcommerceRepository {
  final List<EcommerceReferenciaProduto> produtos;

  _RepositorioFake(this.produtos);

  @override
  Future<List<EcommerceReferenciaProduto>> recuperarProdutosDaReferencia(
    int ecommerceId,
    int referenciaId,
  ) async =>
      produtos;

  @override
  Future<void> atualizarDisponibilidadeProduto(
    int ecommerceId,
    int referenciaId,
    int produtoId, {
    required bool disponivel,
  }) async {}

  @override
  Future<void> atualizarDisponibilidadeProdutosEmLote(
    int ecommerceId,
    int referenciaId, {
    required List<int> produtoIds,
    required bool disponivel,
    void Function(int atual, int total)? onProgresso,
  }) async {}

  @override
  Future<EcommerceReferencia> atualizarReferencia(
    int ecommerceId,
    int id, {
    bool? rascunho,
    int? tabelaDePrecoId,
  }) =>
      throw UnimplementedError();

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  setUp(() {
    sl.reset();
  });

  Future<void> montarPagina(
    WidgetTester tester, {
    required EcommerceReferencia referencia,
    required List<EcommerceReferenciaProduto> produtos,
  }) async {
    final repo = _RepositorioFake(produtos);
    sl.registerFactory<EcommerceReferenciaDetalheBloc>(
      () => EcommerceReferenciaDetalheBloc(
        RecuperarProdutosDaReferenciaEcommerce(repository: repo),
        AtualizarDisponibilidadeProdutoEcommerce(repository: repo),
        AtualizarDisponibilidadeProdutosEmLoteEcommerce(repository: repo),
        AtualizarReferenciaEcommerce(repository: repo),
      ),
    );

    // Tela de celular, do jeito que o bug foi reportado -- overflow e
    // "No Material widget found" não aparecem num viewport largo de desktop.
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: SivTheme.tema,
        home: Scaffold(
          body: EcommerceReferenciaDetalhePage(
            ecommerceId: referencia.ecommerceId,
            referencia: referencia,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('sem pendências: Switch e checklist renderizam sem erro', (tester) async {
    final referencia = EcommerceReferencia.create(
      id: 1,
      ecommerceId: 9,
      referenciaId: 123,
      rascunho: true,
      referenciaNome: 'Camiseta básica',
      valor: 59.9,
      motivosBloqueio: const [],
    );
    final produtos = [
      EcommerceReferenciaProduto.create(
        ecommerceReferenciaId: 1,
        produtoId: 1,
        disponivel: true,
        corNome: 'Azul',
        tamanhoNome: 'M',
        saldo: 5,
      ),
    ];

    await montarPagina(tester, referencia: referencia, produtos: produtos);

    expect(tester.takeException(), isNull);
    expect(find.byType(Switch), findsOneWidget);
  });

  testWidgets('com motivosBloqueio: checklist bloqueada renderiza sem erro', (tester) async {
    final referencia = EcommerceReferencia.create(
      id: 2,
      ecommerceId: 9,
      referenciaId: 456,
      rascunho: true,
      referenciaNome: 'Calça jeans',
      motivosBloqueio: const ['SEM_PRECO', 'SEM_IMAGEM'],
    );
    final produtos = [
      EcommerceReferenciaProduto.create(
        ecommerceReferenciaId: 2,
        produtoId: 2,
        disponivel: false,
        corNome: 'Preto',
        tamanhoNome: 'G',
        saldo: 0,
      ),
    ];

    await montarPagina(tester, referencia: referencia, produtos: produtos);

    expect(tester.takeException(), isNull);
    expect(find.byType(Switch), findsOneWidget);
  });
}
