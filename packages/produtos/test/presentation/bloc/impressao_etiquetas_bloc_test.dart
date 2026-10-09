import 'package:core/seletores.dart';
import 'package:core/sessao.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';
import 'package:produtos/use_cases.dart';

class _Produtos implements RecuperarProdutos {
  final List<Produto> produtos;
  _Produtos(this.produtos);

  @override
  Future<List<Produto>> call({String? idExterno, int? referenciaId}) async =>
      produtos;
}

class _Codigos implements RecuperarCodigoDeBarrasDoProduto {
  @override
  Future<String?> call({required int produtoId}) async => '789$produtoId';
}

class _Preco implements ObterPrecoDaReferencia {
  double preco = 10;

  @override
  Future<double> call({
    required int tabelaDePrecoId,
    required int referenciaId,
  }) async => preco;
}

class _Sessao implements IAcessoGlobalSessao {
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

Produto _p(int id) => Produto.create(
  id: id,
  referenciaId: 7,
  idExterno: '$id',
  corId: 1,
  tamanhoId: 1,
);

void main() {
  late _Preco preco;
  late ImpressaoEtiquetasBloc bloc;
  final etiqueta = Etiqueta.create(
    nome: 'e',
    altura: 10,
    largura: 10,
    dpi: EtiquetaDpi.d203,
    elementos: const [],
    vias: [EtiquetaVia.create(ordem: 0, zpl: '^XA^FD{{titulo}}^XZ')],
  );
  const itens = [
    ItemEtiquetaInicial(
      referenciaId: 7,
      referenciaNome: 'Vestido',
      produtoId: 1,
      quantidade: 2,
    ),
    ItemEtiquetaInicial(
      referenciaId: 7,
      referenciaNome: 'Vestido',
      produtoId: 2,
      quantidade: 1,
    ),
  ];

  setUp(() {
    preco = _Preco();
    bloc = ImpressaoEtiquetasBloc(
      _Produtos([_p(1), _p(2), _p(3)]),
      _Codigos(),
      preco,
      ProcessarEtiquetaParaImpressao(),
      _Imprime(),
      _Sessao(),
    );
  });

  tearDown(() => bloc.close());

  test('itens iniciais viram pilha ao escolher etiqueta e tabela', () async {
    bloc
      ..add(ImpressaoEtiquetasItensIniciaisDefinidos(itens))
      ..add(ImpressaoEtiquetasEtiquetaSelecionada(etiqueta: etiqueta))
      ..add(
        ImpressaoEtiquetasTabelaSelecionada(
          tabela: SelectData(id: 1, nome: 't', data: const {}),
        ),
      )
      ..add(ImpressaoEtiquetasItensIniciaisAdicionarSolicitado());
    final st = await bloc.stream.firstWhere((s) => s.pilhaImpressao.isNotEmpty);

    expect(st.pilhaImpressao, hasLength(3));
    expect(st.itensIniciais, isEmpty);
    expect(st.erro, isNull);
  });

  test('sem etiqueta/tabela avisa e mantém os itens', () async {
    bloc
      ..add(ImpressaoEtiquetasItensIniciaisDefinidos(itens))
      ..add(ImpressaoEtiquetasItensIniciaisAdicionarSolicitado());
    final st = await bloc.stream.firstWhere((s) => s.erro != null);

    expect(st.pilhaImpressao, isEmpty);
    expect(st.itensIniciais, hasLength(2));
  });

  test('referência sem preço na tabela não gera pilha', () async {
    preco.preco = 0;
    bloc
      ..add(ImpressaoEtiquetasItensIniciaisDefinidos(itens))
      ..add(ImpressaoEtiquetasEtiquetaSelecionada(etiqueta: etiqueta))
      ..add(
        ImpressaoEtiquetasTabelaSelecionada(
          tabela: SelectData(id: 1, nome: 't', data: const {}),
        ),
      )
      ..add(ImpressaoEtiquetasItensIniciaisAdicionarSolicitado());
    final st = await bloc.stream.firstWhere((s) => s.erro != null);

    expect(st.erro, contains('Vestido'));
    expect(st.pilhaImpressao, isEmpty);
  });
}

class _Imprime implements ImprimirEtiquetas {
  @override
  Future<void> call({required List<String> zpls}) async {}
}
