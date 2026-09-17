import 'package:core/leitor.dart';
import 'package:estoque/domain/data/datasourcers/i_produtos_estoque_local_datasource.dart';
import 'package:estoque/domain/models/produto_do_estoque.dart';
import 'package:precos/domain/data/local/i_precos_de_referencias_local_data_source.dart';
import 'package:precos/domain/models/preco_da_referencia.dart';
import 'package:produtos/domain/data/local/i_codigos_local_data_source.dart';
import 'package:produtos/domain/models/codigo.dart';

class ProdutoBuscaDoLeitorDataSource implements ILeitorBuscaDataDatasource {
  final IProdutoEstoqueLocalDataSource produtoEstoqueLocalDataSource;
  final ICodigosLocalDataSource codigosLocalDataSource;
  final IPrecosDeReferenciasLocalDataSource precosDeReferenciasLocalDataSource;

  ProdutoBuscaDoLeitorDataSource({
    required this.produtoEstoqueLocalDataSource,
    required this.codigosLocalDataSource,
    required this.precosDeReferenciasLocalDataSource,
  });
  // Termo curto/comum (ex: 1 letra) pode bater em milhares de SKUs no
  // catálogo inteiro (buscarProdutosPorTexto varre tudo sem índice) --
  // sem limite, o enriquecimento abaixo (Future.wait) dispara uma query de
  // código + uma de preço EM PARALELO por resultado, e RAM explode (~4GB
  // observado). Usuário não consegue ler uma lista de milhares de itens
  // mesmo, os primeiros já bastam pra ele refinar a busca.
  static const _limiteResultados = 60;

  @override
  Future<List<LeitorData>> buscarPorTexto(
    String texto, {
    String? tamanho,
    String? cor,
    int? tabelaDePrecoId,
  }) async {
    var produtos = (await produtoEstoqueLocalDataSource.buscarProdutosPorTexto(
      texto,
      tamanho: tamanho,
      cor: cor,
    )).take(_limiteResultados);

    // Antes: um `await` por produto (codigo + preco), N * 2 transações
    // IndexedDB separadas -- cada transação tem overhead real no browser.
    // Agora: 2 buscas em lote (todos os códigos, todos os preços) pra
    // materializar os candidatos, depois monta a lista em memória sem mais
    // round-trip por item.
    final produtoIds = produtos.map((p) => p.produtoId.toInt()).toList();
    final codigosPorProdutoId =
        await codigosLocalDataSource.recuperarCodigosPorProdutoIds(produtoIds);
    final precosPorReferenciaId = tabelaDePrecoId != null
        ? await precosDeReferenciasLocalDataSource
            .obterPrecosDasReferenciasPorIds(
              tabelaDePrecoId: tabelaDePrecoId,
              referenciaIds: produtos.map((p) => p.referenciaId.toInt()),
            )
        : const <int, PrecoDaReferencia?>{};

    final resultados = <ProdutoDoLeitorData>[];
    for (final produto in produtos) {
      final codigos = codigosPorProdutoId[produto.produtoId.toInt()];
      if (codigos == null || codigos.isEmpty) {
        continue;
      }
      final preco = tabelaDePrecoId != null
          ? precosPorReferenciaId[produto.referenciaId.toInt()]
          : null;
      // Pula produtos sem preço se tabelaDePrecoId for fornecida.
      if (tabelaDePrecoId != null && (preco == null || preco.valor == 0)) {
        continue;
      }
      resultados.add(ProdutoDoLeitorData(
        codigo: codigos.first,
        produto: produto,
        precoDaReferencia: preco,
      ));
    }
    return resultados;
  }
}

class ProdutoDoLeitorData implements LeitorData {
  final Codigo codigo;
  final ProdutoDoEstoque produto;
  final PrecoDaReferencia? precoDaReferencia;

  ProdutoDoLeitorData({
    required this.codigo,
    required this.produto,
    this.precoDaReferencia,
  });

  @override
  String get codigoDeBarras => codigo.codigo;

  @override
  Map<String, dynamic> get dados => {
    'codigo': codigo,
    'produto': produto,
    'precoDaReferencia': precoDaReferencia,
    'valor': precoDaReferencia?.valor,
  };

  @override
  String get descricao => produto.nome;

  @override
  int get quantidade => produto.saldo.toInt();

  @override
  int get idReferencia => produto.referenciaId;

  @override
  String get cor => produto.corNome;

  @override
  String get tamanho => produto.tamanhoNome;

  @override
  double? get valor => precoDaReferencia?.valor;

  @override
  int get id => int.parse(produto.produtoId.toString());
}
