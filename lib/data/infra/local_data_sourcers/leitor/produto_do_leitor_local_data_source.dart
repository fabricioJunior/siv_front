import 'package:core/leitor/data_source/i_leitor_data_datasource.dart';
import 'package:core/leitor/leitor_data.dart';
import 'package:estoque/domain/data/datasourcers/i_produtos_estoque_local_datasource.dart';
import 'package:estoque/models.dart';
import 'package:precos/domain/data/local/i_precos_de_referencias_local_data_source.dart';
import 'package:precos/domain/models/preco_da_referencia.dart';
import 'package:produtos/domain/data/local/i_codigos_local_data_source.dart';
import 'package:produtos/domain/models/codigo.dart';

class ProdutoDoLeitorLocalDataSource implements ILeitorDataDatasource {
  final ICodigosLocalDataSource codigosLocalDataSource;
  final IProdutoEstoqueLocalDataSource produtoEstoqueLocalDataSource;
  final IPrecosDeReferenciasLocalDataSource precosDeReferenciasLocalDataSource;

  ProdutoDoLeitorLocalDataSource({
    required this.codigosLocalDataSource,
    required this.produtoEstoqueLocalDataSource,
    required this.precosDeReferenciasLocalDataSource,
  });

  @override
  Future<LeitorData?> getData(String codigo, {int? tabelaDePrecoId}) async {
    var codigoEntity = await codigosLocalDataSource.recuperarCodigo(codigo);
    if (codigoEntity == null) return null;
    var produto = await produtoEstoqueLocalDataSource
        .obterProduto(codigoEntity.produtoId);
    if (produto == null) return null;
    var precoDaReferencia = tabelaDePrecoId != null
        ? await precosDeReferenciasLocalDataSource.obterPrecoDaReferencia(
            referenciaId: produto.referenciaId,
            tabelaDePrecoId: tabelaDePrecoId,
          )
        : null;
    return ProdutoDoLeitorData(
      codigo: codigoEntity,
      produto: produto,
      precoDaReferencia: precoDaReferencia,
    );
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
