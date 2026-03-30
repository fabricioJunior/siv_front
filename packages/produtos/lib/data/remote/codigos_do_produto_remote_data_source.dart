import 'package:core/remote_data_sourcers.dart';
import 'package:produtos/data/remote/dtos/codigo_de_barras_dto.dart';
import 'package:produtos/domain/data/remote/i_codigos_do_produto_remote_data_source.dart';

class CodigosDoProdutoRemoteDatasource extends RemoteDataSourceBase
    implements ICodigosDoProdutoRemoteDatasource {
  CodigosDoProdutoRemoteDatasource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/produtos/{id}/codigo-barras/{barcode}';

  @override
  Future<void> salvarCodigo({
    required int produtoId,
    required String codigoDeBarras,
  }) async {
    var pathParameters = {'id': produtoId.toString()};
    var codigo = CodigoDeBarrasDto(
      tipo: TipoCodigoDeBarras.ean13,
      codigo: codigoDeBarras,
    );
    var response = await post(
      pathParameters: pathParameters,
      body: codigo.toJson(),
    );

    if (response.statusCode != 201) {
      throw Exception('Erro ao salvar código de barras: ${response.body}');
    }
  }

  @override
  Future<void> deletarCodigo({
    required int produtoId,
    required String codigoDeBarras,
  }) {
    var pathParameters = {
      'id': produtoId.toString(),
      'barcode': codigoDeBarras,
    };
    return delete(pathParameters: pathParameters);
  }
}
