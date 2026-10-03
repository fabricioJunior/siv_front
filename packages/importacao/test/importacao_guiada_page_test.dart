import 'dart:async';
import 'dart:typed_data';

import 'package:core/arquivos.dart';
import 'package:core/injecoes.dart';
import 'package:core/permissoes/i_permissoes_controller.dart';
import 'package:core/sync.dart' show ImportacaoProgressoEvent;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:importacao/domain/data/remote/i_importacao_remote_data_source.dart';
import 'package:importacao/domain/models/importacao_guiada.dart';
import 'package:importacao/presentation.dart';

class _Permissoes implements IPermissoesController {
  final Set<String> negadas;
  _Permissoes({this.negadas = const {}});

  @override
  bool temAcesso({String? idComponente, int? grupoId}) =>
      !negadas.contains(idComponente);

  @override
  Future<bool> acessoPermitido({String? idComponente, int? grupoId}) async =>
      temAcesso(idComponente: idComponente);
}

class _Remoto implements IImportacaoRemoteDataSource {
  List<ImportacaoGuiada> ultimas = [];
  final Map<int, ImportacaoGuiada> porId = {};

  @override
  Future<List<ImportacaoGuiada>> listarUltimas() async => ultimas;

  @override
  Future<ImportacaoGuiada> consultar(int id) async => porId[id]!;

  @override
  Future<Uint8List> baixarModelo(
    ImportacaoEtapa etapa, {
    Map<String, String> query = const {},
  }) async => Uint8List(0);

  @override
  Future<ImportacaoGuiada> enviar(
    ImportacaoEtapa etapa, {
    required Uint8List bytes,
    required String nomeArquivo,
    Map<String, String> parametros = const {},
  }) => throw UnimplementedError();
}

Widget _seletorFalso(String nome) => Text('seletor $nome');

void main() {
  late _Remoto remoto;
  late StreamController<ImportacaoProgressoEvent> socket;

  Future<void> abrir(
    WidgetTester tester, {
    Set<String> permissoesNegadas = const {},
  }) async {
    tester.view.physicalSize = const Size(1000, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await sl.reset();
    sl.registerSingleton<IPermissoesController>(
      _Permissoes(negadas: permissoesNegadas),
    );
    sl.registerFactory<ImportacaoGuiadaBloc>(
      () => ImportacaoGuiadaBloc(
        remoto,
        ArquivoService(),
        socket.stream,
        intervaloConsulta: const Duration(hours: 1),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ImportacaoGuiadaPage(
          tabelaDePrecoSeletor: (_) => _seletorFalso('tabela'),
          funcionarioSeletor: (_) => _seletorFalso('funcionario'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    remoto = _Remoto();
    socket = StreamController<ImportacaoProgressoEvent>.broadcast();
  });

  tearDown(() async {
    await socket.close();
    await sl.reset();
  });

  testWidgets(
    'mostra as 6 etapas na ordem e abre em Clientes (modelo e envio disponíveis)',
    (tester) async {
      await abrir(tester);

      for (final titulo in [
        '1. Clientes',
        '2. Referências',
        '3. Preços',
        '4. Produtos',
        '5. Estoque',
        '6. Vendas',
      ]) {
        expect(find.text(titulo), findsWidgets, reason: titulo);
      }
      expect(find.text('Baixar modelo'), findsOneWidget);
      expect(find.text('Selecionar CSV'), findsOneWidget);
      expect(find.text('Importar'), findsOneWidget);
      // nenhuma etapa é bloqueada: todas aparecem como "A importar"
      expect(find.text('A importar'), findsNWidgets(6));
      expect(find.text('Bloqueada'), findsNothing);
    },
  );

  testWidgets(
    'importar só vendas (sem importar as etapas anteriores): avisa a ordem recomendada mas não bloqueia',
    (tester) async {
      await abrir(tester); // histórico vazio, como em produção sem importações

      await tester.tap(find.text('6. Vendas').first);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Ordem recomendada: importe "Estoque"'),
        findsOneWidget,
      );
      // tudo da etapa de vendas continua disponível
      expect(find.text('Baixar modelo'), findsOneWidget);
      expect(find.text('seletor tabela'), findsOneWidget);
      expect(find.text('seletor funcionario'), findsOneWidget);
      expect(find.text('Selecionar CSV'), findsOneWidget);
      expect(find.text('Importar'), findsOneWidget);

      await tester.tap(find.text('Ir para Estoque'));
      await tester.pumpAndSettle();
      expect(find.text('5. Estoque'), findsWidgets);
      expect(
        find.textContaining('Ordem recomendada: importe "Produtos"'),
        findsOneWidget,
      );
    },
  );

  testWidgets('primeira etapa não mostra o aviso de ordem', (tester) async {
    await abrir(tester);

    expect(find.textContaining('Ordem recomendada'), findsNothing);
  });

  testWidgets(
    'etapa de vendas mostra os seletores de tabela de preço e funcionário quando liberada',
    (tester) async {
      remoto.ultimas = [
        for (final (i, tipo) in [
          'cliente',
          'referencia',
          'referenciapreco',
          'produto',
          'estoque',
        ].indexed)
          ImportacaoGuiada(
            id: i + 1,
            tipo: tipo,
            situacao: ImportacaoSituacao.concluida,
          ),
      ];
      await abrir(tester);

      expect(find.text('seletor tabela'), findsOneWidget);
      expect(find.text('seletor funcionario'), findsOneWidget);
      expect(find.textContaining('código de barras'), findsWidgets);
    },
  );

  testWidgets(
    'andamento ao vivo: barra, "X de Y (Z%)" e contadores atualizam pelo socket',
    (tester) async {
      await abrir(tester);

      socket.add(
        const ImportacaoProgressoEvent(
          id: 3,
          tipo: 'cliente',
          situacao: 'processando',
          totalRegistros: 200,
          processados: 50,
          importados: 48,
          rejeitados: 2,
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Processando: 50 de 200 (25%)'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        0.25,
      );
      expect(find.text('48'), findsOneWidget);
      expect(find.text('Importados'), findsOneWidget);
      expect(find.text('Com problema'), findsOneWidget);
      expect(find.text('Processando'), findsOneWidget); // rótulo do passo
      expect(find.textContaining('continua no servidor'), findsOneWidget);
    },
  );

  testWidgets(
    'concluída com problemas: totais, lista com motivo e botão de copiar',
    (tester) async {
      remoto.ultimas = [
        const ImportacaoGuiada(
          id: 1,
          tipo: 'cliente',
          situacao: ImportacaoSituacao.concluida,
          totalRegistros: 10,
          importados: 8,
          rejeitados: 2,
        ),
      ];
      remoto.porId[1] = const ImportacaoGuiada(
        id: 1,
        tipo: 'cliente',
        situacao: ImportacaoSituacao.concluida,
        totalRegistros: 10,
        importados: 8,
        rejeitados: 2,
        problemas: [
          ImportacaoProblema(
            titulo: 'Linha 3',
            motivo: 'CPF inválido',
            conteudo: 'Ana;123',
          ),
          ImportacaoProblema(titulo: 'Linha 7', motivo: 'E-mail inválido'),
        ],
      );
      await abrir(tester);
      await tester.tap(find.text('1. Clientes').first);
      await tester.pumpAndSettle();

      expect(find.text('Com problemas'), findsOneWidget);
      expect(
        find.text('Registros que não foram importados (2)'),
        findsOneWidget,
      );
      expect(find.text('Linha 3'), findsOneWidget);
      expect(find.textContaining('CPF inválido'), findsOneWidget);
      expect(find.text('Copiar'), findsOneWidget);
      expect(find.text('Importar novamente'), findsOneWidget);
    },
  );

  testWidgets('falha mostra o erro do servidor', (tester) async {
    remoto.ultimas = [
      const ImportacaoGuiada(
        id: 1,
        tipo: 'cliente',
        situacao: ImportacaoSituacao.falha,
        erro: 'Cabeçalho CSV inválido',
      ),
    ];
    await abrir(tester);

    expect(find.textContaining('Cabeçalho CSV inválido'), findsOneWidget);
    expect(find.text('Falhou'), findsOneWidget);
  });

  testWidgets('sem permissão para a etapa: avisa e esconde modelo/envio', (
    tester,
  ) async {
    await abrir(tester, permissoesNegadas: {'IMPFP006'});

    expect(find.textContaining('não tem permissão'), findsOneWidget);
    expect(find.text('Baixar modelo'), findsNothing);
    expect(find.text('Importar'), findsNothing);
  });
}
