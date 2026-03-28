import 'package:core/remote_data_sourcers.dart';
import 'package:estoque/data/remote/dtos/saldo_do_estoque_dto.dart';
import 'package:estoque/domain/data/remote/i_estoque_saldo_remote_data_source.dart';
import 'package:estoque/domain/models/filtro_produto_do_estoque.dart';
import 'package:estoque/domain/models/saldo_do_estoque.dart';

class EstoqueSaldoRemoteDataSource extends RemoteDataSourceBase
    implements IEstoqueSaldoRemoteDataSource {
  EstoqueSaldoRemoteDataSource({required super.informacoesParaRequest});

  @override
  Future<SaldoDoEstoque> obterSaldo({
    required FiltroProdutoDoEstoque filtro,
  }) async {
    final response = await get(queryParameters: _toQueryParameters(filtro));
    return SaldoDoEstoqueDto.fromJson(response.body);
  }

  Map<String, String> _toQueryParameters(FiltroProdutoDoEstoque filtro) {
    return {
      if (filtro.empresaIds.isNotEmpty)
        'empresaIds': filtro.empresaIds.join(','),
      if (filtro.referenciaIds.isNotEmpty)
        'referenciaIds': filtro.referenciaIds.join(','),
      if (filtro.referenciaIdExternos.isNotEmpty)
        'referenciaIdExternos': filtro.referenciaIdExternos.join(','),
      if (filtro.produtoIds.isNotEmpty)
        'produtoIds': filtro.produtoIds.join(','),
      if (filtro.produtoIdExternos.isNotEmpty)
        'produtoIdExternos': filtro.produtoIdExternos.join(','),
      if (filtro.corIds.isNotEmpty) 'corIds': filtro.corIds.join(','),
      if (filtro.tamanhoIds.isNotEmpty)
        'tamanhoIds': filtro.tamanhoIds.join(','),
      'page': filtro.page.toString(),
      'limit': filtro.limit.toString(),
    };
  }

  @override
  String get path => '/v1/estoque/saldo';
}
