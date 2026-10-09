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
}
