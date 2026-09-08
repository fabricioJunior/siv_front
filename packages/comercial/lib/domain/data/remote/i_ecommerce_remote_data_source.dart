import 'package:comercial/models.dart';

abstract class IEcommerceRemoteDataSource {
  Future<List<Ecommerce>> recuperarEcommerces({bool incluirApagados = false});
  Future<Ecommerce> recuperarEcommerce(int id);
  Future<Ecommerce> criarEcommerce(Ecommerce ecommerce);
  Future<Ecommerce> atualizarEcommerce(Ecommerce ecommerce);
  Future<void> excluirEcommerce(int id);
  Future<void> restaurarEcommerce(int id);

  Future<EcommerceReferenciasPagina> recuperarReferencias(
    int ecommerceId, {
    String? busca,
    List<int>? categoriaIds,
    bool? rascunho,
    bool? publicavel,
    int page = 1,
    int limit = 50,
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

  /// `PATCH /v1/e-commerce/{id}/referencias/lote` -- lança [HttpException]
  /// com `statusCode` 404/405 se o endpoint ainda não existir; quem decide o
  /// fallback é o repositório.
  Future<EcommerceLoteResultado> publicarReferenciasEmLote(
    int ecommerceId, {
    required List<int> ids,
    required bool rascunho,
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

  /// `PUT /v1/e-commerce/{id}/referencias/{refId}/produtos/lote` -- mesmo
  /// esquema de fallback do lote de referências.
  Future<void> atualizarDisponibilidadeProdutosEmLote(
    int ecommerceId,
    int referenciaId, {
    required List<int> produtoIds,
    required bool disponivel,
  });
}
