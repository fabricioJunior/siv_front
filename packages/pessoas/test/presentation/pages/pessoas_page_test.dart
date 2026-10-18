import 'package:core/injecoes.dart';
import 'package:core/permissoes/i_permissoes_controller.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/presentation/bloc/pessoas_bloc/pessoas_bloc.dart';
import 'package:pessoas/presentation/pages/pessoas_page.dart';
import 'package:pessoas/presentation/pages/selecionar_pessoa_page.dart';
import 'package:pessoas/uses_cases.dart';

import '../../doubles/fakes.dart';

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

class _RecPessoas extends Mock implements RecuperarPessoas {
  final List<({bool? cliente, bool? fornecedor})> chamadas = [];
  @override
  Future<Iterable<Pessoa>> call({
    int pagina = 1,
    String? busca,
    bool? eCliente,
    bool? eFornecedor,
    bool? eFuncionario,
    bool? clienteOuFuncionario,
  }) async {
    chamadas.add((cliente: eCliente, fornecedor: eFornecedor));
    return [
      fakePessoa(id: 7, nome: 'Maria Souza', documento: '12345678901'),
      fakePessoa(
        id: 8,
        nome: 'Loja LTDA',
        tipoPessoa: TipoPessoa.juridica,
        documento: '12345678000199',
      ),
    ];
  }
}

class _RecPessoa extends Mock implements RecuperarPessoa {}

Future<_RecPessoas> _pump(
  WidgetTester t, {
  double largura = 1280,
  Set<String> permissoes = const {'PESFM001'},
  Widget home = const PessoasPage(),
  Map<String, WidgetBuilder> rotas = const {},
  List<Object?>? argumentos,
}) async {
  t.view.physicalSize = Size(largura, 900);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await sl.reset();
  addTearDown(sl.reset);
  final rec = _RecPessoas();
  sl.registerSingleton<IPermissoesController>(_Permissoes(permissoes));
  sl.registerFactory(() => PessoasBloc(rec, _RecPessoa()));
  await t.pumpWidget(MaterialApp(
    theme: SivTheme.tema,
    home: home,
    routes: rotas,
    onGenerateRoute: (s) {
      argumentos?.add(s.arguments);
      return MaterialPageRoute(
        settings: s,
        builder: (_) => Text('ROTA ${s.name}'),
      );
    },
  ));
  await t.pumpAndSettle();
  return rec;
}

void main() {
  for (final largura in [800.0, 1280.0]) {
    final desktop = largura >= 820;
    group('PessoasPage ($largura px)', () {
      testWidgets(desktop ? 'tabela' : 'lista de linhas', (t) async {
        await _pump(t, largura: largura);
        expect(find.byType(SivTabela), desktop ? findsOneWidget : findsNothing);
        expect(find.text('NOME'), desktop ? findsOneWidget : findsNothing);
        expect(find.text('Maria Souza'), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right),
            desktop ? findsNothing : findsNWidgets(2));
      });

      testWidgets('documento mascarado, nunca completo', (t) async {
        await _pump(t, largura: largura);
        expect(find.textContaining('123.***.***-01'), findsOneWidget);
        expect(find.textContaining('12.***.***/****-99'), findsOneWidget);
        expect(find.textContaining('12345678901'), findsNothing);
      });

      testWidgets('segmentado dispara eCliente/eFornecedor', (t) async {
        final rec = await _pump(t, largura: largura);
        expect(rec.chamadas.last, (cliente: true, fornecedor: null));
        await t.tap(find.text('Fornecedores'));
        await t.pumpAndSettle();
        expect(rec.chamadas.last, (cliente: null, fornecedor: true));
        await t.tap(find.text('Clientes'));
        await t.pumpAndSettle();
        expect(rec.chamadas.last, (cliente: true, fornecedor: null));
      });

      testWidgets('+ Novo cliente só com PESFM001', (t) async {
        await _pump(t, largura: largura);
        expect(find.text('+ Novo cliente'), findsOneWidget);
        await _pump(t, largura: largura, permissoes: {});
        expect(find.text('+ Novo cliente'), findsNothing);
        expect(find.text('Pessoas'), findsOneWidget);
      });

      testWidgets('clique na linha abre /pessoa_visualizacao', (t) async {
        final args = <Object?>[];
        await _pump(t, largura: largura, argumentos: args);
        await t.tap(find.text('Maria Souza'));
        await t.pumpAndSettle();
        expect(find.text('ROTA /pessoa_visualizacao'), findsOneWidget);
        expect(args.last, {'idPessoa': 7});
      });
    });
  }

  testWidgets('regressão: SelecionarPessoaPage lista via PessoasBloc',
      (t) async {
    await _pump(t, home: const SelecionarPessoaPage());
    expect(find.text('Selecionar pessoa'), findsOneWidget);
    expect(find.text('MARIA SOUZA'), findsOneWidget);
    expect(find.text('LOJA LTDA'), findsOneWidget);
  });
}
