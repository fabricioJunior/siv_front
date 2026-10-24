import 'dart:async';

import 'package:core/injecoes.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:siv_front/presentation/bloc/sync_data/sync_data_bloc.dart';
import 'package:siv_front/presentation/pages/sync_page.dart';

import '../../doubles/use_cases.mocks.dart';

SyncDataState _estado(Map<SyncModulo, SyncModuloState> m, {DateTime? fim}) {
  const base = SyncDataState();
  return SyncDataState(
    modulos: {...base.modulos, ...m},
    iniciadoEm: DateTime(2026, 10, 23, 9),
    finalizadoEm: fim,
    origemUltimaSincronizacao: SyncDataOrigem.manual,
  );
}

SyncModuloState _mod(SyncModulo m, SyncModuloStatus s, {String? erro}) =>
    SyncModuloState(
      modulo: m,
      status: s,
      totalPaginas: 10,
      paginaAtual: 3,
      paginasSincronizadas: 4,
      itensSincronizados: 1234,
      totalItens: 5000,
      erro: erro,
    );

final _casos = <String, (SyncDataState, String)>{
  'andamento': (
    _estado({
      SyncModulo.codigos: _mod(SyncModulo.codigos, SyncModuloStatus.concluido),
      SyncModulo.estoque: _mod(
        SyncModulo.estoque,
        SyncModuloStatus.sincronizando,
      ),
    }),
    'EM ANDAMENTO',
  ),
  'concluida': (
    _estado({
      for (final m in SyncModulo.values) m: _mod(m, SyncModuloStatus.concluido),
    }, fim: DateTime(2026, 10, 23, 9, 5)),
    'ÚLTIMA SINCRONIZAÇÃO',
  ),
  'falha': (
    _estado({
      SyncModulo.codigos: _mod(
        SyncModulo.codigos,
        SyncModuloStatus.falha,
        erro: 'Timeout na API',
      ),
    }, fim: DateTime(2026, 10, 23, 9, 5)),
    'ÚLTIMA SINCRONIZAÇÃO',
  ),
  'aguardando': (const SyncDataState(), 'AGUARDANDO'),
};

Future<MockSyncDataBloc> _abre(
  WidgetTester t,
  double largura,
  SyncDataState s,
) async {
  await sl.reset();
  addTearDown(sl.reset);
  final bloc = MockSyncDataBloc();
  when(bloc.state).thenReturn(s);
  when(bloc.stream).thenAnswer((_) => const Stream.empty());
  when(bloc.close()).thenAnswer((_) async {});
  sl.registerSingleton<SyncDataBloc>(bloc);
  t.view.physicalSize = Size(largura, 1400);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(theme: SivTheme.tema, home: const SyncPage()));
  await t.pump(const Duration(milliseconds: 600));
  return bloc;
}

void main() {
  for (final largura in [1440.0, 390.0]) {
    for (final e in _casos.entries) {
      testWidgets('${e.key} @ $largura', (t) async {
        await _abre(t, largura, e.value.$1);
        expect(find.text(e.value.$2), findsOneWidget);
        expect(find.text('Códigos'), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsNothing);
        final sinc = e.key == 'andamento';
        expect(
          find.text(sinc ? 'Sincronizando…' : 'Sincronizar agora'),
          findsOneWidget,
        );
        final botao = find.ancestor(
          of: find.byIcon(Icons.sync),
          matching: find.byType(FilledButton),
        );
        expect(t.widget<FilledButton>(botao).onPressed == null, sinc);
        if (e.key == 'falha') {
          expect(find.text('Timeout na API'), findsOneWidget);
        }
      });
    }
  }

  testWidgets('Sincronizar agora dispara origem manual', (t) async {
    final bloc = await _abre(t, 1440, const SyncDataState());
    await t.tap(find.text('Sincronizar agora'));
    final ev =
        verify(bloc.add(captureAny)).captured.single
            as SyncDataSolicitouSincronizacao;
    expect(ev.origem, SyncDataOrigem.manual);
  });
}
