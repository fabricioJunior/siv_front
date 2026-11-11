import 'dart:async';

import 'package:core/injecoes.dart';
import 'package:core/leitor.dart';
import 'package:core/sessao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Sessao implements IAcessoGlobalSessao {
  final sync = StreamController<bool>.broadcast();
  bool sincronizando = false;
  @override
  dynamic noSuchMethod(Invocation i) {
    if (i.memberName == #dadosSincronizados) return !sincronizando;
    if (i.memberName == #sincronizandoDados) return sync.stream;
    return null;
  }
}

class _Produto with LeitorData {
  @override
  String get codigoDeBarras => '777';
  @override
  String get descricao => 'Produto 777';
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
  int get id => 7;
  @override
  Map<String, dynamic> get dados => const {};
}

class _Fonte implements ILeitorDataDatasource {
  @override
  Future<LeitorData?> getData(String codigo, {int? tabelaDePrecoId}) async =>
      _Produto();
  @override
  Future<LeitorData?> getDataPorProdutoId(int produtoId,
          {int? tabelaDePrecoId}) async =>
      _Produto();
}

void main() {
  late _Sessao sessao;
  setUp(() async {
    await sl.reset();
    sessao = _Sessao();
    sl.registerSingleton<IAcessoGlobalSessao>(sessao);
  });
  tearDown(() async => sl.reset());

  testWidgets(
      'item que entra durante a sincronização aparece no controller (total e botão da tela) quando ela termina',
      (t) async {
    t.view.physicalSize = const Size(1400, 900);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final controller = LeitorController();
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LeitorWidget(
            controller: controller,
            dataSource: _Fonte(),
            controlarQuantidade: true,
            tabelaDePrecoId: 1,
            aceitarApenasProdutosComPreco: true,
          ),
        ),
      ),
    );

    sessao.sync.add(true);
    await t.pump();
    controller.preCarregarProdutos(const [ProdutosPreCarregado(id: 7, quantidade: 2)]);
    await t.pump(const Duration(milliseconds: 200));
    expect(controller.itens, isEmpty); // consumer fora da árvore: controller não ouviu

    sessao.sync.add(false);
    await t.pumpAndSettle();
    expect(controller.itens, hasLength(1));
    expect(controller.valorTotalLido, 20);
  });
}
