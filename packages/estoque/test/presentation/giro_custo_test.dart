import 'package:core/injecoes.dart';
import 'package:core/permissoes/i_permissoes_controller.dart';
import 'package:core/tema.dart';
import 'package:estoque/data/remote/dtos/relatorio_giro_estoque_dto.dart';
import 'package:estoque/domain/models/parametros_giro.dart';
import 'package:estoque/domain/models/relatorio_giro_estoque.dart';
import 'package:estoque/presentation/blocs/relatorio_giro_estoque_bloc/relatorio_giro_estoque_bloc.dart';
import 'package:estoque/presentation/pages/giro_estoque/giro_formatacao.dart';
import 'package:estoque/presentation/pages/giro_estoque/giro_mobile.dart';
import 'package:estoque/presentation/pages/giro_estoque/giro_painel.dart';
import 'package:estoque/presentation/pages/giro_estoque/giro_tabela.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Perm implements IPermissoesController {
  final bool ok;
  _Perm(this.ok);
  @override
  bool temAcesso({String? idComponente, int? grupoId}) => ok;
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

final _tema = ThemeData(extensions: const [
  SivTextStyles(
    display: TextStyle(),
    titulo: TextStyle(),
    secao: TextStyle(),
    valor: TextStyle(),
    corpo: TextStyle(),
    apoio: TextStyle(),
    rotulo: TextStyle(),
    codigo: TextStyle(),
  ),
]);

Widget _app(Widget c) => MaterialApp(
    theme: _tema, home: Scaffold(body: SingleChildScrollView(child: c)));

PaginaGiroEstoque _pagina(bool custo) => PaginaGiroEstoque(
      custoVisivel: custo,
      meta: const GiroEstoqueMeta(totalItems: 1),
      items: [
        GiroEstoqueLinha(
          referenciaId: 1,
          nome: 'Sutiã',
          inicial: 10,
          vendido: 1,
          estoque: 9,
          classificacao: ClassificacaoGiro.parado,
          valorParado: custo ? 123.0 : null,
        ),
      ],
    );

Widget _tabela(bool custo) => GiroTabela(
      aba: AbaGiro.parado,
      visaoVariacao: false,
      pagina: _pagina(custo),
      ordenarPor: 'estoque',
      ordem: 'desc',
      variacoes: const {},
      abertos: const {},
      carregandoVariacoes: const {},
      parametros: const ParametrosGiro(),
      onOrdenar: (_) {},
      onExpandir: (_) {},
      onPagina: (_) {},
    );

void main() {
  setUp(() async {
    await sl.reset();
  });

  group('tabela desktop (aba parado)', () {
    for (final custo in [true, false]) {
      testWidgets('custoVisivel=$custo', (t) async {
        t.view.physicalSize = const Size(1440, 900);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        await t.pumpWidget(_app(_tabela(custo)));
        expect(find.text('VALOR PARADO'), custo ? findsOneWidget : findsNothing);
        expect(find.textContaining('123'), custo ? findsOneWidget : findsNothing);
      });
    }
  });

  group('cards mobile (aba parado)', () {
    for (final custo in [true, false]) {
      testWidgets('custoVisivel=$custo', (t) async {
        await t.pumpWidget(_app(GiroCardsMobile(
          aba: AbaGiro.parado,
          visaoVariacao: false,
          pagina: _pagina(custo),
          variacoes: const {},
          abertos: const {},
          carregandoVariacoes: const {},
          onExpandir: (_) {},
          onPagina: (_) {},
        )));
        expect(find.textContaining('parados em estoque'),
            custo ? findsOneWidget : findsNothing);
      });
    }
  });

  group('painel financeiro', () {
    for (final custo in [true, false]) {
      testWidgets('custoVisivel=$custo', (t) async {
        await t.pumpWidget(_app(GiroFinanceiro(GiroEstoqueResumo(custoVisivel: custo))));
        expect(find.text('Valor em estoque'), custo ? findsOneWidget : findsNothing);
        expect(find.textContaining('Imobilizado'), custo ? findsOneWidget : findsNothing);
        expect(find.text('Potencial de faturamento'), findsOneWidget);
      });
    }
  });

  group('exportação e bloc', () {
    test('coluna Valor parado some sem custo', () {
      bool tem(bool c) => colunasExportacaoGiro(AbaGiro.parado, custoVisivel: c)
          .any((e) => e.$1 == 'Valor parado');
      expect(tem(true), isTrue);
      expect(tem(false), isFalse);
    });

    test('ordenação padrão do parado não usa valorParado sem custo', () {
      expect(ordenacaoPadraoGiro(AbaGiro.parado).$1, 'valorParado');
      expect(ordenacaoPadraoGiro(AbaGiro.parado, custoVisivel: false).$1, 'estoque');
    });
  });

  group('DTO', () {
    test('custoVisivel explícito vence', () {
      sl.registerSingleton<IPermissoesController>(_Perm(true));
      expect(paginaGiroFromJson({'custoVisivel': false}).custoVisivel, isFalse);
      expect(giroResumoFromJson({'custoVisivel': false}).custoVisivel, isFalse);
    });
    test('ausente + sem PRDFL007 oculta', () {
      sl.registerSingleton<IPermissoesController>(_Perm(false));
      expect(paginaGiroFromJson({}).custoVisivel, isFalse);
      expect(giroResumoFromJson({}).custoVisivel, isFalse);
    });
    test('ausente + com PRDFL007 mostra', () {
      sl.registerSingleton<IPermissoesController>(_Perm(true));
      expect(paginaGiroFromJson({}).custoVisivel, isTrue);
      expect(giroResumoFromJson({}).custoVisivel, isTrue);
    });
  });
}
