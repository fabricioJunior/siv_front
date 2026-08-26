import 'package:comercial/models.dart';

abstract class IEcommerceRemoteDataSource {
  Future<List<Ecommerce>> recuperarEcommerces({bool incluirApagados = false});
  Future<Ecommerce> recuperarEcommerce(int id);
  Future<Ecommerce> criarEcommerce(Ecommerce ecommerce);
  Future<Ecommerce> atualizarEcommerce(Ecommerce ecommerce);
  Future<void> excluirEcommerce(int id);
  Future<void> restaurarEcommerce(int id);

  Future<List<EcommerceReferencia>> recuperarReferencias(
    int ecommerceId, {
    String? busca,
  });
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
