import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:produtos/repositorios.dart';
import 'package:produtos/use_cases.dart';

import '../../doubles/fakes.dart';
import 'consulta_fakes.dart';

class _CoresRepo implements ICoresRepository {
  @override
  Future<List<Cor>> obterCores({String? nome, bool? inativo}) async => [
        fakeCor(id: 1, nome: 'Azul'),
        fakeCor(id: 2, nome: 'Preto'),
        fakeCor(id: 3, nome: 'Verde'),
      ];

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

Future<ConsultarProdutoBloc> _abrir(WidgetTester t, Size tamanho) async {
  t.view.physicalSize = tamanho;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final repo = _CoresRepo();
  sl.registerFactory<CoresBloc>(() => CoresBloc(
        RecuperarCores(coresRepository: repo),
        DesativarCor(coresRepository: repo),
      ));
  final bloc = novoBloc(FakeConsultaRepo(), FakeGradeRepo());
  addTearDown(bloc.close);
  await t.pumpWidget(MaterialApp(
    home: BlocProvider.value(
      value: bloc,
      child: ConsultarProdutoPage(tabelaDePrecoSeletor: (_) => const SizedBox()),
    ),
  ));
  await t.pumpAndSettle();
  return bloc;
}

Future<void> _escolherDuas(WidgetTester t) async {
  await t.tap(find.byKey(const Key('add_cor')));
  await t.pumpAndSettle();
  expect(find.byType(SeletorTelaCheia<Cor>), findsOneWidget);
  await t.tap(find.byKey(const Key('sel_item_1')));
  await t.tap(find.byKey(const Key('sel_item_3')));
  await t.pump();
  await t.tap(find.byKey(const Key('sel_confirmar')));
  await t.pumpAndSettle();
}

void main() {
  tearDown(() => sl.reset());

  testWidgets('mobile 400: blocos, escolher, remover e cancelar', (t) async {
    final bloc = await _abrir(t, const Size(400, 800));
    expect(find.text('COR'), findsOneWidget);
    expect(find.text('ESTAMPA'), findsOneWidget);
    expect(find.text('TAMANHO'), findsOneWidget);
    for (final b in ['+ cor', '+ estampa', '+ tam.']) {
      expect(find.text(b), findsOneWidget);
    }
    expect(find.text('Filtros'), findsNothing);

    await _escolherDuas(t);
    expect(bloc.state.cores.map((c) => c.id), [1, 3]);
    expect(find.byKey(const Key('chip_cor_1')), findsOneWidget);
    expect(find.byKey(const Key('chip_cor_3')), findsOneWidget);

    await t.tap(find.byKey(const Key('add_cor')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('sel_item_2')));
    await t.tap(find.byKey(const Key('sel_voltar')));
    await t.pumpAndSettle();
    expect(bloc.state.cores.map((c) => c.id), [1, 3]);

    await t.tap(find.descendant(
        of: find.byKey(const Key('chip_cor_1')), matching: find.byType(Icon)));
    await t.pumpAndSettle();
    expect(bloc.state.cores.map((c) => c.id), [3]);
    expect(find.byKey(const Key('chip_cor_1')), findsNothing);
  });

  testWidgets('desktop 1280: mantém ExpansionTile de filtros', (t) async {
    await _abrir(t, const Size(1280, 800));
    expect(find.text('Filtros'), findsOneWidget);
    expect(find.byKey(const Key('add_cor')), findsNothing);
  });
}
