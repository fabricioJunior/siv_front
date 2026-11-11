import 'package:core/seletores.dart';
import 'package:core/sessao.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:produtos/domain/data/gateways/i_promocoes_etiquetas_gateway.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';
import 'package:produtos/use_cases.dart';

class _Gateway implements IPromocoesEtiquetasGateway {
  final bool falha;
  _Gateway({this.falha = false});

  final itensPorPromocao = <int, List<ItemEtiquetaPromocao>>{
    1: [
      const ItemEtiquetaPromocao(
        produtoId: 10,
        referenciaId: 7,
        referenciaNome: 'Vestido',
        corNome: 'Azul',
        tamanhoNome: 'M',
        codigoBarras: '789010',
        saldo: 3,
        precoTabela: 100,
        precoPromocional: 80,
      ),
      const ItemEtiquetaPromocao(
        produtoId: 11,
        referenciaId: 7,
        referenciaNome: 'Vestido',
        corNome: 'Azul',
        tamanhoNome: 'G',
        saldo: 2,
        precoTabela: 100,
      ),
      const ItemEtiquetaPromocao(
        produtoId: 12,
        referenciaId: 8,
        referenciaNome: 'Saia',
        codigoBarras: '789012',
        saldo: 5,
        precoTabela: 0,
      ),
    ],
  };

  @override
  Future<List<PromocaoParaEtiqueta>> promocoes({
    required bool apenasVigentes,
  }) async => const [PromocaoParaEtiqueta(id: 1, nome: 'Verao')];

  @override
  Future<List<ItemEtiquetaPromocao>> itens({
    required int promocaoId,
    required int tabelaDePrecoId,
  }) async {
    if (falha) throw Exception('x');
    return itensPorPromocao[promocaoId] ?? const [];
  }
}

class _Codigos implements RecuperarCodigoDeBarrasDoProduto {
  @override
  Future<String?> call({required int produtoId}) async => '789$produtoId';
}

class _Sessao implements IAcessoGlobalSessao {
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

const _promocao = PromocaoParaEtiqueta(id: 1, nome: 'Verao');

void main() {
  late EtiquetasPromocaoBloc bloc;
  final etiqueta = Etiqueta.create(
    nome: 'e',
    altura: 10,
    largura: 10,
    dpi: EtiquetaDpi.d203,
    elementos: const [],
    vias: [EtiquetaVia.create(ordem: 0, zpl: '^XA^FD{preco}|{codigoBarras}^XZ')],
  );

  EtiquetasPromocaoBloc criar({bool falha = false}) {
    final g = _Gateway(falha: falha);
    return EtiquetasPromocaoBloc(
      RecuperarPromocoesParaEtiqueta(g),
      RecuperarItensDaPromocaoParaEtiqueta(g),
      _Codigos(),
      ProcessarEtiquetaParaImpressao(),
      _Sessao(),
    );
  }

  Future<void> carregar() async {
    bloc
      ..add(EtiquetasPromocaoTabelaSelecionada(
        SelectData(id: 1, nome: 't', data: const {}),
      ))
      ..add(EtiquetasPromocaoSelecionada(_promocao));
    await bloc.stream.firstWhere((s) => s.itens.isNotEmpty);
  }

  setUp(() => bloc = criar());
  tearDown(() => bloc.close());

  test('iniciar carrega promocoes', () async {
    bloc.add(EtiquetasPromocaoIniciou());
    final st = await bloc.stream.firstWhere((s) => s.promocoes.isNotEmpty);
    expect(st.promocoes.single.nome, 'Verao');
  });

  test('selecionar promocao + tabela carrega itens', () async {
    await carregar();
    expect(bloc.state.itens, hasLength(3));
    expect(bloc.state.selecionados, isEmpty);
  });

  test('sem tabela nao carrega itens', () async {
    bloc.add(EtiquetasPromocaoSelecionada(_promocao));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.itens, isEmpty);
    expect(bloc.state.carregandoItens, isFalse);
  });

  test('erro ao carregar itens mostra mensagem', () async {
    await bloc.close();
    bloc = criar(falha: true);
    bloc
      ..add(EtiquetasPromocaoTabelaSelecionada(
        SelectData(id: 1, nome: 't', data: const {}),
      ))
      ..add(EtiquetasPromocaoSelecionada(_promocao));
    final st = await bloc.stream.firstWhere((s) => s.erro != null);
    expect(st.carregandoItens, isFalse);
  });

  test('total = soma dos saldos selecionados; selecionar todos ignora sem preco',
      () async {
    await carregar();
    bloc.add(EtiquetasPromocaoItemAlternado(10));
    var st = await bloc.stream.firstWhere((s) => s.selecionados.isNotEmpty);
    expect(st.totalEtiquetas, 3);

    bloc.add(EtiquetasPromocaoTodosAlternado(true));
    st = await bloc.stream.firstWhere((s) => s.selecionados.length == 2);
    expect(st.totalEtiquetas, 5);
    expect(st.selecionados, {10, 11});
    expect(st.todosSelecionados, isTrue);

    bloc.add(EtiquetasPromocaoItemAlternado(12)); // sem preco: ignorado
    bloc.add(EtiquetasPromocaoTodosAlternado(false));
    st = await bloc.stream.firstWhere((s) => s.selecionados.isEmpty);
    expect(st.totalEtiquetas, 0);
  });

  test('imprimir gera um ZPL por etiqueta com o preco final', () async {
    await carregar();
    bloc
      ..add(EtiquetasPromocaoModeloSelecionado(etiqueta))
      ..add(EtiquetasPromocaoTodosAlternado(true))
      ..add(EtiquetasPromocaoItemAlternado(12)) // sem preco, nao entra
      ..add(EtiquetasPromocaoImprimirSolicitado());
    final st = await bloc.stream.firstWhere((s) => s.pilha.isNotEmpty);

    expect(st.pilha, hasLength(5));
    final zpls = st.pilha.map((i) => i.zpl).toList();
    expect(zpls.where((z) => z == '^XA^FD80,00|789010^XZ'), hasLength(3));
    // produto 11 sem codigo no payload: cai no fallback do cadastro
    expect(zpls.where((z) => z == '^XA^FD100,00|78911^XZ'), hasLength(2));
    expect(zpls.any((z) => z.startsWith('^XA^FD0,00')), isFalse);
  });

  test('imprimir sem modelo de etiqueta avisa', () async {
    await carregar();
    bloc
      ..add(EtiquetasPromocaoTodosAlternado(true))
      ..add(EtiquetasPromocaoImprimirSolicitado());
    final st = await bloc.stream.firstWhere((s) => s.erro != null);
    expect(st.pilha, isEmpty);
  });
}
