import 'package:comercial/domain/data/repositories/i_ecommerce_chaves_mcp_repository.dart';
import 'package:comercial/domain/models/ecommerce_chave_mcp.dart';

class CriarChaveMcp {
  final IEcommerceChavesMcpRepository _repository;

  CriarChaveMcp({required IEcommerceChavesMcpRepository repository})
      : _repository = repository;

  Future<CriarChaveMcpResultado> call(
    int ecommerceId, {
    required String nome,
    required List<String> escopos,
    DateTime? expiraEm,
  }) =>
      _repository.criarChave(ecommerceId, nome: nome, escopos: escopos, expiraEm: expiraEm);
}
