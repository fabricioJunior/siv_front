import 'package:comercial/domain/models/ecommerce_chave_mcp.dart';

abstract class IEcommerceChavesMcpRepository {
  Future<List<EcommerceChaveMcp>> recuperarChaves(int ecommerceId);

  Future<CriarChaveMcpResultado> criarChave(
    int ecommerceId, {
    required String nome,
    required List<String> escopos,
    DateTime? expiraEm,
  });

  Future<EcommerceChaveMcp> revogarChave(int ecommerceId, int chaveId);
}
