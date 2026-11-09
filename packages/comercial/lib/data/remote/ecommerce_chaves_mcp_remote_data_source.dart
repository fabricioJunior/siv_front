import 'package:comercial/data/remote/dtos/ecommerce_chave_mcp_dto.dart';
import 'package:comercial/domain/data/remote/i_ecommerce_chaves_mcp_remote_data_source.dart';
import 'package:comercial/domain/models/ecommerce_chave_mcp.dart';
import 'package:core/remote_data_sourcers.dart';

class EcommerceChavesMcpRemoteDataSource extends RemoteDataSourceBase
    implements IEcommerceChavesMcpRemoteDataSource {
  EcommerceChavesMcpRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/e-commerce/{id}';

  @override
  Future<List<EcommerceChaveMcp>> recuperarChaves(int ecommerceId) async {
    final response = await get(pathParameters: {'id': '$ecommerceId/chaves-mcp'});
    return (response.body as List<dynamic>)
        .map((json) => EcommerceChaveMcpDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CriarChaveMcpResultado> criarChave(
    int ecommerceId, {
    required String nome,
    required List<String> escopos,
    DateTime? expiraEm,
  }) async {
    final response = await post(
      pathParameters: {'id': '$ecommerceId/chaves-mcp'},
      body: {
        'nome': nome,
        'escopos': escopos,
        if (expiraEm != null) 'expiraEm': expiraEm.toUtc().toIso8601String(),
      },
    );
    return EcommerceChaveMcpDto.resultadoDeJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<EcommerceChaveMcp> revogarChave(int ecommerceId, int chaveId) async {
    final response = await delete(pathParameters: {'id': '$ecommerceId/chaves-mcp/$chaveId'});
    return EcommerceChaveMcpDto.fromJson(response.body as Map<String, dynamic>);
  }
}
