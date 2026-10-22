import 'package:comercial/data/remote/dtos/documento_fiscal_dto.dart';
import 'package:comercial/presentation/blocs/romaneio_criacao_bloc/romaneio_criacao_bloc.dart';
import 'package:comercial/presentation/blocs/venda_bloc/venda_bloc.dart';
import 'package:comercial/presentation/venda/venda_concluida_view.dart';
import 'package:comercial/presentation/venda/venda_etapa.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

DocumentoFiscalDto _nota(String status) => DocumentoFiscalDto.fromJson({
      'id': 9,
      'empresaId': 1,
      'romaneioId': 48213,
      'acao': 'emitir',
      'tipoDocumento': 'nfe_venda',
      'status': status,
      'provider': 'sefaz',
      'tentativas': 1,
      'maxTentativas': 5,
    });

Future<void> _pump(WidgetTester t, Widget w) async {
  t.view.physicalSize = const Size(1000, 1000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final antigo = FlutterError.onError;
  FlutterError.onError = (d) {
    if (!d.exceptionAsString().contains('overflowed')) antigo?.call(d);
  };
  addTearDown(() => FlutterError.onError = antigo);
  await t.pumpWidget(
    MaterialApp(theme: SivTheme.tema, home: Scaffold(body: w)),
  );
}

void main() {
  group('etapaDaVenda', () {
    const leitura = VendaState(step: VendaStep.leitura);
    const pagamento = VendaState(step: VendaStep.pagamento);
    final lista = ListaDeProdutosCompartilhada(
      hash: 'h',
      origem: OrigemCompartilhadaTipo.venda,
      criadaEm: DateTime(2026),
      atualizadaEm: DateTime(2026),
    );
    RomaneioCriacaoState criacao(RomaneioCriacaoStep step, {int? romaneioId}) =>
        RomaneioCriacaoState(
          step: step,
          listaCompartilhada: lista.copyWith(idLista: romaneioId),
        );

    test('Itens → Pagamento → Concluída', () {
      expect(etapaDaVenda(const VendaState(), null), VendaEtapa.configuracao);
      expect(etapaDaVenda(leitura, null), VendaEtapa.itens);
      expect(etapaDaVenda(pagamento, null), VendaEtapa.pagamento);
      expect(
        etapaDaVenda(
            pagamento, criacao(RomaneioCriacaoStep.finalizandoVenda)),
        VendaEtapa.processando,
      );
      expect(
        etapaDaVenda(
            pagamento, criacao(RomaneioCriacaoStep.sucesso, romaneioId: 7)),
        VendaEtapa.concluida,
      );
    });

    test('falha total volta ao pagamento (ou aos itens, se deu Esc)', () {
      final falha = criacao(RomaneioCriacaoStep.falha);
      expect(etapaDaVenda(pagamento, falha), VendaEtapa.pagamento);
      expect(etapaDaVenda(leitura, falha), VendaEtapa.itens);
    });

    test('parcial (romaneio criado, não recebido) vira pendência', () {
      expect(
        etapaDaVenda(pagamento,
            criacao(RomaneioCriacaoStep.falha, romaneioId: 7)),
        VendaEtapa.pendencia,
      );
    });
  });

  testWidgets('Concluída: troco, romaneio, formas e NF-e ficam na tela',
      (t) async {
    var novaVenda = 0;
    var imprimiu = 0;
    await _pump(
      t,
      VendaConcluidaView(
        romaneioId: 48213,
        cliente: 'Boutique Rosa Maria',
        concluidaEm: DateTime(2026, 10, 22, 9, 25),
        formas: const [('PIX', 300), ('Dinheiro', 320)],
        totalVenda: 610.38,
        troco: 9.62,
        pontuou: true,
        documentoFiscal: _nota('emitida'),
        emailNota: 'compras@rosamaria.com.br',
        onImprimir: () => imprimiu++,
        onReenviarNota: () {},
        onNovaVenda: () => novaVenda++,
      ),
    );

    expect(find.text('VENDA CONCLUÍDA'), findsOneWidget);
    expect(find.textContaining('Romaneio #48213'), findsOneWidget);
    expect(find.textContaining('09:25'), findsOneWidget);
    expect(find.text('DEVOLVER DE TROCO'), findsOneWidget);
    expect(find.text('R\$ 9,62'), findsOneWidget);
    expect(find.text('PIX'), findsOneWidget);
    expect(find.text('R\$ 320,00'), findsOneWidget);
    expect(find.text('R\$ 610,38'), findsOneWidget);
    expect(find.text('Fidelidade'), findsOneWidget);
    expect(find.textContaining('NF-e autorizada · enviada para compras@'),
        findsOneWidget);

    await t.sendKeyEvent(LogicalKeyboardKey.keyP);
    expect(imprimiu, 1);
    await t.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(novaVenda, 1);
  });

  testWidgets('Concluída: sem troco e nota em emissão não bloqueia a venda',
      (t) async {
    await _pump(
      t,
      VendaConcluidaView(
        romaneioId: 1,
        cliente: null,
        concluidaEm: DateTime(2026),
        formas: const [('PIX', 50)],
        totalVenda: 50,
        troco: 0,
        pontuou: false,
        documentoFiscal: _nota('processando'),
        emailNota: null,
        onImprimir: () {},
        onReenviarNota: () {},
        onNovaVenda: () {},
      ),
    );

    expect(find.text('SEM TROCO'), findsOneWidget);
    expect(find.text('NF-e em emissão...'), findsOneWidget);
    expect(find.text('Fidelidade'), findsNothing);
    final reenviar = find.widgetWithText(OutlinedButton, 'Reenviar nota');
    expect(t.widget<OutlinedButton>(reenviar).onPressed, isNull);
  });

  testWidgets('Pendência: nada cobrado, motivo e tentar de novo', (t) async {
    var tentou = 0;
    var nova = 0;
    await _pump(
      t,
      VendaPendenciaView(
        romaneioId: 48213,
        motivo: 'Estoque insuficiente: Batom',
        onVerRomaneio: () {},
        onNovaVenda: () => nova++,
        onTentarNovamente: () => tentou++,
      ),
    );

    expect(find.textContaining('ROMANEIO #48213 CRIADO'), findsOneWidget);
    expect(find.textContaining('nada foi cobrado e o estoque não baixou'),
        findsOneWidget);
    expect(find.text('Estoque insuficiente: Batom'), findsOneWidget);

    await t.tap(find.text('Nova venda'));
    expect(nova, 1);
    await t.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(tentou, 1);
  });
}
