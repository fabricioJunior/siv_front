import 'package:core/injecoes.dart';
import 'package:core/leitor.dart';
import 'package:core/sessao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Sessao implements IAcessoGlobalSessao {
  @override
  dynamic noSuchMethod(Invocation i) {
    if (i.memberName == #dadosSincronizados) return true;
    if (i.memberName == #sincronizandoDados) return const Stream<bool>.empty();
    return null;
  }
}

class _Produto with LeitorData {
  @override
  final String codigoDeBarras;
  _Produto(this.codigoDeBarras);
  @override
  String get descricao => 'Produto $codigoDeBarras';
  @override
  int get quantidade => 100;
  @override
  int get idReferencia => 1;
  @override
  String get tamanho => 'M';
  @override
  String get cor => 'Preto';
  @override
  double? get valor => 10;
  @override
  int get id => 1;
  @override
  Map<String, dynamic> get dados => const {};
}

class _Fonte implements ILeitorDataDatasource {
  @override
  Future<LeitorData?> getData(String codigo, {int? tabelaDePrecoId}) async =>
      _Produto(codigo);
  @override
  Future<LeitorData?> getDataPorProdutoId(int produtoId,
          {int? tabelaDePrecoId}) async =>
      null;
}

const _esperados = [
  ProdutoEsperado(id: 1, codigoDeBarras: 'A', descricao: 'Pendente', esperado: 4, lido: 0),
  ProdutoEsperado(id: 2, codigoDeBarras: 'B', descricao: 'Parcial', esperado: 4, lido: 2),
  ProdutoEsperado(id: 3, codigoDeBarras: 'C', descricao: 'Conferido', esperado: 3, lido: 3),
  ProdutoEsperado(id: 4, codigoDeBarras: 'D', descricao: 'Excedente', esperado: 2, lido: 3),
];

void main() {
  setUp(() async {
    await sl.reset();
    sl.registerSingleton<IAcessoGlobalSessao>(_Sessao());
  });
  tearDown(() async => sl.reset());

  Future<void> abrir(
    WidgetTester t, {
    List<ProdutoEsperado>? esperados,
    ValueChanged<LeitorItemContado>? onLido,
    ValueChanged<String>? onErro,
    void Function(ProdutoEsperado, int)? onCorrigir,
    ValueChanged<ProdutoEsperado>? onRemover,
  }) async {
    t.view.physicalSize = const Size(420, 1400);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: LeitorWidget(
              dataSource: _Fonte(),
              autofocus: false,
              alturaLista: 500,
              produtosEsperados: esperados,
              onUltimoProdutoLido: onLido,
              onErro: onErro,
              onCorrigirContagem: onCorrigir,
              onRemoverLeitura: onRemover,
            ),
          ),
        ),
      ),
    );
    await t.pump();
  }

  Future<void> bipar(WidgetTester t, String codigo) async {
    await t.enterText(find.byType(TextField).first, codigo);
    await t.testTextInput.receiveAction(TextInputAction.done);
    await t.pump();
    await t.pump();
  }

  testWidgets('modo conferência: abas, 4 situações e progresso', (t) async {
    await abrir(t, esperados: _esperados);

    expect(find.text('MODO CONFERÊNCIA · CONTADO × LIDO'), findsOneWidget);
    expect(find.text('A CONFERIR · 2'), findsOneWidget);
    expect(find.text('CONFERIDOS · 1'), findsOneWidget);
    expect(find.text('TODOS'), findsOneWidget);
    expect(find.text('EXCEDENTES'), findsOneWidget);
    expect(find.text('LISTA'), findsNothing);
    expect(find.text('PENDENTE'), findsOneWidget);
    expect(find.text('PARCIAL'), findsOneWidget);
    expect(find.text('CONFERIDO'), findsNothing);

    await t.tap(find.byKey(const Key('aba_conferencia_conferidos')));
    await t.pump();
    expect(find.text('CONFERIDO'), findsOneWidget);

    await t.tap(find.byKey(const Key('aba_conferencia_excedentes')));
    await t.pump();
    expect(find.text('EXCEDENTE'), findsOneWidget);

    await t.tap(find.byKey(const Key('aba_conferencia_todos')));
    await t.pump();
    expect(find.byKey(const Key('conferencia_linha_1')), findsOneWidget);
    expect(find.byKey(const Key('conferencia_linha_4')), findsOneWidget);
    final barra = t.widget<LinearProgressIndicator>(
      find.byKey(const Key('conferencia_barra_2')),
    );
    expect(barra.value, 0.5);
  });

  testWidgets('código fora da lista vai para onErro e não soma', (t) async {
    String? erro;
    var lidos = 0;
    await abrir(
      t,
      esperados: _esperados,
      onErro: (e) => erro = e,
      onLido: (_) => lidos++,
    );
    await bipar(t, 'XYZ');

    expect(erro, 'Código XYZ não pertence a esta entrada.');
    expect(lidos, 0);
  });

  testWidgets('código da lista dispara onUltimoProdutoLido', (t) async {
    final lidos = <String>[];
    await abrir(
      t,
      esperados: _esperados,
      onLido: (i) => lidos.add(i.codigoDeBarras),
    );
    await bipar(t, 'A');
    await t.pump(const Duration(milliseconds: 50));
    expect(lidos, ['A']);
  });

  testWidgets('remover por leitura chama onRemoverLeitura', (t) async {
    ProdutoEsperado? removido;
    await abrir(t, esperados: _esperados, onRemover: (p) => removido = p);
    await t.tap(find.byType(FilterChip));
    await t.pump();
    await bipar(t, 'B');
    expect(removido?.id, 2);
  });

  testWidgets('Corrigir só em linha parcial/excedente com lido > 0', (t) async {
    (ProdutoEsperado, int)? chamada;
    await abrir(
      t,
      esperados: _esperados,
      onCorrigir: (p, l) => chamada = (p, l),
    );
    await t.tap(find.byKey(const Key('aba_conferencia_todos')));
    await t.pump();
    expect(find.byKey(const Key('conferencia_corrigir_1')), findsNothing);
    expect(find.byKey(const Key('conferencia_corrigir_3')), findsNothing);
    await t.tap(find.byKey(const Key('conferencia_corrigir_2')));
    expect(chamada?.$1.id, 2);
    expect(chamada?.$2, 2);
    expect(find.byKey(const Key('conferencia_corrigir_4')), findsOneWidget);
  });

  testWidgets('REGRESSÃO: sem produtosEsperados o leitor é o de sempre',
      (t) async {
    final lidos = <String>[];
    await abrir(t, onLido: (i) => lidos.add(i.codigoDeBarras));

    expect(find.text('Leitor de código de barras'), findsOneWidget);
    expect(find.text('LISTA'), findsOneWidget);
    expect(find.text('GRADE'), findsOneWidget);
    expect(find.text('QTDES'), findsOneWidget);
    expect(find.text('A CONFERIR · 0'), findsNothing);

    // código qualquer é lido (sem lista de esperados nada é rejeitado)
    await bipar(t, 'QUALQUER');
    await t.pump(const Duration(milliseconds: 50));
    expect(lidos, ['QUALQUER']);

    // remoção por leitura continua no bloc
    await t.tap(find.byType(FilterChip));
    await t.pump();
    await bipar(t, 'QUALQUER');
    expect(find.text('Removendo por leitura (toque para desativar)'),
        findsOneWidget);
  });
}
