import 'package:comercial/domain/data/remote/i_pedido_entrada_remote_data_source.dart';
import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/domain/use_cases/pedido_entrada/pedido_entrada_use_cases.dart';
import 'package:comercial/presentation/blocs/pedido_entrada_bloc/pedido_entrada_bloc.dart';
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

class _Remoto implements IPedidoEntradaRemoteDataSource {
  List<ItemContagem>? itens;
  List<int>? ids;
  int? referenciaId;
  int? categoriaId;
  String? nome;
  Object? erro;

  @override
  Future<EntradaResumo> obter(int pedidoId) async =>
      EntradaResumo.fromJson(_json());

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
}
