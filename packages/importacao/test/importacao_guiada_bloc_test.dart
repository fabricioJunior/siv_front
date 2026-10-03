import 'dart:async';
import 'dart:typed_data';

import 'package:core/arquivos.dart';
import 'package:core/sync.dart' show ImportacaoProgressoEvent;
import 'package:flutter_test/flutter_test.dart';
import 'package:importacao/domain/data/remote/i_importacao_remote_data_source.dart';
import 'package:importacao/domain/models/importacao_guiada.dart';
import 'package:importacao/presentation/blocs/importacao_guiada_bloc/importacao_guiada_bloc.dart';

class _RemotoFake implements IImportacaoRemoteDataSource {
  List<ImportacaoGuiada> ultimas = [];
  final Map<int, ImportacaoGuiada> porId = {};
  Future<ImportacaoGuiada> Function(ImportacaoEtapa)? aoEnviar;
  final consultas = <int>[];
  final envios =
      <
        ({
          ImportacaoEtapa etapa,
          String nome,
          int bytes,
          Map<String, String> parametros,
        })
      >[];
  Object? erroAoBaixar;

  @override
  Future<List<ImportacaoGuiada>> listarUltimas() async => ultimas;

  @override
  Future<ImportacaoGuiada> consultar(int id) async {
    consultas.add(id);
    return porId[id]!;
  }

  @override
  Future<ImportacaoPrevia> previa(
    ImportacaoEtapa etapa, {
    int? tabelaDePrecoId,
  }) async => const ImportacaoPrevia(total: 0, colunas: [], linhas: []);

  @override
  Future<Uint8List> baixarModelo(
    ImportacaoEtapa etapa, {
    Map<String, String> query = const {},
  }) async {
    if (erroAoBaixar != null) throw erroAoBaixar!;
    return Uint8List.fromList([1, 2, 3]);
  }

  @override
  Future<ImportacaoGuiada> enviar(
    ImportacaoEtapa etapa, {
    required Uint8List bytes,
    required String nomeArquivo,
    Map<String, String> parametros = const {},
  }) {
    envios.add((
      etapa: etapa,
      nome: nomeArquivo,
      bytes: bytes.length,
      parametros: parametros,
    ));
    return aoEnviar!(etapa);
  }
}

class _ArquivosFake extends ArquivoService {
  ArquivoSelecionado? escolhido = ArquivoSelecionado(
    nome: 'dados.csv',
    bytes: Uint8List.fromList([9, 9]),
    tamanho: 2,
  );
  final salvos = <String>[];

  @override
  Future<ArquivoSelecionado?> selecionarArquivoComBytes({
    List<String>? extensoes,
  }) async => escolhido;

  @override
  Future<String?> salvarBytes({
    required Uint8List bytes,
    required String nomeSugerido,
  }) async {
    salvos.add(nomeSugerido);
    return '/tmp/$nomeSugerido';
  }
}

ImportacaoGuiada _imp(
  int id,
  String tipo,
  ImportacaoSituacao situacao, {
  int rejeitados = 0,
  List<ImportacaoProblema> problemas = const [],
}) => ImportacaoGuiada(
  id: id,
  tipo: tipo,
  situacao: situacao,
  rejeitados: rejeitados,
  problemas: problemas,
);

ImportacaoProgressoEvent _evento(
  int id,
  String tipo,
  String situacao, {
  int total = 0,
  int processados = 0,
  int importados = 0,
  int rejeitados = 0,
}) => ImportacaoProgressoEvent(
  id: id,
  tipo: tipo,
  situacao: situacao,
  totalRegistros: total,
  processados: processados,
  importados: importados,
  rejeitados: rejeitados,
);

Future<void> _ate(
  ImportacaoGuiadaBloc bloc,
  bool Function(ImportacaoGuiadaState) condicao,
) async {
  if (condicao(bloc.state)) return;
  await bloc.stream.firstWhere(condicao).timeout(const Duration(seconds: 3));
}

void main() {
  late _RemotoFake remoto;
  late _ArquivosFake arquivos;
  late StreamController<ImportacaoProgressoEvent> socket;
  late ImportacaoGuiadaBloc bloc;

  ImportacaoGuiadaBloc criar({Duration consulta = const Duration(hours: 1)}) =>
      ImportacaoGuiadaBloc(
        remoto,
        arquivos,
        socket.stream,
        intervaloConsulta: consulta,
      );

  setUp(() {
    remoto = _RemotoFake();
    arquivos = _ArquivosFake();
    socket = StreamController<ImportacaoProgressoEvent>.broadcast();
    bloc = criar();
  });

  tearDown(() async {
    await bloc.close();
    await socket.close();
  });

  group('carga inicial', () {
    test('abre na primeira etapa não concluída e libera só até ela', () async {
      remoto.ultimas = [_imp(1, 'cliente', ImportacaoSituacao.concluida)];

      bloc.add(const ImportacaoGuiadaIniciou());
      await _ate(
        bloc,
        (s) => !s.carregando && s[ImportacaoEtapa.clientes].importacao != null,
      );

      expect(bloc.state.etapaAtual, ImportacaoEtapa.referencias);
      expect(bloc.state.anteriorConcluida(ImportacaoEtapa.clientes), isTrue);
      expect(bloc.state.anteriorConcluida(ImportacaoEtapa.referencias), isTrue);
      expect(bloc.state.anteriorConcluida(ImportacaoEtapa.produtos), isFalse);
      expect(bloc.state.anteriorConcluida(ImportacaoEtapa.estoque), isFalse);
      expect(bloc.state.anteriorConcluida(ImportacaoEtapa.vendas), isFalse);
    });

    test(
      'sem histórico só a primeira etapa tem a anterior "concluída" (informativo; nada é bloqueado)',
      () async {
        bloc.add(const ImportacaoGuiadaIniciou());
        await _ate(
          bloc,
          (s) => !s.carregando && s.etapaAtual == ImportacaoEtapa.clientes,
        );

        expect(ImportacaoEtapa.values.where(bloc.state.anteriorConcluida), [
          ImportacaoEtapa.clientes,
        ]);
      },
    );

    test('importação com falha não conta como anterior concluída', () async {
      remoto.ultimas = [_imp(1, 'cliente', ImportacaoSituacao.falha)];

      bloc.add(const ImportacaoGuiadaIniciou());
      await _ate(bloc, (s) => s[ImportacaoEtapa.clientes].importacao != null);

      expect(
        bloc.state.anteriorConcluida(ImportacaoEtapa.referencias),
        isFalse,
      );
      expect(bloc.state.etapaAtual, ImportacaoEtapa.clientes);
    });

    test(
      'busca o detalhe (rejeições) só das etapas terminadas com problema',
      () async {
        remoto.ultimas = [
          _imp(1, 'cliente', ImportacaoSituacao.concluida, rejeitados: 2),
          _imp(2, 'produto', ImportacaoSituacao.concluida),
        ];
        remoto.porId[1] = _imp(
          1,
          'cliente',
          ImportacaoSituacao.concluida,
          rejeitados: 2,
          problemas: const [
            ImportacaoProblema(titulo: 'Linha 3', motivo: 'CPF inválido'),
          ],
        );

        bloc.add(const ImportacaoGuiadaIniciou());
        await _ate(
          bloc,
          (s) =>
              s[ImportacaoEtapa.clientes].importacao?.problemas.isNotEmpty ??
              false,
        );

        expect(remoto.consultas, [1]);
      },
    );

    test('tipo fora do assistente (ex.: referência) é ignorado', () async {
      remoto.ultimas = [_imp(9, 'referencia', ImportacaoSituacao.concluida)];

      bloc.add(const ImportacaoGuiadaIniciou());
      await _ate(
        bloc,
        (s) => !s.carregando && s.etapaAtual == ImportacaoEtapa.clientes,
      );

      expect(
        bloc.state.etapas.values.every((e) => e.importacao == null),
        isTrue,
      );
    });
  });

  group('envio', () {
    test('sem arquivo escolhido: avisa e não chama o servidor', () async {
      bloc.add(const ImportacaoGuiadaEnviou(ImportacaoEtapa.clientes));
      await _ate(bloc, (s) => s.erro != null);

      expect(bloc.state.erro, contains('Selecione o arquivo'));
      expect(remoto.envios, isEmpty);
    });

    test('vendas exigem tabela de preço e funcionário', () async {
      bloc.add(
        const ImportacaoGuiadaArquivoSelecionado(ImportacaoEtapa.vendas),
      );
      await _ate(bloc, (s) => s[ImportacaoEtapa.vendas].arquivoNome != null);

      bloc.add(const ImportacaoGuiadaEnviou(ImportacaoEtapa.vendas));
      await _ate(bloc, (s) => s.erro != null);

      expect(bloc.state.erro, contains('tabela de preço'));
      expect(remoto.envios, isEmpty);
    });

    test(
      'envia o CSV, guarda a importação pendente e limpa o arquivo escolhido',
      () async {
        remoto.aoEnviar = (_) async =>
            _imp(5, 'cliente', ImportacaoSituacao.pendente);

        bloc.add(
          const ImportacaoGuiadaArquivoSelecionado(ImportacaoEtapa.clientes),
        );
        await _ate(
          bloc,
          (s) => s[ImportacaoEtapa.clientes].arquivoNome == 'dados.csv',
        );
        bloc.add(const ImportacaoGuiadaEnviou(ImportacaoEtapa.clientes));
        await _ate(
          bloc,
          (s) =>
              s[ImportacaoEtapa.clientes].importacao?.id == 5 &&
              !s[ImportacaoEtapa.clientes].enviando,
        );

        expect(remoto.envios.single.nome, 'dados.csv');
        expect(remoto.envios.single.bytes, 2);
        expect(remoto.envios.single.parametros, isEmpty);
        expect(bloc.state[ImportacaoEtapa.clientes].arquivoNome, isNull);
      },
    );

    test('vendas mandam tabela e funcionário como parâmetros', () async {
      remoto.aoEnviar = (_) async =>
          _imp(6, 'vendaromaneio', ImportacaoSituacao.pendente);

      bloc.add(const ImportacaoGuiadaTabelaDePrecoAlterada(4));
      bloc.add(const ImportacaoGuiadaFuncionarioAlterado(9));
      bloc.add(
        const ImportacaoGuiadaArquivoSelecionado(ImportacaoEtapa.vendas),
      );
      await _ate(
        bloc,
        (s) =>
            s[ImportacaoEtapa.vendas].arquivoNome != null &&
            s[ImportacaoEtapa.vendas].funcionarioId == 9,
      );
      bloc.add(const ImportacaoGuiadaEnviou(ImportacaoEtapa.vendas));
      await _ate(bloc, (s) => s[ImportacaoEtapa.vendas].importacao != null);

      expect(remoto.envios.single.parametros, {
        'tabelaDePrecoId': '4',
        'funcionarioId': '9',
      });
    });

    test('erro do servidor desliga o "enviando" e mostra a mensagem', () async {
      remoto.aoEnviar = (_) async => throw Exception('boom');

      bloc.add(
        const ImportacaoGuiadaArquivoSelecionado(ImportacaoEtapa.clientes),
      );
      await _ate(bloc, (s) => s[ImportacaoEtapa.clientes].arquivoNome != null);
      bloc.add(const ImportacaoGuiadaEnviou(ImportacaoEtapa.clientes));
      await _ate(bloc, (s) => s.erro != null);

      expect(bloc.state[ImportacaoEtapa.clientes].enviando, isFalse);
      expect(bloc.state[ImportacaoEtapa.clientes].importacao, isNull);
    });

    test(
      'o andamento do socket que chega antes da resposta do POST não é desfeito por ela',
      () async {
        final resposta = Completer<ImportacaoGuiada>();
        remoto.aoEnviar = (_) => resposta.future;

        bloc.add(
          const ImportacaoGuiadaArquivoSelecionado(ImportacaoEtapa.clientes),
        );
        await _ate(
          bloc,
          (s) => s[ImportacaoEtapa.clientes].arquivoNome != null,
        );
        bloc.add(const ImportacaoGuiadaEnviou(ImportacaoEtapa.clientes));
        await _ate(bloc, (s) => s[ImportacaoEtapa.clientes].enviando);

        socket.add(
          _evento(5, 'cliente', 'processando', total: 100, processados: 40),
        );
        await _ate(
          bloc,
          (s) => s[ImportacaoEtapa.clientes].importacao?.processados == 40,
        );
        resposta.complete(_imp(5, 'cliente', ImportacaoSituacao.pendente));
        await _ate(bloc, (s) => !s[ImportacaoEtapa.clientes].enviando);

        expect(
          bloc.state[ImportacaoEtapa.clientes].importacao?.situacao,
          ImportacaoSituacao.processando,
        );
        expect(
          bloc.state[ImportacaoEtapa.clientes].importacao?.processados,
          40,
        );
      },
    );
  });

  group('andamento em tempo real', () {
    test('o evento do socket atualiza a etapa certa', () async {
      socket.add(
        _evento(
          3,
          'estoque',
          'processando',
          total: 4000,
          processados: 1530,
          importados: 1500,
          rejeitados: 30,
        ),
      );
      await _ate(bloc, (s) => s[ImportacaoEtapa.estoque].importacao != null);

      final importacao = bloc.state[ImportacaoEtapa.estoque].importacao!;
      expect(importacao.situacao, ImportacaoSituacao.processando);
      expect(
        [
          importacao.processados,
          importacao.totalRegistros,
          importacao.importados,
          importacao.rejeitados,
        ],
        [1530, 4000, 1500, 30],
      );
      expect(bloc.state[ImportacaoEtapa.clientes].importacao, isNull);
    });

    test(
      'ao concluir, busca o resultado detalhado e libera a próxima etapa',
      () async {
        remoto.porId[8] = _imp(
          8,
          'cliente',
          ImportacaoSituacao.concluida,
          rejeitados: 1,
          problemas: const [
            ImportacaoProblema(titulo: 'Linha 4', motivo: 'E-mail inválido'),
          ],
        );

        socket.add(
          _evento(8, 'cliente', 'processando', total: 10, processados: 5),
        );
        await _ate(bloc, (s) => s[ImportacaoEtapa.clientes].importacao != null);
        socket.add(
          _evento(
            8,
            'cliente',
            'concluida',
            total: 10,
            processados: 10,
            importados: 9,
            rejeitados: 1,
          ),
        );
        await _ate(
          bloc,
          (s) =>
              s[ImportacaoEtapa.clientes].importacao?.problemas.isNotEmpty ??
              false,
        );

        expect(remoto.consultas, [8]);
        expect(
          bloc.state.anteriorConcluida(ImportacaoEtapa.referencias),
          isTrue,
        );
      },
    );

    test('evento atrasado de uma importação mais antiga é ignorado', () async {
      socket.add(
        _evento(10, 'cliente', 'processando', total: 10, processados: 6),
      );
      await _ate(bloc, (s) => s[ImportacaoEtapa.clientes].importacao?.id == 10);

      socket.add(_evento(9, 'cliente', 'concluida', total: 3, processados: 3));
      socket.add(
        _evento(10, 'cliente', 'processando', total: 10, processados: 7),
      );
      await _ate(
        bloc,
        (s) => s[ImportacaoEtapa.clientes].importacao?.processados == 7,
      );

      expect(bloc.state[ImportacaoEtapa.clientes].importacao?.id, 10);
    });

    test('importação mais nova (reenvio) substitui a anterior', () async {
      socket.add(_evento(10, 'cliente', 'falha'));
      await _ate(bloc, (s) => s[ImportacaoEtapa.clientes].importacao?.id == 10);
      remoto.porId[10] = _imp(10, 'cliente', ImportacaoSituacao.falha);

      socket.add(
        _evento(11, 'cliente', 'processando', total: 5, processados: 1),
      );
      await _ate(bloc, (s) => s[ImportacaoEtapa.clientes].importacao?.id == 11);

      expect(
        bloc.state[ImportacaoEtapa.clientes].importacao?.situacao,
        ImportacaoSituacao.processando,
      );
    });

    test(
      'consulta de segurança: se o socket calar, a importação termina pela consulta REST',
      () async {
        await bloc.close();
        bloc = criar(consulta: const Duration(milliseconds: 20));
        remoto.porId[20] = _imp(20, 'estoque', ImportacaoSituacao.concluida);

        socket.add(
          _evento(20, 'estoque', 'processando', total: 10, processados: 2),
        );
        await _ate(bloc, (s) => s[ImportacaoEtapa.estoque].importacao != null);
        await _ate(
          bloc,
          (s) =>
              s[ImportacaoEtapa.estoque].importacao?.situacao ==
              ImportacaoSituacao.concluida,
        );

        final consultasAteAqui = remoto.consultas.length;
        await Future<void>.delayed(const Duration(milliseconds: 120));
        expect(
          remoto.consultas.length,
          consultasAteAqui,
          reason: 'sem importação em andamento a consulta periódica para',
        );
      },
    );
  });

  group('modelo', () {
    test('baixa o modelo da etapa e informa onde foi salvo', () async {
      bloc.add(const ImportacaoGuiadaModeloBaixado(ImportacaoEtapa.estoque));
      await _ate(bloc, (s) => s.mensagem != null);

      expect(arquivos.salvos, ['modelo-estoque.csv']);
      expect(bloc.state.mensagem, contains('/tmp/modelo-estoque.csv'));
    });

    test('falha ao baixar vira mensagem de erro', () async {
      remoto.erroAoBaixar = Exception('sem rede');

      bloc.add(const ImportacaoGuiadaModeloBaixado(ImportacaoEtapa.clientes));
      await _ate(bloc, (s) => s.erro != null);

      expect(arquivos.salvos, isEmpty);
    });
  });
}
