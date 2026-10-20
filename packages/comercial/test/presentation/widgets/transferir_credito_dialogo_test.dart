import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/injecoes.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Get implements GetCreditosTransferiveis {
  @override
  Future<List<CreditoTransferivel>> call({required int pessoaId}) async => [
        for (final id in [1, 2])
          CreditoTransferivel(
            romaneioId: id,
            faturaId: id,
            faturaParcela: 1,
            data: DateTime(2026, 1, 1),
            valor: 10.0 * id,
          ),
      ];
}

class _Transf implements TransferirCreditosDevolucao {
  List<int>? ids;
  @override
  Future<ResultadoTransferenciaCredito> call(
      {required int pessoaId, required List<int> romaneioIds}) async {
    ids = romaneioIds;
    return const ResultadoTransferenciaCredito(
        valorTotal: 30, saldoCreditoDevolucaoDestino: 30);
  }
}

void main() {
  for (final w in [800.0, 1280.0]) {
    testWidgets('regressão: seleciona, confirma e devolve resultado ($w px)',
        (t) async {
      t.view.physicalSize = Size(w, 900);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await sl.reset();
      addTearDown(sl.reset);
      final transf = _Transf();
      sl.registerFactory(() => TransferirCreditoBloc(_Get(), transf));
      ResultadoTransferenciaCredito? res;
      await t.pumpWidget(MaterialApp(
        theme: SivTheme.tema,
        home: Builder(
          builder: (c) => TextButton(
            onPressed: () async => res = await TransferirCreditoDialogo.mostrar(
                c, pessoaId: 7, nomeDestino: 'Maria'),
            child: const Text('abrir'),
          ),
        ),
      ));
      await t.tap(find.text('abrir'));
      await t.pumpAndSettle();
      expect(find.text('Destino: Maria'), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsNWidgets(2));
      final transferir = find.widgetWithText(FilledButton, 'TRANSFERIR R\$ 0,00');
      expect(t.widget<FilledButton>(transferir).onPressed, isNull);

      await t.tap(find.byType(CheckboxListTile).at(0));
      await t.tap(find.byType(CheckboxListTile).at(1));
      await t.pump();
      await t.tap(find.widgetWithText(FilledButton, 'TRANSFERIR R\$ 30,00'));
      await t.pumpAndSettle();
      expect(find.text('Confirmar transferência'), findsOneWidget);
      await t.tap(find.widgetWithText(FilledButton, 'Transferir'));
      await t.pumpAndSettle();
      expect(transf.ids, [1, 2]);
      expect(res?.valorTotal, 30);
    });
  }
}
