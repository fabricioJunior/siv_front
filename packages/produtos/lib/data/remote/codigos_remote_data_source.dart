import 'package:core/remote_data_sourcers.dart';
import 'package:produtos/data/remote/dtos/codigo_dto.dart';
import 'package:produtos/domain/data/remote/i_codigos_remote_data_source.dart';
import 'package:produtos/domain/models/codigo.dart';
import 'package:core/paginacao.dart';

class CodigosRemoteDataSource extends RemoteDataSourceBase
    implements ICodigosRemoteDataSource {
  CodigosRemoteDataSource({required super.informacoesParaRequest});

  @override
  Future<Paginacao<Codigo>> buscarCodigos({
    required int pagina,
    required int limite,
  }) async {
    var qeryParameters = {
      'page': pagina.toString(),
      'limite': limite.toString(),
    };
    var response = await get(queryParameters: qeryParameters);
    return PaginacaoDto<Codigo>.fromJson(
      response.body,
      (json) => CodigoDto.fromJson(json),
      'codigos_sync',
    );
  }

  @override
  String get path => '/v1/produtos/codigo-barras/lista';

  @override
  Future<int?> recuperarProdutoIdPorCodigoDeBarras(String codigoDeBarras) {
    var pathParameters = {'codigo': codigoDeBarras};
    return get(pathParameters: pathParameters).then((response) {
      if (response.statusCode == 200) {
        var json = response.body;
        return json['produtoId'] as int?;
      } else if (response.statusCode == 404) {
        return null; // Código de barras não encontrado
      } else {
        throw Exception(
          'Erro ao recuperar produto por código de barras: ${response.body}',
        );
      }
    });
  }
}
