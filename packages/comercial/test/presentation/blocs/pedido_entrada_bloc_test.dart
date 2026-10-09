import 'package:comercial/domain/data/remote/i_pedido_entrada_remote_data_source.dart';
import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/domain/models/trilha_entrada.dart';
import 'package:comercial/domain/use_cases/pedido_entrada/pedido_entrada_use_cases.dart';
import 'package:comercial/presentation/blocs/pedido_entrada_bloc/pedido_entrada_bloc.dart';
import 'package:comercial/domain/use_cases/conferir_pedido.dart';
import 'package:comercial/domain/use_cases/faturar_pedido.dart';
import 'package:core/sessao.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _json({bool livre = true}) => {
      'pedidoId': 9,
      'origemEntrada': 'CONTAGEM',
      'nfe': null,
      'linhas': [],
      'contagens': livre
          ? []
          : [
              {'produtoId': 5, 'quantidade': '3', 'referenciaId': 77},
            ],
      'contagensLivres': livre
          ? [
              {
                'id': 1,
                'descricao': 'Vestido Luna',
                'corId': 1,
                'tamanhoId': 2,
                'quantidade': '3',
              },
            ]
          : [],
      'totais': {'nfe': 0, 'contado': 3},
      'pendencias': [],
    };

class _Sessao implements IAcessoGlobalSessao {
  @override
  int? get caixaIdDaSessao => 1;
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _Remoto implements IPedidoEntradaRemoteDataSource {
  Map<String, dynamic>? resposta; // sobrescreve o resumo devolvido
  final chamadas = <String>[];
  final lotes = <Map<int, int>>[];
  List<ItemContagem>? itens;
  List<int>? ids;
  int? referenciaId;
  int? categoriaId;
  String? nome;
  Object? erro;

  @override
  Future<EntradaResumo> obter(int pedidoId) async =>
      EntradaResumo.fromJson(resposta ?? _json());

  @override
  Future<EntradaResumo> corrigirContagem(
    int pedidoId,
    int produtoId,
    double para, {
    String? motivo,
    required String origem,
  }) async {
    chamadas.add('corrigir $produtoId $para $origem $motivo');
    return EntradaResumo.fromJson(resposta ?? _json());
  }

  @override
  Future<EntradaResumo> decidirDivergencia(
    int pedidoId,
    int produtoId,
    AcaoDivergencia acao, {
    String? observacao,
  }) async {
    chamadas.add('decidir $produtoId ${acao.name} $observacao');
    return EntradaResumo.fromJson(resposta ?? _json());
  }

  @override
  Future<EntradaResumo> registrarLeituras(
    int pedidoId,
    Map<int, int> deltas,
  ) async {
    lotes.add(Map.of(deltas));
    if (erro != null) throw erro!;
    return EntradaResumo.fromJson(resposta ?? _json());
  }

  @override
  Future<EntradaResumo> registrarEtiquetas(
    int pedidoId, {
    Map<int, double>? itens,
    bool pular = false,
  }) async {
    chamadas.add('etiquetas $itens $pular');
    if (erro != null) throw erro!;
    return EntradaResumo.fromJson(resposta ?? _json());
  }

  @override
  Future<EntradaResumo> registrarContagemLivre(
    int pedidoId,
    List<ItemContagem> itens,
  ) async {
    if (erro != null) throw erro!;
    this.itens = itens;
    return EntradaResumo.fromJson(_json());
  }

  @override
  Future<EntradaResumo> associarContagemLivre(
    int pedidoId,
    List<int> ids, {
    int? referenciaId,
    int? categoriaId,
    String? nome,
  }) async {
    this.ids = ids;
    this.referenciaId = referenciaId;
    this.categoriaId = categoriaId;
    this.nome = nome;
    return EntradaResumo.fromJson(_json(livre: false));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

final _faturamento = <String>[];

class _ConferirFalso implements ConferirPedido {
  @override
  Future<void> call(int id, {bool processarComDivergencia = false}) async =>
      _faturamento.add('conferir $id $processarComDivergencia');
}

class _FaturarFalso implements FaturarPedido {
  @override
  Future<void> call(int id, {required int caixaId}) async =>
      _faturamento.add('faturar $id $caixaId');
}

void main() {
  late _Remoto remoto;
  late PedidoEntradaBloc bloc;

  setUp(() {
    remoto = _Remoto();
    bloc = PedidoEntradaBloc(
      ImportarNfeEntrada(remoto),
      CriarEntradaPorContagem(remoto),
      ObterPedidoEntrada(remoto),
      VincularLinhaEntrada(remoto),
      PreCadastrarLinhaEntrada(remoto),
      IgnorarLinhaEntrada(remoto),
      ResolverDivergenciaEntrada(remoto),
      RegistrarContagemEntrada(remoto),
      RegistrarContagemLivreEntrada(remoto),
      AssociarContagemLivreEntrada(remoto),
      CorrigirContagemEntrada(remoto),
      DecidirDivergenciaEntrada(remoto),
      RegistrarEtiquetasEntrada(remoto),
      FaturarEntrada(_ConferirFalso(), _FaturarFalso()),
      RegistrarLeiturasEntrada(remoto),
      _Sessao(),
    );
    bloc.add(const PedidoEntradaCarregou(9));
  });

  tearDown(() => bloc.close());

  test('registra contagem livre e expõe contagensLivres', () async {
    bloc.add(
      const PedidoEntradaRegistrouContagemLivre([
        ItemContagem(
          descricao: 'Vestido Luna',
          corId: 1,
          tamanhoId: 2,
          quantidade: 3,
        ),
      ]),
    );
    final st = await bloc.stream.firstWhere((s) => s.mensagem != null);

    expect(remoto.itens!.single.toJson(), {
      'descricao': 'Vestido Luna',
      'corId': 1,
      'tamanhoId': 2,
      'quantidade': 3.0,
    });
    expect(st.resumo!.contagensLivres.single.descricao, 'Vestido Luna');
    expect(st.resumo!.contagensLivres.single.quantidade, 3);
  });

  test('erro da API na contagem livre vira mensagem de erro', () async {
    remoto.erro = Exception('falhou');
    bloc.add(
      const PedidoEntradaRegistrouContagemLivre([
        ItemContagem(descricao: 'x', corId: 1, tamanhoId: 2, quantidade: 1),
      ]),
    );
    final st = await bloc.stream.firstWhere((s) => s.erro != null);
    expect(st.salvando, isFalse);
  });

  test('associa a referência existente e esvazia contagensLivres', () async {
    bloc.add(const PedidoEntradaAssociouContagemLivre([1], referenciaId: 77));
    final st = await bloc.stream.firstWhere((s) => s.mensagem != null);

    expect(remoto.ids, [1]);
    expect(remoto.referenciaId, 77);
    expect(remoto.categoriaId, isNull);
    expect(st.resumo!.contagensLivres, isEmpty);
    expect(st.resumo!.contagens, hasLength(1));
  });

  test('associa criando referência (pré-cadastro)', () async {
    bloc.add(
      const PedidoEntradaAssociouContagemLivre(
        [1, 2],
        categoriaId: 4,
        nome: 'Vestido Luna',
      ),
    );
    await bloc.stream.firstWhere((s) => s.mensagem != null);

    expect(remoto.ids, [1, 2]);
    expect(remoto.referenciaId, isNull);
    expect(remoto.categoriaId, 4);
    expect(remoto.nome, 'Vestido Luna');
  });

  group('redesenho', () {
    Map<String, dynamic> conf({
      String? etapa,
      List<Map<String, dynamic>> itens = const [],
      List<Map<String, dynamic>> divergencias = const [],
      Map<String, dynamic>? etiquetas,
    }) =>
        {
          ..._json(livre: false),
          if (etapa != null) 'etapa': etapa,
          if (etiquetas != null) 'etiquetas': etiquetas,
          'conferencia': {'itens': itens, 'totalContado': 3, 'totalLido': 1},
          'divergencias': divergencias,
        };

    test('trilha degrada sem campos novos: derivada das contagens', () async {
      await Future<void>.delayed(Duration.zero);
      final st = bloc.state;
      // _json() = só contagem livre -> Associar
      expect(st.etapaAtual, 1);
      expect(st.trilha[1].status, StatusPasso.ativo);
      expect(st.trilha[1].subtitulo, '1 sem referência');
      expect(st.trilha[2].subtitulo, 'após associar');
    });

    test('etiquetas puladas: backend antigo segue só no app', () async {
      remoto.resposta = _json(livre: false);
      bloc.add(const PedidoEntradaCarregou(9));
      await bloc.stream.firstWhere((s) => s.etapaAtual == 2);
      remoto.erro = Exception('404');
      bloc.add(const PedidoEntradaPulouEtiquetas());
      final st = await bloc.stream.firstWhere((s) => s.etiquetasLocal);
      expect(st.etapaAtual, 3);
      expect(st.erro, isNull);
    });

    test('corrigir contagem abaixo do lido é barrado no front', () async {
      remoto.resposta = conf(
        etapa: 'conferindo',
        itens: [
          {'produtoId': 5, 'contado': 3, 'lido': 2, 'situacao': 'parcial'},
        ],
      );
      bloc.add(const PedidoEntradaCarregou(9));
      await bloc.stream.firstWhere((s) => s.etapaAtual == 3);
      bloc.add(
        const PedidoEntradaCorrigiuContagem(5, 1, origem: 'conferencia'),
      );
      final st = await bloc.stream.firstWhere((s) => s.erro != null);
      expect(st.erro, contains('abaixo do lido (2)'));
      expect(remoto.chamadas, isEmpty);

      bloc.add(
        const PedidoEntradaCorrigiuContagem(5, 2,
            motivo: 'contei errado', origem: 'conferencia'),
      );
      await bloc.stream.firstWhere((s) => s.mensagem == 'Contagem corrigida');
      expect(remoto.chamadas.single, 'corrigir 5 2.0 conferencia contei errado');
    });

    test('Faturar bloqueado com divergência sem decisão', () async {
      remoto.resposta = conf(
        etapa: 'conferindo',
        divergencias: [
          {
            'produtoId': 5,
            'descricao': 'X',
            'grade': 'Preto · M',
            'contado': 3,
            'lido': 2,
            'tipo': 'falta',
            'decisao': null,
          },
        ],
      );
      bloc.add(const PedidoEntradaCarregou(9));
      var st = await bloc.stream.firstWhere((s) => s.divergencias.isNotEmpty);
      expect(TrilhaEntrada.podeFaturar(st.resumo!), isFalse);

      bloc.add(const PedidoEntradaFaturou());
      st = await bloc.stream.firstWhere((s) => s.erro != null);
      expect(st.erro, contains('Decida as divergências'));
      expect(st.faturado, isFalse);
    });

    test('Faturar com tudo decidido confere e fatura', () async {
      _faturamento.clear();
      remoto.resposta = {...conf(etapa: 'conferindo'), 'revisao': {'podeFaturar': true}};
      bloc.add(const PedidoEntradaCarregou(9));
      await bloc.stream.firstWhere((s) => s.etapaAtual == 3);
      bloc.add(const PedidoEntradaFaturou());
      final st = await bloc.stream.firstWhere((s) => s.faturado);
      expect(_faturamento, ['conferir 9 true', 'faturar 9 1']);
      expect(st.trilha.last.status, StatusPasso.ativo);
    });

    test('decidir divergência chama o endpoint e libera quando decidida',
        () async {
      bloc.add(
        const PedidoEntradaDecidiuDivergencia(
          5,
          AcaoDivergencia.manter,
          observacao: 'veio a menos',
        ),
      );
      await bloc.stream.firstWhere((s) => s.mensagem != null);
      expect(remoto.chamadas.single, 'decidir 5 manter veio a menos');
    });
  });

  group('conferência local (leituras em lote)', () {
    Map<String, dynamic> conf({int lido = 2, int lido2 = 0}) => {
          ..._json(livre: false),
          'etapa': 'conferindo',
          'conferencia': {
            'totalContado': 7,
            'totalLido': lido + lido2,
            'itens': [
              {'produtoId': 5, 'contado': 4, 'lido': lido, 'situacao': 'parcial'},
              {'produtoId': 6, 'contado': 3, 'lido': lido2, 'situacao': 'pendente'},
            ],
          },
        };

    Future<void> carregar() async {
      remoto.resposta = conf();
      bloc.add(const PedidoEntradaCarregou(9));
      await bloc.stream.firstWhere((s) => s.etapaAtual == 3);
    }

    test('Leu acumula localmente, sem chamar o remote', () async {
      await carregar();
      bloc
        ..add(const PedidoEntradaLeu(5, 1))
        ..add(const PedidoEntradaLeu(5, 1))
        ..add(const PedidoEntradaLeu(6, 1));
      final st = await bloc.stream.firstWhere(
        (s) => s.leiturasPendentes.length == 2 && s.leiturasPendentes[5] == 2,
      );
      expect(st.leiturasPendentes, {5: 2, 6: 1});
      expect(remoto.lotes, isEmpty);
      expect(st.salvando, isFalse);
    });

    test('lido nunca fica abaixo de zero (clamp) e produto de fora é ignorado',
        () async {
      await carregar();
      bloc
        ..add(const PedidoEntradaLeu(6, -1)) // lido 0: ignora
        ..add(const PedidoEntradaLeu(99, 1)) // fora da entrada: ignora
        ..add(const PedidoEntradaLeu(5, -2)) // lido 2 -> 0 ok
        ..add(const PedidoEntradaLeu(5, -1)); // abaixo de 0: ignora
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(bloc.state.leiturasPendentes, {5: -2});
      bloc.add(const PedidoEntradaLeu(5, 2)); // volta a zero: some do mapa
      await bloc.stream.firstWhere((s) => s.leiturasPendentes.isEmpty);
    });

    test('Enviou faz UMA chamada com os deltas, limpa e atualiza o resumo',
        () async {
      await carregar();
      bloc
        ..add(const PedidoEntradaLeu(5, 1))
        ..add(const PedidoEntradaLeu(5, 1))
        ..add(const PedidoEntradaLeu(6, 1));
      await bloc.stream.firstWhere((s) => s.leiturasPendentes[5] == 2 && s.leiturasPendentes.containsKey(6));
      remoto.resposta = conf(lido: 4, lido2: 1);
      bloc.add(const PedidoEntradaEnviouLeituras());
      final st = await bloc.stream.firstWhere(
        (s) => !s.salvando && s.leiturasPendentes.isEmpty && s.resumo!.conferencia.totalLido == 5,
      );
      expect(remoto.lotes, [
        {5: 2, 6: 1},
      ]);
      expect(st.passoVisivel, 3);
    });

    test('Enviou com irParaRevisar segue para Revisar só no sucesso', () async {
      await carregar();
      bloc.add(const PedidoEntradaLeu(5, 1));
      await bloc.stream.firstWhere((s) => s.leiturasPendentes.isNotEmpty);
      remoto.erro = Exception('falhou');
      bloc.add(const PedidoEntradaEnviouLeituras(irParaRevisar: true));
      var st = await bloc.stream.firstWhere((s) => s.erro != null);
      expect(st.leiturasPendentes, {5: 1}); // mantém o pendente
      expect(st.passoVisivel, 3);
      expect(st.salvando, isFalse);

      remoto.erro = null;
      bloc.add(const PedidoEntradaEnviouLeituras(irParaRevisar: true));
      st = await bloc.stream.firstWhere((s) => s.passoVisivel == 4);
      expect(st.leiturasPendentes, isEmpty);
      expect(remoto.lotes, hasLength(2));
    });

    test('Descartou limpa o pendente sem rede', () async {
      await carregar();
      bloc.add(const PedidoEntradaLeu(5, 1));
      await bloc.stream.firstWhere((s) => s.leiturasPendentes.isNotEmpty);
      bloc.add(const PedidoEntradaDescartouLeituras());
      await bloc.stream.firstWhere((s) => s.leiturasPendentes.isEmpty);
      expect(remoto.lotes, isEmpty);
    });
  });
}
