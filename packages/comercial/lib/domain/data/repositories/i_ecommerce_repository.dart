import 'package:comercial/models.dart';

abstract class IEcommerceRepository {
  Future<List<Ecommerce>> recuperarEcommerces();
  Future<Ecommerce> recuperarEcommerce(int id);
  Future<Ecommerce> criarEcommerce(Ecommerce ecommerce);
  Future<Ecommerce> atualizarEcommerce(Ecommerce ecommerce);

  Future<List<EcommerceReferencia>> recuperarReferencias(int ecommerceId);
  Future<EcommerceReferencia> adicionarReferencia(
    int ecommerceId, {
    required int referenciaId,
    int? tabelaDePrecoId,
  });
  Future<EcommerceReferencia> atualizarReferencia(
    int ecommerceId,
    int id, {
    bool? rascunho,
    int? tabelaDePrecoId,
  });

  Future<List<EcommerceReferenciaProduto>> recuperarProdutosDaReferencia(
    int ecommerceId,
    int referenciaId,
  );
  Future<void> atualizarDisponibilidadeProduto(
    int ecommerceId,
    int referenciaId,
    int produtoId, {
    required bool disponivel,
  });
}
