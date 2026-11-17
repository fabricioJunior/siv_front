import 'package:comercial/domain/data/repositories/i_ecommerce_chaves_mcp_repository.dart';
import 'package:comercial/domain/models/ecommerce_chave_mcp.dart';

class RecuperarChavesMcp {
  final IEcommerceChavesMcpRepository _repository;

  RecuperarChavesMcp({required IEcommerceChavesMcpRepository repository})
      : _repository = repository;

  Future<List<EcommerceChaveMcp>> call(int ecommerceId) =>
      _repository.recuperarChaves(ecommerceId);
}
