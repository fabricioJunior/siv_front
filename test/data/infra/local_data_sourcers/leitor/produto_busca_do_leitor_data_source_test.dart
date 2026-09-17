import 'package:estoque/domain/data/datasourcers/i_produtos_estoque_local_datasource.dart';
import 'package:estoque/estoque.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:precos/domain/data/local/i_precos_de_referencias_local_data_source.dart';
import 'package:precos/models.dart';
import 'package:produtos/domain/data/local/i_codigos_local_data_source.dart';
import 'package:produtos/domain/models/codigo.dart';
import 'package:siv_front/data/infra/local_data_sourcers/leitor/produto_busca_do_leitor_data_source.dart';

class _CodigoFake implements Codigo {
  @override
  final String codigo;
  @override
  final int produtoId;
  @override
  TipoCodigo get tipo => TipoCodigo.ean13;

  _CodigoFake({required this.codigo, required this.produtoId});
}

class _ProdutoEstoqueLocalDataSourceFake implements IProdutoEstoqueLocalDataSource {
  final List<ProdutoDoEstoque> produtos;

  _ProdutoEstoqueLocalDataSourceFake(this.produtos);

  @override
  Future<List<ProdutoDoEstoque>> buscarProdutosPorTexto(
    String texto, {
    String? tamanho,
    String? cor,
  }) async =>
      produtos;

  @override
  Future<void> salvarProduto(ProdutoDoEstoque produto) async {}
  @override
  Future<void> salvarProdutos(List<ProdutoDoEstoque> produtos) async {}
  @override
  Future<SaldoDoEstoque> obterSaldo({required FiltroProdutoDoEstoque filtro}) =>
      throw UnimplementedError();
  @override
  Future<ProdutoDoEstoque?> obterProduto(int id) => throw UnimplementedError();
  @override
  Future<List<ProdutoDoEstoque>> obterTodosProdutos() => throw UnimplementedError();
  @override
  Future<void> excluirProduto(int id) async {}
  @override
  Future<void> excluirTodosProdutos() async {}
  @override
  Future<void> excluirProdutosWhere({DateTime? produtosAtualizadosAntesDe}) async {}
}

class _CodigosLocalDataSourceFake implements ICodigosLocalDataSource {
  int chamadas = 0;

  @override
  Future<Iterable<Codigo>> recuperarCodigosPorProdutoId(int produtoId) async {
    chamadas++;
    return [_CodigoFake(codigo: 'EAN$produtoId', produtoId: produtoId)];
  }

  @override
  Future<Codigo?> recuperarCodigo(String codigo) => throw UnimplementedError();
  @override
  Future<void> salvarCodigosDeBarras(List<Codigo> codigos) async {}
}

class _PrecosDeReferenciasLocalDataSourceFake implements IPrecosDeReferenciasLocalDataSource {
  @override
  Future<PrecoDaReferencia?> obterPrecoDaReferencia({
    required int tabelaDePrecoId,
    required int referenciaId,
  }) async =>
      null;

  @override
  Future<List<PrecoDaReferencia>> obterPrecosDasReferencias({required int tabelaDePrecoId}) =>
      throw UnimplementedError();
  @override
  Future<void> salvarPrecoDaReferencia(PrecoDaReferencia preco) async {}
  @override
  Future<void> salvarPrecosDasReferencias(List<PrecoDaReferencia> precos) async {}
  @override
  Future<void> limparPrecosDasReferencias() async {}
}

void main() {
  test(
    'limita resultados a 60 mesmo quando a busca no estoque retorna milhares -- '
    'termo curto/comum não pode disparar milhares de queries concorrentes de '
    'código/preço (causa real do consumo de ~4GB de RAM na busca manual)',
    () async {
      final produtosEmMassa = List.generate(
        5000,
        (i) => ProdutoDoEstoque.create(
          empresaId: 1,
          referenciaId: i,
          referenciaIdExterno: null,
          produtoId: BigInt.from(i),
          produtoIdExterno: null,
          nome: 'PRODUTO $i',
          corId: 1,
          corNome: 'AZUL',
          tamanhoId: 1,
          tamanhoNome: 'UN',
          unidadeMedida: 'UN',
          saldo: 1,
        ),
      );

      final codigosDataSource = _CodigosLocalDataSourceFake();
      final dataSource = ProdutoBuscaDoLeitorDataSource(
        produtoEstoqueLocalDataSource: _ProdutoEstoqueLocalDataSourceFake(produtosEmMassa),
        codigosLocalDataSource: codigosDataSource,
        precosDeReferenciasLocalDataSource: _PrecosDeReferenciasLocalDataSourceFake(),
      );

      final resultados = await dataSource.buscarPorTexto('PRODUTO');

      expect(resultados.length, 60);
      expect(codigosDataSource.chamadas, 60);
    },
  );
}
