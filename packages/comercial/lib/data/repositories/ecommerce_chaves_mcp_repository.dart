import 'package:comercial/domain/data/remote/i_ecommerce_chaves_mcp_remote_data_source.dart';
import 'package:comercial/domain/data/repositories/i_ecommerce_chaves_mcp_repository.dart';
import 'package:comercial/domain/models/ecommerce_chave_mcp.dart';

class EcommerceChavesMcpRepository implements IEcommerceChavesMcpRepository {
  final IEcommerceChavesMcpRemoteDataSource remoteDataSource;

  EcommerceChavesMcpRepository({required this.remoteDataSource});

  @override
  Future<List<EcommerceChaveMcp>> recuperarChaves(int ecommerceId) =>
      remoteDataSource.recuperarChaves(ecommerceId);

  @override
  Future<CriarChaveMcpResultado> criarChave(
    int ecommerceId, {
    required String nome,
    required List<String> escopos,
    DateTime? expiraEm,
  }) =>
      remoteDataSource.criarChave(ecommerceId, nome: nome, escopos: escopos, expiraEm: expiraEm);

  @override
  Future<EcommerceChaveMcp> revogarChave(int ecommerceId, int chaveId) =>
      remoteDataSource.revogarChave(ecommerceId, chaveId);
}
