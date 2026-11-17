import 'package:comercial/domain/data/repositories/i_ecommerce_chaves_mcp_repository.dart';
import 'package:comercial/domain/models/ecommerce_chave_mcp.dart';

class RevogarChaveMcp {
  final IEcommerceChavesMcpRepository _repository;

  RevogarChaveMcp({required IEcommerceChavesMcpRepository repository})
      : _repository = repository;

  Future<EcommerceChaveMcp> call(int ecommerceId, int chaveId) =>
      _repository.revogarChave(ecommerceId, chaveId);
}
