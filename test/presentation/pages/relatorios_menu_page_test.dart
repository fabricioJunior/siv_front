import 'package:core/injecoes.dart';
import 'package:core/permissoes/i_permissoes_controller.dart';
import 'package:core/sessao.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siv_front/presentation/pages/relatorios_menu_page.dart';

class _Perm implements IPermissoesController {
  final Set<String> ok;
  _Perm(this.ok);

  @override
  bool temAcesso({String? idComponente, int? grupoId}) => ok.contains(idComponente);

  @override
  Future<bool> acessoPermitido({String? idComponente, int? grupoId}) async =>
      temAcesso(idComponente: idComponente);
}

class _Sessao implements IAcessoGlobalSessao {
  @override
  int? get usuarioIdDaSessao => null;

  @override
  String? get empresaNomeDaSessao => 'Loja';

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

const _novos = {
  'RELFC014': 'Estoque',
  'RELFC015': 'Movimentações do sistema',
  'RELFC016': 'Frequência de clientes',
};

Future<void> _abre(WidgetTester t, double largura, Set<String> permitidos) async {
  await sl.reset();
  addTearDown(sl.reset);
  sl.registerSingleton<IPermissoesController>(_Perm(permitidos));
  sl.registerSingleton<IAcessoGlobalSessao>(_Sessao());
  t.view.physicalSize = Size(largura, 1600);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(const SizedBox());
  await t.pumpWidget(MaterialApp(theme: SivTheme.tema, home: const Scaffold(body: RelatoriosMenuPage())));
  await t.pumpAndSettle();
}

void main() {
  for (final largura in [800.0, 1280.0]) {
    testWidgets('sem RELFC014/15/16 os itens somem ($largura)', (t) async {
      await _abre(t, largura, {'RELFC001'});
      for (final n in _novos.values) {
        expect(find.text(n), findsNothing, reason: n);
      }
      expect(find.text('Faturamento e Ticket'), findsOneWidget);
    });

    testWidgets('com os componentes os itens aparecem ($largura)', (t) async {
      await _abre(t, largura, {'RELFC001', ..._novos.keys});
      for (final n in _novos.values) {
        expect(find.text(n), findsOneWidget, reason: n);
      }
    });

    testWidgets('cada componente libera só o seu item ($largura)', (t) async {
      for (final e in _novos.entries) {
        await _abre(t, largura, {e.key});
        expect(find.text(e.value), findsOneWidget);
        for (final o in _novos.values.where((v) => v != e.value)) {
          expect(find.text(o), findsNothing);
        }
      }
    });
  }

  test('acordeão do menu lateral tem os 3 componentes novos', () {
    final cs = {for (final f in relatoriosAcordeaoItens) f.componente: f.rota};
    expect(cs['RELFC014'], '/relatorio_estoque');
    expect(cs['RELFC015'], '/relatorio_movimentacoes');
    expect(cs['RELFC016'], '/relatorio_frequencia_clientes');
  });
}
