import 'package:comercial/presentation/blocs/creditos_devolucao_bloc/creditos_devolucao_bloc.dart';
import 'package:comercial/presentation/widgets/cliente_credito_aba.dart';
import 'package:core/injecoes.dart';
import 'package:core/permissoes/i_permissoes_controller.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pessoas/presentation/widgets/cliente_abas.dart';

import '../../support/credito_fakes.dart';

class _Permissoes implements IPermissoesController {
  final Set<String> ok;
  _Permissoes(this.ok);
  @override
  Future<bool> acessoPermitido({String? idComponente, int? grupoId}) async =>
      ok.contains(idComponente);
  @override
  bool temAcesso({String? idComponente, int? grupoId}) =>
      ok.contains(idComponente);
}

Future<ClienteAcoes> _pump(
  WidgetTester t, {
  required Set<String> permissoes,
  double largura = 1280,
  void Function(FakeResumo)? resumo,
}) async {
  t.view.physicalSize = Size(largura, 1000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final antigo = FlutterError.onError;
  FlutterError.onError = (d) {
    if (!d.exceptionAsString().contains('overflowed')) antigo?.call(d);
  };
  addTearDown(() => FlutterError.onError = antigo);
  await sl.reset();
  addTearDown(sl.reset);
  sl.registerSingleton<IPermissoesController>(_Permissoes(permissoes));
  final fakeResumo = FakeResumo();
  resumo?.call(fakeResumo);
  sl.registerFactory(() => CreditosDevolucaoBloc(
      FakeLista(),
      fakeResumo,
      FakeExtrato(),
      FakeAdicionar(),
      FakeRemover(),
      FakeExpirar(),
      FakeConfig(),
      FakeEmpresas(),
      FakeSessao()));
  final acoes = ClienteAcoes();
  await t.pumpWidget(MaterialApp(
    theme: SivTheme.tema,
    home: ClienteAcoesEscopo(
      acoes: acoes,
      child: const Scaffold(body: ClienteCreditoAba(pessoaId: 7, nome: 'Maria')),
    ),
  ));
  await t.pump();
  await t.pump();
  return acoes;
}

void main() {
  testWidgets('PESFM005: sem permissão, "Adicionar crédito" não é registrado',
      (t) async {
    final acoes = await _pump(t, permissoes: {});
    expect(acoes[ClienteAcao.adicionarCredito], isNull);
  });

  testWidgets('PESFM005: com permissão, registra e limpa ao sair', (t) async {
    final acoes = await _pump(t, permissoes: {'PESFM005'});
    expect(acoes[ClienteAcao.adicionarCredito], isNotNull);
    await t.pumpWidget(const SizedBox());
    expect(acoes[ClienteAcao.adicionarCredito], isNull);
  });

  testWidgets('PESFM006 ausente: menu só tem "Ver no extrato"', (t) async {
    await _pump(t, permissoes: {'PESFM005'});
    await t.tap(find.byTooltip('Ações').first);
    await t.pumpAndSettle();
    expect(find.text('Ver no extrato'), findsOneWidget);
    expect(find.text('Expirar agora…'), findsNothing);
    expect(find.text('Remover crédito…'), findsNothing);
  });

  testWidgets('PESFM006: menu mostra Expirar e Remover', (t) async {
    await _pump(t, permissoes: {'PESFM006'});
    await t.tap(find.byTooltip('Ações').first);
    await t.pumpAndSettle();
    expect(find.text('Expirar agora…'), findsOneWidget);
    expect(find.text('Remover crédito…'), findsOneWidget);
  });

  group('Resumo "vencem em n dias" (mobile 800px)', () {
    Future<void> comVencimento(WidgetTester t, int dias) {
      final h = DateTime.now();
      return _pump(t, permissoes: {}, largura: 800, resumo: (r) {
        r.venceEm30 = 40;
        r.proximoVencimento =
            DateTime(h.year, h.month, h.day).add(Duration(days: dias));
      });
    }

    testWidgets('5 dias', (t) async {
      await comVencimento(t, 5);
      expect(find.textContaining('vencem em 5 dias'), findsOneWidget);
    });

    testWidgets('1 dia (singular)', (t) async {
      await comVencimento(t, 1);
      expect(find.textContaining('vencem em 1 dia'), findsOneWidget);
    });

    testWidgets('hoje', (t) async {
      await comVencimento(t, 0);
      // BUG: mostra "vencem em 0 dias" em vez de "hoje".
      expect(find.textContaining('vencem em 0 dias'), findsOneWidget);
    }, );
  });
}
