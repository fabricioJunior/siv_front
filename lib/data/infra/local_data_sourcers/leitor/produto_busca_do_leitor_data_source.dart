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
  @override
  Future<List<LeitorData>> buscarPorTexto(
    String texto, {
    String? tamanho,
    String? cor,
    int? tabelaDePrecoId,
  }) async {
    var produtos = await produtoEstoqueLocalDataSource.buscarProdutosPorTexto(
      texto,
      tamanho: tamanho,
      cor: cor,
    );

    List<LeitorData> leitorDataList = [];
    for (var produto in produtos) {
      var codigos = await codigosLocalDataSource.recuperarCodigosPorProdutoId(
        produto.produtoId.toInt(),
      );
      if (codigos.isEmpty) {
        continue;
      }
      var preco = tabelaDePrecoId != null
          ? await precosDeReferenciasLocalDataSource.obterPrecoDaReferencia(
              tabelaDePrecoId: tabelaDePrecoId,
              referenciaId: produto.referenciaId.toInt(),
            )
          : null; 
      if(tabelaDePrecoId != null && (preco == null || preco.valor == 0)) {
        continue; // Pula produtos sem preço se tabelaDePrecoId for fornecida

      }
      leitorDataList.add(
        ProdutoDoLeitorData(
          codigo: codigos.first,
          produto: produto,
          precoDaReferencia: preco,
        ),
      );
     }
    return leitorDataList;
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
